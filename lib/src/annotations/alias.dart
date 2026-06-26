/// 组件别名注解
///
/// 为常用组件创建简短的别名
///
/// Example:
/// ```dart
/// @Alias('PrimaryButton', target: 'ElevatedButton')
/// PrimaryButton(onPressed: _onTap, child: Text('Click'))
/// ```
class Alias {
  final String alias;
  final String target;

  const Alias(this.alias, {required this.target});
}