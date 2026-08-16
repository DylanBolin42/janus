// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task_draft_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(TaskDraftNotifier)
final taskDraftProvider = TaskDraftNotifierProvider._();

final class TaskDraftNotifierProvider
    extends $NotifierProvider<TaskDraftNotifier, TaskDraft> {
  TaskDraftNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'taskDraftProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$taskDraftNotifierHash();

  @$internal
  @override
  TaskDraftNotifier create() => TaskDraftNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TaskDraft value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TaskDraft>(value),
    );
  }
}

String _$taskDraftNotifierHash() => r'480a3559af4bb8213c482e554612b7d4cd6234dd';

abstract class _$TaskDraftNotifier extends $Notifier<TaskDraft> {
  TaskDraft build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<TaskDraft, TaskDraft>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<TaskDraft, TaskDraft>,
              TaskDraft,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
