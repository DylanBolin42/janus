import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:janus/providers/database_provider.dart';
import 'package:janus/providers/settings_provider.dart';
import 'package:janus/services/sync/sync_backend.dart';
import 'package:janus/services/sync/sync_credentials.dart';
import 'package:janus/services/sync/sync_service.dart';

final syncCredentialsProvider = Provider((ref) => SyncCredentials());
final syncServiceProvider = Provider((ref) {
  final service = SyncService(
    backend: WebDavBackend.new,
    store: () => SnapshotStore(
      ref.read(appDatabaseProvider),
      ref.read(settingsServiceProvider),
    ),
  );
  ref.onDispose(service.dispose);
  return service;
});
