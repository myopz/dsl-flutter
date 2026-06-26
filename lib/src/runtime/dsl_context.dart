// lib/src/runtime/dsl_context.dart

import 'package:flutter/widgets.dart';

/// DSL 运行时上下文
///
/// 管理 DSL 的全局状态、配置和扩展
class DSLContext {
  static final DSLContext _instance = DSLContext._internal();

  /// 获取 DSL 上下文单例
  static DSLContext get instance => _instance;

  /// 是否启用调试模式
  bool _debugMode = false;

  /// 自定义扩展处理器
  final Map<String, dynamic Function(dynamic)> _extensions = {};

  /// 自定义组件映射
  final Map<String, Widget Function(Map<String, dynamic>)> _customWidgets = {};

  /// DSL 配置
  final Map<String, dynamic> _config = {};

  DSLContext._internal();

  /// 启用调试模式
  void enableDebug() {
    _debugMode = true;
    print('🔍 DSL Flutter debug mode enabled');
  }

  /// 禁用调试模式
  void disableDebug() {
    _debugMode = false;
  }

  /// 检查是否处于调试模式
  bool get isDebugMode => _debugMode;

  /// 注册扩展处理器
  ///
  /// [name] 扩展名称
  /// [handler] 处理函数，接收值并返回处理后的值
  void registerExtension(String name, dynamic Function(dynamic) handler) {
    _extensions[name] = handler;
  }

  /// 调用扩展
  ///
  /// [name] 扩展名称
  /// [value] 要处理的值
  /// 返回处理后的值
  dynamic callExtension(String name, dynamic value) {
    final handler = _extensions[name];
    if (handler != null) {
      try {
        return handler(value);
      } catch (e) {
        if (_debugMode) {
          print('⚠️  Extension "$name" error: $e');
        }
        return value;
      }
    }
    return value;
  }

  /// 注册自定义组件
  ///
  /// [name] 组件名称
  /// [builder] 构建函数，接收参数并返回 Widget
  void registerCustomWidget(String name, Widget Function(Map<String, dynamic>) builder) {
    _customWidgets[name] = builder;
  }

  /// 获取自定义组件
  Widget? buildCustomWidget(String name, Map<String, dynamic> params) {
    final builder = _customWidgets[name];
    if (builder != null) {
      try {
        return builder(params);
      } catch (e) {
        if (_debugMode) {
          print('⚠️  Custom widget "$name" build error: $e');
        }
        return null;
      }
    }
    return null;
  }

  /// 设置配置
  void setConfig(String key, dynamic value) {
    _config[key] = value;
  }

  /// 获取配置
  dynamic getConfig(String key, [dynamic defaultValue]) {
    return _config[key] ?? defaultValue;
  }

  /// 获取所有配置
  Map<String, dynamic> get allConfig => Map.unmodifiable(_config);

  /// 重置上下文
  void reset() {
    _extensions.clear();
    _customWidgets.clear();
    _config.clear();
    _debugMode = false;
  }
}

/// DSL Widget 扩展
extension DSLWidgetExtensions on Widget {
  /// 添加调试边框（仅在调试模式下生效）
  Widget withDebugBorder() {
    if (DSLContext.instance.isDebugMode) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(0xFFFF0000),
            width: 1,
          ),
        ),
        child: this,
      );
    }
    return this;
  }

  /// 添加调试标签
  Widget withDebugLabel(String label) {
    if (DSLContext.instance.isDebugMode) {
      return Stack(
        children: [
          this,
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              color: const Color(0xFFFF0000),
              child: Text(
                label,
                style: const TextStyle(
                  color: const Color(0xFFFFFFFF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return this;
  }

  /// 添加性能监控
  Widget withPerformanceMonitor(String name) {
    if (DSLContext.instance.isDebugMode) {
      return PerformanceMonitorWidget(
        name: name,
        child: this,
      );
    }
    return this;
  }
}

/// 性能监控 Widget
class PerformanceMonitorWidget extends StatefulWidget {
  final String name;
  final Widget child;

  const PerformanceMonitorWidget({
    super.key,
    required this.name,
    required this.child,
  });

  @override
  State<PerformanceMonitorWidget> createState() => _PerformanceMonitorWidgetState();
}

class _PerformanceMonitorWidgetState extends State<PerformanceMonitorWidget> {
  final Stopwatch _stopwatch = Stopwatch();

  @override
  void initState() {
    super.initState();
    _stopwatch.start();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    if (DSLContext.instance.isDebugMode) {
      print('⏱️  Performance: ${widget.name} took ${_stopwatch.elapsedMilliseconds}ms');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

/// DSL 上下文 Provider
class DSLContextProvider extends StatelessWidget {
  final Widget child;
  final DSLContext? context;

  const DSLContextProvider({
    super.key,
    required this.child,
    this.context,
  });

  @override
  Widget build(BuildContext context) {
    final providedContext = this.context ?? DSLContext.instance;
    return DSLContextScope(
      context: providedContext,
      child: child,
    );
  }
}

/// DSL 上下文作用域
class DSLContextScope extends InheritedWidget {
  final DSLContext context;

  const DSLContextScope({
    super.key,
    required this.context,
    required super.child,
  });

  static DSLContext of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<DSLContextScope>();
    return scope?.context ?? DSLContext.instance;
  }

  @override
  bool updateShouldNotify(DSLContextScope oldWidget) {
    return context != oldWidget.context;
  }
}