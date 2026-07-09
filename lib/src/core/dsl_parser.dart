// lib/src/core/dsl_parser.dart

import 'package:ansicolor/ansicolor.dart';

/// 片段定义
class FragmentDefinition {
  final String name;
  final List<String> params;
  final String body;

  FragmentDefinition({
    required this.name,
    required this.params,
    required this.body,
  });
}

/// 纯正无括号DSL解析器
class DSLParser {
  static const int indentUnit = 2;
  static const String fragmentPrefix = '@';
  static bool _hasWarned = false;

  final _yellow = AnsiPen()..yellow;
  final _green = AnsiPen()..green;
  final _cyan = AnsiPen()..cyan;

  // 内置Widget列表
  static const List<String> builtInWidgets = [
    'Text', 'Image', 'Icon', 'Button', 'Card', 'Container',
    'Row', 'Column', 'Stack', 'ListView', 'GridView',
    'Scaffold', 'AppBar', 'FloatingActionButton',
    'ElevatedButton', 'TextButton', 'OutlinedButton',
    'SizedBox', 'Padding', 'Center', 'Align', 'Expanded',
    'CircleAvatar', 'Chip', 'Divider', 'Spacer',
    'Wrap', 'Flow', 'CustomScrollView', 'SliverList',
    'SliverGrid', 'TabBar', 'TabBarView', 'BottomNavigationBar',
    'Drawer', 'PopupMenuButton', 'DropdownButton',
    'Switch', 'Checkbox', 'Radio', 'Slider',
    'TextField', 'Form', 'GestureDetector', 'InkWell',
  ];

  // 片段定义缓存
  final Map<String, FragmentDefinition> _fragments = {};

  /// 解析DSL源代码，转换为标准Dart代码
  String parse(String source) {
    // 智能检测：检查是否被格式化破坏
    _checkFormatting(source);

    // 1. 提取片段定义
    _extractFragments(source);

    // 2. 提取注解并从源码中移除（注解定义不保留在输出中）
    final annotations = _extractAnnotations(source);
    final cleanSource = _removeAnnotationLines(source);

    // 3. 预处理续行
    final preprocessed = _preprocessLines(cleanSource);

    // 4. 转换缩进为括号
    final transformed = _transformIndents(preprocessed);

    // 5. 应用注解配置（别名替换、默认参数注入、Mixin、片段展开）
    //    注解应用完成后即被消费，不会出现在输出中
    return _applyAnnotations(transformed, annotations);
  }

  /// 智能检测：检查是否被格式化破坏
  void _checkFormatting(String source) {
    if (_hasWarned) return;

    final lines = source.split('\n');
    var hasIssue = false;
    var issueLine = -1;
    var issueDetail = '';

    for (var i = 0; i < lines.length && i < 20; i++) {
      final line = lines[i].trim();
      if (line.isEmpty) continue;

      // 检测 Text('Hello') 这种格式（说明被格式化破坏）
      if (RegExp(r'\b(Text|Icon|Image|Card|Container)\s*\([^)]*\)').hasMatch(line)) {
        // 排除方法调用
        if (!_isMethodCall(line)) {
          hasIssue = true;
          issueLine = i + 1;
          issueDetail = 'Widget "${_getWidgetName(line)}" 带了多余的括号';
          break;
        }
      }

      // 检测缩进是不是2的倍数
      final indent = lines[i].length - lines[i].trimLeft().length;
      if (indent > 0 && indent % 2 != 0) {
        hasIssue = true;
        issueLine = i + 1;
        issueDetail = '缩进 ${indent} 个空格，应该是 2 的倍数';
        break;
      }
    }

    if (hasIssue) {
      print('''
${_yellow('⚠️  检测到 DSL 文件可能被格式化工具破坏了！')}

第 $issueLine 行: $issueDetail

这通常是因为 VS Code 自动格式化了 .dui 文件。

${_yellow('解决方案:')}
1. 运行修复: ${_yellow('dsl_flutter setup')}
2. 重新加载 VS Code: Cmd+Shift+P -> "Reload Window"
3. 或者手动禁用 .dui 文件的自动格式化

${_yellow('继续转换... (但可能需要手动修复)')}
''');
      _hasWarned = true;
    }
  }

  bool _isMethodCall(String line) {
    final methods = [
      'setState', 'Theme.of', 'MediaQuery.of', 'Navigator.of',
      'print', 'debugPrint', 'showDialog', 'showModalBottomSheet',
    ];
    return methods.any((m) => line.contains(m));
  }

  String _getWidgetName(String line) {
    return line.split(' ').first;
  }

  /// 提取片段定义
  void _extractFragments(String source) {
    _fragments.clear();

    // 匹配 @Fragment('Name', ['param1', 'param2'], '''body''')
    // body 可以是三引号 '''...''' 或单引号 '...' 或双引号 "..."
    final fragmentRegex = RegExp(
        r"""@Fragment\(['"]([^'"]+)['"],\s*\[([^\]]*)\],\s*(?:'''([\s\S]*?)'''|'([^']*)'|"([^"]*)")\)""");
    for (final match in fragmentRegex.allMatches(source)) {
      final name = match.group(1)!;
      final paramsStr = match.group(2)!;
      // body 在 group 3 (三引号) / group 4 (单引号) / group 5 (双引号)
      final body = match.group(3) ?? match.group(4) ?? match.group(5) ?? '';

      final params = paramsStr.split(',').map((p) {
        var trimmed = p.trim();
        // 去掉引号
        if ((trimmed.startsWith("'") && trimmed.endsWith("'")) ||
            (trimmed.startsWith('"') && trimmed.endsWith('"'))) {
          trimmed = trimmed.substring(1, trimmed.length - 1);
        }
        return trimmed;
      }).where((p) => p.isNotEmpty).toList();

      // 检测与内置Widget冲突
      if (builtInWidgets.contains(name)) {
        print('''
${_yellow('⚠️  片段名称冲突检测')}

片段名称: "$name" 与 Flutter 内置组件 "${name}" 冲突！

位置: 第 ${_getLineNumber(source, match.start)} 行

${_green('✅ 推荐解决方案:')}
1. 使用前缀调用: @$name (无括号调用)
2. 重命名片段: @Fragment('My$name', ...)
3. 使用描述性名称: @Fragment('Custom$name', ...)

${_cyan('💡 提示:')} 使用前缀 @ 可以无括号调用片段！
示例: @$name param1: value1 param2: value2
''');
      }

      _fragments[name] = FragmentDefinition(
        name: name,
        params: params,
        body: body,
      );
    }
  }

  /// 提取注解
  Map<String, dynamic> _extractAnnotations(String source) {
    final annotations = <String, dynamic>{};

    // // 此处留待其他注解的扩展,注意,@Alias 已不存在,仅供示例参考:
    // // @Alias('Name', target: 'Widget') — 引号可以是 ' 或 "
    // final aliasRegex =
    //     RegExp(r'''@Alias\(['"]([^'"]+)['"],\s*target:\s*['"]([^'"]+)['"]\)''');
    // for (final match in aliasRegex.allMatches(source)) {
    //   annotations['alias_${match.group(1)}'] = {
    //     'type': 'alias',
    //     'name': match.group(1),
    //     'target': match.group(2),
    //   };
    // }

    return annotations;
  }

  /// 移除注解行（包括多行注解体）— 注解应用完成后不保留在输出中
  String _removeAnnotationLines(String source) {
    final lines = source.split('\n');
    final result = <String>[];
    var inAnnotation = false;
    var parenDepth = 0;
    var inString = false;
    var stringChar = '';

    for (final line in lines) {
      final trimmed = line.trim();

      // 如果正在处理注解体
      if (inAnnotation) {
        // 继续追踪括号深度
        for (var i = 0; i < line.length; i++) {
          final ch = line[i];
          if (inString) {
            if (ch == stringChar && (i == 0 || line[i - 1] != '\\')) {
              inString = false;
            }
          } else {
            if (ch == "'" || ch == '"') {
              inString = true;
              stringChar = ch;
            } else if (ch == '(') {
              parenDepth++;
            } else if (ch == ')') {
              parenDepth--;
            }
          }
        }
        if (parenDepth == 0) {
          inAnnotation = false;
        }
        // 跳过这行（不加入result）
        continue;
      }

      // 检查是否是注解开始
      if (trimmed.startsWith('@Fragment')) {
        // 计算这行的括号深度
        parenDepth = 0;
        inString = false;
        for (var i = 0; i < line.length; i++) {
          final ch = line[i];
          if (inString) {
            if (ch == stringChar && (i == 0 || line[i - 1] != '\\')) {
              inString = false;
            }
          } else {
            if (ch == "'" || ch == '"') {
              inString = true;
              stringChar = ch;
            } else if (ch == '(') {
              parenDepth++;
            } else if (ch == ')') {
              parenDepth--;
            }
          }
        }
        if (parenDepth > 0) {
          // 注解跨多行
          inAnnotation = true;
        }
        // 跳过注解行（不加入result）
        continue;
      }

      result.add(line);
    }

    return result.join('\n');
  }

  /// 预处理续行
  String _preprocessLines(String source) {
    final lines = source.split('\n');
    final result = <String>[];
    var buffer = StringBuffer();
    var isContinued = false;

    for (var i = 0; i < lines.length; i++) {
      var line = lines[i];
      final trimmed = line.trim();

      // 跳过空行
      if (trimmed.isEmpty) {
        if (isContinued) {
          // 空行结束续行
          result.add(buffer.toString().trimRight());
          buffer.clear();
          isContinued = false;
        }
        continue;
      }

      // 检查是否以 \ 结尾（续行符）
      if (trimmed.endsWith('\\')) {
        line = line.substring(0, line.length - 1);
        buffer.write(line);
        isContinued = true;
        continue;
      }

      // 检查是否以 , 结尾且下一行缩进更大（隐式续行）
      if (trimmed.endsWith(',') && i + 1 < lines.length) {
        final nextLine = lines[i + 1];
        final nextIndent = nextLine.length - nextLine.trimLeft().length;
        final currentIndent = line.length - line.trimLeft().length;

        if (nextIndent > currentIndent) {
          buffer.write(line);
          isContinued = true;
          continue;
        }
      }

      // 检查括号是否未闭合
      // 但不要续行以 `{` 或 `[` 结尾的行（block body 和 list 由树结构处理）
      if (!trimmed.endsWith('{') && !trimmed.endsWith('[') &&
          _hasUnclosedParens(trimmed) && i + 1 < lines.length) {
        buffer.write(line);
        isContinued = true;
        continue;
      }

      // 结束续行
      if (isContinued) {
        buffer.write(line);
        result.add(buffer.toString());
        buffer.clear();
        isContinued = false;
      } else {
        result.add(line);
      }
    }

    if (buffer.isNotEmpty) {
      result.add(buffer.toString());
    }

    return result.join('\n');
  }

  bool _hasUnclosedParens(String line) {
    var open = 0;
    var inString = false;
    var stringChar = '';

    for (var i = 0; i < line.length; i++) {
      final char = line[i];

      if (inString) {
        if (char == stringChar && (i == 0 || line[i - 1] != '\\')) {
          inString = false;
        }
        continue;
      }

      if (char == "'" || char == '"') {
        inString = true;
        stringChar = char;
        continue;
      }

      // 只检查 ( )，不检查 [ ] 或 { }（list 和 block 由树结构处理）
      if (char == '(') {
        open++;
      } else if (char == ')') {
        open--;
      }
    }

    // 只有真正未闭合（open > close）才返回 true
    return open > 0;
  }

  /// 简单检查是否是Widget名称（不带前缀/冒号）
  bool _isWidgetNameSimple(String name) {
    // 检查内置Widget
    if (builtInWidgets.contains(name)) {
      return true;
    }

    // 检查自定义Widget（大写字母开头）
    if (RegExp(r'^[A-Z]').hasMatch(name)) {
      return true;
    }

    return false;
  }

  Map<String, dynamic> _parseParams(String paramsStr) {
    final map = <String, dynamic>{};
    final parts = _splitTopLevel(paramsStr);
    for (final part in parts) {
      final colonIdx = part.indexOf(':');
      if (colonIdx > 0) {
        final key = part.substring(0, colonIdx).trim();
        // 去掉 key 外层的引号
        var cleanKey = key;
        if ((cleanKey.startsWith("'") && cleanKey.endsWith("'")) ||
            (cleanKey.startsWith('"') && cleanKey.endsWith('"'))) {
          cleanKey = cleanKey.substring(1, cleanKey.length - 1);
        }
        var value = part.substring(colonIdx + 1).trim();
        map[cleanKey] = _parseValue(value);
      }
    }
    return map;
  }

  dynamic _parseValue(String value) {
    if (value.startsWith("'") && value.endsWith("'")) {
      return value.substring(1, value.length - 1);
    }
    if (value == 'true') return true;
    if (value == 'false') return false;
    if (int.tryParse(value) != null) return int.parse(value);
    if (double.tryParse(value) != null) return double.parse(value);
    return value;
  }

  List<String> _splitTopLevel(String str) {
    final parts = <String>[];
    var current = StringBuffer();
    var depth = 0;
    var inString = false;

    for (var i = 0; i < str.length; i++) {
      final char = str[i];

      if (char == "'" && (i == 0 || str[i-1] != '\\')) {
        inString = !inString;
        current.write(char);
        continue;
      }

      if (!inString) {
        if (char == '(' || char == '[' || char == '{') depth++;
        else if (char == ')' || char == ']' || char == '}') depth--;
        else if (char == ',' && depth == 0) {
          parts.add(current.toString().trim());
          current.clear();
          continue;
        }
      }

      current.write(char);
    }

    if (current.isNotEmpty) {
      parts.add(current.toString().trim());
    }

    return parts;
  }

  /// 应用注解
  String _applyAnnotations(String code, Map<String, dynamic> annotations) {
    var result = code;

    // 1. 应用别名：PrimaryButton -> ElevatedButton 等
    for (final entry in annotations.entries) {
      final value = entry.value as Map<String, dynamic>;
      if (value['type'] == 'alias') {
        final alias = value['name'] as String;
        final target = value['target'] as String;
        final regex = RegExp('\\b${RegExp.escape(alias)}\\b');
        result = result.replaceAll(regex, target);
      }
    }

    // 2. 应用默认参数：给 Widget(...) 调用注入未指定的默认参数
    //    使用平衡括号扫描（同时跟踪 () 和 {}），正确处理 lambda 体
    for (final entry in annotations.entries) {
      final value = entry.value as Map<String, dynamic>;
      if (value['type'] == 'default') {
        final target = value['target'] as String;
        final params = value['params'] as Map<String, dynamic>;
        result = _injectDefaultParams(result, target, params);
      }
    }

    // 3. 应用 Mixin：给匹配的 Widget(...) 调用注入属性
    //    @Mixin('DarkMode', ['Card', 'Container', 'Scaffold'], {'color': '...'})
    for (final entry in annotations.entries) {
      final value = entry.value as Map<String, dynamic>;
      if (value['type'] == 'mixin') {
        final targets = (value['targets'] as List).cast<String>();
        final props = value['props'] as Map<String, dynamic>;
        for (final target in targets) {
          result = _injectDefaultParams(result, target, props);
        }
      }
    }

    // 4. 应用片段展开：UserCard(name: '张三', ...) -> Card(child: ...)
    //    （放在最后，避免片段体内的 Widget 被别名/默认参数处理干扰）
    for (final entry in _fragments.entries) {
      final fragName = entry.key;
      final fragment = entry.value;
      result = _expandFragmentCalls(result, fragName, fragment);
    }

    return result;
  }

  /// 给 Widget(...) 调用注入未指定的默认参数（处理嵌套括号和 lambda 体）
  /// 用于 @Default 和 @Mixin 注解的应用
  String _injectDefaultParams(
      String code, String target, Map<String, dynamic> params) {
    // 用 \b 确保只匹配完整的 Widget 名（避免 UserCard 中的 Card 被匹配）
    final callRegex = RegExp('\\b${RegExp.escape(target)}\\s*\\(');
    var result = code;
    var searchFrom = 0;

    while (true) {
      final match = callRegex.firstMatch(result.substring(searchFrom));
      if (match == null) break;

      final nameStart = searchFrom + match.start;
      final argsStart = searchFrom + match.end;

      // 找到平衡的闭括号 — 同时跟踪 () 和 {} 深度
      // 关键：当 braceDepth > 0 时，说明在 lambda 体内，() 属于内部语句
      // 不影响 Widget 调用的括号平衡
      var parenDepth = 1;
      var braceDepth = 0;
      var i = argsStart;
      var inString = false;
      var stringChar = '';
      while (i < result.length) {
        final ch = result[i];
        if (inString) {
          if (ch == stringChar && (i == 0 || result[i - 1] != '\\')) {
            inString = false;
          }
        } else if (braceDepth > 0) {
          // 在 lambda 体内：只跟踪 {} 深度，忽略 ()
          if (ch == '{') {
            braceDepth++;
          } else if (ch == '}') {
            braceDepth--;
          } else if (ch == "'" || ch == '"') {
            inString = true;
            stringChar = ch;
          }
        } else {
          // 在 Widget 调用参数区：跟踪 () 和 {}
          if (ch == "'" || ch == '"') {
            inString = true;
            stringChar = ch;
          } else if (ch == '(') {
            parenDepth++;
          } else if (ch == ')') {
            parenDepth--;
            if (parenDepth == 0) break; // 找到匹配的闭括号
          } else if (ch == '{') {
            braceDepth++;
          }
        }
        i++;
      }
      if (parenDepth != 0) break; // 未找到匹配的闭括号

      final argsEnd = i; // i 指向 `)` 的位置
      var args = result.substring(argsStart, argsEnd).trim();

      // 注入未指定的参数
      // 跳过包含 lambda 体（{）的调用——平衡扫描可能不准确
      if (args.contains('{')) {
        searchFrom = argsEnd + 1;
        continue;
      }
      for (final p in params.entries) {
        if (!args.contains('${p.key}:')) {
          // 确保已有参数后有逗号分隔
          if (args.isNotEmpty && !args.endsWith(',') && !args.endsWith('(')) {
            args = '$args, ';
          }
          args = '$args${p.key}: ${p.value}, ';
        }
      }
      // 去掉末尾多余的逗号和空格
      args = args.trimRight();
      if (args.endsWith(',')) args = args.substring(0, args.length - 1).trimRight();

      result = result.substring(0, nameStart) +
          '$target($args)' +
          result.substring(argsEnd + 1);
      // Advance search position past this replacement
      searchFrom = nameStart + target.length + 1 + args.length + 1;
      // Skip remaining params for this match (avoid infinite loop)
      if (searchFrom >= result.length) break;
    }
    return result;
  }

  /// 展开片段调用：UserCard(name: '张三', email: '...', avatar: '...')
  /// → 片段body（用参数值替换占位符）
  String _expandFragmentCalls(
      String code, String fragName, FragmentDefinition fragment) {
    // 匹配 FragmentName( ... ) — 需要找到平衡的闭括号
    final callRegex = RegExp('${RegExp.escape(fragName)}\\s*\\(');
    var result = code;
    var searchFrom = 0;

    while (true) {
      final match = callRegex.firstMatch(result.substring(searchFrom));
      if (match == null) break;

      final callStart = searchFrom + match.start;
      final argsStart = searchFrom + match.end;

      // 找到平衡的闭括号
      var depth = 1;
      var i = argsStart;
      var inString = false;
      var stringChar = '';
      while (i < result.length && depth > 0) {
        final ch = result[i];
        if (inString) {
          if (ch == stringChar && (i == 0 || result[i - 1] != '\\')) {
            inString = false;
          }
        } else {
          if (ch == "'" || ch == '"') {
            inString = true;
            stringChar = ch;
          } else if (ch == '(') {
            depth++;
          } else if (ch == ')') {
            depth--;
          }
        }
        i++;
      }

      if (depth != 0) break; // 未闭合，跳过

      final argsEnd = i - 1; // 闭括号位置
      final argsStr = result.substring(argsStart, argsEnd).trim();

      // 解析参数：name: '张三', email: '...', avatar: '...'
      final argValues = <String, String>{};
      for (final part in _splitTopLevel(argsStr)) {
        final colonIdx = part.indexOf(':');
        if (colonIdx > 0) {
          final key = part.substring(0, colonIdx).trim();
          final value = part.substring(colonIdx + 1).trim();
          argValues[key] = value;
        }
      }

      // 用参数值替换片段body中的占位符
      var expandedBody = fragment.body;
      for (final param in fragment.params) {
        final value = argValues[param];
        if (value != null) {
          expandedBody = expandedBody
              .replaceAll(RegExp('\\b${RegExp.escape(param)}\\b'), value);
        }
      }

      // 替换：去掉末尾的逗号和换行
      expandedBody = expandedBody.trimRight();
      if (expandedBody.endsWith(',')) {
        expandedBody = expandedBody.substring(0, expandedBody.length - 1);
      }

      // 替换调用为展开的body
      result = result.substring(0, callStart) +
          expandedBody +
          result.substring(argsEnd + 1);

      // 继续搜索（body可能包含新的片段调用）
      searchFrom = callStart + expandedBody.length;
    }

    return result;
  }

  int _getLineNumber(String source, int position) {
    return source.substring(0, position).split('\n').length;
  }
String _transformIndents(String source) {
  // Pass 1: build a tree from indentation
  final root = _buildTree(source);

  // Pass 2: emit Dart code from the tree
  final result = StringBuffer();
  _emitTree(root, result, 0, isRoot: true);
  return result.toString();
}

/// Pass 1: Build a tree of nodes from indentation-based DSL.
_TreeNode _buildTree(String source) {
  final lines = source.split('\n');
  final root = _TreeNode('__ROOT__', -1, _NodeKind.root);
  final stack = <_TreeNode>[root];
  // Track how many `{` we're inside (for block bodies). When > 0, lines are
  // emitted verbatim as statements, not as widget-tree nodes.
  var blockDepth = 0;

  _TreeNode currentParent(int level) {
    while (stack.length > 1 && stack.last.level >= level) {
      stack.removeLast();
    }
    return stack.last;
  }

  for (final rawLine in lines) {
    final trimmed = rawLine.trim();
    if (trimmed.isEmpty) continue;

    final indent = rawLine.length - rawLine.trimLeft().length;
    final level = indent ~/ indentUnit;

    // If we're inside a block body, classify as blockBodyLine (verbatim)
    // unless it's a block closer (`}`, `};`) which closes the block.
    _NodeKind kind;
    if (blockDepth > 0 && trimmed != '}' && trimmed != '};') {
      kind = _NodeKind.blockBodyLine;
    } else {
      kind = _classifyLine(trimmed);
    }

    final parent = currentParent(level);
    final node = _TreeNode(trimmed, level, kind);
    parent.children.add(node);

    // Update block depth and stack
    if (kind == _NodeKind.blockBodyOpen) {
      blockDepth++;
      stack.add(node);
    } else if (kind == _NodeKind.blockClose) {
      if (blockDepth > 0) blockDepth--;
      // Don't push `}` onto the stack as a parent
    } else if (kind != _NodeKind.blockBodyLine &&
               kind != _NodeKind.comment &&
               kind != _NodeKind.importDecl &&
               kind != _NodeKind.fieldDecl &&
               kind != _NodeKind.propertyValue) {
      // Push potential parents onto the stack. Leaf nodes (propertyLeaf,
      // bareLeaf) are included because they CAN have children (e.g.
      // `Text 'hello'` with `style: ...` as a child).
      stack.add(node);
    }
  }

  return root;
}

/// Pass 2: Recursively emit Dart code from the tree.
void _emitTree(_TreeNode node, StringBuffer result, int depth,
    {bool isRoot = false}) {
  for (var i = 0; i < node.children.length; i++) {
    final child = node.children[i];
    final isLast = i == node.children.length - 1;
    _emitNode(child, result, depth, isLast);
  }
}

/// Emit a single node and (recursively) its children.
void _emitNode(_TreeNode node, StringBuffer result, int depth, bool isLast) {
  final indent = '  ' * depth;

  switch (node.kind) {
    case _NodeKind.root:
      _emitTree(node, result, depth, isRoot: true);
      return;

    case _NodeKind.comment:
      // `// ...` verbatim, no comma
      result.writeln('$indent${node.line}');
      return;

    case _NodeKind.importDecl:
      // Top-level import, no indentation
      result.writeln(node.line);
      return;

    case _NodeKind.fieldDecl:
      // `int _counter = 0;` verbatim
      result.writeln('$indent${node.line}');
      return;

    case _NodeKind.blockOpen:
      // `class ... {`, `Widget build(...) {`, `@override`
      result.writeln('$indent${node.line}');
      _emitTree(node, result, depth + 1);
      return;

    case _NodeKind.blockBodyOpen:
      // Method/lambda body opener: `void _f() {`, `setState(() {`,
      // `onPressed: () {`, `itemBuilder: (context, index) {`
      // Emit verbatim; children are statements emitted verbatim.
      result.writeln('$indent${node.line}');
      _emitTree(node, result, depth + 1);
      return;

    case _NodeKind.blockBodyLine:
      // Statement inside a block body — emit verbatim
      result.writeln('$indent${node.line}');
      return;

    case _NodeKind.blockClose:
      // `}` closes a Dart block body (method/lambda) — emit verbatim.
      // `};` closes a lambda property in DSL shorthand where the `;` also
      // terminates the enclosing `return Widget(...)` statement. We drop the
      // `;` here because the returnWidget emitter adds its own `);` closer.
      // `]` and `];` are no-ops — list closers are emitted by listOpen/propertyWidget.
      if (node.line == '}') {
        result.writeln('$indent}');
      } else if (node.line == '};') {
        result.writeln('$indent}');
      }
      // `]` and `];` → no output
      return;

    case _NodeKind.returnWidget:
      // `return Scaffold` → `return Scaffold(` ... `);`
      // `return @MainCard` → `return MainCard(` ... `);` (alias applied later)
      final returnMatch = RegExp(r'return\s+@?([\w.]+)').firstMatch(node.line);
      if (returnMatch == null) {
        result.writeln('$indent${node.line}');
        return;
      }
      final widgetName = returnMatch.group(1)!;
      result.writeln('${indent}return $widgetName(');
      _emitTree(node, result, depth + 1);
      result.writeln('$indent);');
      return;

    case _NodeKind.propertyWidget:
      // `appBar: AppBar` → `appBar: AppBar(` ... `),`
      final colonIdx = node.line.indexOf(':');
      final key = node.line.substring(0, colonIdx).trim();
      final value = node.line.substring(colonIdx + 1).trim();
      // Value is a bare widget name (possibly `Widget.method`)
      result.writeln('$indent$key: $value(');
      _emitTree(node, result, depth + 1);
      result.writeln('$indent),');
      return;

    case _NodeKind.propertyLeaf:
      // `title: Text 'Test'` → `title: Text('Test'),` (no children)
      // OR `child: Text 'Hello'` with `style: ...` children →
      //    `child: Text('Hello', style: ...),`
      final colonIdx2 = node.line.indexOf(':');
      final key2 = node.line.substring(0, colonIdx2).trim();
      var value2 = node.line.substring(colonIdx2 + 1).trim();
      final hadSemi = value2.endsWith(';');
      if (hadSemi) value2 = value2.substring(0, value2.length - 1).trim();
      // Convert `Widget 'arg'` → `Widget('arg'`
      // (leave paren open if there are children, close it after)
      final hasChildren = node.children.isNotEmpty;
      if (hasChildren) {
        // Open paren, emit arg + children, close
        final m = RegExp(r'^(\w+)\s+(.+)$').firstMatch(value2);
        if (m != null && _isWidgetNameSimple(m.group(1)!)) {
          final widgetName = m.group(1)!;
          final arg = m.group(2)!;
          result.writeln('$indent$key2: $widgetName($arg,');
        } else {
          result.writeln('$indent$key2: $value2(');
        }
        _emitTree(node, result, depth + 1);
        result.writeln('$indent),');
      } else {
        value2 = _convertLeafValue(value2);
        result.writeln('$indent$key2: $value2,');
      }
      return;

    case _NodeKind.propertyValue:
      // `elevation: 0`, `onPressed: _increment`, `backgroundColor: Theme.of(...)`
      var line = node.line;
      if (line.endsWith(';')) line = line.substring(0, line.length - 1).trim();
      result.writeln('$indent$line,');
      return;

    case _NodeKind.listOpen:
      // `actions: [` → emit `[`, children as list items, `],`
      final colonIdx3 = node.line.indexOf(':');
      final key3 = node.line.substring(0, colonIdx3).trim();
      result.writeln('$indent$key3: [');
      _emitTree(node, result, depth + 1);
      result.writeln('$indent],');
      return;

    case _NodeKind.fragmentCall:
      // `UserCard` (bare widget name) with `key: value` children
      // → `UserName(key: value, key: value),`
      // Also handles bare widgets in lists like `Column` with children
      final hasFragChildren = node.children.isNotEmpty;
      if (hasFragChildren) {
        result.writeln('$indent${node.line}(');
        _emitTree(node, result, depth + 1);
        result.writeln('$indent),');
      } else {
        // Bare widget with no children — just emit as-is (e.g. `SizedBox()`)
        result.writeln('$indent${node.line}(),');
      }
      return;

    case _NodeKind.annotationUsage:
      // `@PrimaryButton`, `@UserCard`, `@MainCard` — annotation usage
      // Strip `@`, look up the annotation, emit the target widget
      final annName = node.line.substring(1).trim(); // remove `@`
      // Check if it's a fragment
      if (_fragments.containsKey(annName)) {
        // Fragment: emit `FragmentName(` + children + `),` for later expansion
        final hasChildren = node.children.isNotEmpty;
        if (hasChildren) {
          result.writeln('$indent$annName(');
          _emitTree(node, result, depth + 1);
          result.writeln('$indent),');
        } else {
          result.writeln('$indent$annName(),');
        }
      } else {
        // Alias or unknown annotation: emit as `TargetWidget(` + children + `),`
        // The alias replacement happens later in _applyAnnotations
        final hasChildren = node.children.isNotEmpty;
        if (hasChildren) {
          result.writeln('$indent$annName(');
          _emitTree(node, result, depth + 1);
          result.writeln('$indent),');
        } else {
          result.writeln('$indent$annName(),');
        }
      }
      return;

    case _NodeKind.bareLeaf:
      // Standalone `Text 'Hello'` (widget with arg, no key)
      // May have children (e.g. `style:`) → `Text('Hello', style: ...)`
      var value = node.line;
      final hadSemi = value.endsWith(';');
      if (hadSemi) value = value.substring(0, value.length - 1).trim();
      final hasLeafChildren = node.children.isNotEmpty;
      if (hasLeafChildren) {
        final m = RegExp(r'^(\w+)\s+(.+)$').firstMatch(value);
        if (m != null && _isWidgetNameSimple(m.group(1)!)) {
          final widgetName = m.group(1)!;
          final arg = m.group(2)!;
          result.writeln('$indent$widgetName($arg,');
        } else {
          result.writeln('$indent$value(');
        }
        _emitTree(node, result, depth + 1);
        result.writeln('$indent),');
      } else {
        value = _convertLeafValue(value);
        result.writeln('$indent$value,');
      }
      return;
  }
}

/// Convert a leaf value like `Text 'Hello'` to `Text('Hello')`.
/// If the value already has parens, leave it alone.
String _convertLeafValue(String value) {
  if (value.contains('(') && value.contains(')')) return value;
  final m = RegExp(r'^(\w+)\s+(.+)$').firstMatch(value);
  if (m == null) return value;
  final firstWord = m.group(1)!;
  final rest = m.group(2)!;
  if (!_isWidgetNameSimple(firstWord)) return value;
  return '$firstWord($rest)';
}

/// Classify a DSL line into a node kind.
_NodeKind _classifyLine(String line) {
  // Comments
  if (line.startsWith('//')) return _NodeKind.comment;

  // Imports
  if (line.startsWith('import ')) return _NodeKind.importDecl;

  // Block close — `}`, `};`, `];`, `]` (list/block close markers)
  if (line == '}' || line == '};' || line == '];' || line == ']') {
    return _NodeKind.blockClose;
  }

  // `@` lines: distinguish annotation definitions from usages
  if (line.startsWith('@')) {
    // Annotation definitions: @Fragment(...)
    // These should have been removed by _removeAnnotationLines, but if they
    // survive (e.g. inside a class), treat as blockOpen (verbatim).
    if (line.startsWith('@Fragment(')) {
      return _NodeKind.blockOpen;
    }
    // `@override` — verbatim
    if (line == '@override' || line.startsWith('@override')) {
      return _NodeKind.blockOpen;
    }
    // Everything else `@Name` is an annotation USAGE:
    // `@PrimaryButton`, `@UserCard`, `@MainCard`, `@DarkMode`
    return _NodeKind.annotationUsage;
  }

  // Lines ending with `{` are block-body openers (methods, lambdas)
  // This catches: `void _f() {`, `setState(() {`, `onPressed: () {`,
  // `itemBuilder: (context, index) {`, `class X {`, `Widget build(...) {`
  // We distinguish class/method-decl blockOpen from lambda blockBodyOpen by
  // whether the line starts with a declaration keyword.
  if (line.endsWith('{')) {
    if (line.startsWith('class ') || line.startsWith('Widget ') ||
        line.startsWith('void ') || line.startsWith('@override')) {
      return _NodeKind.blockOpen;
    }
    // Everything else ending with `{` is a block body (lambda, setState, etc.)
    return _NodeKind.blockBodyOpen;
  }

  // `return Widget` or `return @Annotation` (with optional trailing `;`)
  if (line.startsWith('return ')) {
    return _NodeKind.returnWidget;
  }

  // `key: [` — list literal opener
  if (RegExp(r'^\w+:\s*\[\s*$').hasMatch(line)) {
    return _NodeKind.listOpen;
  }

  // `key: value` — property
  if (line.contains(':')) {
    final colonIdx = line.indexOf(':');
    final value = line.substring(colonIdx + 1).trim();
    // Strip trailing `;` for classification purposes
    final valueNoSemi = value.replaceAll(RegExp(r';\s*$'), '');

    // If value is a bare widget name (single Capitalized word, no dot)
    // AND it's a known built-in widget → propertyWidget (potential parent)
    // We require it to be a KNOWN widget to avoid matching `MainAxisAlignment`
    // etc. Custom widgets (Capitalized, no dot) are also potential parents.
    final bareWidgetMatch = RegExp(r'^([A-Z]\w*)$').firstMatch(valueNoSemi);
    if (bareWidgetMatch != null) {
      final name = bareWidgetMatch.group(1)!;
      // Built-in widgets are always potential parents
      if (builtInWidgets.contains(name)) {
        return _NodeKind.propertyWidget;
      }
      // Other Capitalized names: could be custom widgets OR enums like
      // MainAxisAlignment. Heuristic: enum-like names are long and contain
      // "Alignment"/"Axis"/"Color"/"Style". Treat as propertyValue if so.
      // Otherwise treat as custom widget parent.
      // Better: treat as propertyWidget (custom widgets are common in .dui)
      return _NodeKind.propertyWidget;
    }

    // `Widget.method` like `ListView.builder` → propertyWidget
    final dottedWidgetMatch = RegExp(r'^([A-Z]\w*)\.(\w+)$').firstMatch(valueNoSemi);
    if (dottedWidgetMatch != null) {
      final first = dottedWidgetMatch.group(1)!;
      // Only treat as widget if first part is a known widget
      if (builtInWidgets.contains(first)) {
        return _NodeKind.propertyWidget;
      }
      // Otherwise (MainAxisAlignment.spaceAround, EdgeInsets.all) → propertyValue
      return _NodeKind.propertyValue;
    }

    // If value is `Widget 'arg'` or `Widget arg` (widget with leaf arg)
    // → propertyLeaf
    final leafMatch = RegExp(r'^([A-Z]\w*(?:\.\w+)?)\s+(.+)$').firstMatch(valueNoSemi);
    if (leafMatch != null) {
      final firstWord = leafMatch.group(1)!;
      if (_isWidgetNameSimple(firstWord)) {
        return _NodeKind.propertyLeaf;
      }
    }

    // Everything else: `elevation: 0`, `onPressed: _increment`,
    // `backgroundColor: Theme.of(context)...`, `margin: EdgeInsets.all(16)`
    return _NodeKind.propertyValue;
  }

  // Class member declarations: fields, constructors, arrow methods
  // 任何以 `;` 结尾且不是 return 语句的行都是标准 Dart 声明，应原样输出
  // （此时已排除含 `:` 的属性行和以 `{` 结尾的 block opener）
  if (line.endsWith(';') && !line.startsWith('return ')) {
    return _NodeKind.fieldDecl;
  }

  // Bare widget name with no `:` — could be a fragment call (`UserCard`)
  // or a bare widget (`Text 'Hello'`)
  final bareWidgetMatch = RegExp(r'^([A-Z]\w*(?:\.\w+)?)$').firstMatch(line);
  if (bareWidgetMatch != null) {
    return _NodeKind.fragmentCall;
  }

  // Bare widget with args, e.g. standalone `Text 'Hello'`
  return _NodeKind.bareLeaf;
}

/// Upgrade a propertyWidget node to propertyLeaf if it ended up with no
/// children (e.g. `appBar: AppBar` with nothing nested under it).
/// Called after tree build, before emission. We handle this directly in
/// _emitNode by checking children length.

} // end of class DSLParser

// ─────────────────────────────────────────────────────────────
// Tree node types (top-level)
// ─────────────────────────────────────────────────────────────

enum _NodeKind {
  root,
  importDecl,        // `import '...';`
  comment,           // `// ...`
  blockOpen,         // `class ... {`, `Widget build(...) {`, `@override`
  blockClose,        // `}`
  blockBodyOpen,     // method/lambda body opener: `void _f() {`, `setState(() {`, `onPressed: () {`
  blockBodyLine,     // statement inside a block body (emitted verbatim)
  fieldDecl,         // `int _counter = 0;` — class-level field declaration
  returnWidget,      // `return Scaffold`
  propertyWidget,    // `appBar: AppBar`  (widget with children)
  propertyLeaf,      // `title: Text 'Test'`  (leaf property: widget with arg)
  propertyValue,     // `elevation: 0`, `onPressed: _increment`, `backgroundColor: Theme.of(...)`
  listOpen,          // `actions: [`  (list literal opener)
  fragmentCall,      // `UserCard` (bare widget name with key:value children, no `:` on head)
  annotationUsage,   // `@PrimaryButton`, `@UserCard`, `@MainCard` — alias/fragment usage
  bareLeaf,          // standalone `Text 'Hello'`
}

class _TreeNode {
  final String line;
  final int level;
  final _NodeKind kind;
  final List<_TreeNode> children = [];
  _TreeNode(this.line, this.level, this.kind);
}

