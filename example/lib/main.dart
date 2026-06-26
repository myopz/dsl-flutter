// example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:dsl_flutter/dsl_flutter.dart';

// 导入生成的DSL文件
import 'pages/test.dsl.dart';
import 'pages/home.dsl.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DSL Flutter Demo',
      theme: DSLTheme.lightTheme,
      darkTheme: DSLTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const MainPage(),
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          // 使用DSL生成的Widget
          TestPage(),
          HomePage(),
          SettingsPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: '测试',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: '设置',
          ),
        ],
      ),
    );
  }
}

// ============ 设置页面（传统的写法和DSL对比） ============

/// 传统写法 - 嵌套地狱
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('深色模式'),
            trailing: Switch(
              value: false,
              onChanged: (value) {},
            ),
          ),
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('通知'),
            trailing: Switch(
              value: true,
              onChanged: (value) {},
            ),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('语言'),
            trailing: const Text('简体中文'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('隐私'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info),
            title: const Text('关于'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}