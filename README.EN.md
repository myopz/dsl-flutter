<h1 align="center">
DSL Flutter 🚀
</h1>

<p align="center">
  Say goodbye to bracket hell. Write Flutter with indentation!
</p>

<p align="center">
  <a href="https://pub.dev/packages/dsl_flutter">
    <img src="https://img.shields.io/pub/v/dsl_flutter.svg" alt="Pub Version">
  </a>
  <a href="https://github.com/myopz/dsl-flutter/actions">
    <img src="https://img.shields.io/github/actions/workflow/status/myopz/dsl-flutter/test.yml?branch=main" alt="Build Status">
  </a>
  <a href="https://codecov.io/gh/myopz/dsl-flutter">
    <img src="https://img.shields.io/codecov/c/github/myopz/dsl-flutter" alt="Code Coverage">
  </a>
  <a href="https://github.com/myopz/dsl-flutter/blob/main/LICENSE">
    <img src="https://img.shields.io/github/license/myopz/dsl-flutter" alt="License">
  </a>
  <a href="https://github.com/myopz/dsl-flutter/stargazers">
    <img src="https://img.shields.io/github/stars/myopz/dsl-flutter" alt="Stars">
  </a>
  <a href="https://github.com/myopz/dsl-flutter/issues">
    <img src="https://img.shields.io/github/issues/myopz/dsl-flutter" alt="Issues">
  </a>
  <a href="https://github.com/myopz/dsl-flutter/forks">
    <img src="https://img.shields.io/github/forks/myopz/dsl-flutter" alt="Forks">
  </a>
</p>

<p align="center">
  <a href="#-features">Features</a> |
  <a href="#-installation">Installation</a> |
  <a href="#-quick-start">Quick Start</a> |
  <a href="#-syntax-guide">Syntax Guide</a> |
  <a href="#-advanced-features">Advanced Features</a> |
  <a href="#-configuration">Configuration</a> |
  <a href="#-cli-commands">CLI Commands</a> |
  <a href="#-donate">Donate</a> |
  <a href="#-contributing">Contributing</a> |
  <a href="#-license">License</a>
</p>

---

## ✨ Features

- 🎯 **Zero Brackets** - No more `(`, `)`, nesting hell
- 📦 **Indentation as Hierarchy** - Express widget tree with indentation
- 🎨 **Component Aliases** - Create short aliases for common widgets
- 🧩 **Template Fragments** - Reusable UI structures (DRY)
- ⚡ **Compile-time** - Zero runtime overhead
- 🔌 **Universal** - Works with all Flutter and third-party widgets
- 🛡️ **Formatter Protection** - One-command setup to prevent IDE formatting issues
- 🧪 **Fully Tested** - 100% test coverage guarantee

---

## 📦 Installation

### Option 1: Add to project (Recommended)

```yaml
dev_dependencies:
  dsl_flutter: ^1.0.0
  build_runner: ^2.4.0
```

Then run:

```bash
flutter pub get
```

### Option 2: Global CLI installation

```bash
dart pub global activate dsl_flutter
```

---

## 🚀 Quick Start

### 1. Setup development environment

```bash
dsl_flutter setup
```

### 2. Create a DSL file

Create `lib/pages/home.dui`:

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
            Text 'Click count'
            Text '$_counter'
              style: Theme.of(context).textTheme.headlineMedium
            PrimaryButton
              onPressed: _increment
              child: Text 'Increment'
          ]
      floatingActionButton: FloatingActionButton
        onPressed: _increment
        child: Icon Icons.add
  }
}
```

### 3. Run code generation

```bash
flutter pub run build_runner build
```

### 4. Use generated code

```dart
import 'pages/home.dsl.dart';

// Use directly
HomePage()
```

---

## 📝 Syntax Guide

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
Scaffold
  appBar: AppBar
    title: Text 'Home'
    backgroundColor: Colors.blue
  body: Column
    children: [
      Text 'Title'
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
### Basic Widget

```dart
Container
  padding: EdgeInsets.all(16)
  child: Text 'Hello'
```
### Widgets with Parameters

```dart
Text 'Hello World'
  style: TextStyle
    fontSize: 20
    fontWeight: FontWeight.bold
    color: Colors.blue
```

### Custom Widgets

```dart
MyCustomWidget
  title: 'Custom'
  onTap: _handleTap
  child: Text 'Content'
```

### Conditional Rendering

```dart
Column
  children: [
    if (isLoggedIn){
      Text 'Welcome back'
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

## 🎨 Advanced Features

### Component Aliases

```dart
@Alias('PrimaryButton', target: 'ElevatedButton')
@Alias('SecondaryButton', target: 'TextButton')

// Usage
PrimaryButton(
  onPressed: _onTap
  child: Text 'Submit'
)
```


### Template Fragments (Two Calling Styles)

#### Define Fragment

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

#### Prefix Call (no parentheses!)

```dart
@UserCard(
  name: 'John Doe'
  email: 'john@example.com'
  avatar: 'https://example.com/avatar.jpg'
)
```

### TODO

#### Default Parameters

not implemented

```dart
@Default('Card', {
  'elevation': 4,
  'margin': 'EdgeInsets.all(16)',
  'shape': 'RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))'
})

#### Mixins

```dart
@Mixin('CardStyle', ['Card', 'Container'], {
  'elevation': 8,
  'shape': 'RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))'
})

```

---

## 🔧 Configuration

### VS Code Configuration

`dsl_flutter setup` automatically creates these configurations:

```json
// .vscode/settings.json
{
  "[dart]": {
    "editor.formatOnSave": true
  },
  "[dart-ui]": {
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

## 📚 CLI Commands

```bash
dsl_flutter --help       # Show help
dsl_flutter setup        # Setup development environment
dsl_flutter init         # Initialize project
dsl_flutter watch        # Watch files and auto-convert
dsl_flutter build        # Build all files once
dsl_flutter check        # Check file formatting
```

---

## 🔗 Documentation

- [Example Project](https://github.com/myopz/dsl-flutter/tree/main/example)
- [Changelog](https://github.com/myopz/dsl-flutter/blob/main/CHANGELOG.md)

---

## 💝 Donate

If DSL Flutter has been helpful to you, please consider donating to support the project's continued development!

### Scan to Donate

<table>
  <tr>
    <td align="center" width="50%">
      <h3>Alipay</h3>
      <img src="./assets/alipay_qr.jpg" width="200" alt="Alipay QR Code">
      <p><small>Scan with Alipay</small></p>
    </td>
    <td align="center" width="50%">
      <h3>WeChat Pay</h3>
      <img src="./assets/wechat_qr.jpg" width="200" alt="WeChat QR Code">
      <p><small>Scan with WeChat</small></p>
    </td>
  </tr>
</table>


---

## 🤝 Contributing

Contributions are welcome!

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing`)
5. Open a Pull Request

---


## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 💬 Community & Support

- [GitHub Issues](https://github.com/myopz/dsl-flutter/issues) - Bug reports & feature requests
- [GitHub Discussions](https://github.com/myopz/dsl-flutter/discussions) - Discussions & Q&A
- [Email](mailto:mr_jianlong@163.com) - Contact via email <mr_jianlong@163.com>

---

## ⭐ Support Us

If this project helps you, please give it a Star ⭐️

[![Star History Chart](https://api.star-history.com/svg?repos=myopz/dsl-flutter&type=Date)](https://star-history.com/#myopz/dsl-flutter&Date)

---