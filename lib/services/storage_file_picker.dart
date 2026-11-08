import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:janus/services/storage_service.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StorageFileException implements Exception {
  const StorageFileException(this.message);
  final String message;
}

/// A readable source, not a filesystem path: content URIs must stay with
/// the platform adapter. Streams are consumed once, then released.
class SnapshotSource {
  SnapshotSource({
    required this.size,
    required this.open,
    required this.release,
  });
  final int? size;
  final Stream<List<int>> Function() open;
  final Future<void> Function() release;
}

abstract interface class StorageFilePicker {
  Future<SnapshotSource?> pickJson();

  /// Returns the platform's destination identifier, without reopening it as File.
  Future<String?> saveJson(String name, Uint8List bytes);
}

class NativeStorageFilePicker implements StorageFilePicker {
  NativeStorageFilePicker({
    FilePicker? platform,
    MethodChannel? importChannel,
    bool? useBoundedImport,
  }) : platform = platform ?? FilePicker.platform,
       importChannel =
           importChannel ?? const MethodChannel('janus/storage_import'),
       useBoundedImport =
           useBoundedImport ?? (Platform.isAndroid || Platform.isIOS);
  final FilePicker platform;
  final MethodChannel importChannel;
  final bool useBoundedImport;

  Future<void> _cleanup(String? cachedPath) async {
    if (cachedPath == null || (!Platform.isAndroid && !Platform.isIOS)) return;
    try {
      final roots = [
        Directory.systemTemp.path,
        (await getTemporaryDirectory()).path,
      ];
      if (roots.any((root) => p.isWithin(root, cachedPath))) {
        final file = File(cachedPath);
        if (await file.exists()) await file.delete();
      }
    } catch (_) {
      // Best effort; do not clear the whole app temporary directory.
    }
  }

  Future<T> _native<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on PlatformException catch (error) {
      if (error.code == 'too_large') {
        throw const StorageFileException('快照超过 20 MiB，已停止读取并清理临时副本');
      }
      final code = '${error.code} ${error.message}'.toLowerCase();
      if (code.contains('permission') ||
          code.contains('denied') ||
          code.contains('access')) {
        throw const StorageFileException('文件访问被拒绝，请重新选择并允许访问');
      }
      throw StorageFileException('系统文件操作失败（${error.code}），请重试或选择其他位置');
    } on FileSystemException {
      throw const StorageFileException('无法读写所选文件，请检查访问权限与可用空间');
    }
  }

  @override
  Future<SnapshotSource?> pickJson() => _native(() async {
    String? cachedPath;
    try {
      if (useBoundedImport) {
        final selected = await importChannel.invokeMapMethod<String, dynamic>(
          'pickJson',
        );
        if (selected == null) return null;
        final path = selected['path'];
        final size = selected['size'];
        if (path is! String ||
            !p.isAbsolute(path) ||
            path.contains('://') ||
            size is! int) {
          throw const StorageFileException('系统未返回可读的临时副本');
        }
        cachedPath = path;
        if (size > StorageService.maxSnapshotBytes) {
          throw const StorageFileException('快照超过 20 MiB');
        }
        return SnapshotSource(
          size: size,
          open: File(path).openRead,
          release: () => _cleanup(path),
        );
      }
      final result = await platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        withData: false,
        withReadStream: true,
      );
      if (result == null) {
        await _cleanup(cachedPath);
        return null;
      }
      if (result.files.length != 1) {
        throw const StorageFileException('无法读取所选文件，请检查访问权限或选择其他文件');
      }
      final file = result.files.single;
      cachedPath = file.path;
      final localPath = file.path;
      final stream =
          file.readStream ??
          (localPath != null &&
                  p.isAbsolute(localPath) &&
                  !localPath.contains('://')
              ? File(localPath).openRead()
              : null);
      if (stream == null) {
        throw const StorageFileException('所选文件无法读取，请重新选择');
      }
      // Android: plugin copies content:// with ContentResolver.openInputStream.
      // iOS: UIDocumentPickerModeImport provides an app-owned temporary copy.
      // Never interpret a provider URI as a File path here.
      return SnapshotSource(
        size: file.size,
        open: () => stream,
        release: () => _cleanup(cachedPath),
      );
    } catch (_) {
      await _cleanup(cachedPath);
      rethrow;
    }
  });

  @override
  Future<String?> saveJson(String name, Uint8List bytes) => _native(() async {
    try {
      return await platform.saveFile(
        fileName: name,
        type: FileType.custom,
        allowedExtensions: ['json'],
        bytes: bytes,
      );
    } finally {
      if (Platform.isIOS) {
        // v10 stages iOS exports in Documents/<name>. Keep our snapshots in
        // janus_snapshots, and remove only this operation's staging file.
        try {
          final file = File(
            p.join((await getApplicationDocumentsDirectory()).path, name),
          );
          if (await file.exists()) await file.delete();
        } catch (_) {
          /* A cleanup failure must not hide the save result. */
        }
      }
    }
  });
}

/// Platform-neutral selection/read/validation pipeline. It never mutates data;
/// the UI must obtain confirmation before calling StorageRepository.restore.
class StorageTransfer {
  StorageTransfer(this.storage, this.picker);
  final StorageService storage;
  final StorageFilePicker picker;

  Future<StorageSnapshot?> selectSnapshot() async {
    final source = await picker.pickJson();
    if (source == null) return null;
    try {
      return await storage.readSnapshotStream(source.open, size: source.size);
    } on FileSystemException {
      throw const StorageFileException('所选文件不可读或访问权限已失效，请重新选择');
    } on PlatformException {
      throw const StorageFileException('读取所选文件失败，请检查文件访问权限');
    } finally {
      await source.release();
    }
  }

  /// Keeps a local recovery snapshot even when the destination is cancelled.
  Future<String?> exportToPicker() async {
    final snapshot = await storage.exportForTransfer();
    return picker.saveJson(snapshot.name, snapshot.bytes);
  }
}
