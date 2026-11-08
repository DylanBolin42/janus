import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/database/app_database.dart';
import 'package:janus/services/storage_file_picker.dart';
import 'package:janus/services/storage_service.dart';

class FakePicker implements StorageFilePicker {
  SnapshotSource? source;
  String? destination;
  Uint8List? saved;
  @override
  Future<SnapshotSource?> pickJson() async => source;
  @override
  Future<String?> saveJson(String name, Uint8List bytes) async {
    saved = bytes;
    return destination;
  }
}

class PluginPicker extends FilePicker {
  PlatformException? error;
  FilePickerResult? result;
  Uint8List? saved;
  bool streamed = false;
  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    bool allowCompression = true,
    int compressionQuality = 30,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
  }) async {
    if (error != null) throw error!;
    streamed = withReadStream && !withData && !allowMultiple;
    return result;
  }

  @override
  Future<String?> saveFile({
    String? dialogTitle,
    String? fileName,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Uint8List? bytes,
    bool lockParentWindow = false,
  }) async {
    if (error != null) throw error!;
    saved = bytes;
    return 'content://documents/saved.json';
  }
}

void main() {
  late AppDatabase db;
  late StorageService storage;
  late Directory dir;
  late FakePicker picker;
  late StorageTransfer transfer;
  var released = false;
  SnapshotSource source(Stream<List<int>> Function() open, {int? size}) =>
      SnapshotSource(
        size: size,
        open: open,
        release: () async {
          released = true;
        },
      );

  setUp(() async {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.taskDao.seedSampleData();
    dir = await Directory.systemTemp.createTemp('janus_picker');
    storage = StorageService(db, documents: () async => dir);
    picker = FakePicker();
    transfer = StorageTransfer(storage, picker);
    released = false;
  });
  tearDown(() async {
    await db.close();
    await dir.delete(recursive: true);
  });

  test(
    'cancel import and export preserve database; local export stays available',
    () async {
      expect(await transfer.selectSnapshot(), isNull);
      expect(await transfer.exportToPicker(), isNull);
      expect((await storage.snapshots()).length, 1);
      expect((await storage.statistics()).tasks, 6);
    },
  );

  test(
    'selected source validates without applying until explicit restore',
    () async {
      final bytes = await (await storage.exportSnapshot()).readAsBytes();
      picker.source = source(() => Stream.value(bytes));
      await storage.clear();
      final snapshot = await transfer.selectSnapshot();
      expect(released, isTrue);
      expect((await storage.statistics()).tasks, 0);
      await storage.restore(snapshot!);
      expect((await storage.statistics()).tasks, 6);
    },
  );

  test('known oversize is rejected before stream opens', () async {
    var opened = false;
    picker.source = source(() {
      opened = true;
      return const Stream.empty();
    }, size: StorageService.maxSnapshotBytes + 1);
    await expectLater(transfer.selectSnapshot(), throwsFormatException);
    expect(opened, isFalse);
    expect(released, isTrue);
    expect((await storage.statistics()).tasks, 6);
  });

  test('unknown or false small size cannot bypass streaming limit', () async {
    var cancelled = false;
    Stream<List<int>> chunks() async* {
      try {
        yield Uint8List(StorageService.maxSnapshotBytes);
        yield [32];
        fail('stream must be cancelled at limit');
      } finally {
        cancelled = true;
      }
    }

    picker.source = source(chunks, size: 1);
    await expectLater(transfer.selectSnapshot(), throwsFormatException);
    expect(cancelled, isTrue);
    expect(released, isTrue);
    expect((await storage.statistics()).tasks, 6);
  });

  test('read permission loss releases source and preserves database', () async {
    picker.source = source(
      () => Stream.error(const FileSystemException('denied')),
    );
    await expectLater(
      transfer.selectSnapshot(),
      throwsA(isA<StorageFileException>()),
    );
    expect(released, isTrue);
    expect((await storage.statistics()).tasks, 6);
  });

  test(
    'corrupt, invalid UTF-8 and wrong-version external sources are rejected',
    () async {
      final valid =
          jsonDecode(await (await storage.exportSnapshot()).readAsString())
              as Map<String, dynamic>;
      for (final bytes in [
        utf8.encode('{'),
        [0xff],
        utf8.encode(jsonEncode({...valid, 'formatVersion': 999})),
      ]) {
        released = false;
        picker.source = source(() => Stream.value(bytes));
        await expectLater(transfer.selectSnapshot(), throwsFormatException);
        expect(released, isTrue);
        expect((await storage.statistics()).tasks, 6);
      }
    },
  );

  test(
    'native adapter consumes provided stream, never opens content URI as File',
    () async {
      final plugin = PluginPicker()
        ..result = FilePickerResult([
          PlatformFile(
            name: 'source.json',
            size: 2,
            path: 'content://provider/document/1',
            readStream: Stream.value(utf8.encode('{}')),
          ),
        ]);
      final native = NativeStorageFilePicker(platform: plugin);
      final picked = (await native.pickJson())!;
      expect(plugin.streamed, isTrue);
      expect(
        await picked.open().expand((chunk) => chunk).toList(),
        utf8.encode('{}'),
      );
      final bytes = Uint8List.fromList([1, 2, 3]);
      expect(
        await native.saveJson('source.json', bytes),
        'content://documents/saved.json',
      );
      expect(plugin.saved, bytes);
      plugin.result = FilePickerResult([
        PlatformFile(
          name: 'unreadable.json',
          size: 0,
          path: 'content://provider/unreadable',
        ),
      ]);
      await expectLater(
        native.pickJson(),
        throwsA(isA<StorageFileException>()),
      );
      plugin.result = FilePickerResult([]);
      await expectLater(
        native.pickJson(),
        throwsA(isA<StorageFileException>()),
      );
    },
  );

  test(
    'native adapter distinguishes cancellation, permission and provider errors',
    () async {
      final plugin = PluginPicker();
      final native = NativeStorageFilePicker(platform: plugin);
      expect(await native.pickJson(), isNull);
      plugin.error = PlatformException(code: 'permission_denied');
      await expectLater(
        native.pickJson(),
        throwsA(
          isA<StorageFileException>().having(
            (e) => e.message,
            'message',
            contains('拒绝'),
          ),
        ),
      );
      await expectLater(
        native.saveJson('x.json', Uint8List(0)),
        throwsA(isA<StorageFileException>()),
      );
      plugin.error = PlatformException(code: 'provider_unavailable');
      await expectLater(
        native.pickJson(),
        throwsA(
          isA<StorageFileException>().having(
            (e) => e.message,
            'message',
            contains('provider_unavailable'),
          ),
        ),
      );
    },
  );

  test('save transfers actual JSON bytes to destination adapter', () async {
    picker.destination = 'content://cloud/document/2';
    expect(await transfer.exportToPicker(), picker.destination);
    final payload =
        jsonDecode(utf8.decode(picker.saved!)) as Map<String, dynamic>;
    expect(payload['formatVersion'], 1);
    expect(payload['tasks'], hasLength(6));
  });
}
