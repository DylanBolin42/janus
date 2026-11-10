// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ddlMeta = const VerificationMeta('ddl');
  @override
  late final GeneratedColumn<DateTime> ddl = GeneratedColumn<DateTime>(
    'ddl',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usedTimeMeta = const VerificationMeta(
    'usedTime',
  );
  @override
  late final GeneratedColumn<int> usedTime = GeneratedColumn<int>(
    'used_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'CHECK (used_time >= 0)',
  );
  static const VerificationMeta _dependencyGraphKnownMeta =
      const VerificationMeta('dependencyGraphKnown');
  @override
  late final GeneratedColumn<bool> dependencyGraphKnown = GeneratedColumn<bool>(
    'dependency_graph_known',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dependency_graph_known" IN (0, 1))',
    ),
  );
  static const VerificationMeta _priorityExplicitMeta = const VerificationMeta(
    'priorityExplicit',
  );
  @override
  late final GeneratedColumn<bool> priorityExplicit = GeneratedColumn<bool>(
    'priority_explicit',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("priority_explicit" IN (0, 1))',
    ),
  );
  static const VerificationMeta _estHourMeta = const VerificationMeta(
    'estHour',
  );
  @override
  late final GeneratedColumn<int> estHour = GeneratedColumn<int>(
    'est_hour',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estMinuteMeta = const VerificationMeta(
    'estMinute',
  );
  @override
  late final GeneratedColumn<int> estMinute = GeneratedColumn<int>(
    'est_minute',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityMeta = const VerificationMeta(
    'priority',
  );
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
    'priority',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<List<String>?, String> tags =
      GeneratedColumn<String>(
        'tags',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<List<String>?>($TasksTable.$convertertagsn);
  @override
  List<GeneratedColumn> get $columns => [
    id,
    status,
    title,
    description,
    ddl,
    createdAt,
    startedAt,
    completedAt,
    usedTime,
    dependencyGraphKnown,
    priorityExplicit,
    estHour,
    estMinute,
    priority,
    tags,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('ddl')) {
      context.handle(
        _ddlMeta,
        ddl.isAcceptableOrUnknown(data['ddl']!, _ddlMeta),
      );
    } else if (isInserting) {
      context.missing(_ddlMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('used_time')) {
      context.handle(
        _usedTimeMeta,
        usedTime.isAcceptableOrUnknown(data['used_time']!, _usedTimeMeta),
      );
    }
    if (data.containsKey('dependency_graph_known')) {
      context.handle(
        _dependencyGraphKnownMeta,
        dependencyGraphKnown.isAcceptableOrUnknown(
          data['dependency_graph_known']!,
          _dependencyGraphKnownMeta,
        ),
      );
    }
    if (data.containsKey('priority_explicit')) {
      context.handle(
        _priorityExplicitMeta,
        priorityExplicit.isAcceptableOrUnknown(
          data['priority_explicit']!,
          _priorityExplicitMeta,
        ),
      );
    }
    if (data.containsKey('est_hour')) {
      context.handle(
        _estHourMeta,
        estHour.isAcceptableOrUnknown(data['est_hour']!, _estHourMeta),
      );
    }
    if (data.containsKey('est_minute')) {
      context.handle(
        _estMinuteMeta,
        estMinute.isAcceptableOrUnknown(data['est_minute']!, _estMinuteMeta),
      );
    }
    if (data.containsKey('priority')) {
      context.handle(
        _priorityMeta,
        priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      ddl: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ddl'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      usedTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}used_time'],
      ),
      dependencyGraphKnown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}dependency_graph_known'],
      ),
      priorityExplicit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}priority_explicit'],
      ),
      estHour: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}est_hour'],
      ),
      estMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}est_minute'],
      ),
      priority: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority'],
      )!,
      tags: $TasksTable.$convertertagsn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}tags'],
        ),
      ),
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }

  static TypeConverter<List<String>, String> $convertertags =
      const TagConverter();
  static TypeConverter<List<String>?, String?> $convertertagsn =
      NullAwareTypeConverter.wrap($convertertags);
}

class Task extends DataClass implements Insertable<Task> {
  final int id;

  /// Status定义
  /// 0  -> 未完成
  /// 1  -> 已完成
  /// 2  -> 已规划
  /// -1 -> 已冻结
  /// 是否逾期交由Status和DDL与当前时间的比较运算后得出
  final int status;
  final String title;
  final String? description;
  final DateTime ddl;
  final DateTime? createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  /// Actual consumed whole minutes, independently of EST. Null means unknown.
  final int? usedTime;

  /// Null on legacy records: an absent historical graph is not confirmed empty.
  final bool? dependencyGraphKnown;
  final bool? priorityExplicit;
  final int? estHour;
  final int? estMinute;
  final int priority;
  final List<String>? tags;
  const Task({
    required this.id,
    required this.status,
    required this.title,
    this.description,
    required this.ddl,
    this.createdAt,
    this.startedAt,
    this.completedAt,
    this.usedTime,
    this.dependencyGraphKnown,
    this.priorityExplicit,
    this.estHour,
    this.estMinute,
    required this.priority,
    this.tags,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['status'] = Variable<int>(status);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['ddl'] = Variable<DateTime>(ddl);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    if (!nullToAbsent || usedTime != null) {
      map['used_time'] = Variable<int>(usedTime);
    }
    if (!nullToAbsent || dependencyGraphKnown != null) {
      map['dependency_graph_known'] = Variable<bool>(dependencyGraphKnown);
    }
    if (!nullToAbsent || priorityExplicit != null) {
      map['priority_explicit'] = Variable<bool>(priorityExplicit);
    }
    if (!nullToAbsent || estHour != null) {
      map['est_hour'] = Variable<int>(estHour);
    }
    if (!nullToAbsent || estMinute != null) {
      map['est_minute'] = Variable<int>(estMinute);
    }
    map['priority'] = Variable<int>(priority);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>($TasksTable.$convertertagsn.toSql(tags));
    }
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      status: Value(status),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      ddl: Value(ddl),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      usedTime: usedTime == null && nullToAbsent
          ? const Value.absent()
          : Value(usedTime),
      dependencyGraphKnown: dependencyGraphKnown == null && nullToAbsent
          ? const Value.absent()
          : Value(dependencyGraphKnown),
      priorityExplicit: priorityExplicit == null && nullToAbsent
          ? const Value.absent()
          : Value(priorityExplicit),
      estHour: estHour == null && nullToAbsent
          ? const Value.absent()
          : Value(estHour),
      estMinute: estMinute == null && nullToAbsent
          ? const Value.absent()
          : Value(estMinute),
      priority: Value(priority),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      status: serializer.fromJson<int>(json['status']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      ddl: serializer.fromJson<DateTime>(json['ddl']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
      usedTime: serializer.fromJson<int?>(json['usedTime']),
      dependencyGraphKnown: serializer.fromJson<bool?>(
        json['dependencyGraphKnown'],
      ),
      priorityExplicit: serializer.fromJson<bool?>(json['priorityExplicit']),
      estHour: serializer.fromJson<int?>(json['estHour']),
      estMinute: serializer.fromJson<int?>(json['estMinute']),
      priority: serializer.fromJson<int>(json['priority']),
      tags: serializer.fromJson<List<String>?>(json['tags']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'status': serializer.toJson<int>(status),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'ddl': serializer.toJson<DateTime>(ddl),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
      'usedTime': serializer.toJson<int?>(usedTime),
      'dependencyGraphKnown': serializer.toJson<bool?>(dependencyGraphKnown),
      'priorityExplicit': serializer.toJson<bool?>(priorityExplicit),
      'estHour': serializer.toJson<int?>(estHour),
      'estMinute': serializer.toJson<int?>(estMinute),
      'priority': serializer.toJson<int>(priority),
      'tags': serializer.toJson<List<String>?>(tags),
    };
  }

  Task copyWith({
    int? id,
    int? status,
    String? title,
    Value<String?> description = const Value.absent(),
    DateTime? ddl,
    Value<DateTime?> createdAt = const Value.absent(),
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
    Value<int?> usedTime = const Value.absent(),
    Value<bool?> dependencyGraphKnown = const Value.absent(),
    Value<bool?> priorityExplicit = const Value.absent(),
    Value<int?> estHour = const Value.absent(),
    Value<int?> estMinute = const Value.absent(),
    int? priority,
    Value<List<String>?> tags = const Value.absent(),
  }) => Task(
    id: id ?? this.id,
    status: status ?? this.status,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    ddl: ddl ?? this.ddl,
    createdAt: createdAt.present ? createdAt.value : this.createdAt,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    usedTime: usedTime.present ? usedTime.value : this.usedTime,
    dependencyGraphKnown: dependencyGraphKnown.present
        ? dependencyGraphKnown.value
        : this.dependencyGraphKnown,
    priorityExplicit: priorityExplicit.present
        ? priorityExplicit.value
        : this.priorityExplicit,
    estHour: estHour.present ? estHour.value : this.estHour,
    estMinute: estMinute.present ? estMinute.value : this.estMinute,
    priority: priority ?? this.priority,
    tags: tags.present ? tags.value : this.tags,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      status: data.status.present ? data.status.value : this.status,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      ddl: data.ddl.present ? data.ddl.value : this.ddl,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      usedTime: data.usedTime.present ? data.usedTime.value : this.usedTime,
      dependencyGraphKnown: data.dependencyGraphKnown.present
          ? data.dependencyGraphKnown.value
          : this.dependencyGraphKnown,
      priorityExplicit: data.priorityExplicit.present
          ? data.priorityExplicit.value
          : this.priorityExplicit,
      estHour: data.estHour.present ? data.estHour.value : this.estHour,
      estMinute: data.estMinute.present ? data.estMinute.value : this.estMinute,
      priority: data.priority.present ? data.priority.value : this.priority,
      tags: data.tags.present ? data.tags.value : this.tags,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('ddl: $ddl, ')
          ..write('createdAt: $createdAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('usedTime: $usedTime, ')
          ..write('dependencyGraphKnown: $dependencyGraphKnown, ')
          ..write('priorityExplicit: $priorityExplicit, ')
          ..write('estHour: $estHour, ')
          ..write('estMinute: $estMinute, ')
          ..write('priority: $priority, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    status,
    title,
    description,
    ddl,
    createdAt,
    startedAt,
    completedAt,
    usedTime,
    dependencyGraphKnown,
    priorityExplicit,
    estHour,
    estMinute,
    priority,
    tags,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.status == this.status &&
          other.title == this.title &&
          other.description == this.description &&
          other.ddl == this.ddl &&
          other.createdAt == this.createdAt &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.usedTime == this.usedTime &&
          other.dependencyGraphKnown == this.dependencyGraphKnown &&
          other.priorityExplicit == this.priorityExplicit &&
          other.estHour == this.estHour &&
          other.estMinute == this.estMinute &&
          other.priority == this.priority &&
          other.tags == this.tags);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<int> status;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime> ddl;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> completedAt;
  final Value<int?> usedTime;
  final Value<bool?> dependencyGraphKnown;
  final Value<bool?> priorityExplicit;
  final Value<int?> estHour;
  final Value<int?> estMinute;
  final Value<int> priority;
  final Value<List<String>?> tags;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.ddl = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.usedTime = const Value.absent(),
    this.dependencyGraphKnown = const Value.absent(),
    this.priorityExplicit = const Value.absent(),
    this.estHour = const Value.absent(),
    this.estMinute = const Value.absent(),
    this.priority = const Value.absent(),
    this.tags = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    this.status = const Value.absent(),
    required String title,
    this.description = const Value.absent(),
    required DateTime ddl,
    this.createdAt = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.usedTime = const Value.absent(),
    this.dependencyGraphKnown = const Value.absent(),
    this.priorityExplicit = const Value.absent(),
    this.estHour = const Value.absent(),
    this.estMinute = const Value.absent(),
    this.priority = const Value.absent(),
    this.tags = const Value.absent(),
  }) : title = Value(title),
       ddl = Value(ddl);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<int>? status,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? ddl,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<int>? usedTime,
    Expression<bool>? dependencyGraphKnown,
    Expression<bool>? priorityExplicit,
    Expression<int>? estHour,
    Expression<int>? estMinute,
    Expression<int>? priority,
    Expression<String>? tags,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (status != null) 'status': status,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (ddl != null) 'ddl': ddl,
      if (createdAt != null) 'created_at': createdAt,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (usedTime != null) 'used_time': usedTime,
      if (dependencyGraphKnown != null)
        'dependency_graph_known': dependencyGraphKnown,
      if (priorityExplicit != null) 'priority_explicit': priorityExplicit,
      if (estHour != null) 'est_hour': estHour,
      if (estMinute != null) 'est_minute': estMinute,
      if (priority != null) 'priority': priority,
      if (tags != null) 'tags': tags,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<int>? status,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime>? ddl,
    Value<DateTime?>? createdAt,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? completedAt,
    Value<int?>? usedTime,
    Value<bool?>? dependencyGraphKnown,
    Value<bool?>? priorityExplicit,
    Value<int?>? estHour,
    Value<int?>? estMinute,
    Value<int>? priority,
    Value<List<String>?>? tags,
  }) {
    return TasksCompanion(
      id: id ?? this.id,
      status: status ?? this.status,
      title: title ?? this.title,
      description: description ?? this.description,
      ddl: ddl ?? this.ddl,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      usedTime: usedTime ?? this.usedTime,
      dependencyGraphKnown: dependencyGraphKnown ?? this.dependencyGraphKnown,
      priorityExplicit: priorityExplicit ?? this.priorityExplicit,
      estHour: estHour ?? this.estHour,
      estMinute: estMinute ?? this.estMinute,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (ddl.present) {
      map['ddl'] = Variable<DateTime>(ddl.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (usedTime.present) {
      map['used_time'] = Variable<int>(usedTime.value);
    }
    if (dependencyGraphKnown.present) {
      map['dependency_graph_known'] = Variable<bool>(
        dependencyGraphKnown.value,
      );
    }
    if (priorityExplicit.present) {
      map['priority_explicit'] = Variable<bool>(priorityExplicit.value);
    }
    if (estHour.present) {
      map['est_hour'] = Variable<int>(estHour.value);
    }
    if (estMinute.present) {
      map['est_minute'] = Variable<int>(estMinute.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(
        $TasksTable.$convertertagsn.toSql(tags.value),
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('status: $status, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('ddl: $ddl, ')
          ..write('createdAt: $createdAt, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('usedTime: $usedTime, ')
          ..write('dependencyGraphKnown: $dependencyGraphKnown, ')
          ..write('priorityExplicit: $priorityExplicit, ')
          ..write('estHour: $estHour, ')
          ..write('estMinute: $estMinute, ')
          ..write('priority: $priority, ')
          ..write('tags: $tags')
          ..write(')'))
        .toString();
  }
}

class $TagsTable extends Tags with TableInfo<$TagsTable, Tag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(minTextLength: 1),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $TagsTable createAlias(String alias) {
    return $TagsTable(attachedDatabase, alias);
  }
}

class Tag extends DataClass implements Insertable<Tag> {
  final int id;
  final String name;
  const Tag({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  TagsCompanion toCompanion(bool nullToAbsent) {
    return TagsCompanion(id: Value(id), name: Value(name));
  }

  factory Tag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tag(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  Tag copyWith({int? id, String? name}) =>
      Tag(id: id ?? this.id, name: name ?? this.name);
  Tag copyWithCompanion(TagsCompanion data) {
    return Tag(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tag(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tag && other.id == this.id && other.name == this.name);
}

class TagsCompanion extends UpdateCompanion<Tag> {
  final Value<int> id;
  final Value<String> name;
  const TagsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  TagsCompanion.insert({this.id = const Value.absent(), required String name})
    : name = Value(name);
  static Insertable<Tag> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  TagsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return TagsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TagsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $TaskDependenciesTable extends TaskDependencies
    with TableInfo<$TaskDependenciesTable, TaskDependency> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskDependenciesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _predecessorMeta = const VerificationMeta(
    'predecessor',
  );
  @override
  late final GeneratedColumn<int> predecessor = GeneratedColumn<int>(
    'predecessor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _successorMeta = const VerificationMeta(
    'successor',
  );
  @override
  late final GeneratedColumn<int> successor = GeneratedColumn<int>(
    'successor',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [predecessor, successor];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_dependencies';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskDependency> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('predecessor')) {
      context.handle(
        _predecessorMeta,
        predecessor.isAcceptableOrUnknown(
          data['predecessor']!,
          _predecessorMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_predecessorMeta);
    }
    if (data.containsKey('successor')) {
      context.handle(
        _successorMeta,
        successor.isAcceptableOrUnknown(data['successor']!, _successorMeta),
      );
    } else if (isInserting) {
      context.missing(_successorMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {predecessor, successor};
  @override
  TaskDependency map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskDependency(
      predecessor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}predecessor'],
      )!,
      successor: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}successor'],
      )!,
    );
  }

  @override
  $TaskDependenciesTable createAlias(String alias) {
    return $TaskDependenciesTable(attachedDatabase, alias);
  }
}

class TaskDependency extends DataClass implements Insertable<TaskDependency> {
  final int predecessor;
  final int successor;
  const TaskDependency({required this.predecessor, required this.successor});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['predecessor'] = Variable<int>(predecessor);
    map['successor'] = Variable<int>(successor);
    return map;
  }

  TaskDependenciesCompanion toCompanion(bool nullToAbsent) {
    return TaskDependenciesCompanion(
      predecessor: Value(predecessor),
      successor: Value(successor),
    );
  }

  factory TaskDependency.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskDependency(
      predecessor: serializer.fromJson<int>(json['predecessor']),
      successor: serializer.fromJson<int>(json['successor']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'predecessor': serializer.toJson<int>(predecessor),
      'successor': serializer.toJson<int>(successor),
    };
  }

  TaskDependency copyWith({int? predecessor, int? successor}) => TaskDependency(
    predecessor: predecessor ?? this.predecessor,
    successor: successor ?? this.successor,
  );
  TaskDependency copyWithCompanion(TaskDependenciesCompanion data) {
    return TaskDependency(
      predecessor: data.predecessor.present
          ? data.predecessor.value
          : this.predecessor,
      successor: data.successor.present ? data.successor.value : this.successor,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskDependency(')
          ..write('predecessor: $predecessor, ')
          ..write('successor: $successor')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(predecessor, successor);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskDependency &&
          other.predecessor == this.predecessor &&
          other.successor == this.successor);
}

class TaskDependenciesCompanion extends UpdateCompanion<TaskDependency> {
  final Value<int> predecessor;
  final Value<int> successor;
  final Value<int> rowid;
  const TaskDependenciesCompanion({
    this.predecessor = const Value.absent(),
    this.successor = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TaskDependenciesCompanion.insert({
    required int predecessor,
    required int successor,
    this.rowid = const Value.absent(),
  }) : predecessor = Value(predecessor),
       successor = Value(successor);
  static Insertable<TaskDependency> custom({
    Expression<int>? predecessor,
    Expression<int>? successor,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (predecessor != null) 'predecessor': predecessor,
      if (successor != null) 'successor': successor,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TaskDependenciesCompanion copyWith({
    Value<int>? predecessor,
    Value<int>? successor,
    Value<int>? rowid,
  }) {
    return TaskDependenciesCompanion(
      predecessor: predecessor ?? this.predecessor,
      successor: successor ?? this.successor,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (predecessor.present) {
      map['predecessor'] = Variable<int>(predecessor.value);
    }
    if (successor.present) {
      map['successor'] = Variable<int>(successor.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskDependenciesCompanion(')
          ..write('predecessor: $predecessor, ')
          ..write('successor: $successor, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TaskEventsTable extends TaskEvents
    with TableInfo<$TaskEventsTable, TaskEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _idempotencyKeyMeta = const VerificationMeta(
    'idempotencyKey',
  );
  @override
  late final GeneratedColumn<String> idempotencyKey = GeneratedColumn<String>(
    'idempotency_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minutesMeta = const VerificationMeta(
    'minutes',
  );
  @override
  late final GeneratedColumn<int> minutes = GeneratedColumn<int>(
    'minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _estimatedMinutesMeta = const VerificationMeta(
    'estimatedMinutes',
  );
  @override
  late final GeneratedColumn<int> estimatedMinutes = GeneratedColumn<int>(
    'estimated_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityValueMeta = const VerificationMeta(
    'priorityValue',
  );
  @override
  late final GeneratedColumn<int> priorityValue = GeneratedColumn<int>(
    'priority_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _configRevisionMeta = const VerificationMeta(
    'configRevision',
  );
  @override
  late final GeneratedColumn<int> configRevision = GeneratedColumn<int>(
    'config_revision',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    taskId,
    kind,
    idempotencyKey,
    occurredAt,
    minutes,
    estimatedMinutes,
    priorityValue,
    reason,
    configRevision,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    } else if (isInserting) {
      context.missing(_taskIdMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('idempotency_key')) {
      context.handle(
        _idempotencyKeyMeta,
        idempotencyKey.isAcceptableOrUnknown(
          data['idempotency_key']!,
          _idempotencyKeyMeta,
        ),
      );
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('minutes')) {
      context.handle(
        _minutesMeta,
        minutes.isAcceptableOrUnknown(data['minutes']!, _minutesMeta),
      );
    }
    if (data.containsKey('estimated_minutes')) {
      context.handle(
        _estimatedMinutesMeta,
        estimatedMinutes.isAcceptableOrUnknown(
          data['estimated_minutes']!,
          _estimatedMinutesMeta,
        ),
      );
    }
    if (data.containsKey('priority_value')) {
      context.handle(
        _priorityValueMeta,
        priorityValue.isAcceptableOrUnknown(
          data['priority_value']!,
          _priorityValueMeta,
        ),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('config_revision')) {
      context.handle(
        _configRevisionMeta,
        configRevision.isAcceptableOrUnknown(
          data['config_revision']!,
          _configRevisionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskEvent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      idempotencyKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}idempotency_key'],
      ),
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      minutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minutes'],
      ),
      estimatedMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimated_minutes'],
      ),
      priorityValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority_value'],
      ),
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      configRevision: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}config_revision'],
      ),
    );
  }

  @override
  $TaskEventsTable createAlias(String alias) {
    return $TaskEventsTable(attachedDatabase, alias);
  }
}

class TaskEvent extends DataClass implements Insertable<TaskEvent> {
  final int id;
  final int taskId;
  final String kind;
  final String? idempotencyKey;
  final DateTime occurredAt;
  final int? minutes;
  final int? estimatedMinutes;
  final int? priorityValue;
  final String? reason;
  final int? configRevision;
  const TaskEvent({
    required this.id,
    required this.taskId,
    required this.kind,
    this.idempotencyKey,
    required this.occurredAt,
    this.minutes,
    this.estimatedMinutes,
    this.priorityValue,
    this.reason,
    this.configRevision,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['task_id'] = Variable<int>(taskId);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || idempotencyKey != null) {
      map['idempotency_key'] = Variable<String>(idempotencyKey);
    }
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || minutes != null) {
      map['minutes'] = Variable<int>(minutes);
    }
    if (!nullToAbsent || estimatedMinutes != null) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes);
    }
    if (!nullToAbsent || priorityValue != null) {
      map['priority_value'] = Variable<int>(priorityValue);
    }
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || configRevision != null) {
      map['config_revision'] = Variable<int>(configRevision);
    }
    return map;
  }

  TaskEventsCompanion toCompanion(bool nullToAbsent) {
    return TaskEventsCompanion(
      id: Value(id),
      taskId: Value(taskId),
      kind: Value(kind),
      idempotencyKey: idempotencyKey == null && nullToAbsent
          ? const Value.absent()
          : Value(idempotencyKey),
      occurredAt: Value(occurredAt),
      minutes: minutes == null && nullToAbsent
          ? const Value.absent()
          : Value(minutes),
      estimatedMinutes: estimatedMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(estimatedMinutes),
      priorityValue: priorityValue == null && nullToAbsent
          ? const Value.absent()
          : Value(priorityValue),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      configRevision: configRevision == null && nullToAbsent
          ? const Value.absent()
          : Value(configRevision),
    );
  }

  factory TaskEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskEvent(
      id: serializer.fromJson<int>(json['id']),
      taskId: serializer.fromJson<int>(json['taskId']),
      kind: serializer.fromJson<String>(json['kind']),
      idempotencyKey: serializer.fromJson<String?>(json['idempotencyKey']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      minutes: serializer.fromJson<int?>(json['minutes']),
      estimatedMinutes: serializer.fromJson<int?>(json['estimatedMinutes']),
      priorityValue: serializer.fromJson<int?>(json['priorityValue']),
      reason: serializer.fromJson<String?>(json['reason']),
      configRevision: serializer.fromJson<int?>(json['configRevision']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'taskId': serializer.toJson<int>(taskId),
      'kind': serializer.toJson<String>(kind),
      'idempotencyKey': serializer.toJson<String?>(idempotencyKey),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'minutes': serializer.toJson<int?>(minutes),
      'estimatedMinutes': serializer.toJson<int?>(estimatedMinutes),
      'priorityValue': serializer.toJson<int?>(priorityValue),
      'reason': serializer.toJson<String?>(reason),
      'configRevision': serializer.toJson<int?>(configRevision),
    };
  }

  TaskEvent copyWith({
    int? id,
    int? taskId,
    String? kind,
    Value<String?> idempotencyKey = const Value.absent(),
    DateTime? occurredAt,
    Value<int?> minutes = const Value.absent(),
    Value<int?> estimatedMinutes = const Value.absent(),
    Value<int?> priorityValue = const Value.absent(),
    Value<String?> reason = const Value.absent(),
    Value<int?> configRevision = const Value.absent(),
  }) => TaskEvent(
    id: id ?? this.id,
    taskId: taskId ?? this.taskId,
    kind: kind ?? this.kind,
    idempotencyKey: idempotencyKey.present
        ? idempotencyKey.value
        : this.idempotencyKey,
    occurredAt: occurredAt ?? this.occurredAt,
    minutes: minutes.present ? minutes.value : this.minutes,
    estimatedMinutes: estimatedMinutes.present
        ? estimatedMinutes.value
        : this.estimatedMinutes,
    priorityValue: priorityValue.present
        ? priorityValue.value
        : this.priorityValue,
    reason: reason.present ? reason.value : this.reason,
    configRevision: configRevision.present
        ? configRevision.value
        : this.configRevision,
  );
  TaskEvent copyWithCompanion(TaskEventsCompanion data) {
    return TaskEvent(
      id: data.id.present ? data.id.value : this.id,
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      kind: data.kind.present ? data.kind.value : this.kind,
      idempotencyKey: data.idempotencyKey.present
          ? data.idempotencyKey.value
          : this.idempotencyKey,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      minutes: data.minutes.present ? data.minutes.value : this.minutes,
      estimatedMinutes: data.estimatedMinutes.present
          ? data.estimatedMinutes.value
          : this.estimatedMinutes,
      priorityValue: data.priorityValue.present
          ? data.priorityValue.value
          : this.priorityValue,
      reason: data.reason.present ? data.reason.value : this.reason,
      configRevision: data.configRevision.present
          ? data.configRevision.value
          : this.configRevision,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskEvent(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('kind: $kind, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('minutes: $minutes, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('priorityValue: $priorityValue, ')
          ..write('reason: $reason, ')
          ..write('configRevision: $configRevision')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    taskId,
    kind,
    idempotencyKey,
    occurredAt,
    minutes,
    estimatedMinutes,
    priorityValue,
    reason,
    configRevision,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskEvent &&
          other.id == this.id &&
          other.taskId == this.taskId &&
          other.kind == this.kind &&
          other.idempotencyKey == this.idempotencyKey &&
          other.occurredAt == this.occurredAt &&
          other.minutes == this.minutes &&
          other.estimatedMinutes == this.estimatedMinutes &&
          other.priorityValue == this.priorityValue &&
          other.reason == this.reason &&
          other.configRevision == this.configRevision);
}

class TaskEventsCompanion extends UpdateCompanion<TaskEvent> {
  final Value<int> id;
  final Value<int> taskId;
  final Value<String> kind;
  final Value<String?> idempotencyKey;
  final Value<DateTime> occurredAt;
  final Value<int?> minutes;
  final Value<int?> estimatedMinutes;
  final Value<int?> priorityValue;
  final Value<String?> reason;
  final Value<int?> configRevision;
  const TaskEventsCompanion({
    this.id = const Value.absent(),
    this.taskId = const Value.absent(),
    this.kind = const Value.absent(),
    this.idempotencyKey = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.minutes = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.priorityValue = const Value.absent(),
    this.reason = const Value.absent(),
    this.configRevision = const Value.absent(),
  });
  TaskEventsCompanion.insert({
    this.id = const Value.absent(),
    required int taskId,
    required String kind,
    this.idempotencyKey = const Value.absent(),
    required DateTime occurredAt,
    this.minutes = const Value.absent(),
    this.estimatedMinutes = const Value.absent(),
    this.priorityValue = const Value.absent(),
    this.reason = const Value.absent(),
    this.configRevision = const Value.absent(),
  }) : taskId = Value(taskId),
       kind = Value(kind),
       occurredAt = Value(occurredAt);
  static Insertable<TaskEvent> custom({
    Expression<int>? id,
    Expression<int>? taskId,
    Expression<String>? kind,
    Expression<String>? idempotencyKey,
    Expression<DateTime>? occurredAt,
    Expression<int>? minutes,
    Expression<int>? estimatedMinutes,
    Expression<int>? priorityValue,
    Expression<String>? reason,
    Expression<int>? configRevision,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (taskId != null) 'task_id': taskId,
      if (kind != null) 'kind': kind,
      if (idempotencyKey != null) 'idempotency_key': idempotencyKey,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (minutes != null) 'minutes': minutes,
      if (estimatedMinutes != null) 'estimated_minutes': estimatedMinutes,
      if (priorityValue != null) 'priority_value': priorityValue,
      if (reason != null) 'reason': reason,
      if (configRevision != null) 'config_revision': configRevision,
    });
  }

  TaskEventsCompanion copyWith({
    Value<int>? id,
    Value<int>? taskId,
    Value<String>? kind,
    Value<String?>? idempotencyKey,
    Value<DateTime>? occurredAt,
    Value<int?>? minutes,
    Value<int?>? estimatedMinutes,
    Value<int?>? priorityValue,
    Value<String?>? reason,
    Value<int?>? configRevision,
  }) {
    return TaskEventsCompanion(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      kind: kind ?? this.kind,
      idempotencyKey: idempotencyKey ?? this.idempotencyKey,
      occurredAt: occurredAt ?? this.occurredAt,
      minutes: minutes ?? this.minutes,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      priorityValue: priorityValue ?? this.priorityValue,
      reason: reason ?? this.reason,
      configRevision: configRevision ?? this.configRevision,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (idempotencyKey.present) {
      map['idempotency_key'] = Variable<String>(idempotencyKey.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (minutes.present) {
      map['minutes'] = Variable<int>(minutes.value);
    }
    if (estimatedMinutes.present) {
      map['estimated_minutes'] = Variable<int>(estimatedMinutes.value);
    }
    if (priorityValue.present) {
      map['priority_value'] = Variable<int>(priorityValue.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (configRevision.present) {
      map['config_revision'] = Variable<int>(configRevision.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskEventsCompanion(')
          ..write('id: $id, ')
          ..write('taskId: $taskId, ')
          ..write('kind: $kind, ')
          ..write('idempotencyKey: $idempotencyKey, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('minutes: $minutes, ')
          ..write('estimatedMinutes: $estimatedMinutes, ')
          ..write('priorityValue: $priorityValue, ')
          ..write('reason: $reason, ')
          ..write('configRevision: $configRevision')
          ..write(')'))
        .toString();
  }
}

class $TaskContextsTable extends TaskContexts
    with TableInfo<$TaskContextsTable, TaskContext> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TaskContextsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _taskIdMeta = const VerificationMeta('taskId');
  @override
  late final GeneratedColumn<int> taskId = GeneratedColumn<int>(
    'task_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tasks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _resourcesReadyMeta = const VerificationMeta(
    'resourcesReady',
  );
  @override
  late final GeneratedColumn<bool> resourcesReady = GeneratedColumn<bool>(
    'resources_ready',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("resources_ready" IN (0, 1))',
    ),
  );
  static const VerificationMeta _availableMinutesMeta = const VerificationMeta(
    'availableMinutes',
  );
  @override
  late final GeneratedColumn<int> availableMinutes = GeneratedColumn<int>(
    'available_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _energyMatchMeta = const VerificationMeta(
    'energyMatch',
  );
  @override
  late final GeneratedColumn<double> energyMatch = GeneratedColumn<double>(
    'energy_match',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _goalImpactMeta = const VerificationMeta(
    'goalImpact',
  );
  @override
  late final GeneratedColumn<double> goalImpact = GeneratedColumn<double>(
    'goal_impact',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expiresAtMeta = const VerificationMeta(
    'expiresAt',
  );
  @override
  late final GeneratedColumn<DateTime> expiresAt = GeneratedColumn<DateTime>(
    'expires_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    taskId,
    resourcesReady,
    availableMinutes,
    energyMatch,
    goalImpact,
    expiresAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'task_contexts';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskContext> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('task_id')) {
      context.handle(
        _taskIdMeta,
        taskId.isAcceptableOrUnknown(data['task_id']!, _taskIdMeta),
      );
    }
    if (data.containsKey('resources_ready')) {
      context.handle(
        _resourcesReadyMeta,
        resourcesReady.isAcceptableOrUnknown(
          data['resources_ready']!,
          _resourcesReadyMeta,
        ),
      );
    }
    if (data.containsKey('available_minutes')) {
      context.handle(
        _availableMinutesMeta,
        availableMinutes.isAcceptableOrUnknown(
          data['available_minutes']!,
          _availableMinutesMeta,
        ),
      );
    }
    if (data.containsKey('energy_match')) {
      context.handle(
        _energyMatchMeta,
        energyMatch.isAcceptableOrUnknown(
          data['energy_match']!,
          _energyMatchMeta,
        ),
      );
    }
    if (data.containsKey('goal_impact')) {
      context.handle(
        _goalImpactMeta,
        goalImpact.isAcceptableOrUnknown(data['goal_impact']!, _goalImpactMeta),
      );
    }
    if (data.containsKey('expires_at')) {
      context.handle(
        _expiresAtMeta,
        expiresAt.isAcceptableOrUnknown(data['expires_at']!, _expiresAtMeta),
      );
    } else if (isInserting) {
      context.missing(_expiresAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {taskId};
  @override
  TaskContext map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskContext(
      taskId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}task_id'],
      )!,
      resourcesReady: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}resources_ready'],
      ),
      availableMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}available_minutes'],
      ),
      energyMatch: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}energy_match'],
      ),
      goalImpact: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}goal_impact'],
      ),
      expiresAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}expires_at'],
      )!,
    );
  }

  @override
  $TaskContextsTable createAlias(String alias) {
    return $TaskContextsTable(attachedDatabase, alias);
  }
}

class TaskContext extends DataClass implements Insertable<TaskContext> {
  final int taskId;
  final bool? resourcesReady;
  final int? availableMinutes;
  final double? energyMatch;
  final double? goalImpact;
  final DateTime expiresAt;
  const TaskContext({
    required this.taskId,
    this.resourcesReady,
    this.availableMinutes,
    this.energyMatch,
    this.goalImpact,
    required this.expiresAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['task_id'] = Variable<int>(taskId);
    if (!nullToAbsent || resourcesReady != null) {
      map['resources_ready'] = Variable<bool>(resourcesReady);
    }
    if (!nullToAbsent || availableMinutes != null) {
      map['available_minutes'] = Variable<int>(availableMinutes);
    }
    if (!nullToAbsent || energyMatch != null) {
      map['energy_match'] = Variable<double>(energyMatch);
    }
    if (!nullToAbsent || goalImpact != null) {
      map['goal_impact'] = Variable<double>(goalImpact);
    }
    map['expires_at'] = Variable<DateTime>(expiresAt);
    return map;
  }

  TaskContextsCompanion toCompanion(bool nullToAbsent) {
    return TaskContextsCompanion(
      taskId: Value(taskId),
      resourcesReady: resourcesReady == null && nullToAbsent
          ? const Value.absent()
          : Value(resourcesReady),
      availableMinutes: availableMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(availableMinutes),
      energyMatch: energyMatch == null && nullToAbsent
          ? const Value.absent()
          : Value(energyMatch),
      goalImpact: goalImpact == null && nullToAbsent
          ? const Value.absent()
          : Value(goalImpact),
      expiresAt: Value(expiresAt),
    );
  }

  factory TaskContext.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskContext(
      taskId: serializer.fromJson<int>(json['taskId']),
      resourcesReady: serializer.fromJson<bool?>(json['resourcesReady']),
      availableMinutes: serializer.fromJson<int?>(json['availableMinutes']),
      energyMatch: serializer.fromJson<double?>(json['energyMatch']),
      goalImpact: serializer.fromJson<double?>(json['goalImpact']),
      expiresAt: serializer.fromJson<DateTime>(json['expiresAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'taskId': serializer.toJson<int>(taskId),
      'resourcesReady': serializer.toJson<bool?>(resourcesReady),
      'availableMinutes': serializer.toJson<int?>(availableMinutes),
      'energyMatch': serializer.toJson<double?>(energyMatch),
      'goalImpact': serializer.toJson<double?>(goalImpact),
      'expiresAt': serializer.toJson<DateTime>(expiresAt),
    };
  }

  TaskContext copyWith({
    int? taskId,
    Value<bool?> resourcesReady = const Value.absent(),
    Value<int?> availableMinutes = const Value.absent(),
    Value<double?> energyMatch = const Value.absent(),
    Value<double?> goalImpact = const Value.absent(),
    DateTime? expiresAt,
  }) => TaskContext(
    taskId: taskId ?? this.taskId,
    resourcesReady: resourcesReady.present
        ? resourcesReady.value
        : this.resourcesReady,
    availableMinutes: availableMinutes.present
        ? availableMinutes.value
        : this.availableMinutes,
    energyMatch: energyMatch.present ? energyMatch.value : this.energyMatch,
    goalImpact: goalImpact.present ? goalImpact.value : this.goalImpact,
    expiresAt: expiresAt ?? this.expiresAt,
  );
  TaskContext copyWithCompanion(TaskContextsCompanion data) {
    return TaskContext(
      taskId: data.taskId.present ? data.taskId.value : this.taskId,
      resourcesReady: data.resourcesReady.present
          ? data.resourcesReady.value
          : this.resourcesReady,
      availableMinutes: data.availableMinutes.present
          ? data.availableMinutes.value
          : this.availableMinutes,
      energyMatch: data.energyMatch.present
          ? data.energyMatch.value
          : this.energyMatch,
      goalImpact: data.goalImpact.present
          ? data.goalImpact.value
          : this.goalImpact,
      expiresAt: data.expiresAt.present ? data.expiresAt.value : this.expiresAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskContext(')
          ..write('taskId: $taskId, ')
          ..write('resourcesReady: $resourcesReady, ')
          ..write('availableMinutes: $availableMinutes, ')
          ..write('energyMatch: $energyMatch, ')
          ..write('goalImpact: $goalImpact, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    taskId,
    resourcesReady,
    availableMinutes,
    energyMatch,
    goalImpact,
    expiresAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskContext &&
          other.taskId == this.taskId &&
          other.resourcesReady == this.resourcesReady &&
          other.availableMinutes == this.availableMinutes &&
          other.energyMatch == this.energyMatch &&
          other.goalImpact == this.goalImpact &&
          other.expiresAt == this.expiresAt);
}

class TaskContextsCompanion extends UpdateCompanion<TaskContext> {
  final Value<int> taskId;
  final Value<bool?> resourcesReady;
  final Value<int?> availableMinutes;
  final Value<double?> energyMatch;
  final Value<double?> goalImpact;
  final Value<DateTime> expiresAt;
  const TaskContextsCompanion({
    this.taskId = const Value.absent(),
    this.resourcesReady = const Value.absent(),
    this.availableMinutes = const Value.absent(),
    this.energyMatch = const Value.absent(),
    this.goalImpact = const Value.absent(),
    this.expiresAt = const Value.absent(),
  });
  TaskContextsCompanion.insert({
    this.taskId = const Value.absent(),
    this.resourcesReady = const Value.absent(),
    this.availableMinutes = const Value.absent(),
    this.energyMatch = const Value.absent(),
    this.goalImpact = const Value.absent(),
    required DateTime expiresAt,
  }) : expiresAt = Value(expiresAt);
  static Insertable<TaskContext> custom({
    Expression<int>? taskId,
    Expression<bool>? resourcesReady,
    Expression<int>? availableMinutes,
    Expression<double>? energyMatch,
    Expression<double>? goalImpact,
    Expression<DateTime>? expiresAt,
  }) {
    return RawValuesInsertable({
      if (taskId != null) 'task_id': taskId,
      if (resourcesReady != null) 'resources_ready': resourcesReady,
      if (availableMinutes != null) 'available_minutes': availableMinutes,
      if (energyMatch != null) 'energy_match': energyMatch,
      if (goalImpact != null) 'goal_impact': goalImpact,
      if (expiresAt != null) 'expires_at': expiresAt,
    });
  }

  TaskContextsCompanion copyWith({
    Value<int>? taskId,
    Value<bool?>? resourcesReady,
    Value<int?>? availableMinutes,
    Value<double?>? energyMatch,
    Value<double?>? goalImpact,
    Value<DateTime>? expiresAt,
  }) {
    return TaskContextsCompanion(
      taskId: taskId ?? this.taskId,
      resourcesReady: resourcesReady ?? this.resourcesReady,
      availableMinutes: availableMinutes ?? this.availableMinutes,
      energyMatch: energyMatch ?? this.energyMatch,
      goalImpact: goalImpact ?? this.goalImpact,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (taskId.present) {
      map['task_id'] = Variable<int>(taskId.value);
    }
    if (resourcesReady.present) {
      map['resources_ready'] = Variable<bool>(resourcesReady.value);
    }
    if (availableMinutes.present) {
      map['available_minutes'] = Variable<int>(availableMinutes.value);
    }
    if (energyMatch.present) {
      map['energy_match'] = Variable<double>(energyMatch.value);
    }
    if (goalImpact.present) {
      map['goal_impact'] = Variable<double>(goalImpact.value);
    }
    if (expiresAt.present) {
      map['expires_at'] = Variable<DateTime>(expiresAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TaskContextsCompanion(')
          ..write('taskId: $taskId, ')
          ..write('resourcesReady: $resourcesReady, ')
          ..write('availableMinutes: $availableMinutes, ')
          ..write('energyMatch: $energyMatch, ')
          ..write('goalImpact: $goalImpact, ')
          ..write('expiresAt: $expiresAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final $TagsTable tags = $TagsTable(this);
  late final $TaskDependenciesTable taskDependencies = $TaskDependenciesTable(
    this,
  );
  late final $TaskEventsTable taskEvents = $TaskEventsTable(this);
  late final $TaskContextsTable taskContexts = $TaskContextsTable(this);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tasks,
    tags,
    taskDependencies,
    taskEvents,
    taskContexts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('task_dependencies', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('task_dependencies', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('task_events', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'tasks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('task_contexts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TasksTableCreateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<int> status,
      required String title,
      Value<String?> description,
      required DateTime ddl,
      Value<DateTime?> createdAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int?> usedTime,
      Value<bool?> dependencyGraphKnown,
      Value<bool?> priorityExplicit,
      Value<int?> estHour,
      Value<int?> estMinute,
      Value<int> priority,
      Value<List<String>?> tags,
    });
typedef $$TasksTableUpdateCompanionBuilder =
    TasksCompanion Function({
      Value<int> id,
      Value<int> status,
      Value<String> title,
      Value<String?> description,
      Value<DateTime> ddl,
      Value<DateTime?> createdAt,
      Value<DateTime?> startedAt,
      Value<DateTime?> completedAt,
      Value<int?> usedTime,
      Value<bool?> dependencyGraphKnown,
      Value<bool?> priorityExplicit,
      Value<int?> estHour,
      Value<int?> estMinute,
      Value<int> priority,
      Value<List<String>?> tags,
    });

final class $$TasksTableReferences
    extends BaseReferences<_$AppDatabase, $TasksTable, Task> {
  $$TasksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TaskDependenciesTable, List<TaskDependency>>
  _outgoingDependenciesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskDependencies,
    aliasName: 'tasks__id__task_dependencies__predecessor',
  );

  $$TaskDependenciesTableProcessedTableManager get outgoingDependencies {
    final manager = $$TaskDependenciesTableTableManager(
      $_db,
      $_db.taskDependencies,
    ).filter((f) => f.predecessor.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _outgoingDependenciesTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TaskDependenciesTable, List<TaskDependency>>
  _incomingDependenciesTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskDependencies,
    aliasName: 'tasks__id__task_dependencies__successor',
  );

  $$TaskDependenciesTableProcessedTableManager get incomingDependencies {
    final manager = $$TaskDependenciesTableTableManager(
      $_db,
      $_db.taskDependencies,
    ).filter((f) => f.successor.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _incomingDependenciesTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TaskEventsTable, List<TaskEvent>>
  _taskEventsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskEvents,
    aliasName: 'tasks__id__task_events__task_id',
  );

  $$TaskEventsTableProcessedTableManager get taskEventsRefs {
    final manager = $$TaskEventsTableTableManager(
      $_db,
      $_db.taskEvents,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskEventsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TaskContextsTable, List<TaskContext>>
  _taskContextsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.taskContexts,
    aliasName: 'tasks__id__task_contexts__task_id',
  );

  $$TaskContextsTableProcessedTableManager get taskContextsRefs {
    final manager = $$TaskContextsTableTableManager(
      $_db,
      $_db.taskContexts,
    ).filter((f) => f.taskId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_taskContextsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get ddl => $composableBuilder(
    column: $table.ddl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usedTime => $composableBuilder(
    column: $table.usedTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get dependencyGraphKnown => $composableBuilder(
    column: $table.dependencyGraphKnown,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get priorityExplicit => $composableBuilder(
    column: $table.priorityExplicit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estHour => $composableBuilder(
    column: $table.estHour,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estMinute => $composableBuilder(
    column: $table.estMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<List<String>?, List<String>, String>
  get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  Expression<bool> outgoingDependencies(
    Expression<bool> Function($$TaskDependenciesTableFilterComposer f) f,
  ) {
    final $$TaskDependenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskDependencies,
      getReferencedColumn: (t) => t.predecessor,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskDependenciesTableFilterComposer(
            $db: $db,
            $table: $db.taskDependencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> incomingDependencies(
    Expression<bool> Function($$TaskDependenciesTableFilterComposer f) f,
  ) {
    final $$TaskDependenciesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskDependencies,
      getReferencedColumn: (t) => t.successor,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskDependenciesTableFilterComposer(
            $db: $db,
            $table: $db.taskDependencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskEventsRefs(
    Expression<bool> Function($$TaskEventsTableFilterComposer f) f,
  ) {
    final $$TaskEventsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskEvents,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskEventsTableFilterComposer(
            $db: $db,
            $table: $db.taskEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> taskContextsRefs(
    Expression<bool> Function($$TaskContextsTableFilterComposer f) f,
  ) {
    final $$TaskContextsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskContexts,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskContextsTableFilterComposer(
            $db: $db,
            $table: $db.taskContexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get ddl => $composableBuilder(
    column: $table.ddl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usedTime => $composableBuilder(
    column: $table.usedTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get dependencyGraphKnown => $composableBuilder(
    column: $table.dependencyGraphKnown,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get priorityExplicit => $composableBuilder(
    column: $table.priorityExplicit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estHour => $composableBuilder(
    column: $table.estHour,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estMinute => $composableBuilder(
    column: $table.estMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priority => $composableBuilder(
    column: $table.priority,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get ddl =>
      $composableBuilder(column: $table.ddl, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usedTime =>
      $composableBuilder(column: $table.usedTime, builder: (column) => column);

  GeneratedColumn<bool> get dependencyGraphKnown => $composableBuilder(
    column: $table.dependencyGraphKnown,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get priorityExplicit => $composableBuilder(
    column: $table.priorityExplicit,
    builder: (column) => column,
  );

  GeneratedColumn<int> get estHour =>
      $composableBuilder(column: $table.estHour, builder: (column) => column);

  GeneratedColumn<int> get estMinute =>
      $composableBuilder(column: $table.estMinute, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumnWithTypeConverter<List<String>?, String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  Expression<T> outgoingDependencies<T extends Object>(
    Expression<T> Function($$TaskDependenciesTableAnnotationComposer a) f,
  ) {
    final $$TaskDependenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskDependencies,
      getReferencedColumn: (t) => t.predecessor,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskDependenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.taskDependencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> incomingDependencies<T extends Object>(
    Expression<T> Function($$TaskDependenciesTableAnnotationComposer a) f,
  ) {
    final $$TaskDependenciesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskDependencies,
      getReferencedColumn: (t) => t.successor,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskDependenciesTableAnnotationComposer(
            $db: $db,
            $table: $db.taskDependencies,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskEventsRefs<T extends Object>(
    Expression<T> Function($$TaskEventsTableAnnotationComposer a) f,
  ) {
    final $$TaskEventsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskEvents,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskEventsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskEvents,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> taskContextsRefs<T extends Object>(
    Expression<T> Function($$TaskContextsTableAnnotationComposer a) f,
  ) {
    final $$TaskContextsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.taskContexts,
      getReferencedColumn: (t) => t.taskId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TaskContextsTableAnnotationComposer(
            $db: $db,
            $table: $db.taskContexts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, $$TasksTableReferences),
          Task,
          PrefetchHooks Function({
            bool outgoingDependencies,
            bool incomingDependencies,
            bool taskEventsRefs,
            bool taskContextsRefs,
          })
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> ddl = const Value.absent(),
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> usedTime = const Value.absent(),
                Value<bool?> dependencyGraphKnown = const Value.absent(),
                Value<bool?> priorityExplicit = const Value.absent(),
                Value<int?> estHour = const Value.absent(),
                Value<int?> estMinute = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<List<String>?> tags = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                status: status,
                title: title,
                description: description,
                ddl: ddl,
                createdAt: createdAt,
                startedAt: startedAt,
                completedAt: completedAt,
                usedTime: usedTime,
                dependencyGraphKnown: dependencyGraphKnown,
                priorityExplicit: priorityExplicit,
                estHour: estHour,
                estMinute: estMinute,
                priority: priority,
                tags: tags,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> status = const Value.absent(),
                required String title,
                Value<String?> description = const Value.absent(),
                required DateTime ddl,
                Value<DateTime?> createdAt = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<int?> usedTime = const Value.absent(),
                Value<bool?> dependencyGraphKnown = const Value.absent(),
                Value<bool?> priorityExplicit = const Value.absent(),
                Value<int?> estHour = const Value.absent(),
                Value<int?> estMinute = const Value.absent(),
                Value<int> priority = const Value.absent(),
                Value<List<String>?> tags = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                status: status,
                title: title,
                description: description,
                ddl: ddl,
                createdAt: createdAt,
                startedAt: startedAt,
                completedAt: completedAt,
                usedTime: usedTime,
                dependencyGraphKnown: dependencyGraphKnown,
                priorityExplicit: priorityExplicit,
                estHour: estHour,
                estMinute: estMinute,
                priority: priority,
                tags: tags,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TasksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                outgoingDependencies = false,
                incomingDependencies = false,
                taskEventsRefs = false,
                taskContextsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (outgoingDependencies) db.taskDependencies,
                    if (incomingDependencies) db.taskDependencies,
                    if (taskEventsRefs) db.taskEvents,
                    if (taskContextsRefs) db.taskContexts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (outgoingDependencies)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          TaskDependency
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._outgoingDependenciesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).outgoingDependencies,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.predecessor == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (incomingDependencies)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          TaskDependency
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._incomingDependenciesTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).incomingDependencies,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.successor == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (taskEventsRefs)
                        await $_getPrefetchedData<Task, $TasksTable, TaskEvent>(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._taskEventsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).taskEventsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (taskContextsRefs)
                        await $_getPrefetchedData<
                          Task,
                          $TasksTable,
                          TaskContext
                        >(
                          currentTable: table,
                          referencedTable: $$TasksTableReferences
                              ._taskContextsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TasksTableReferences(
                                db,
                                table,
                                p0,
                              ).taskContextsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.taskId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, $$TasksTableReferences),
      Task,
      PrefetchHooks Function({
        bool outgoingDependencies,
        bool incomingDependencies,
        bool taskEventsRefs,
        bool taskContextsRefs,
      })
    >;
typedef $$TagsTableCreateCompanionBuilder =
    TagsCompanion Function({Value<int> id, required String name});
typedef $$TagsTableUpdateCompanionBuilder =
    TagsCompanion Function({Value<int> id, Value<String> name});

class $$TagsTableFilterComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TagsTableOrderingComposer extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TagsTable> {
  $$TagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);
}

class $$TagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TagsTable,
          Tag,
          $$TagsTableFilterComposer,
          $$TagsTableOrderingComposer,
          $$TagsTableAnnotationComposer,
          $$TagsTableCreateCompanionBuilder,
          $$TagsTableUpdateCompanionBuilder,
          (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
          Tag,
          PrefetchHooks Function()
        > {
  $$TagsTableTableManager(_$AppDatabase db, $TagsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
              }) => TagsCompanion(id: id, name: name),
          createCompanionCallback:
              ({Value<int> id = const Value.absent(), required String name}) =>
                  TagsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TagsTable,
      Tag,
      $$TagsTableFilterComposer,
      $$TagsTableOrderingComposer,
      $$TagsTableAnnotationComposer,
      $$TagsTableCreateCompanionBuilder,
      $$TagsTableUpdateCompanionBuilder,
      (Tag, BaseReferences<_$AppDatabase, $TagsTable, Tag>),
      Tag,
      PrefetchHooks Function()
    >;
typedef $$TaskDependenciesTableCreateCompanionBuilder =
    TaskDependenciesCompanion Function({
      required int predecessor,
      required int successor,
      Value<int> rowid,
    });
typedef $$TaskDependenciesTableUpdateCompanionBuilder =
    TaskDependenciesCompanion Function({
      Value<int> predecessor,
      Value<int> successor,
      Value<int> rowid,
    });

final class $$TaskDependenciesTableReferences
    extends
        BaseReferences<_$AppDatabase, $TaskDependenciesTable, TaskDependency> {
  $$TaskDependenciesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TasksTable _predecessorTable(_$AppDatabase db) =>
      db.tasks.createAlias('task_dependencies__predecessor__tasks__id');

  $$TasksTableProcessedTableManager get predecessor {
    final $_column = $_itemColumn<int>('predecessor')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_predecessorTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TasksTable _successorTable(_$AppDatabase db) =>
      db.tasks.createAlias('task_dependencies__successor__tasks__id');

  $$TasksTableProcessedTableManager get successor {
    final $_column = $_itemColumn<int>('successor')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_successorTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskDependenciesTableFilterComposer
    extends Composer<_$AppDatabase, $TaskDependenciesTable> {
  $$TaskDependenciesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableFilterComposer get predecessor {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predecessor,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableFilterComposer get successor {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.successor,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskDependenciesTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskDependenciesTable> {
  $$TaskDependenciesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableOrderingComposer get predecessor {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predecessor,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableOrderingComposer get successor {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.successor,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskDependenciesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskDependenciesTable> {
  $$TaskDependenciesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$TasksTableAnnotationComposer get predecessor {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.predecessor,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TasksTableAnnotationComposer get successor {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.successor,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskDependenciesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskDependenciesTable,
          TaskDependency,
          $$TaskDependenciesTableFilterComposer,
          $$TaskDependenciesTableOrderingComposer,
          $$TaskDependenciesTableAnnotationComposer,
          $$TaskDependenciesTableCreateCompanionBuilder,
          $$TaskDependenciesTableUpdateCompanionBuilder,
          (TaskDependency, $$TaskDependenciesTableReferences),
          TaskDependency,
          PrefetchHooks Function({bool predecessor, bool successor})
        > {
  $$TaskDependenciesTableTableManager(
    _$AppDatabase db,
    $TaskDependenciesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskDependenciesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskDependenciesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskDependenciesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> predecessor = const Value.absent(),
                Value<int> successor = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TaskDependenciesCompanion(
                predecessor: predecessor,
                successor: successor,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int predecessor,
                required int successor,
                Value<int> rowid = const Value.absent(),
              }) => TaskDependenciesCompanion.insert(
                predecessor: predecessor,
                successor: successor,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskDependenciesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({predecessor = false, successor = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (predecessor) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.predecessor,
                                referencedTable:
                                    $$TaskDependenciesTableReferences
                                        ._predecessorTable(db),
                                referencedColumn:
                                    $$TaskDependenciesTableReferences
                                        ._predecessorTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (successor) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.successor,
                                referencedTable:
                                    $$TaskDependenciesTableReferences
                                        ._successorTable(db),
                                referencedColumn:
                                    $$TaskDependenciesTableReferences
                                        ._successorTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskDependenciesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskDependenciesTable,
      TaskDependency,
      $$TaskDependenciesTableFilterComposer,
      $$TaskDependenciesTableOrderingComposer,
      $$TaskDependenciesTableAnnotationComposer,
      $$TaskDependenciesTableCreateCompanionBuilder,
      $$TaskDependenciesTableUpdateCompanionBuilder,
      (TaskDependency, $$TaskDependenciesTableReferences),
      TaskDependency,
      PrefetchHooks Function({bool predecessor, bool successor})
    >;
typedef $$TaskEventsTableCreateCompanionBuilder =
    TaskEventsCompanion Function({
      Value<int> id,
      required int taskId,
      required String kind,
      Value<String?> idempotencyKey,
      required DateTime occurredAt,
      Value<int?> minutes,
      Value<int?> estimatedMinutes,
      Value<int?> priorityValue,
      Value<String?> reason,
      Value<int?> configRevision,
    });
typedef $$TaskEventsTableUpdateCompanionBuilder =
    TaskEventsCompanion Function({
      Value<int> id,
      Value<int> taskId,
      Value<String> kind,
      Value<String?> idempotencyKey,
      Value<DateTime> occurredAt,
      Value<int?> minutes,
      Value<int?> estimatedMinutes,
      Value<int?> priorityValue,
      Value<String?> reason,
      Value<int?> configRevision,
    });

final class $$TaskEventsTableReferences
    extends BaseReferences<_$AppDatabase, $TaskEventsTable, TaskEvent> {
  $$TaskEventsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('task_events__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskEventsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskEventsTable> {
  $$TaskEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priorityValue => $composableBuilder(
    column: $table.priorityValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get configRevision => $composableBuilder(
    column: $table.configRevision,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskEventsTable> {
  $$TaskEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minutes => $composableBuilder(
    column: $table.minutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priorityValue => $composableBuilder(
    column: $table.priorityValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get configRevision => $composableBuilder(
    column: $table.configRevision,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskEventsTable> {
  $$TaskEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get idempotencyKey => $composableBuilder(
    column: $table.idempotencyKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get minutes =>
      $composableBuilder(column: $table.minutes, builder: (column) => column);

  GeneratedColumn<int> get estimatedMinutes => $composableBuilder(
    column: $table.estimatedMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get priorityValue => $composableBuilder(
    column: $table.priorityValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<int> get configRevision => $composableBuilder(
    column: $table.configRevision,
    builder: (column) => column,
  );

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskEventsTable,
          TaskEvent,
          $$TaskEventsTableFilterComposer,
          $$TaskEventsTableOrderingComposer,
          $$TaskEventsTableAnnotationComposer,
          $$TaskEventsTableCreateCompanionBuilder,
          $$TaskEventsTableUpdateCompanionBuilder,
          (TaskEvent, $$TaskEventsTableReferences),
          TaskEvent,
          PrefetchHooks Function({bool taskId})
        > {
  $$TaskEventsTableTableManager(_$AppDatabase db, $TaskEventsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> taskId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String?> idempotencyKey = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<int?> minutes = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<int?> priorityValue = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int?> configRevision = const Value.absent(),
              }) => TaskEventsCompanion(
                id: id,
                taskId: taskId,
                kind: kind,
                idempotencyKey: idempotencyKey,
                occurredAt: occurredAt,
                minutes: minutes,
                estimatedMinutes: estimatedMinutes,
                priorityValue: priorityValue,
                reason: reason,
                configRevision: configRevision,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int taskId,
                required String kind,
                Value<String?> idempotencyKey = const Value.absent(),
                required DateTime occurredAt,
                Value<int?> minutes = const Value.absent(),
                Value<int?> estimatedMinutes = const Value.absent(),
                Value<int?> priorityValue = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<int?> configRevision = const Value.absent(),
              }) => TaskEventsCompanion.insert(
                id: id,
                taskId: taskId,
                kind: kind,
                idempotencyKey: idempotencyKey,
                occurredAt: occurredAt,
                minutes: minutes,
                estimatedMinutes: estimatedMinutes,
                priorityValue: priorityValue,
                reason: reason,
                configRevision: configRevision,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskEventsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$TaskEventsTableReferences
                                    ._taskIdTable(db),
                                referencedColumn: $$TaskEventsTableReferences
                                    ._taskIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskEventsTable,
      TaskEvent,
      $$TaskEventsTableFilterComposer,
      $$TaskEventsTableOrderingComposer,
      $$TaskEventsTableAnnotationComposer,
      $$TaskEventsTableCreateCompanionBuilder,
      $$TaskEventsTableUpdateCompanionBuilder,
      (TaskEvent, $$TaskEventsTableReferences),
      TaskEvent,
      PrefetchHooks Function({bool taskId})
    >;
typedef $$TaskContextsTableCreateCompanionBuilder =
    TaskContextsCompanion Function({
      Value<int> taskId,
      Value<bool?> resourcesReady,
      Value<int?> availableMinutes,
      Value<double?> energyMatch,
      Value<double?> goalImpact,
      required DateTime expiresAt,
    });
typedef $$TaskContextsTableUpdateCompanionBuilder =
    TaskContextsCompanion Function({
      Value<int> taskId,
      Value<bool?> resourcesReady,
      Value<int?> availableMinutes,
      Value<double?> energyMatch,
      Value<double?> goalImpact,
      Value<DateTime> expiresAt,
    });

final class $$TaskContextsTableReferences
    extends BaseReferences<_$AppDatabase, $TaskContextsTable, TaskContext> {
  $$TaskContextsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TasksTable _taskIdTable(_$AppDatabase db) =>
      db.tasks.createAlias('task_contexts__task_id__tasks__id');

  $$TasksTableProcessedTableManager get taskId {
    final $_column = $_itemColumn<int>('task_id')!;

    final manager = $$TasksTableTableManager(
      $_db,
      $_db.tasks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_taskIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TaskContextsTableFilterComposer
    extends Composer<_$AppDatabase, $TaskContextsTable> {
  $$TaskContextsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get resourcesReady => $composableBuilder(
    column: $table.resourcesReady,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get availableMinutes => $composableBuilder(
    column: $table.availableMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get energyMatch => $composableBuilder(
    column: $table.energyMatch,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get goalImpact => $composableBuilder(
    column: $table.goalImpact,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnFilters(column),
  );

  $$TasksTableFilterComposer get taskId {
    final $$TasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableFilterComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskContextsTableOrderingComposer
    extends Composer<_$AppDatabase, $TaskContextsTable> {
  $$TaskContextsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get resourcesReady => $composableBuilder(
    column: $table.resourcesReady,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get availableMinutes => $composableBuilder(
    column: $table.availableMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get energyMatch => $composableBuilder(
    column: $table.energyMatch,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get goalImpact => $composableBuilder(
    column: $table.goalImpact,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get expiresAt => $composableBuilder(
    column: $table.expiresAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$TasksTableOrderingComposer get taskId {
    final $$TasksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableOrderingComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskContextsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TaskContextsTable> {
  $$TaskContextsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get resourcesReady => $composableBuilder(
    column: $table.resourcesReady,
    builder: (column) => column,
  );

  GeneratedColumn<int> get availableMinutes => $composableBuilder(
    column: $table.availableMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<double> get energyMatch => $composableBuilder(
    column: $table.energyMatch,
    builder: (column) => column,
  );

  GeneratedColumn<double> get goalImpact => $composableBuilder(
    column: $table.goalImpact,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get expiresAt =>
      $composableBuilder(column: $table.expiresAt, builder: (column) => column);

  $$TasksTableAnnotationComposer get taskId {
    final $$TasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.taskId,
      referencedTable: $db.tasks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TasksTableAnnotationComposer(
            $db: $db,
            $table: $db.tasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TaskContextsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TaskContextsTable,
          TaskContext,
          $$TaskContextsTableFilterComposer,
          $$TaskContextsTableOrderingComposer,
          $$TaskContextsTableAnnotationComposer,
          $$TaskContextsTableCreateCompanionBuilder,
          $$TaskContextsTableUpdateCompanionBuilder,
          (TaskContext, $$TaskContextsTableReferences),
          TaskContext,
          PrefetchHooks Function({bool taskId})
        > {
  $$TaskContextsTableTableManager(_$AppDatabase db, $TaskContextsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TaskContextsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TaskContextsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TaskContextsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> taskId = const Value.absent(),
                Value<bool?> resourcesReady = const Value.absent(),
                Value<int?> availableMinutes = const Value.absent(),
                Value<double?> energyMatch = const Value.absent(),
                Value<double?> goalImpact = const Value.absent(),
                Value<DateTime> expiresAt = const Value.absent(),
              }) => TaskContextsCompanion(
                taskId: taskId,
                resourcesReady: resourcesReady,
                availableMinutes: availableMinutes,
                energyMatch: energyMatch,
                goalImpact: goalImpact,
                expiresAt: expiresAt,
              ),
          createCompanionCallback:
              ({
                Value<int> taskId = const Value.absent(),
                Value<bool?> resourcesReady = const Value.absent(),
                Value<int?> availableMinutes = const Value.absent(),
                Value<double?> energyMatch = const Value.absent(),
                Value<double?> goalImpact = const Value.absent(),
                required DateTime expiresAt,
              }) => TaskContextsCompanion.insert(
                taskId: taskId,
                resourcesReady: resourcesReady,
                availableMinutes: availableMinutes,
                energyMatch: energyMatch,
                goalImpact: goalImpact,
                expiresAt: expiresAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TaskContextsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({taskId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (taskId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.taskId,
                                referencedTable: $$TaskContextsTableReferences
                                    ._taskIdTable(db),
                                referencedColumn: $$TaskContextsTableReferences
                                    ._taskIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TaskContextsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TaskContextsTable,
      TaskContext,
      $$TaskContextsTableFilterComposer,
      $$TaskContextsTableOrderingComposer,
      $$TaskContextsTableAnnotationComposer,
      $$TaskContextsTableCreateCompanionBuilder,
      $$TaskContextsTableUpdateCompanionBuilder,
      (TaskContext, $$TaskContextsTableReferences),
      TaskContext,
      PrefetchHooks Function({bool taskId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$TagsTableTableManager get tags => $$TagsTableTableManager(_db, _db.tags);
  $$TaskDependenciesTableTableManager get taskDependencies =>
      $$TaskDependenciesTableTableManager(_db, _db.taskDependencies);
  $$TaskEventsTableTableManager get taskEvents =>
      $$TaskEventsTableTableManager(_db, _db.taskEvents);
  $$TaskContextsTableTableManager get taskContexts =>
      $$TaskContextsTableTableManager(_db, _db.taskContexts);
}

mixin _$TaskDaoMixin on DatabaseAccessor<AppDatabase> {
  $TasksTable get tasks => attachedDatabase.tasks;
  $TagsTable get tags => attachedDatabase.tags;
  $TaskDependenciesTable get taskDependencies =>
      attachedDatabase.taskDependencies;
  $TaskEventsTable get taskEvents => attachedDatabase.taskEvents;
  $TaskContextsTable get taskContexts => attachedDatabase.taskContexts;
  TaskDaoManager get managers => TaskDaoManager(this);
}

class TaskDaoManager {
  final _$TaskDaoMixin _db;
  TaskDaoManager(this._db);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db.attachedDatabase, _db.tasks);
  $$TagsTableTableManager get tags =>
      $$TagsTableTableManager(_db.attachedDatabase, _db.tags);
  $$TaskDependenciesTableTableManager get taskDependencies =>
      $$TaskDependenciesTableTableManager(
        _db.attachedDatabase,
        _db.taskDependencies,
      );
  $$TaskEventsTableTableManager get taskEvents =>
      $$TaskEventsTableTableManager(_db.attachedDatabase, _db.taskEvents);
  $$TaskContextsTableTableManager get taskContexts =>
      $$TaskContextsTableTableManager(_db.attachedDatabase, _db.taskContexts);
}
