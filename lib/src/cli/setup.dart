import 'dart:io';
import 'package:args/args.dart';
import 'package:ansicolor/ansicolor.dart';

final _green = AnsiPen()..green();
final _yellow = AnsiPen()..yellow();
final _cyan = AnsiPen()..cyan();

/// Setup命令 - 一键配置开发环境
class SetupCommand {
  void run(ArgResults args) {
    print('\n${_cyan('🔧 DSL Flutter 环境配置')}\n');

    // 1. 创建 .editorconfig
    _createEditorConfig();

    // 2. 创建 VS Code 配置
    _createVSCodeSettings();

    // 3. 创建 VS Code 扩展推荐
    _createVSCodeExtensions();

    // 4. 创建 .gitignore（如果不存在）
    _createGitIgnore();

    // 5. 输出完成信息
    _printSuccess();
  }

  void _createEditorConfig() {
    final file = File('.editorconfig');

    if (file.existsSync()) {
      stdout.write('${_yellow('⚠️  .editorconfig 已存在，是否覆盖？ (y/N) ')}');
      final answer = stdin.readLineSync()?.toLowerCase();
      if (answer != 'y') {
        print('${_yellow('⏭️  跳过 .editorconfig')}');
        return;
      }
    }

    final content = '''
# EditorConfig - DSL Flutter 配置
# 防止IDE自动格式化破坏DSL缩进
root = true

[*]
charset = utf-8
end_of_line = lf
insert_final_newline = true
trim_trailing_whitespace = true

[*.dui]
# DSL 核心：缩进大小
indent_style = space
indent_size = 2

# 关键：关闭自动格式化
max_line_length = off

# 其他优化
ij_dart_force_style = off
ij_dart_keep_blank_lines = true
''';

    file.writeAsStringSync(content);
    print('${_green('✅ 已创建: .editorconfig')}');
  }

  void _createVSCodeSettings() {
    final dir = Directory('.vscode');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File('.vscode/settings.json');

    if (file.existsSync()) {
      stdout.write('${_yellow('⚠️  .vscode/settings.json 已存在，是否覆盖？ (y/N) ')}');
      final answer = stdin.readLineSync()?.toLowerCase();
      if (answer != 'y') {
        print('${_yellow('⏭️  跳过 .vscode/settings.json')}');
        return;
      }
    }

    final content = '''
{
  // ========== DSL Flutter 配置 ==========
  // 防止VS Code自动格式化破坏DSL文件

  // Dart 文件正常格式化
  "[dart]": {
    "editor.formatOnSave": true,
    "editor.formatOnType": false,
    "editor.codeActionsOnSave": {
      "source.fixAll": "explicit"
    }
  },

  // DSL 文件禁用自动格式化
  "[dart-ui]": {
    "editor.formatOnSave": false,
    "editor.formatOnType": false,
    "editor.formatOnPaste": false,
    "editor.tabSize": 2,
    "editor.insertSpaces": true,
    "editor.detectIndentation": false
  },

  // 文件关联
  "files.associations": {
    "*.dui": "dart"
  },

  // 文件监视排除
  "files.watcherExclude": {
    "**/.dart_tool/**": true,
    "**/*.dsl.dart": true
  },

  // 搜索排除
  "search.exclude": {
    "**/*.dsl.dart": true
  }
}
''';

    file.writeAsStringSync(content);
    print('${_green('✅ 已创建: .vscode/settings.json')}');
  }

  void _createVSCodeExtensions() {
    final dir = Directory('.vscode');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File('.vscode/extensions.json');

    if (file.existsSync()) {
      stdout.write('${_yellow('⚠️  .vscode/extensions.json 已存在，是否覆盖？ (y/N) ')}');
      final answer = stdin.readLineSync()?.toLowerCase();
      if (answer != 'y') {
        print('${_yellow('⏭️  跳过 .vscode/extensions.json')}');
        return;
      }
    }

    final content = '''
{
  // DSL Flutter 推荐扩展
  "recommendations": [
    "dart-code.dart-code",
    "dart-code.flutter"
  ],
  "unwantedRecommendations": []
}
''';

    file.writeAsStringSync(content);
    print('${_green('✅ 已创建: .vscode/extensions.json')}');
  }

  void _createGitIgnore() {
    final file = File('.gitignore');
    if (file.existsSync()) return;

    final content = '''
# DSL Flutter
*.dsl.dart
.dart_tool/
build/
pubspec.lock

# IDE
.vscode/
.idea/
*.iml

# OS
.DS_Store
Thumbs.db
''';

    file.writeAsStringSync(content);
    print('${_green('✅ 已创建: .gitignore')}');
  }

  void _printSuccess() {
    print('\n${_green('✅ 环境配置完成！')}\n');
    print('${_cyan('📁 已创建以下文件:')}');
    print('  - .editorconfig');
    print('  - .vscode/settings.json');
    print('  - .vscode/extensions.json');
    print('  - .gitignore');

    print('\n${_cyan('📝 下一步:')}');
    print('  1. 重新加载 VS Code: Cmd+Shift+P -> "Reload Window"');
    print('  2. 创建 DSL 文件: lib/pages/home.dui');
    print('  3. 运行构建: flutter pub run build_runner watch');

    print('\n${_green('🚀 开始编写无括号的 Flutter 代码吧！')}');
    print('${_cyan('📖 文档: https://github.com/yourusername/dsl_flutter')}\n');
  }
}