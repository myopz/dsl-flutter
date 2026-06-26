import 'dart:io';
import 'package:args/args.dart';
import 'package:ansicolor/ansicolor.dart';
import 'setup.dart';
import 'init.dart';
import 'watch.dart';
import 'build.dart';
import 'check.dart';

/// ANSI颜色支持
final _red = AnsiPen()..red();

/// 命令处理器
class CommandHandler {
  void handle(String command, ArgResults args) {
    switch (command) {
      case 'setup':
        SetupCommand().run(args);
        break;
      case 'init':
        InitCommand().run(args);
        break;
      case 'watch':
        WatchCommand().run(args);
        break;
      case 'build':
        BuildCommand().run(args);
        break;
      case 'check':
        CheckCommand().run(args);
        break;
      default:
        print('${_red('❌ 未知命令:')} $command');
        print('使用 --help 查看帮助');
        exit(1);
    }
  }
}