import 'dart:io';
import "dart:async";
import "dart:isolate";

Future cleaning(List args) async {
  SendPort port = (args[0] as SendPort);

  String path = (args[1] as String);
  String name = (args[2] as String);
  int delay = (args[3] as int);

  final receive = ReceivePort();
  port.send(receive.sendPort);

  cleaner c = cleaner(path, name, delay);
  c.working();

  Timer t = Timer.periodic(Duration(hours: 1), (_) {
    c.working();
  });

  receive.listen((msg) {
    var data = msg[0];
    SendPort replyTo = msg[1];

    switch (data[0]) {
      case 'close':
        t.cancel();
        receive.close();
        replyTo.send(['closed']);
        break;
      default:
        break;
    }
  });
}

class cleaner {
  /// 日志所在目录
  final String path;

  /// 日志文件名称
  final String name;

  /// 延迟小时
  final int delay;

  cleaner._(this.path, this.name, this.delay);

  factory cleaner(String path, String name, int delay) =>
      cleaner._(path, name, delay);

  /// working 工作线程
  void working() {
    /// 生成文件路径特征
    String name = '${this.path}/${this.name}.';
    if (FileSystemEntity.isFileSync(this.path)) {
      return;
    }

    /// 遍历目录
    List<FileSystemEntity> files = Directory(this.path).listSync();
    for (var f in files) {
      /// 特征不符合
      if (!f.path.contains(name)) {
        continue;
      }

      /// 切割目录 规则不符合跳过
      List<String> arr = f.path.split(name);
      if (arr.length != 2) {
        continue;
      }

      /// 切割日期 规则不符合跳过
      arr = arr[1].split('-');
      if (arr.length != 4) {
        continue;
      }

      /// 时间对比 delay 小时前的文件将被删除
      var time = '${arr[0]}-${arr[1]}-${arr[2]} ${arr[3]}:00:00';
      DateTime old = DateTime.tryParse(time);
      DateTime now = DateTime.now();
      if (now.subtract(Duration(hours: this.delay)).isAfter(old)) {
        f.deleteSync();
        assert(f.existsSync() == false);
      }
    }
    return;
  }
}
