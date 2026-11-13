import 'dart:io';

import 'package:dsl_flutter/src/utils/formatter_checker.dart';
import 'package:test/test.dart';

void main() {
  late FormatterChecker checker;

  setUp(() {
    checker = FormatterChecker();
  });

  group('合法 DSL 不应报错', () {
    test('多层 ] / } 缩进回落', () {
      final content = '''
return Scaffold
  appBar: AppBar
    title: Text 'Test'
  body: Column
    children: [
      Text '标题'
      Row
        children: [
          Icon Icons.star
          Text '评分'
          Card
            child: Text '内容'
        ]
    ]
''';
      expect(checker.check(content), isEmpty);
    });

    test('@Fragment 三引号 body 内标准 Dart 不报多余括号', () {
      final content = """
@Fragment('UserCard', ['name'], '''
Card(
  child: Column(
    children: [
      Text(name, style: TextStyle(fontSize: 18)),
    ],
  ),
)
''')

class HomePage extends StatelessWidget {
  Widget build(BuildContext context) {
    return Scaffold
      body: Center
        child: Text 'Hello'
  }
}
""";
      expect(checker.check(content), isEmpty);
    });

    test('TextStyle / EdgeInsets 等方法调用不报错', () {
      final content = '''
return Container
  padding: EdgeInsets.all(16)
  child: Text 'Hi'
    style: TextStyle
      fontSize: 20
      color: Colors.blue
''';
      expect(checker.check(content), isEmpty);
    });

    test('example/*.dui 全部通过', () {
      final pagesDir = Directory('example/lib/pages');
      if (!pagesDir.existsSync()) {
        // 从 package 根目录运行；若不存在则跳过
        return;
      }
      final duiFiles = pagesDir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.dui'));
      expect(duiFiles, isNotEmpty);
      for (final file in duiFiles) {
        final issues = checker.check(file.readAsStringSync());
        expect(issues, isEmpty, reason: '${file.path} 不应有格式问题: $issues');
      }
    });
  });

  group('损坏信号应报错', () {
    test('奇数缩进', () {
      final content = '''
return Scaffold
   body: Center
    child: Text 'Hi'
''';
      final issues = checker.check(content);
      expect(issues, isNotEmpty);
      expect(issues.any((e) => e.contains('缩进')), isTrue);
    });

    test('行尾多余空格', () {
      final content = 'return Scaffold  \n  body: Center\n';
      final issues = checker.check(content);
      expect(issues.any((e) => e.contains('行尾有多余空格')), isTrue);
    });

    test('DSL 区域 Text(\'x\') 报多余括号', () {
      final content = '''
return Scaffold
  body: Center
    child: Text('Hello')
''';
      final issues = checker.check(content);
      expect(issues.any((e) => e.contains('多余的括号')), isTrue);
      expect(issues.any((e) => e.contains('Text')), isTrue);
    });

    test('行首 Text(\'x\') 也能检出', () {
      final content = '''
return Column
  children: [
    Text('Hello')
  ]
''';
      final issues = checker.check(content);
      expect(issues.any((e) => e.contains('多余的括号')), isTrue);
    });
  });
}
