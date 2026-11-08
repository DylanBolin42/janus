import 'dart:async';
import 'dart:convert';
import 'dart:io';

class SyncConfig {
  const SyncConfig(this.url, this.username, this.password, this.filename);
  final String url;
  final String username;
  final String password;
  final String filename;

  Uri get directory {
    final uri = Uri.tryParse(url.trim());
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      throw const SyncFailure('请输入不含凭据、查询参数的 HTTPS WebDAV 目录地址');
    }
    if (username.isEmpty ||
        password.isEmpty ||
        !RegExp(r'^[a-zA-Z0-9_-]+\.json$').hasMatch(filename)) {
      throw const SyncFailure('请填写用户名、密码及快照文件名（例如 janus.json）');
    }
    return uri.replace(
      path: uri.path.endsWith('/') ? uri.path : '${uri.path}/',
    );
  }

  Map<String, dynamic> toJson() => {
    'url': url,
    'username': username,
    'password': password,
    'filename': filename,
  };
  factory SyncConfig.fromJson(Map<String, dynamic> json) => SyncConfig(
    json['url'] as String,
    json['username'] as String,
    json['password'] as String,
    json['filename'] as String,
  );
}

class SyncFailure implements Exception {
  const SyncFailure(this.message);
  final String message;
  @override
  String toString() => message;
}

abstract interface class SyncBackend {
  Future<void> verify();
  Future<void> upload(String snapshot);
  Future<String> download();
}

/// HTTPS only; redirects are rejected so Basic credentials never cross origins.
class WebDavBackend implements SyncBackend {
  WebDavBackend(this.config, {HttpClient Function()? clientFactory})
    : _clientFactory = clientFactory ?? HttpClient.new;
  final SyncConfig config;
  final HttpClient Function() _clientFactory;
  static const maxBytes = 10 * 1024 * 1024;

  Future<String> _request(String method, Uri uri, {String? body}) async {
    final client = _clientFactory()
      ..connectionTimeout = const Duration(seconds: 15);
    try {
      return await (() async {
        final request = await client.openUrl(method, uri);
        request.followRedirects = false;
        request.headers.set(
          HttpHeaders.authorizationHeader,
          'Basic ${base64Encode(utf8.encode('${config.username}:${config.password}'))}',
        );
        if (method == 'PROPFIND') {
          request.headers.set('Depth', '0');
        }
        if (body != null) {
          final bytes = utf8.encode(body);
          if (bytes.length > maxBytes) throw const SyncFailure('快照超过 10MB 限制');
          request.headers.contentType = ContentType.json;
          request.add(bytes);
        }
        final response = await request.close();
        final ok = method == 'PROPFIND'
            ? response.statusCode == 207 || response.statusCode == 200
            : method == 'PUT'
            ? [200, 201, 204].contains(response.statusCode)
            : response.statusCode == 200;
        if (!ok) {
          final code = response.statusCode;
          throw SyncFailure(switch (code) {
            401 || 403 => '认证失败或没有访问权限（HTTP $code）',
            404 => '目录或远端快照不存在（HTTP 404）',
            >= 300 && < 400 => '服务器重定向已拒绝，请填写最终 HTTPS 地址',
            _ => 'WebDAV 请求失败（HTTP $code）',
          });
        }
        final bytes = <int>[];
        await for (final chunk in response) {
          if (bytes.length + chunk.length > maxBytes) {
            throw const SyncFailure('远端响应超过 10MB 限制');
          }
          bytes.addAll(chunk);
        }
        return utf8.decode(bytes);
      })().timeout(const Duration(seconds: 30));
    } on SyncFailure {
      rethrow;
    } on TimeoutException {
      throw const SyncFailure('连接超时，请检查网络后重试');
    } on HandshakeException {
      throw const SyncFailure('TLS 证书验证失败，请检查服务器证书');
    } on SocketException {
      throw const SyncFailure('无法连接服务器，请检查网络和地址');
    } catch (_) {
      throw const SyncFailure('网络请求失败，请检查配置后重试');
    } finally {
      client.close(force: true);
    }
  }

  @override
  Future<void> verify() async {
    await _request('PROPFIND', config.directory);
  }

  @override
  Future<void> upload(String snapshot) async {
    await _request(
      'PUT',
      config.directory.resolve(config.filename),
      body: snapshot,
    );
  }

  @override
  Future<String> download() =>
      _request('GET', config.directory.resolve(config.filename));
}
