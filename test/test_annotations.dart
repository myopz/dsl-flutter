import 'dart:io';
import 'package:dsl_flutter/src/core/dsl_parser.dart';

void main() {
  final parser = DSLParser();
  final input = File('example/lib/pages/home.dui').readAsStringSync();
  final output = parser.parse(input);

  // Check if aliases were applied
  print('Contains PrimaryButton: ${output.contains('PrimaryButton')}');
  print('Contains ElevatedButton: ${output.contains('ElevatedButton')}');
  print('Contains UserCard: ${output.contains('UserCard')}');
  print('Contains MainCard: ${output.contains('MainCard')}');
  print('Contains Card(: ${output.contains('Card(')}');
}
