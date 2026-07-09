# dsl_flutter_example

Example usage of dsl_flutter

### 运行示例

```bash
# 进入example目录
cd example

# 获取依赖
flutter pub get

# 运行构建（生成 .dsl.dart 文件）
flutter pub run build_runner build --delete-conflicting-outputs

# 运行应用
flutter run
```

---

## 文件树

```
example/
  ├── lib/
  │   ├── main.dart
  │   └── pages/
  │       ├── home.dui          ← DSL文件
  │       ├── home.dsl.dart         ← 生成文件（自动）
  │       ├── test.dui       ← DSL文件
  │       └── test.dsl.dart      ← 生成文件（自动）
  ├── pubspec.yaml
  └── build.yaml

```

---

## 用户使用流程

```bash
# 1. 克隆或创建项目
flutter create my_app
cd my_app

# 2. 添加依赖
flutter pub add --dev dsl_flutter build_runner

# 3. 一键配置（防止格式化破坏）
dart pub global activate dsl_flutter
dsl_flutter setup

# 4. 创建 .dui 文件
# 参考 example/lib/pages/home.dui

# 5. 运行构建
flutter pub run build_runner watch

# 6. 在代码中导入生成的 .dsl.dart 文件
import 'pages/home.dsl.dart';
```

---

## 对比：传统 vs DSL

### 传统写法（home.dart）

```dart
Column(
  children: [
    Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Column(
            children: [
              Text('点击次数'),
              Text('$_counter'),
            ],
          ),
          ElevatedButton(
            onPressed: _increment,
            child: Text('增加'),
          ),
        ],
      ),
    ),
    Expanded(
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
              title: Text(_items[index]),
            ),
          );
        },
      ),
    ),
  ],
)
```

### DSL写法（home.dui）

```dart
Column
  children: [
    Container
      padding: EdgeInsets.all 16
      child: Row
        children: [
          Column
            children: [
              Text '点击次数'
              Text '$_counter'
            ]
          ElevatedButton
            onPressed: _increment
            child: Text '增加'
        ]
    Expanded
      child: ListView.builder
        itemCount: _items.length
        itemBuilder: (context, index) {
          return Card
            child: ListTile
              title: Text _items[index]
        }
  ]
```

**代码量减少 40%+，可读性提升明显！** 🚀

## 完整示例（home.dui）

```dart
// home.dui - 完全正确的DSL语法

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState => _HomePageState()  // ✅ 方法调用需要括号
}

class _HomePageState extends State<HomePage> {
  int _counter = 0

  void _increment() {  // ✅ 方法定义需要括号
    setState(() {     // ✅ 匿名函数需要括号
      _counter++
    })
  }

  @override
  Widget build(BuildContext context) {  // ✅ 方法定义需要括号
    return Scaffold  // ❌ Widget创建不需要括号
      appBar: AppBar  // ❌ Widget创建不需要括号
        title: Text 'DSL Demo'  // ❌ Text不需要括号
        backgroundColor: Theme.of(context).colorScheme.inversePrimary  // ✅ 方法调用需要括号
        elevation: 0
      body: Column  // ❌ Widget创建不需要括号
        children: [  // ✅ 集合需要括号
          // 标题区域
          Container  // ❌ Widget创建不需要括号
            padding: EdgeInsets.all(16)  // ✅ 构造函数需要括号
            child: Text '欢迎使用DSL'  // ❌ Text不需要括号
              style: TextStyle  // ❌ Widget创建不需要括号
                fontSize: 24
                fontWeight: FontWeight.bold

          // 计数器
          Center  // ❌ Widget创建不需要括号
            child: Column  // ❌ Widget创建不需要括号
              mainAxisAlignment: MainAxisAlignment.center
              children: [
                Text '点击次数'  // ❌ Text不需要括号
                Text '$_counter'  // ❌ Text不需要括号
                  style: Theme.of(context).textTheme.headlineMedium  // ✅ 方法调用需要括号
                SizedBox height: 20  // ❌ SizedBox不需要括号
                ElevatedButton  // ❌ Widget创建不需要括号（别名展开为ElevatedButton）
                  onPressed: _increment  // 方法引用（无括号）
                  child: Text '增加'  // ❌ Text不需要括号
              ]

          // 卡片
          Card  // ❌ Widget创建不需要括号（自动应用默认参数）
            child: Column  // ❌ Widget创建不需要括号
              children: [
                Text '卡片标题'  // ❌ Text不需要括号
                Text '卡片内容'  // ❌ Text不需要括号
              ]

          // 第三方组件
          CarouselSlider  // ❌ Widget创建不需要括号
            items: [  // ✅ 集合需要括号
              Image.network 'https://picsum.photos/800/400?random=1'  // ❌ Image不需要括号
              Image.network 'https://picsum.photos/800/400?random=2'  // ❌ Image不需要括号
            ]
            options: CarouselOptions  // ❌ Widget创建不需要括号
              height: 200
              autoPlay: true
        ]
      floatingActionButton: FloatingActionButton  // ❌ Widget创建不需要括号
        onPressed: _increment  // 方法引用
        child: Icon Icons.add  // ❌ Icon不需要括号
  }
}

// 辅助方法示例
Widget _buildCustomWidget() {  // ✅ 方法定义需要括号
  return Container  // ❌ Widget创建不需要括号
    padding: EdgeInsets.symmetric(  // ✅ 构造函数需要括号
      horizontal: 16
      vertical: 8
    )
    decoration: BoxDecoration(  // ✅ 构造函数需要括号
      color: Colors.blue
      borderRadius: BorderRadius.circular(8)  // ✅ 静态方法需要括号
    )
    child: Row  // ❌ Widget创建不需要括号
      children: [
        Icon Icons.star  // ❌ Icon不需要括号
          color: Colors.yellow
        Text '评分 4.8'  // ❌ Text不需要括号
      ]
}
```
