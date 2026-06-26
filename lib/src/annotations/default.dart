/// 默认参数注解
///
/// 为组件设置默认参数值，减少重复代码
///
/// Example:
/// ```dart
/// @Default('Card', {'elevation': 4, 'margin': 'EdgeInsets.all(16)'})
/// Card(child: Text('Content')) // 自动添加默认参数
/// ```
class Default {
  final String target;
  final Map<String, dynamic> params;

  const Default(this.target, this.params);
}