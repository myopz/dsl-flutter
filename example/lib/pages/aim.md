# 转换为 Flutter 代码示例

## 1.简单示例

example/lib/pages/test.dui

### 原始 DSL 代码

example/lib/pages/test.dui

```dart
import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold
      appBar: AppBar
        title: Text 'Test'
      body: Center
        child: Text 'Hello DSL'
  }
}
```
### 转换后的 Flutter 代码
```dart
import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test'),
      ),
      body: Center(
        child: Text('Hello DSL'),
      ),
    );
  }
}
```


## 2.复杂示例

example/lib/pages/home.dui

### 原始 DSL 代码

```dart
// example/lib/pages/home.dui
import 'package:flutter/material.dart';
import 'package:dsl_flutter/dsl_flutter.dart';

// ============ 注解定义 ============

@Fragment('UserCard', ['name', 'email', 'avatar'], '''
Card(
  child: Column(
    children: [
      CircleAvatar(
        radius: 40,
        backgroundImage: NetworkImage(avatar),
      ),
      SizedBox(height: 8),
      Text(name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      Text(email, style: TextStyle(color: Colors.grey)),
    ],
  ),
)
''')

// ============ 页面 ============

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();  // ← 加 ;
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  List<String> _items = ['Item 1', 'Item 2', 'Item 3'];

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  void _addItem() {
    setState(() {
      _items.add('Item ${_items.length + 1}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold
      appBar: AppBar
        title: Text 'DSL Flutter Demo'
        backgroundColor: Theme.of(context).colorScheme.inversePrimary
        elevation: 0
        actions: [
          IconButton
            icon: Icon Icons.refresh
            onPressed: () {
              setState(() {
                _items.clear();  // ← 加 ;
                _items.addAll(['Item 1', 'Item 2', 'Item 3']);  // ← 加 ;
              });
            }
        ]
      body: Column
        children: [
          // 计数器区域
          Container
            padding: EdgeInsets.all(16)
            color: Theme.of(context).colorScheme.primaryContainer
            child: Row
              mainAxisAlignment: MainAxisAlignment.spaceAround
              children: [
                Column
                  children: [
                    Text '点击次数'
                      style: TextStyle(fontSize: 14, color: Colors.grey)
                    Text '$_counter'
                      style: Theme.of(context).textTheme.headlineMedium
                  ]
                ElevatedButton
                  onPressed: _increment
                  child: Text '增加'
                TextButton
                  onPressed: _addItem
                  child: Text '添加项目'
              ]

          // 列表区域
          Expanded
            child: ListView.builder
              itemCount: _items.length
              itemBuilder: (context, index) {
                return _buildItem(_items[index], index);  // ← 加 ;
              }

          // 底部卡片（使用片段）
          @UserCard
            name: '张三'
            email: 'zhangsan@example.com'
            avatar: 'https://i.pravatar.cc/150?img=1'
        ]
      floatingActionButton: FloatingActionButton
        onPressed: _increment
        child: Icon Icons.add;
  }

  Widget _buildItem(String title, int index) {
    return Card
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4)
      child: ListTile
        leading: CircleAvatar
          child: Text '${index + 1}'
        title: Text title
        trailing: IconButton
          icon: Icon Icons.delete
          onPressed: () {
            setState(() {
              _items.removeAt(index);  // ← 加 ;
            });
          }
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('点击了: $title'))
          );
        };
  }
}

```

### 转换后的 Flutter 代码
```dart
// example/lib/pages/home.dui
import 'package:flutter/material.dart';

// ============ 页面 ============
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState(); // ← 加 ;
}

class _HomePageState extends State<HomePage> {
  int _counter = 0;
  List<String> _items = ['Item 1', 'Item 2', 'Item 3'];

  void _increment() {
    setState(() {
      _counter++;
    });
  }

  void _addItem() {
    setState(() {
      _items.add('Item ${_items.length + 1}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('DSL Flutter Demo'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _items.clear(); // ← 加 ;
                _items.addAll(['Item 1', 'Item 2', 'Item 3']); // ← 加 ;
              });
            },
          ),
        ],
      ),

      body: Column(
        children: [
          // 计数器区域
          Container(
            padding: EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    Text(
                      '点击次数',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      '$_counter',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
                ElevatedButton(onPressed: _increment, child: Text('增加')),
                TextButton(onPressed: _addItem, child: Text('添加项目')),
              ],
            ),
          ),

          // 列表区域
          Expanded(
            child: ListView.builder(
              itemCount: _items.length,
              itemBuilder: (context, index) {
                return _buildItem(_items[index], index); // ← 加 ;
              },
            ),
          ),

          // 底部卡片（使用片段）
          Card(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=1'),
                ),
                SizedBox(height: 8),
                Text('张三', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('zhangsan@example.com', style: TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
        floatingActionButton: FloatingActionButton(
          onPressed: _increment,
          child: Icon(Icons.add),
        ),
    );
  }

  Widget _buildItem(String title, int index) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(child: Text('${index + 1}')),
        title: Text(title),
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            setState(() {
              _items.removeAt(index); // ← 加 ;
            });
          },
        ),
        onTap: () {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('点击了: $title')));
        },
      ),
    );
  }
}
```