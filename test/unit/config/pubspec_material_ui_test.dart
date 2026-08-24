// 回归测试：验证 material_ui 依赖版本从 1.0.0 升级到 1.0.1 后，
// pubspec.yaml 的版本约束与 pubspec.lock 的解析结果保持一致，
// 避免出现 lock 文件未同步更新、或误回退到旧版本/旧哈希的问题。
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late String pubspecYamlContent;
  late String pubspecLockContent;

  setUpAll(() {
    pubspecYamlContent = File('pubspec.yaml').readAsStringSync();
    pubspecLockContent = File('pubspec.lock').readAsStringSync();
  });

  group('pubspec.yaml material_ui dependency', () {
    final constraintPattern = RegExp(
      r'^\s*material_ui:\s*(\S+)\s*$',
      multiLine: true,
    );

    test('declares a single material_ui dependency entry', () {
      final matches = constraintPattern.allMatches(pubspecYamlContent);
      expect(
        matches.length,
        1,
        reason: 'Expected exactly one material_ui dependency declaration',
      );
    });

    test('pins material_ui to the ^1.0.1 constraint', () {
      final match = constraintPattern.firstMatch(pubspecYamlContent);
      expect(match, isNotNull);
      expect(match!.group(1), '^1.0.1');
    });

    test('no longer uses the previous ^1.0.0 constraint', () {
      final match = constraintPattern.firstMatch(pubspecYamlContent);
      expect(match, isNotNull);
      expect(match!.group(1), isNot('^1.0.0'));
    });
  });

  group('pubspec.lock material_ui entry', () {
    // pub 生成的 lock 文件针对每个 hosted 包都遵循固定的缩进/字段顺序，
    // 用该结构化正则一次性提取 material_ui 条目的所有字段。
    final entryPattern = RegExp(
      r'  material_ui:\s*\n'
      r'\s*dependency:\s*"([^"]+)"\s*\n'
      r'\s*description:\s*\n'
      r'\s*name:\s*material_ui\s*\n'
      r'\s*sha256:\s*"?([0-9a-fA-F]+)"?\s*\n'
      r'\s*url:\s*"([^"]+)"\s*\n'
      r'\s*source:\s*(\S+)\s*\n'
      r'\s*version:\s*"([^"]+)"',
    );

    RegExpMatch matchEntry() {
      final match = entryPattern.firstMatch(pubspecLockContent);
      expect(
        match,
        isNotNull,
        reason:
            'Could not find a well-formed material_ui entry in pubspec.lock',
      );
      return match!;
    }

    test('resolves material_ui to version 1.0.1', () {
      final match = matchEntry();
      expect(match.group(5), '1.0.1');
    });

    test('records the expected sha256 checksum for the 1.0.1 release', () {
      final match = matchEntry();
      expect(
        match.group(2),
        '4f3f38b9953df0a87d6bf5f21880029f77c47048487d5339410c39936be4683b',
      );
    });

    test('sha256 checksum differs from the previous 1.0.0 release', () {
      final match = matchEntry();
      expect(
        match.group(2),
        isNot(
          'd9b4f6c69b80bc83d0a14357c86e4c14c8076e807ae73cf2960c8560f623995f',
        ),
      );
    });

    test('is sourced from the hosted pub.dartlang.org registry', () {
      final match = matchEntry();
      expect(match.group(3), 'https://pub.dartlang.org');
      expect(match.group(4), 'hosted');
    });

    test('remains a direct main dependency', () {
      final match = matchEntry();
      expect(match.group(1), 'direct main');
    });
  });

  group('pubspec.yaml and pubspec.lock consistency', () {
    test(
      'locked material_ui version satisfies the ^1.0.1 caret constraint',
      () {
        final yamlMatch = RegExp(
          r'^\s*material_ui:\s*\^([\d.]+)\s*$',
          multiLine: true,
        ).firstMatch(pubspecYamlContent);
        final lockMatch = RegExp(
          r'  material_ui:[\s\S]*?version:\s*"([\d.]+)"',
        ).firstMatch(pubspecLockContent);

        expect(yamlMatch, isNotNull);
        expect(lockMatch, isNotNull);

        final constraintParts = yamlMatch!.group(1)!
            .split('.')
            .map(int.parse)
            .toList();
        final lockedParts = lockMatch!.group(1)!
            .split('.')
            .map(int.parse)
            .toList();

        // Caret syntax ^1.0.1 allows >=1.0.1 <2.0.0.
        expect(lockedParts[0], constraintParts[0]);
        final lockedGteConstraint =
            lockedParts[1] > constraintParts[1] ||
            (lockedParts[1] == constraintParts[1] &&
                lockedParts[2] >= constraintParts[2]);
        expect(
          lockedGteConstraint,
          isTrue,
          reason:
              'Locked version $lockedParts must be '
              '>= constraint $constraintParts',
        );
      },
    );
  });
}