/// 模板片段注解
///
/// 定义可复用的UI片段
///
/// Example:
/// ```dart
/// @Fragment('UserCard', ['user'], 'Card(child: Text(user.name))')
/// UserCard(user: currentUser)
/// ```
class Fragment {
  final String name;
  final List<String> params;
  final String body;

  const Fragment(this.name, this.params, this.body);
}