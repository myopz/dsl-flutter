import 'dart:io';
import 'package:args/args.dart';
import 'package:path/path.dart' as path;
import 'package:ansicolor/ansicolor.dart';
import '../core/dsl_generator.dart';

final _green = AnsiPen()..green();
final _red = AnsiPen()..red();
final _yellow = AnsiPen()..yellow();
final _cyan = AnsiPen()..cyan();

/// Watch命令 - 监听文件变化
class WatchCommand {
  final DSLGenerator _generator = DSLGenerator();

  void run(ArgResults args) {
    print('\n${_cyan('👀 监听 DSL 文件变化...')}\n');

    final dslFiles = _findDSLFiles();
    if (dslFiles.isEmpty) {
      print('${_yellow('⚠️  未找到 .dui 文件')}');
      print('创建示例: lib/pages/home.dui\n');
      return;
    }

    print('${_green('📁 找到 ${dslFiles.length} 个 DSL 文件')}');
    for (final file in dslFiles) {
      print('  - ${path.basename(file)}');
    }
    print('');

    // 监听文件变化
    final watchDir = Directory('lib');
    watchDir.watch(recursive: true).listen((event) {
      if (event.type == FileSystemEvent.modify ||
          event.type == FileSystemEvent.create) {
        final file = File(event.path);
        if (file.existsSync() && event.path.endsWith('.dui')) {
          _processFile(file);
        }
      }
    });

    print('${_green('✅ 监听已启动，修改 .dui 文件将自动转换')}');
    print('${_yellow('按 Ctrl+C 停止监听')}\n');

    // 保持运行
    stdin.listen((_) {});
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

  void _processFile(File file) {
    try {
      final content = file.readAsStringSync();
      final generated = _generator.generate(content);

      final outputPath = file.path.replaceAll('.dui', '.dsl.dart');
      final outputFile = File(outputPath);
      outputFile.writeAsStringSync(generated);

      print('${_green('✅ 已转换:')} ${path.basename(file.path)}');
      print('   → ${path.basename(outputPath)}\n');
    } catch (e) {
      print('${_red('❌ 转换失败:')} ${path.basename(file.path)}');
      print('   $e\n');
    }
  }
}