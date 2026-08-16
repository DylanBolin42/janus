import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/models/task.dart';
import 'package:janus/providers/task_draft_provider.dart';

void main() {
  /// 创建并注册好销毁钩子的容器。
  ProviderContainer createContainer() {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    return container;
  }

  group('TaskDraftNotifier', () {
    test('build returns an empty draft', () {
      final container = createContainer();

      final draft = container.read(taskDraftProvider);

      expect(draft, const TaskDraft());
      expect(draft.title, isEmpty);
      expect(draft.tags, isEmpty);
      expect(draft.priority, 0);
    });

    test('setTitle updates the title', () {
      final container = createContainer();

      container.read(taskDraftProvider.notifier).setTitle('买牛奶');

      expect(container.read(taskDraftProvider).title, '买牛奶');
    });

    test('setDescription updates the description', () {
      final container = createContainer();

      container.read(taskDraftProvider.notifier).setDescription('回家路上带瓶牛奶');

      expect(container.read(taskDraftProvider).description, '回家路上带瓶牛奶');
    });

    test('setDdl updates the ddl', () {
      final container = createContainer();

      container
          .read(taskDraftProvider.notifier)
          .setDdl(DateTime(2026, 8, 18, 20, 0));

      expect(container.read(taskDraftProvider).ddl, DateTime(2026, 8, 18, 20));
    });

    test('setEst updates the estimated time', () {
      final container = createContainer();

      container
          .read(taskDraftProvider.notifier)
          .setEst(const TimeOfDay(hour: 1, minute: 15));

      expect(
        container.read(taskDraftProvider).est,
        const TimeOfDay(hour: 1, minute: 15),
      );
    });

    test('setPriority updates the priority', () {
      final container = createContainer();

      container.read(taskDraftProvider.notifier).setPriority(2);

      expect(container.read(taskDraftProvider).priority, 2);
    });

    test('setTags updates the tags', () {
      final container = createContainer();

      container.read(taskDraftProvider.notifier).setTags(const ['工作', '个人']);

      expect(container.read(taskDraftProvider).tags, ['工作', '个人']);
    });

    test('mutations accumulate on the same draft', () {
      final container = createContainer();

      final notifier = container.read(taskDraftProvider.notifier);
      notifier.setTitle('写周报');
      notifier.setDescription('汇总本周进展');
      notifier.setPriority(3);

      final draft = container.read(taskDraftProvider);
      expect(draft.title, '写周报');
      expect(draft.description, '汇总本周进展');
      expect(draft.priority, 3);
    });

    test('reset clears the draft back to defaults', () {
      final container = createContainer();

      final notifier = container.read(taskDraftProvider.notifier);
      notifier.setTitle('写周报');
      notifier.setTags(const ['工作']);
      expect(container.read(taskDraftProvider).title, '写周报');

      notifier.reset();

      expect(container.read(taskDraftProvider), const TaskDraft());
    });
  });
}
