/// 格式化检查器 - 检测DSL文件是否被自动格式化破坏
class FormatterChecker {
  static const List<String> _widgets = [
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

  /// 行首 Widget 调用带括号：`Text('x')` / `child: Text('x')`
  /// 使用 `\b` 避免把 `TextStyle` 误判为 `Text`
  static final RegExp _redundantParenPattern = RegExp(
    '^(?:\\w+:\\s*)?(${_widgets.join('|')})\\b\\s*\\(',
  );

  List<String> check(String content) {
    final issues = <String>[];
    final lines = content.split('\n');
    var inTripleQuoted = false;
    String? tripleQuoteDelimiter;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      final trimmed = line.trim();

      // 跟踪 ''' / """ 区域（@Fragment body 内是标准 Dart）
      final quoteTransition = _updateTripleQuoteState(
        trimmed,
        inTripleQuoted,
        tripleQuoteDelimiter,
      );
      final wasInTripleQuoted = inTripleQuoted;
      inTripleQuoted = quoteTransition.inTripleQuoted;
      tripleQuoteDelimiter = quoteTransition.delimiter;

      // 跳过空行
      if (trimmed.isEmpty) continue;

      // Fragment body（含起止行上的三引号内容）按标准 Dart 处理，不做 DSL 启发式
      if (wasInTripleQuoted || inTripleQuoted) {
        // 仍检测行尾空格（与 DSL 区域一致）
        if (line != line.trimRight()) {
          issues.add('第 ${i + 1} 行: 行尾有多余空格');
        }
        continue;
      }

      // 1. 检测多余的括号（Widget 创建带了括号）
      final widgetName = _findRedundantParenWidget(trimmed);
      if (widgetName != null) {
        issues.add('第 ${i + 1} 行: Widget "$widgetName" 带了多余的括号');
      }

      // 2. 检测缩进异常（仅奇数缩进 / 非 2 倍数）
      if (_hasIndentIssue(line)) {
        issues.add('第 ${i + 1} 行: 缩进可能被破坏');
      }

      // 3. 检测行尾多余空格（格式化常见问题）
      if (line != line.trimRight()) {
        issues.add('第 ${i + 1} 行: 行尾有多余空格');
      }
    }

    return issues;
  }

  /// 更新三引号字符串状态；返回更新后的状态
  ({bool inTripleQuoted, String? delimiter}) _updateTripleQuoteState(
    String trimmed,
    bool inTripleQuoted,
    String? delimiter,
  ) {
    if (!inTripleQuoted) {
      // 进入：行内出现未闭合的 ''' 或 """
      final single = "'''";
      final double = '"""';
      final singleIdx = trimmed.indexOf(single);
      final doubleIdx = trimmed.indexOf(double);

      if (singleIdx < 0 && doubleIdx < 0) {
        return (inTripleQuoted: false, delimiter: null);
      }

      // 取先出现的分隔符
      final useSingle =
          doubleIdx < 0 || (singleIdx >= 0 && singleIdx < doubleIdx);
      final delim = useSingle ? single : double;
      final start = useSingle ? singleIdx : doubleIdx;
      final after = trimmed.substring(start + 3);
      // 同一行内又闭合则仍在 DSL 区
      if (after.contains(delim)) {
        return (inTripleQuoted: false, delimiter: null);
      }
      return (inTripleQuoted: true, delimiter: delim);
    }

    // 退出：找到匹配的结束分隔符
    if (delimiter != null && trimmed.contains(delimiter)) {
      return (inTripleQuoted: false, delimiter: null);
    }
    return (inTripleQuoted: true, delimiter: delimiter);
  }

  /// 若行首（或 `prop:` 后）是带括号的 Widget 创建，返回 Widget 名；否则 null
  String? _findRedundantParenWidget(String line) {
    if (_isMethodCall(line)) return null;
    final match = _redundantParenPattern.firstMatch(line);
    return match?.group(1);
  }

  bool _isMethodCall(String line) {
    const methods = [
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
      'SnackBar',
      'NetworkImage',
    ];
    return methods.any((m) => line.contains(m));
  }

  /// 缩进不是 2 的倍数时视为被破坏（嵌套闭合的大幅回落是合法的）
  bool _hasIndentIssue(String currLine) {
    final currIndent = currLine.length - currLine.trimLeft().length;
    if (currIndent == 0) return false;
    return currIndent % 2 != 0;
  }
}
