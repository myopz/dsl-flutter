// lib/builder.dart

import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:ansicolor/ansicolor.dart';
import '../core/dsl_generator.dart';
import 'package:args/args.dart';



/// ANSI颜色支持
final _green = AnsiPen()..green();
final _red = AnsiPen()..red();
final _yellow = AnsiPen()..yellow();
final _cyan = AnsiPen()..cyan();

/// Build命令 - 一次性转换所有DSL文件
class BuildCommand {
  final DSLGenerator _generator = DSLGenerator();

  void run(ArgResults args) {
    print('');
    print(_cyan('🔨 构建 DSL 文件...'));
    print('');

    // 获取要构建的文件列表
    final rest = args.rest;
    List<String> dslFiles;

    if (rest.isNotEmpty) {
      // 构建指定的文件
      dslFiles = rest.where((f) => f.endsWith('.dui')).toList();
      if (dslFiles.isEmpty) {
        print(_red('❌ 请指定 .dui 文件'));
        return;
      }
    } else {
      // 构建所有文件
      dslFiles = _findDSLFiles();
    }

    if (dslFiles.isEmpty) {
      print(_yellow('⚠️  未找到 .dui 文件'));
      print('创建示例: lib/pages/home.dui');
      print('');
      return;
    }

    print('📁 找到 ${dslFiles.length} 个 DSL 文件');
    print('');

    var successCount = 0;
    var failCount = 0;

    for (final filePath in dslFiles) {
      try {
        final file = File(filePath);
        if (!file.existsSync()) {
          print(_red('❌ 文件不存在: $filePath'));
          failCount++;
          continue;
        }

        final content = file.readAsStringSync();
        final generated = _generator.generate(content);

        final outputPath = filePath.replaceAll('.dui', '.dsl.dart');
        final outputFile = File(outputPath);
        outputFile.writeAsStringSync(generated);

        print(_green('✅ ${path.basename(filePath)} → ${path.basename(outputPath)}'));
        successCount++;
      } catch (e) {
        print(_red('❌ ${path.basename(filePath)}: $e'));
        failCount++;
      }
    }

    print('');
    print(_green('✅ 构建完成: 成功 $successCount 个, 失败 $failCount 个'));
    print('');

    if (failCount > 0) {
      exit(1);
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