import 'package:drift/drift.dart';
import 'task_tables.dart';

/// Directed edge: predecessor must finish before successor is eligible.
class TaskDependencies extends Table {
  @ReferenceName('outgoingDependencies')
  IntColumn get predecessor =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  @ReferenceName('incomingDependencies')
  IntColumn get successor =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  @override
  Set<Column> get primaryKey => {predecessor, successor};
}

/// Append-only observations. Unknown historical outcomes are never backfilled.
class TaskEvents extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get taskId =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  TextColumn get kind => text()();
  TextColumn get idempotencyKey => text().nullable()();
  DateTimeColumn get occurredAt => dateTime()();
  IntColumn get minutes => integer().nullable()();
  IntColumn get estimatedMinutes => integer().nullable()();
  IntColumn get priorityValue => integer().nullable()();
  TextColumn get reason => text().nullable()();
  IntColumn get configRevision => integer().nullable()();
}

/// User supplied context; expiry prevents stale resources from becoming gates.
class TaskContexts extends Table {
  IntColumn get taskId =>
      integer().references(Tasks, #id, onDelete: KeyAction.cascade)();
  BoolColumn get resourcesReady => boolean().nullable()();
  IntColumn get availableMinutes => integer().nullable()();
  RealColumn get energyMatch => real().nullable()();
  RealColumn get goalImpact => real().nullable()();
  DateTimeColumn get expiresAt => dateTime()();
  @override
  Set<Column> get primaryKey => {taskId};
}
