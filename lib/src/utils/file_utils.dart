import 'dart:io';
import 'package:path/path.dart' as path;

/// 文件工具类
class FileUtils {
  /// 递归查找所有匹配的文件
  static List<String> findFiles(String rootDir, String pattern) {
    final files = <String>[];
    final dir = Directory(rootDir);
    if (!dir.existsSync()) return files;

    dir.listSync(recursive: true).forEach((entity) {
      if (entity is File && entity.path.endsWith(pattern)) {
        files.add(entity.path);
      }
    });

    return files;
  }

  /// 确保目录存在
  static void ensureDir(String dirPath) {
    final dir = Directory(dirPath);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// 读取文件内容，如果不存在返回null
  static String? readFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return null;
    return file.readAsStringSync();
  }

  /// 写入文件（自动创建目录）
  static void writeFile(String filePath, String content) {
    final dir = Directory(path.dirname(filePath));
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    File(filePath).writeAsStringSync(content);
  }

  /// 备份文件
  static void backupFile(String filePath) {
    final file = File(filePath);
    if (!file.existsSync()) return;

    final backupPath = '$filePath.bak';
    file.copySync(backupPath);
  }

  /// 恢复备份
  static void restoreBackup(String filePath) {
    final backupPath = '$filePath.bak';
    final backup = File(backupPath);
    if (!backup.existsSync()) return;

    backup.copySync(filePath);
    backup.deleteSync();
  }

  /// 获取相对路径
  static String getRelativePath(String fullPath, {String? baseDir}) {
    final base = baseDir ?? Directory.current.path;
    return path.relative(fullPath, from: base);
  }

  /// 检查文件是否被Git忽略
  static bool isGitIgnored(String filePath) {
    final gitIgnore = File('.gitignore');
    if (!gitIgnore.existsSync()) return false;

    final content = gitIgnore.readAsStringSync();
    final relativePath = getRelativePath(filePath);

    for (final line in content.split('\n')) {
      final pattern = line.trim();
      if (pattern.isEmpty || pattern.startsWith('#')) continue;

      // 简单匹配
      if (relativePath.contains(pattern) ||
          relativePath.contains(pattern.replaceAll('*', ''))) {
        return true;
      }
    }

    return false;
  }
}