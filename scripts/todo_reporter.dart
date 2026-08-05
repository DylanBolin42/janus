// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

class TodoItem {
  final int lineNumber;
  final String content;

  TodoItem(this.lineNumber, this.content);
}

void main() async {
  final projectDir = Directory.current;
  final fileTodos = <String, List<TodoItem>>{};
  int totalTodos = 0;

  final ignoredSegments = {
    '.git',
    '.github',
    '.dart_tool',
    'build',
    'ios/Pods',
    'Pods',
    '.symlinks',
    'ephemeral',
    'node_modules',
  };

  final supportedExtensions = {
    '.dart',
    '.yaml',
    '.yml',
    '.gradle',
    '.properties',
    '.kt',
    '.java',
    '.swift',
    '.h',
    '.m',
    '.cpp',
    '.js',
    '.ts',
    '.css',
    '.html',
    '.sh',
  };

  await for (final entity in projectDir.list(
    recursive: true,
    followLinks: false,
  )) {
    if (entity is! File) continue;

    final path = entity.path;
    // Check if path is in ignored segments
    final pathSegments = path.split(Platform.pathSeparator);
    bool shouldIgnore = false;
    for (final segment in pathSegments) {
      if (ignoredSegments.contains(segment) || segment.startsWith('.')) {
        shouldIgnore = true;
        break;
      }
    }
    if (shouldIgnore) continue;

    final extIndex = path.lastIndexOf('.');
    if (extIndex == -1) continue;
    final ext = path.substring(extIndex).toLowerCase();
    if (!supportedExtensions.contains(ext)) continue;

    try {
      final bytes = await entity.readAsBytes();
      final content = utf8.decode(bytes, allowMalformed: true);
      final lines = content.split(RegExp(r'\r?\n'));

      final list = <TodoItem>[];
      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        if (hasTodo(line, ext)) {
          list.add(TodoItem(i + 1, line.trim()));
        }
      }

      if (list.isNotEmpty) {
        // Use relative path for cleaner output
        final relativePath = path.startsWith(projectDir.path)
            ? path
                  .substring(projectDir.path.length)
                  .replaceFirst(
                    RegExp('^${RegExp.escape(Platform.pathSeparator)}'),
                    '',
                  )
            : path;
        fileTodos[relativePath] = list;
        totalTodos += list.length;
      }
    } catch (e) {
      stderr.writeln('Error reading file $path: $e');
    }
  }

  // Generate report
  final sb = StringBuffer();
  sb.writeln('### 📊 TODO Summary Report\n');
  sb.writeln('**Total TODOs found: $totalTodos**\n');

  if (totalTodos > 0) {
    sb.writeln('<details>');
    sb.writeln(
      '<summary><b>📋 Click to expand TODO Details ($totalTodos)</b></summary>\n',
    );

    sb.writeln('#### 📂 Files with TODOs:\n');
    sb.writeln('| File Path | TODO Count |');
    sb.writeln('| :--- | :--- |');
    final sortedFiles = fileTodos.keys.toList()..sort();
    for (final file in sortedFiles) {
      sb.writeln('| `$file` | ${fileTodos[file]!.length} |');
    }
    sb.writeln('\n---\n');
    sb.writeln('### 🔍 Details:\n');

    for (final file in sortedFiles) {
      final todos = fileTodos[file]!;
      sb.writeln('<details>');
      sb.writeln('<summary><b>$file (${todos.length})</b></summary>\n');
      sb.writeln('| Line | Content |');
      sb.writeln('| :--- | :--- |');
      for (final todo in todos) {
        // Clean comment characters and escape markdown pipe
        final displayContent = todo.content
            .replaceAll('|', '\\|')
            .replaceAll('<', '&lt;')
            .replaceAll('>', '&gt;');
        sb.writeln('| `${todo.lineNumber}` | $displayContent |');
      }
      sb.writeln('\n</details>\n');
    }

    sb.writeln('</details>\n');
  } else {
    sb.writeln('🎉 No TODOs found!');
  }

  final report = sb.toString();

  // Print report to standard output
  print(report);

  // Write the report to a local file
  try {
    final reportFile = File('todo_report.md');
    await reportFile.writeAsString(report);
    print('Successfully wrote TODO report to ${reportFile.path}');
  } catch (e) {
    stderr.writeln('Error writing report file: $e');
  }

  // If in GITHUB_ACTIONS, write to GITHUB_STEP_SUMMARY
  final stepSummaryPath = Platform.environment['GITHUB_STEP_SUMMARY'];
  if (stepSummaryPath != null && stepSummaryPath.isNotEmpty) {
    final file = File(stepSummaryPath);
    await file.writeAsString(report, mode: FileMode.append);
    print(
      'Successfully appended summary to GITHUB_STEP_SUMMARY at $stepSummaryPath',
    );
  }
}

bool hasTodo(String line, String ext) {
  final trimmed = line.trim();
  final todoRegex = RegExp(r'\bTODO\b', caseSensitive: true);

  if (ext == '.dart' ||
      ext == '.kt' ||
      ext == '.java' ||
      ext == '.swift' ||
      ext == '.cpp' ||
      ext == '.js' ||
      ext == '.ts') {
    final doubleSlash = trimmed.indexOf('//');
    if (doubleSlash != -1) {
      return todoRegex.hasMatch(trimmed.substring(doubleSlash));
    }
    if (trimmed.startsWith('/*') || trimmed.startsWith('*')) {
      return todoRegex.hasMatch(trimmed);
    }
  } else if (ext == '.yaml' ||
      ext == '.yml' ||
      ext == '.sh' ||
      ext == '.properties' ||
      ext == '.gradle') {
    final hashIndex = trimmed.indexOf('#');
    if (hashIndex != -1) {
      return todoRegex.hasMatch(trimmed.substring(hashIndex));
    }
  } else {
    return todoRegex.hasMatch(trimmed);
  }
  return false;
}
