import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:dart_style/dart_style.dart';
import 'package:analyzer/dart/analysis/features.dart';

/// AST转换器 - 优化和美化生成的代码
class DSLTransformer {
  final DartFormatter _formatter = DartFormatter();

  /// 转换并格式化代码
  String transform(String source) {
    // 1. 解析为AST
    final ast = _parseToAST(source);

    // 2. 优化AST
    final optimized = _optimizeAST(ast);

    // 3. 生成代码
    var code = _generateCode(optimized);

    // 4. 格式化
    try {
      code = _formatter.format(code);
    } catch (e) {
      // 格式化失败，返回原始代码
    }

    return code;
  }

  /// 解析源代码为AST
  CompilationUnit _parseToAST(String source) {
    try {
      final parseResult = parseString(
        content: source,
        featureSet: FeatureSet.latestLanguageVersion(),
      );
      return parseResult.unit;
    } catch (e) {
      // 如果解析失败，返回一个空的编译单元
      // 但实际上我们应该抛出异常或返回原始代码
      rethrow;
    }
  }

  /// 优化AST
  CompilationUnit _optimizeAST(CompilationUnit unit) {
    final visitor = _OptimizationVisitor();
    unit.accept(visitor);
    return unit;
  }

  /// 生成代码
  String _generateCode(CompilationUnit unit) {
    // 使用 toSource() 方法生成代码
    // 注意：这个方法的输出可能不是你期望的格式化结果
    // 建议使用 dart_style 进行最终格式化
    return unit.toSource();
  }
}

/// AST优化访问器
class _OptimizationVisitor extends RecursiveAstVisitor<void> {
  final List<InstanceCreationExpression> _constCandidates = [];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    // 检查是否可以添加 const
    if (_canBeConst(node)) {
      _constCandidates.add(node);
    }
    super.visitInstanceCreationExpression(node);
  }

  /// 检查实例创建表达式是否可以标记为 const
  bool _canBeConst(InstanceCreationExpression node) {
    // 检查构造函数名称是否以 const 开头
    if (node.isConst) return true;
    // 检查所有参数是否都是常量表达式
    final arguments = node.argumentList.arguments;
    for (final arg in arguments) {
      if (!_isConstantExpression(arg)) {
        return false;
      }
    }

    return true;
  }

  /// 检查表达式是否是常量表达式
  bool _isConstantExpression(Expression node) {
    // 字面量是常量
    if (node is Literal) return true;

    // 字符串插值如果是常量也是常量
    if (node is StringInterpolation) {
      // 检查所有部分是否都是常量
      for (final part in node.elements) {
        if (part is InterpolationString) continue;
        if (part is InterpolationExpression) {
          if (!_isConstantExpression(part.expression)) {
            return false;
          }
        }
      }
      return true;
    }

    // 标识符引用
    if (node is Identifier) {
      // 检查是否引用的是常量
      // 在完整实现中需要查找符号表
      return true; // 简化实现
    }

    // 前缀引用
    if (node is PrefixedIdentifier) {
      return true; // 简化实现
    }

    // 属性访问
    if (node is PropertyAccess) {
      final target = node.target;
      // 如果 target 为 null，无法确定是否为常量，返回 false
      if (target == null) return false;
      return _isConstantExpression(target);
    }

    // 方法调用 (如 DateTime.now() 不是常量)
    if (node is MethodInvocation) {
      return false;
    }

    return false;
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    // 优化链式调用
    // 例如: widget.child.child.child -> 优化为级联调用
    super.visitMethodInvocation(node);
  }

  /// 获取所有可添加 const 的节点（供外部使用）
  List<InstanceCreationExpression> get constCandidates => _constCandidates;

  /// 标记节点为 const（需要外部实现）
  void markAsConst(InstanceCreationExpression node) {
    // 注意：在 analyzer 中，直接修改 AST 节点可能不被支持
    // 更好的方式是在代码生成阶段处理
    // 这里只是一个示例
  }
}

/// 扩展：添加常量化优化
class ConstOptimizer extends RecursiveAstVisitor<void> {
  final List<InstanceCreationExpression> _toConst = [];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    if (_canBeConst(node)) {
      _toConst.add(node);
    }
    super.visitInstanceCreationExpression(node);
  }

  /// 检查实例创建表达式是否可以标记为 const
  bool _canBeConst(InstanceCreationExpression node) {
    // 检查构造函数名称是否以 const 开头
    if (node.isConst) return true;

    // 检查所有参数
    final args = node.argumentList.arguments;
    for (final arg in args) {
      if (!_isConstArgument(arg)) {
        return false;
      }
    }
    return true;
  }

  bool _isConstArgument(Expression arg) {
    // 字面量
    if (arg is Literal) return true;

    // 简单的标识符
    if (arg is SimpleIdentifier) {
      // 在真实场景中需要检查符号是否为常量
      return true;
    }

    // 递归检查
    if (arg is InstanceCreationExpression) {
      return _canBeConst(arg);
    }

    return false;
  }

  List<InstanceCreationExpression> get constCandidates => _toConst;
}

/// 代码生成辅助
class CodeGenerator {
  /// 生成带有 const 优化的代码
  static String generateWithConst(
    CompilationUnit unit,
    List<InstanceCreationExpression> constNodes,
  ) {
    // 注意：由于 analyzer 的 AST 是不可变的，
    // 这里我们通过字符串替换来实现 const 添加
    // 在真实项目中，建议使用 source_gen 或其他代码生成框架

    final source = unit.toSource();
    var result = source;

    // 简单的字符串替换（演示用）
    // 在实际项目中，需要更精确的替换逻辑
    for (final node in constNodes) {
      final nodeSource = node.toSource();
      if (!nodeSource.startsWith('const')) {
        result = result.replaceFirst(nodeSource, 'const $nodeSource');
      }
    }

    return result;
  }
}
