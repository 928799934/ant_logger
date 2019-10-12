# ant_logger

> 服务端及客户端日志处理
>
> 支持小时分割，周期性删除
>
> 可配合其他日志使用

## Usage

```dart
import 'package:ant_logger/ant_logger.dart';

main() async {
  /// 日志路径
    String path = '.';
    /// 日志主文件名称
    String name = 'cc';
    /// 删除1小时前的日志
    int delay = 1;
    AntLogger logger = AntLogger(path,name,delay);
  
    await logger.start();
    logger.addString('a\n');
    logger.addString('b\n');
    logger.addStringLn('c');
    logger.addStringLn('d');
  
    await logger.stop();
}
```

