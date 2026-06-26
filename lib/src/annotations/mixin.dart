/// 组件混入注解
///
/// 为多个组件共享相同的属性配置
///
/// Example:
/// ```dart
/// @Mixin('CardStyle', ['Card', 'Container'], {
///   'elevation': 8,
///   'shape': 'RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))'
/// })
/// ```
class Mixin {
  final String name;
  final List<String> targets;
  final Map<String, dynamic> props;

  const Mixin(this.name, this.targets, this.props);
}