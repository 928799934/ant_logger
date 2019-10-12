import 'dart:io';
import "dart:async";
import "dart:isolate";

Future writing(List args) async {
  SendPort port = (args[0] as SendPort);
  String path = (args[1] as String);
  String name = (args[2] as String);

  final receive = ReceivePort();
  port.send(receive.sendPort);

  fileWriter f = fileWriter(path, name);
  receive.listen((msg) {
    var data = msg[0];
    SendPort replyTo = msg[1];

    switch (data[0]) {
      case 'close':
        receive.close();
        replyTo.send(['closed']);
        break;
      case 'msg':
        f.write(data[1]);
        replyTo.send(['ok']);
        break;
      case 'msgln':
        f.writeln(data[1]);
        replyTo.send(['ok']);
        break;
      default:
        break;
    }
  });
}

String hour() {
  DateTime now = DateTime.now();
  return '${now.year.toString()}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}-${now.hour.toString().padLeft(2, '0')}';
}

class fileWriter {
  final String path;

  fileWriter._(this.path);

  factory fileWriter(String path, String name) =>
      fileWriter._('${path}/${name}');

  int write(String msg) {
    File file = File('${this.path}.${hour()}');
    if (!file.existsSync()) {
      file.writeAsStringSync(msg);
      return msg.length;
    }
    int nLen = file.lengthSync();
    file.writeAsStringSync(msg, mode: FileMode.append);
    return file.lengthSync() - nLen;
  }

  int writeln(String msg) {
    return this.write(msg + '\n');
  }
}
