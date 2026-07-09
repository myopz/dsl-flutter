// test/dsl_parser_test.dart
//
// Automated test suite for DSLParser.
// Run with: dart test
//
// Covers: simple widget trees, leaf args, property classification, list
// literals, block bodies, class members, @Fragment,
// comments, Widget.method, inline semicolons, and golden tests.

import 'dart:io';

import 'package:dsl_flutter/src/core/dsl_parser.dart';
import 'package:test/test.dart';

void main() {
  late DSLParser parser;

  setUp(() {
    parser = DSLParser();
  });

  // Helper: strip the auto-generated header comment block from output
  // so assertions focus on the transformed code, not the timestamp.
  String stripHeader(String output) {
    final lines = output.split('\n');
    final start = lines.indexWhere((l) => !l.startsWith('//') && l.trim().isNotEmpty);
    return lines.sublist(start < 0 ? 0 : start).join('\n');
  }

  // ─────────────────────────────────────────────────────────────────
  group('Simple widget tree', () {
    test('Scaffold with AppBar and body', () {
      final input = '''
return Scaffold
  appBar: AppBar
    title: Text 'Test'
  body: Center
    child: Text 'Hello'
''';
      final output = parser.parse(input);
      expect(output, contains('return Scaffold('));
      expect(output, contains('appBar: AppBar('));
      expect(output, contains("title: Text('Test'),"));
      expect(output, contains('body: Center('));
      expect(output, contains("child: Text('Hello'),"));
      expect(output, contains(');'));
    });

    test('return statement terminator present', () {
      final input = '''
return Scaffold
  body: Text 'Hi'
''';
      final output = parser.parse(input);
      expect(output, contains(');'));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  group('Leaf widget arg conversion', () {
    test("Text 'Hello' → Text('Hello')", () {
      final input = '''
return Scaffold
  body: Text 'Hello'
''';
      final output = parser.parse(input);
      expect(output, contains("Text('Hello')"));
    });

    test('Icon Icons.add → Icon(Icons.add)', () {
      final input = '''
return Scaffold
  body: Icon Icons.add
''';
      final output = parser.parse(input);
      expect(output, contains('Icon(Icons.add)'));
    });

    test('widget with existing parens preserved (no double parens)', () {
      final input = '''
return Scaffold
  body: Text('Already')
''';
      final output = parser.parse(input);
      expect(output, contains("Text('Already')"));
      expect(output, isNot(contains("Text(('Already'))")));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  group('Property value classification', () {
    test('numeric value not treated as widget', () {
      final input = '''
return Scaffold
  appBar: AppBar
    elevation: 0
''';
      final output = parser.parse(input);
      expect(output, contains('elevation: 0,'));
      expect(output, isNot(contains('elevation: 0(')));
    });

    test('method reference not treated as widget', () {
      final input = '''
return Scaffold
  floatingActionButton: FloatingActionButton
    onPressed: _increment
''';
      final output = parser.parse(input);
      expect(output, contains('onPressed: _increment,'));
      expect(output, isNot(contains('onPressed: _increment(')));
    });

    test('Theme.of(context) expression on one line', () {
      final input = '''
return Scaffold
  appBar: AppBar
    backgroundColor: Theme.of(context).colorScheme.inversePrimary
''';
      final output = parser.parse(input);
      expect(output,
          contains('backgroundColor: Theme.of(context).colorScheme.inversePrimary'));
    });

    test('MainAxisAlignment.spaceAround not treated as widget', () {
      final input = '''
return Scaffold
  body: Row
    mainAxisAlignment: MainAxisAlignment.spaceAround
''';
      final output = parser.parse(input);
      expect(output, contains('mainAxisAlignment: MainAxisAlignment.spaceAround,'));
      expect(output, isNot(contains('MainAxisAlignment.spaceAround(')));
    });

    test('EdgeInsets.all(16) as property value', () {
      final input = '''
return Scaffold
  body: Container
    padding: EdgeInsets.all(16)
''';
      final output = parser.parse(input);
      expect(output, contains('padding: EdgeInsets.all(16),'));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  group('List literals', () {
    test('actions list with IconButton children', () {
      final input = '''
return Scaffold
  appBar: AppBar
    actions: [
      IconButton
        icon: Icon Icons.refresh
    ]
''';
      final output = parser.parse(input);
      expect(output, contains('actions: ['));
      expect(output, contains('IconButton('));
      expect(output, contains('],'));
    });

    test('children list with multiple widgets', () {
      final input = '''
return Scaffold
  body: Column
    children: [
      Text 'First'
      Text 'Second'
    ]
''';
      final output = parser.parse(input);
      expect(output, contains('children: ['));
      expect(output, contains("Text('First')"));
      expect(output, contains("Text('Second')"));
      expect(output, contains('],'));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  group('Block bodies', () {
    test('setState body emitted verbatim', () {
      final input = '''
class _State extends State<Widget> {
  void _increment() {
    setState(() {
      _counter++;
    });
  }
}
''';
      final output = parser.parse(input);
      expect(output, contains('_counter++;'));
      expect(output, isNot(contains('_counter++,')));
    });

    test('lambda property body emitted verbatim', () {
      final input = '''
return Scaffold
  floatingActionButton: FloatingActionButton
    onPressed: () {
      _items.clear();
    }
''';
      final output = parser.parse(input);
      expect(output, contains('_items.clear();'));
    });

    test('itemBuilder lambda body emitted verbatim', () {
      final input = '''
return Scaffold
  body: ListView.builder
    itemCount: _items.length
    itemBuilder: (context, index) {
      return _buildItem(_items[index], index);
    }
''';
      final output = parser.parse(input);
      expect(output, contains('return _buildItem(_items[index], index);'));
    });

    test('method body emitted verbatim', () {
      final input = '''
class _State extends State<Widget> {
  void _addItem() {
    setState(() {
      _items.add('New');
    });
  }
}
''';
      final output = parser.parse(input);
      expect(output, contains("_items.add('New');"));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  group('Class members', () {
    test('constructor emitted verbatim (no trailing comma)', () {
      final input = '''
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}
''';
      final output = parser.parse(input);
      expect(output, contains('const HomePage({super.key});'));
      expect(output, isNot(contains('const HomePage({super.key}),')));
    });

    test('field declaration emitted verbatim', () {
      final input = '''
class _State extends State<Widget> {
  int _counter = 0;
}
''';
      final output = parser.parse(input);
      expect(output, contains('int _counter = 0;'));
    });

    test('arrow method emitted verbatim', () {
      final input = '''
class HomePage extends StatefulWidget {
  State<HomePage> createState() => _HomePageState();
}
''';
      final output = parser.parse(input);
      expect(output, contains('State<HomePage> createState() => _HomePageState();'));
    });

    test('list field declaration emitted verbatim', () {
      final input = '''
class _State extends State<Widget> {
  List<String> _items = ['Item 1', 'Item 2', 'Item 3'];
}
''';
      final output = parser.parse(input);
      expect(output, contains("List<String> _items = ['Item 1', 'Item 2', 'Item 3'];"));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  group('@Fragment', () {
    test('@UserCard expansion with param substitution', () {
      final input = """
@Fragment('UserCard', ['name'], '''
Text(name)
''')

return Scaffold
  body: Column
    children: [
      @UserCard
        name: '张三'
    ]
""";
      final output = parser.parse(input);
      expect(output, contains("Text('张三')"));
      expect(output, isNot(contains('@UserCard')));
      expect(output, isNot(contains('UserCard(')));
    });

    test('fragment with URL param (colon in value)', () {
      final input = """
@Fragment('UserCard', ['avatar'], '''
CircleAvatar(backgroundImage: NetworkImage(avatar))
''')

return Scaffold
  body: Column
    children: [
      @UserCard
        avatar: 'https://example.com/img.jpg'
    ]
""";
      final output = parser.parse(input);
      expect(output, contains('https://example.com/img.jpg'));
    });

    test('@Fragment definition NOT in output', () {
      final input = """
@Fragment('UserCard', ['name'], '''
Text(name)
''')

return Scaffold
  body: Text 'Hi'
""";
      final output = parser.parse(input);
      expect(output, isNot(contains('@Fragment(')));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  group('Comments', () {
    test('comment line preserved verbatim (no comma)', () {
      final input = '''
// This is a comment
return Scaffold
  body: Text 'Hi'
''';
      final output = parser.parse(input);
      expect(output, contains('// This is a comment'));
      expect(output, isNot(contains('// This is a comment,')));
    });

    test('inline comment preserved', () {
      final input = '''
class _State extends State<Widget> {
  int _counter = 0;  // counter field
}
''';
      final output = parser.parse(input);
      expect(output, contains('// counter field'));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  group('Widget.method names', () {
    test('ListView.builder recognized as widget', () {
      final input = '''
return Scaffold
  body: ListView.builder
    itemCount: _items.length
''';
      final output = parser.parse(input);
      expect(output, contains('body: ListView.builder('));
    });

    test('Widget.method not split at the dot', () {
      final input = '''
return Scaffold
  body: ListView.builder
    itemCount: 10
''';
      final output = parser.parse(input);
      expect(output, contains('ListView.builder('));
      expect(output, isNot(contains('ListView(.builder')));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  group('Inline semicolons', () {
    test("child: Icon Icons.add; → ; not inside parens", () {
      final input = '''
return Scaffold
  body: Icon Icons.add;
''';
      final output = parser.parse(input);
      expect(output, contains('Icon(Icons.add)'));
      expect(output, isNot(contains('Icon(Icons.add;)')));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  group('Golden: test.dui', () {
    test('test.dui produces expected Scaffold/AppBar/Text structure', () {
      final file = File('example/lib/pages/test.dui');
      final input = file.readAsStringSync();
      final output = parser.parse(input);

      expect(output, contains('import '));
      expect(output, contains('class TestPage extends StatelessWidget {'));
      expect(output, contains('return Scaffold('));
      expect(output, contains('appBar: AppBar('));
      expect(output, contains("title: Text('Test'),"));
      expect(output, contains('body: Center('));
      expect(output, contains("child: Text('Hello DSL'),"));
      expect(output, contains(');'));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  group('Golden: home.dui', () {
    test('home.dui produces expected transformation', () {
      final file = File('example/lib/pages/home.dui');
      final input = file.readAsStringSync();
      final output = parser.parse(input);

      // Aliases applied
      expect(output, contains('ElevatedButton('));
      expect(output, contains('TextButton('));
      expect(output, contains('Card('));

      // Fragment expanded
      expect(output, contains("Text('张三'"));
      expect(output, contains('zhangsan@example.com'));

      // Default params injected
      expect(output, contains('style: TextStyle(fontSize: 16'));

      // Annotations removed
      expect(output, isNot(contains('@Fragment(')));

      // Block bodies preserved
      expect(output, contains('_counter++;'));
      expect(output, contains('_items.clear();'));

      // Class members preserved
      expect(output, contains('const HomePage({super.key});'));

      // ListView.builder
      expect(output, contains('ListView.builder('));
    });
  });
}
