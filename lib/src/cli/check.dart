import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:ansicolor/ansicolor.dart';
import '../utils/formatter_checker.dart';

/// ANSI颜色支持
final _cyan = AnsiPen()..cyan();
final _green = AnsiPen()..green();
final _red = AnsiPen()..red();
final _yellow = AnsiPen()..yellow();

/// Check命令 - 检查DSL文件是否被格式化破坏
class CheckCommand {
  final FormatterChecker _checker = FormatterChecker();

  void run(ArgResults args) {
    print('\n${_cyan('🔍 检查 DSL 文件格式...')}\n');

    final dslFiles = _findDSLFiles();
    if (dslFiles.isEmpty) {
      print('${_yellow('⚠️  未找到 .dui 文件')}');
      return;
    }

    var hasIssue = false;

    for (final filePath in dslFiles) {
      final file = File(filePath);
      final content = file.readAsStringSync();
      final issues = _checker.check(content);

      if (issues.isNotEmpty) {
        print('${_red('❌')} ${path.basename(filePath)}');
        for (final issue in issues) {
          print('   ${_yellow('⚠️')} $issue');
        }
        hasIssue = true;
      } else {
        print('${_green('✅')} ${path.basename(filePath)}');
      }
    }

    if (hasIssue) {
      print('\n${_red('⚠️  发现格式问题！')}');
      print('运行 ${_cyan('dsl_flutter setup')} 修复配置');
      print('或手动禁用 .dui 文件的自动格式化\n');
      exit(1);
    } else {
      print('\n${_green('✅ 所有 DSL 文件格式正确！')}\n');
    }
  }

  List<String> _findDSLFiles() {
    final files = <String>[];
    final dir = Directory('lib');
    if (!dir.existsSync()) return files;

    dir.listSync(recursive: true).forEach((entity) {
      if (entity is File && entity.path.endsWith('.dui')) {
        files.add(entity.path);
      }
    });

    return files;
  }
}