// lib/builder.dart

import 'dart:async';
import 'package:build/build.dart';
import 'package:dart_style/dart_style.dart';
import 'package:path/path.dart' as path;

import 'src/core/dsl_generator.dart';
import 'src/utils/formatter_checker.dart';

/// 自定义 DSL Builder - 不经过 Dart 解析器，直接处理文本
class DSLDirectBuilder implements Builder {
  @override
  final buildExtensions = {
    '.dui': ['.dsl.dart'],
  };

  final DSLGenerator _generator = DSLGenerator();
  final FormatterChecker _checker = FormatterChecker();

  @override
  Future<void> build(BuildStep buildStep) async {
    final inputId = buildStep.inputId;
    if (!inputId.path.endsWith('.dui')) return;

    try {
      final content = await buildStep.readAsString(inputId);

      // 检查格式（仅警告，不阻止构建）
      final issues = _checker.check(content);
      if (issues.isNotEmpty) {
        log.warning('⚠️  检测到格式问题在 ${inputId.path}');
        for (final issue in issues) {
          log.warning('   - $issue');
        }
      }

      // 生成代码
      final generated = _generator.generate(content);

      final outputId = inputId.changeExtension('.dsl.dart');

      var output = '''
// ═══════════════════════════════════════════════════════════
// 自动生成代码 - 由 dsl_flutter 转换
// 源文件: ${inputId.path}
// 生成时间: ${DateTime.now()}
// 请勿手动修改
// ═══════════════════════════════════════════════════════════

$generated
''';

      // 格式化生成的代码
      try {
        final formatter = DartFormatter();
        final formatted = formatter.format(output);
        log.info('✅ 格式化成功');
        output = formatted;
      } catch (e) {
        // 格式化失败，使用原始输出
        log.warning('⚠️ 格式化失败: $e');
        log.info('ℹ️ 将使用未格式化的输出');
      }

      await buildStep.writeAsString(outputId, output);
      log.info('✅ 生成: ${path.basename(inputId.path)} → ${path.basename(outputId.path)}');
    } catch (e, stackTrace) {
      log.severe('❌ 生成失败在 ${inputId.path}: $e');
      if (e is! FormatException) {
        log.severe(stackTrace.toString());
      }
      rethrow;
    }
  }

  List<String> _extractImports(String content) {
    final imports = <String>[];
    for (final line in content.split('\n')) {
      final trimmed = line.trim();
      if (trimmed.startsWith('import ')) {
        imports.add(trimmed);
      }
    }
    return imports;
  }
}

/// 工厂函数 - 返回自定义 Builder
Builder dslBuilder(BuilderOptions options) {
  return DSLDirectBuilder();
}

/// 聚合 Builder 工厂（可选，但这里用同一个实现）
Builder dslAggregateBuilder(BuilderOptions options) {
  return DSLDirectBuilder();
}