// lib/src/core/dsl_generator.dart

import 'dsl_parser.dart';
// 移除 dsl_transformer.dart 的导入，因为不需要 AST 转换

/// DSL代码生成器
class DSLGenerator {
  final DSLParser _parser = DSLParser();
  // 移除 _transformer

  /// 生成完整的Dart代码
  String generate(String source) {
    // 1. 解析DSL（直接转换为标准 Dart 代码字符串）
    final parsed = _parser.parse(source);

    // 2. 包装为完整代码（不需要 transformer）
    return _wrapWithBoilerplate(parsed);
  }

  String _wrapWithBoilerplate(String code) {
    // 不再添加文档头，由 builder.dart 负责添加
    return code;
  }
}