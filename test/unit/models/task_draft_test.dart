import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:janus/models/task.dart';

void main() {
  group('TaskDraft', () {
    test('default values', () {
      const draft = TaskDraft();

      expect(draft.title, isEmpty);
      expect(draft.description, isNull);
      expect(draft.ddl, isNull);
      expect(draft.est, isNull);
      expect(draft.priority, 0);
      expect(draft.tags, isEmpty);
    });

    test('copyWith overrides a single field', () {
      const draft = TaskDraft();

      final updated = draft.copyWith(title: '买牛奶');

      expect(updated.title, '买牛奶');
      expect(updated.description, isNull);
      expect(updated.priority, 0);
      expect(updated.tags, isEmpty);
    });

    test('copyWith overrides multiple fields', () {
      final updated = const TaskDraft().copyWith(
        title: '写周报',
        description: '汇总本周进展',
        ddl: DateTime(2026, 8, 20),
        est: const TimeOfDay(hour: 2, minute: 30),
        priority: 3,
        tags: const ['工作', '文档'],
      );

      expect(updated.title, '写周报');
      expect(updated.description, '汇总本周进展');
      expect(updated.ddl, DateTime(2026, 8, 20));
      expect(updated.est, const TimeOfDay(hour: 2, minute: 30));
      expect(updated.priority, 3);
      expect(updated.tags, ['工作', '文档']);
    });

    test('copyWith with nulls keeps existing values', () {
      const draft = TaskDraft(title: '原始标题', description: '原始描述', tags: ['a']);

      // 传 null 的字段应保持原值，不覆盖为 null
      final updated = draft.copyWith(title: '新标题');

      expect(updated.title, '新标题');
      expect(updated.description, '原始描述');
      expect(updated.tags, ['a']);
    });

    test('tags list is not shared between instances after copyWith', () {
      const draft = TaskDraft(tags: ['a']);

      final updated = draft.copyWith(tags: ['a', 'b']);

      expect(updated.tags, ['a', 'b']);
      expect(draft.tags, ['a']);
    });
  });
}
