// ═══════════════════════════════════════════════════════════
// 自动生成代码 - 由 dsl_flutter 转换
// 源文件: lib/pages/hell.dui
// 生成时间: 2026-06-26 17:56:30.511659
// 请勿手动修改
// ═══════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

class TestPage extends StatelessWidget {
  const TestPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('首页'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Text('标题'),
          Row(
            children: [
              Icon(Icons.star),
              Text('评分 4.8'),
              Column(
                children: [
                  ElevatedButton(
                    onPressed: () => {},
                    child: Text('点击'),
                  ),
                  Text(
                    'Hello World',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  Card(
                    child: Text('内容'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
