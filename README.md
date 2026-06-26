<h1 align="center">
DSL Flutter 🚀
</h1>

<p align="center">
  告别括号地狱，用缩进书写 Flutter！
</p>

<p align="center">
  <a href="README.EN.md">English</a>
</p>

<p align="center">
  <a href="#-特性">特性</a> |
  <a href="#-安装">安装</a> |
  <a href="#-快速开始">快速开始</a> |
  <a href="#-语法指南">语法指南</a> |
  <a href="#-高级特性">高级特性</a> |
  <a href="#-配置">配置</a> |
  <a href="#-cli-命令">CLI 命令</a> |
  <a href="#-捐赠支持">捐赠支持</a> |
  <a href="#-贡献">贡献</a> |
  <a href="#-许可证">许可证</a>
</p>

---

## ✨ 特性

- 🎯 **零括号** - 告别 `(`, `)`, `,` 的嵌套地狱
- 📦 **缩进即层级** - 用缩进直观表达 Widget 树结构
- 🎨 **组件别名** - 为常用组件创建简短别名
- 🧩 **模板片段** - 复用 UI 结构，DRY 原则
- ⚡ **编译时转换** - 零运行时开销，性能无损
- 🔌 **完全通用** - 支持所有 Flutter 及第三方组件
- 🛡️ **防格式化** - 一键配置，防止 IDE 自动破坏 DSL
- 🧪 **完整测试** - 100% 测试覆盖率保证

---

## 📦 安装

### 方式一：添加到项目（推荐）

```yaml
dev_dependencies:
  dsl_flutter: ^1.0.0
  build_runner: ^2.4.0
```

然后运行：

```bash
flutter pub get
```

### 方式二：全局安装 CLI 工具

```bash
dart pub global activate dsl_flutter
```

---

## 🚀 快速开始

### 1. 配置开发环境（防止格式化破坏）

```bash
dsl_flutter setup
```

### 2. 创建 DSL 文件

创建 `lib/pages/home.dui`：

```dart
import 'package:flutter/material.dart';
import 'package:dsl_flutter/dsl_flutter.dart';

@Alias('PrimaryButton', target: 'ElevatedButton')

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState => _HomePageState()
}

class _HomePageState extends State<HomePage> {
  int _counter = 0

  void _increment() {
    setState(() {
      _counter++
    })
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold
      appBar: AppBar
        title: Text 'DSL Flutter'
      body: Center
        child: Column
          mainAxisAlignment: MainAxisAlignment.center
          children: [
            Text '点击次数'
            Text '$_counter'
              style: Theme.of(context).textTheme.headlineMedium
            @PrimaryButton
              onPressed: _increment
              child: Text '增加'
          ]
      floatingActionButton: FloatingActionButton
        onPressed: _increment
        child: Icon Icons.add
  }
}
```

### 3. 运行代码生成

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 4. 使用生成的代码

```dart
import 'pages/home.dsl.dart';

// 直接使用
HomePage()
```

---

## 📝 语法指南

### 传统写法 - 嵌套地狱

有一堆嵌套的括号，导致代码难以阅读和维护。

```dart
// ❌ 传统写法 - 嵌套地狱
Scaffold(
  appBar: AppBar(title: Text('首页'), backgroundColor: Colors.blue),
  body: Column(
    children: [
      Text('标题'),
      Row(
        children: [
          Icon(Icons.star),
          Text('评分 4.8'),
          Column(
            children: [
              ElevatedButton(onPressed: () => {}, child: Text('点击')),
              Text(
                'Hello World',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              Card(child: Text('内容')),
            ],
          ),
        ],
      ),
    ],
  ),
)
```

### DSL 写法 - 清晰简洁

采用缩进表达 Widget 树结构，清晰明了。

```dart
// ✅ DSL 写法 - 清晰简洁
Scaffold
  appBar: AppBar
    title: Text '首页'
    backgroundColor: Colors.blue
  body: Column
    children: [
      Text '标题'
      Row
        children: [
          Icon Icons.star
          Text '评分 4.8'
          Column
            children: [
              ElevatedButton
                onPressed: () => {}
                child: Text '点击'
              Text 'Hello World'
                style: TextStyle
                  fontSize: 20
                  fontWeight: FontWeight.bold
                  color: Colors.blue
              Card
                child: Text '内容'
            ]
        ]
    ]
```

### 基础的 Widget

```dart
Container
  padding: EdgeInsets.all(16)
  child: Text 'Hello'
```

### 带参数的 Widget

```dart
Text 'Hello World'
  style: TextStyle
    fontSize: 20
    fontWeight: FontWeight.bold
    color: Colors.blue
```

### 自定义 Widget

```dart
MyCustomWidget
  title: '自定义'
  onTap: _handleTap
  child: Text '内容'
```

### 条件渲染

```dart
Column
  children: [
    if (isLoggedIn){
      Text '欢迎回来'
    } else {
      LoginButton()
    }

    for (var item in items)
      ListTile
        title: Text item.name
        onTap: () => _handleTap(item)
  ]
```

---

## 🎨 高级特性

### 组件别名

```dart
@Alias('PrimaryButton', target: 'ElevatedButton')
@Alias('SecondaryButton', target: 'TextButton')

// 使用
PrimaryButton(
  onPressed: _onTap
  child: Text '提交'
)
```

### 模板片段

#### 定义片段

```dart
@Fragment('UserCard', ['name', 'email', 'avatar'], '''
Card(
  child: Column(
    children: [
      CircleAvatar(backgroundImage: NetworkImage(avatar)),
      Text(name),
      Text(email),
    ],
  ),
)
''')
```

前缀调用（无括号）

```dart
@UserCard  // ← 无括号！
  name: '张三'
  email: 'zhangsan@example.com'
  avatar: 'https://example.com/avatar.jpg'
```

### 待实现功能

#### 默认参数

`未实现`

```dart
@Default('Card', {
  'elevation': 4,
  'margin': 'EdgeInsets.all(16)',
  'shape': 'RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))'
})

```

#### 混入

`未实现`

```dart
@Mixin('CardStyle', ['Card', 'Container'], {
  'elevation': 8,
  'shape': 'RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))'
})

```

---

## 🔧 配置

### VS Code 配置

`dsl_flutter setup` 会自动创建以下配置：

```json
// .vscode/settings.json
{
  "[dart]": {
    "editor.formatOnSave": true
  },
  "[dui]": {
    "editor.formatOnSave": false,
    "editor.tabSize": 2,
    "editor.insertSpaces": true
  },
  "files.associations": {
    "*.dui": "dart"
  }
}
```

```editorconfig
// .editorconfig
[*.dui]
indent_style = space
indent_size = 2
max_line_length = off
```

### build.yaml

```yaml
targets:
  $default:
    builders:
      dsl_flutter|dslBuilder:
        enabled: true
        generate_for:
          - lib/**/*.dui
```

---

## 📚 CLI 命令

```bash
dsl_flutter --help       # 显示帮助
dsl_flutter setup        # 配置开发环境
dsl_flutter init         # 初始化项目
dsl_flutter watch        # 监听文件并自动转换
dsl_flutter build        # 一次性构建所有文件
dsl_flutter check        # 检查文件格式
```

---

## 💝 捐赠支持

如果您觉得 DSL Flutter 对您有帮助，欢迎捐赠支持项目持续发展！

<table>
  <tr>
    <td align="center" width="50%">
      <h3>支付宝</h3>
      <img src="./assets/alipay_qr.jpg" width="200" alt="支付宝收款码">
      <p><small>支付宝扫码捐赠</small></p>
    </td>
    <td align="center" width="50%">
      <h3>微信支付</h3>
      <img src="./assets/wechat_qr.jpg" width="200" alt="微信收款码">
      <p><small>微信扫码捐赠</small></p>
    </td>
  </tr>
</table>

## 🤝 贡献

欢迎贡献！

1. Fork 仓库
2. 创建功能分支 (`git checkout -b feature/amazing`)
3. 提交更改 (`git commit -m 'Add amazing feature'`)
4. 推送分支 (`git push origin feature/amazing`)
5. 创建 Pull Request

---

## 📄 许可证

本项目采用 [MIT License](LICENSE) 开源。

---

## 💬 交流与支持

- [GitHub Issues](https://github.com/myopz/dsl-flutter/issues) - Bug 报告和功能请求
- [GitHub Discussions](https://github.com/myopz/dsl-flutter/discussions) - 讨论和交流
- [Email](mailto:mr_jianlong@163.com) - 邮件联系 <mr_jianlong@163.com>

---

## ⭐ 支持我们

如果这个项目对你有帮助，请给个 Star ⭐️

[![Star History Chart](https://api.star-history.com/svg?repos=myopz/dsl-flutter&type=Date)](https://star-history.com/#myopz/dsl-flutter&Date)

---
