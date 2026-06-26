import 'dart:io';
import 'package:args/args.dart';
import 'package:ansicolor/ansicolor.dart';

final _green = AnsiPen()..green();
final _cyan = AnsiPen()..cyan();
final _yellow = AnsiPen()..yellow();

/// Init命令 - 初始化DSL项目
class InitCommand {
  void run(ArgResults args) {
    print('\n${_cyan('🚀 初始化 DSL Flutter 项目...')}\n');

    // 检查是否是Flutter项目
    if (!File('pubspec.yaml').existsSync()) {
      print('❌ 当前目录不是 Flutter 项目');
      print('请先运行: flutter create my_app');
      exit(1);
    }

    // 1. 检查是否已添加依赖
    _checkAndAddDependency();

    // 2. 创建示例DSL文件
    _createExampleDSL();

    // 3. 创建build.yaml
    _createBuildYaml();

    print('\n${_green('✅ 项目初始化完成！')}');
    print('\n${_cyan('📝 下一步:')}');
    print('  1. 运行: flutter pub get');
    print('  2. 运行: flutter pub run build_runner watch');
    print('  3. 编写: lib/pages/home.dui');
  }

  void _checkAndAddDependency() {
    final pubspec = File('pubspec.yaml');
    var content = pubspec.readAsStringSync();

    if (!content.contains('dsl_flutter:')) {
      print('${_cyan('📦 添加 dsl_flutter 依赖...')}');

      // 检查是否有 dev_dependencies 部分
      if (content.contains('dev_dependencies:')) {
        // 在 dev_dependencies 中添加
        content = content.replaceFirst(
          'dev_dependencies:',
          'dev_dependencies:\n  dsl_flutter: ^1.0.0\n  build_runner: ^2.4.0\n'
        );
      } else {
        // 在文件末尾添加
        content += '\n\ndev_dependencies:\n  dsl_flutter: ^1.0.0\n  build_runner: ^2.4.0\n';
      }

      pubspec.writeAsStringSync(content);
      print('${_green('✅ 已添加依赖到 pubspec.yaml')}');
      print('${_yellow('⚠️  请运行: flutter pub get')}');
    } else {
      print('${_green('✅ 依赖已存在')}');
    }
  }

  void _createExampleDSL() {
    final dir = Directory('lib/pages');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File('lib/pages/home.dui');
    if (file.existsSync()) {
      stdout.write('${_cyan('⚠️  home.dui 已存在，是否覆盖？ (y/N) ')}');
      final answer = stdin.readLineSync()?.toLowerCase();
      if (answer != 'y') {
        print('${_yellow('⏭️  跳过示例文件')}');
        return;
      }
    }

    final content = '''
import 'package:flutter/material.dart';

// ============ DSL Flutter 示例 ============
// 无需括号！用缩进表示层级

@Alias('PrimaryButton', target: 'ElevatedButton')

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState => _HomePageState()
}

class _HomePageState extends State<HomePage> {
  int _counter = 0

  void _increment() {
    setState(() {
      _counter++
    })
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold
      appBar: AppBar
        title: Text 'DSL Flutter'
        backgroundColor: Theme.of(context).colorScheme.inversePrimary
      body: Center
        child: Column
          mainAxisAlignment: MainAxisAlignment.center
          children: [
            Text '点击次数'
            Text '\$_counter'
              style: Theme.of(context).textTheme.headlineMedium
            SizedBox height: 20
            PrimaryButton
              onPressed: _increment
              child: Text '增加'
          ]
      floatingActionButton: FloatingActionButton
        onPressed: _increment
        child: Icon Icons.add
  }
}
''';

    file.writeAsStringSync(content);
    print('${_green('✅ 已创建示例: lib/pages/home.dui')}');
  }

  void _createBuildYaml() {
    final file = File('build.yaml');
    if (file.existsSync()) {
      print('${_green('✅ build.yaml 已存在')}');
      return;
    }

    final content = '''
targets:
  \$default:
    builders:
      dsl_flutter|dslBuilder:
        enabled: true
        generate_for:
          - lib/**/*.dui

# DSL Flutter 构建配置
builders:
  dsl_flutter|dslBuilder:
    target: ":dsl_flutter"
    import: "package:dsl_flutter/builder.dart"
    builder_factories: ["dslBuilder"]
    build_extensions: {".dui": [".dsl.dart"]}
    auto_apply: dependents
    build_to: source
''';

    file.writeAsStringSync(content);
    print('${_green('✅ 已创建: build.yaml')}');
  }
}