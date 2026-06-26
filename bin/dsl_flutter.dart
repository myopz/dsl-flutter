#!/usr/bin/env dart

import 'dart:io';
import 'package:args/command_runner.dart';
import 'package:ansicolor/ansicolor.dart';
import 'package:dsl_flutter/src/cli/commands.dart';

/// ANSI颜色支持
final _cyan = AnsiPen()..cyan();
final _green = AnsiPen()..green();
final _red = AnsiPen()..red();

/// 自定义 CommandRunner，重写 usage 以支持颜色
class DslCommandRunner extends CommandRunner {
  DslCommandRunner() : super('dsl_flutter', 'DSL Flutter CLI - 让Flutter开发更简单');

  @override
  String get usage {
    return '''
${_cyan('DSL Flutter CLI')} - 让Flutter开发更简单

用法: dsl_flutter <command> [options]

${_green('Commands:')}
  setup   配置开发环境（一键创建 .editorconfig 和 VS Code 配置）
  init    初始化 DSL 项目结构
  watch   监听并转换 DSL 文件
  build   一次性转换所有 DSL 文件
  check   检查 DSL 文件是否被格式化破坏

${_green('Options:')}
  -h, --help     显示帮助信息
  --version      显示版本信息

${_green('Examples:')}
  dsl_flutter setup          # 配置开发环境
  dsl_flutter init           # 初始化项目
  dsl_flutter watch          # 监听并转换
  dsl_flutter build          # 一次性构建
  dsl_flutter check          # 检查格式

${_green('Quick Start:')}
  dart pub global activate dsl_flutter
  dsl_flutter setup
  flutter pub run build_runner watch
''';
  }
}

void main(List<String> args) {
  final runner = DslCommandRunner()
    ..addCommand(SetupCommand())
    ..addCommand(InitCommand())
    ..addCommand(WatchCommand())
    ..addCommand(BuildCommand())
    ..addCommand(CheckCommand());

  // 通过 argParser 添加全局选项
  runner.argParser.addFlag('version', negatable: false, help: '显示版本信息');

  // 处理版本号
  if (args.contains('--version')) {
    print('dsl_flutter version 1.0.0');
    return;
  }

  try {
    runner.run(args).catchError((error) {
      if (error is! UsageException) throw error;
      print('${_red('❌ 错误:')} ${error.message}');
      print('');
      print(runner.usage);
      exit(1);
    });
  } catch (error) {
    if (error is UsageException) {
      print('${_red('❌ 错误:')} ${error.message}');
      print('');
      print(runner.usage);
      exit(1);
    }
    print('${_red('❌ 错误:')} $error');
    exit(1);
  }
}

/// setup 命令
class SetupCommand extends Command {
  @override
  String get name => 'setup';

  @override
  String get description => '配置开发环境（创建 .editorconfig 和 VS Code 配置）';

  SetupCommand() {
    // 可以添加命令特有的选项
    // argParser.addFlag('force', abbr: 'f', help: '强制覆盖已有文件');
  }

  @override
  void run() {
    final commandHandler = CommandHandler();
    commandHandler.handle(name, argResults!);
  }
}

/// init 命令
class InitCommand extends Command {
  @override
  String get name => 'init';

  @override
  String get description => '初始化 DSL 项目结构';

  @override
  void run() {
    final commandHandler = CommandHandler();
    commandHandler.handle(name, argResults!);
  }
}

/// watch 命令
class WatchCommand extends Command {
  @override
  String get name => 'watch';

  @override
  String get description => '监听并转换 DSL 文件';

  @override
  List<String> get aliases => ['w'];

  @override
  void run() {
    final commandHandler = CommandHandler();
    commandHandler.handle(name, argResults!);
  }
}

/// build 命令
class BuildCommand extends Command {
  @override
  String get name => 'build';

  @override
  String get description => '一次性转换所有 DSL 文件';

  @override
  List<String> get aliases => ['b'];

  @override
  void run() {
    final commandHandler = CommandHandler();
    commandHandler.handle(name, argResults!);
  }
}

/// check 命令
class CheckCommand extends Command {
  @override
  String get name => 'check';

  @override
  String get description => '检查 DSL 文件是否被格式化破坏';

  @override
  void run() {
    final commandHandler = CommandHandler();
    commandHandler.handle(name, argResults!);
  }
}