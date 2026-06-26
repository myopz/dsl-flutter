/// 格式化检查器 - 检测DSL文件是否被自动格式化破坏
class FormatterChecker {
  List<String> check(String content) {
    final issues = <String>[];
    final lines = content.split('\n');

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      // 跳过空行
      if (trimmed.isEmpty) continue;

      // 1. 检测多余的括号（Widget创建带了括号）
      if (_isWidgetCreation(trimmed) && _hasRedundantParens(trimmed)) {
        issues.add('第 ${i + 1} 行: Widget "${_getWidgetName(trimmed)}" 带了多余的括号');
      }

      // 2. 检测缩进异常（可能是格式化导致）
      // 检查当前行和上一行（跳过空行）
      if (i > 0) {
        final prevLine = _findPreviousNonEmptyLine(lines, i);
        if (prevLine != null && _hasIndentIssue(prevLine, line)) {
          issues.add('第 ${i + 1} 行: 缩进可能被破坏');
        }
      }

      // 3. 检测行尾多余空格（格式化常见问题）
      if (line != line.trimRight()) {
        issues.add('第 ${i + 1} 行: 行尾有多余空格');
      }
    }

    return issues;
  }

  /// 查找前一个非空行
  String? _findPreviousNonEmptyLine(List<String> lines, int currentIndex) {
    for (var i = currentIndex - 1; i >= 0; i--) {
      if (lines[i].trim().isNotEmpty) {
        return lines[i];
      }
    }
    return null;
  }

  bool _isWidgetCreation(String line) {
    final widgets = [
      'Text',
      'Image',
      'Icon',
      'Button',
      'Card',
      'Container',
      'Row',
      'Column',
      'Stack',
      'ListView',
      'GridView',
      'Scaffold',
      'AppBar',
      'FloatingActionButton',
      'ElevatedButton',
      'TextButton',
      'OutlinedButton',
      'SizedBox',
      'Padding',
      'Center',
      'Align',
      'Expanded',
    ];
    final name = line.split(' ').first;
    return widgets.contains(name);
  }

  bool _hasRedundantParens(String line) {
    // 检测 Text('Hello') 这种格式
    // 但排除方法调用
    if (_isMethodCall(line)) return false;
    return RegExp(
      r'\b(Text|Icon|Image|Card|Container)\s*\([^)]*\)',
    ).hasMatch(line);
  }

  bool _isMethodCall(String line) {
    final methods = [
      'setState',
      'Theme.of',
      'MediaQuery.of',
      'Navigator.of',
      'print',
      'debugPrint',
      'showDialog',
      'showModalBottomSheet',
      'EdgeInsets',
      'BorderRadius',
      'BoxDecoration',
      'TextStyle',
    ];
    return methods.any((m) => line.contains(m));
  }

  String _getWidgetName(String line) {
    return line.split(' ').first;
  }

  bool _hasIndentIssue(String prevLine, String currLine) {
    // 检测缩进是否被破坏
    final prevIndent = prevLine.length - prevLine.trimLeft().length;
    final currIndent = currLine.length - currLine.trimLeft().length;

    // 如果缩进不是2的倍数，可能被格式化破坏了
    if (currIndent % 2 != 0) return true;

    // 如果缩进变化超过4，可能有问题
    if ((currIndent - prevIndent).abs() > 4) {
      // 但如果是 children: [ 这种特殊语法，允许大的缩进变化
      final trimmed = currLine.trim();
      if (trimmed.startsWith('children:') ||
          trimmed == 'children' ||
          trimmed == '[') {
        return false;
      }
      return true;
    }

    return false;
  }
}
