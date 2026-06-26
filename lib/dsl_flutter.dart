/// DSL Flutter - Clean, indentation-based syntax for Flutter
library dsl_flutter;

// 核心功能
export 'src/core/dsl_parser.dart';
export 'src/core/dsl_transformer.dart';
export 'src/core/dsl_generator.dart';

// 注解
export 'src/annotations/alias.dart';
export 'src/annotations/default.dart';
export 'src/annotations/fragment.dart';
export 'src/annotations/mixin.dart';

// 运行时
export 'src/runtime/dsl_context.dart';
export 'src/runtime/dsl_theme.dart';

// 工具
export 'src/utils/formatter_checker.dart';

// Builder
export 'builder.dart';