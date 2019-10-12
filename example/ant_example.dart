import 'package:ant_logger/ant_logger.dart';

main() async {
  /// 日志路径
  String path = '.';
  /// 日志主文件名称
  String name = 'cc';
  /// 删除周期(小时)
  int delay = 1;
  AntLogger logger = AntLogger(path,name,delay);

  await logger.start();
  logger.addString('a\n');
  logger.addString('b\n');
  logger.addStringLn('c');
  logger.addStringLn('d');

  await logger.stop();
}
