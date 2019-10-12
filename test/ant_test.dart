import 'dart:io';
import 'package:ant_logger/ant_logger.dart';
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    AntLogger logger = AntLogger('.','cc',1);

    setUp(() async {
      await logger.start();
      logger.addString('test');
    });

    test('read Test', () async {
      await logger.stop();
      var file = File(logger.filepath);
      print(await file.exists());
      var context = file.readAsStringSync();
      expect(context, 'test');
      file.deleteSync();
    });
  });
}
