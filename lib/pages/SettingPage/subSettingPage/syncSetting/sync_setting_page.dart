import 'package:card_settings_ui/card_settings_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/models/app_settings.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/shared/custom_app_settings_tile.dart';
import 'package:janus/shared/custom_appbar.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';
import 'package:janus/shared/flex_setting_section.dart';
import 'package:janus/providers/sync_provider.dart';
import 'package:janus/services/sync/sync_backend.dart';
import 'package:janus/services/sync/sync_service.dart';

class SyncSettingPage extends ConsumerStatefulWidget {
  const SyncSettingPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SyncSettingPageState();
}

class _SyncSettingPageState extends ConsumerState<SyncSettingPage> {
  final _webdavUrlController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _syncToController = TextEditingController();
  bool _loading = true;
  bool _saving = false;
  bool _hasConfig = false;
  String? _configError;
  late final SyncService _sync;

  @override
  void initState() {
    super.initState();
    _sync = ref.read(syncServiceProvider)..addListener(_changed);
    _load();
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    try {
      final config = await ref.read(syncCredentialsProvider).load();
      if (!mounted) return;
      if (config != null) {
        config.directory;
        _hasConfig = true;
        _webdavUrlController.text = config.url;
        _usernameController.text = config.username;
        _passwordController.text = config.password;
        _syncToController.text = config.filename;
      } else {
        _syncToController.text = 'janus.json';
      }
    } catch (_) {
      if (mounted) _configError = '无法读取安全配置；安全存储目前仅支持 Android / iOS';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    await _sync.refresh();
  }

  SyncConfig get _config => SyncConfig(
    _webdavUrlController.text.trim(),
    _usernameController.text,
    _passwordController.text,
    _syncToController.text.trim(),
  );

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _configError = null;
    });
    try {
      await ref.read(syncCredentialsProvider).save(_config);
      if (mounted) {
        setState(() {
          _hasConfig = true;
          _configError = '配置已安全保存，尚未验证连接';
        });
      }
    } on SyncFailure catch (error) {
      if (mounted) setState(() => _configError = error.message);
    } catch (_) {
      if (mounted) setState(() => _configError = '安全保存失败；请在 Android / iOS 上重试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggle(bool enabled) async {
    if (_loading || _saving || _sync.busy) return;
    setState(() {
      _saving = true;
      _configError = null;
    });
    try {
      if (enabled) {
        await _sync.run(SyncAction.check, _config);
        if (!mounted || _sync.phase != SyncPhase.success) return;
        await ref.read(syncCredentialsProvider).save(_config);
        if (!mounted) return;
        setState(() => _hasConfig = true);
      }
      if (!mounted) return;
      await ref.read(appSettingsProvider.notifier).setSyncEnabled(enabled);
    } catch (_) {
      if (mounted) setState(() => _configError = '配置或启用状态保存失败，请重试');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _run(SyncAction action) async {
    if (_loading || _saving || _sync.busy) return;
    if (action != SyncAction.check) {
      late AppSettings settings;
      try {
        settings = await ref.read(appSettingsProvider.future);
      } catch (_) {
        if (mounted) setState(() => _configError = '无法读取同步设置，请重新进入页面后重试');
        return;
      }
      if (!mounted) return;
      if (!settings.syncEnabled || !_hasConfig) {
        setState(() => _configError = '请先开启手动同步');
        return;
      }
      final accepted = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(action == SyncAction.download ? '替换本地数据？' : '替换远端快照？'),
          content: Text(
            action == SyncAction.download
                ? '仅限单写入者：确认其他设备已停止编辑和上传，再下载。此操作完整替换本地任务、标签与通用设置，无法合并。请先备份本地数据。'
                : '仅限单写入者：先停止其他设备编辑，下载最新快照后再修改、上传。本次上传无条件覆盖远端同名快照，不检查其他设备更新，可能丢失数据。快照为包含任务内容的明文 JSON。',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('确认替换'),
            ),
          ],
        ),
      );
      if (accepted != true || !mounted) return;
    }
    await _sync.run(action, _config);
    if (mounted &&
        action == SyncAction.download &&
        _sync.phase == SyncPhase.success) {
      ref.invalidate(appSettingsProvider);
    }
  }

  @override
  void dispose() {
    _webdavUrlController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    _syncToController.dispose();
    _sync.removeListener(_changed);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(appSettingsProvider).value ?? const AppSettings();
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      body: GlassScaffold(
        topEdgeFade: false,
        appBar: const CustomAppbar(title: '同步', showBack: true),
        body: CustomAppbar.wrapBody(
          context,
          RefreshIndicator(
            onRefresh: _sync.refresh,
            child: SettingsList(
              physics: const AlwaysScrollableScrollPhysics(),
              sections: [
                SettingsSection(
                  tiles: [
                    CustomAppSettingsTile(
                      child: Row(
                        children: [
                          Icon(Icons.update_rounded),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(_sync.message),
                                Text(
                                  _sync.lastSync == null
                                      ? '上次同步：无记录'
                                      : '上次同步：${_sync.lastSync!.toLocal()}',
                                ),
                                if (_sync.busy) const LinearProgressIndicator(),
                                if (_configError != null) Text(_configError!),
                                if (_sync.phase == SyncPhase.failed &&
                                    _sync.lastAction != null)
                                  TextButton(
                                    onPressed: () => _run(_sync.lastAction!),
                                    child: const Text('重试'),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    InteractiveTile(
                      title: Text('是否同步'),
                      description: const Text('启用手动同步；不会自动调度或合并'),
                      leading: Icon(Icons.upload_rounded),
                      trailing: GlassSwitch(
                        value: !_loading && _hasConfig && settings.syncEnabled,
                        onChanged: _toggle,
                      ),
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text('同步设置', style: tt.titleMedium),
                  tiles: [
                    InteractiveTile(
                      title: Text('WEBDAV地址'),
                      trailing: SizedBox(
                        width: 200,
                        child: GlassTextField(
                          controller: _webdavUrlController,
                          enabled: !_loading && !_saving && !_sync.busy,
                          shape: LiquidRoundedSuperellipse(borderRadius: 64),
                        ),
                      ),
                    ),
                    InteractiveTile(
                      title: Text('用户名'),
                      trailing: SizedBox(
                        width: 200,
                        child: GlassTextField(
                          controller: _usernameController,
                          enabled: !_loading && !_saving && !_sync.busy,
                          shape: LiquidRoundedSuperellipse(borderRadius: 64),
                        ),
                      ),
                    ),
                    InteractiveTile(
                      title: Text('密码'),
                      trailing: SizedBox(
                        width: 200,
                        child: GlassTextField(
                          controller: _passwordController,
                          enabled: !_loading && !_saving && !_sync.busy,
                          obscureText: true,
                          shape: LiquidRoundedSuperellipse(borderRadius: 64),
                        ),
                      ),
                    ),
                    InteractiveTile(
                      title: Text('同步至'),
                      trailing: SizedBox(
                        width: 200,
                        child: GlassTextField(
                          controller: _syncToController,
                          enabled: !_loading && !_saving && !_sync.busy,
                          shape: LiquidRoundedSuperellipse(borderRadius: 64),
                        ),
                      ),
                    ),
                    InteractiveTile(
                      title: const Text('同步模式'),
                      description: const Text(
                        '仅限单写入者、全量覆盖，无版本冲突保护。先停止其他设备编辑，下载最新快照，再修改并上传；其他设备只能随后下载。切换写入设备前先上传并停止旧设备编辑，再由新设备下载。同步至填写 .json 文件名，目录必须已存在。',
                      ),
                    ),
                    InteractiveTile(
                      title: const Text('保存配置'),
                      description: const Text(
                        'Android Keystore / iOS Keychain；不会保存到普通偏好设置',
                      ),
                      enabled: !_loading && !_saving && !_sync.busy,
                      onPressed: (_) => _save(),
                    ),
                  ],
                ),
                FlexSettingSection(
                  title: Text('手动操作', style: tt.titleMedium),
                  tiles: [
                    FlexRow(
                      children: [
                        FlexTile(
                          enabled: !_loading && !_saving && !_sync.busy,
                          onTap: (_) => _run(SyncAction.upload),
                          child: Center(
                            child: Text(
                              '手动上传',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        FlexTile(
                          enabled: !_loading && !_saving && !_sync.busy,
                          onTap: (_) => _run(SyncAction.download),
                          child: Center(
                            child: Text(
                              '手动下载',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                    FlexTile(
                      enabled: !_loading && !_saving && !_sync.busy,
                      onTap: (_) => _run(SyncAction.check),
                      child: Center(
                        child: Text(
                          '连通性检查',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text('同步行为', style: tt.titleMedium),
                  tiles: [
                    InteractiveTile(
                      title: const Text('仅手动触发'),
                      description: const Text('定时、间隔及修改后自动同步尚未实现。下拉刷新上次同步时间。'),
                    ),
                  ],
                ),
                SettingsSection(
                  title: Text('安全', style: tt.titleMedium),
                  tiles: [
                    InteractiveTile(
                      leading: const Icon(Icons.security_rounded),
                      title: const Text('安全性说明'),
                      description: const Text(
                        '快照明文包含任务标题、备注、标签及设置。传输安全依赖服务端 TLS 的完整性与有效证书；服务器及其备份的访问者可以读取快照。仅使用可信 HTTPS 服务器。客户端加密尚未实现（TODO：认证加密、密钥管理与恢复流程）；RSA 与应用锁也未实现。桌面/Web 安全存储暂不支持。',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
