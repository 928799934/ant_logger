import "dart:isolate";

import 'clean.dart';
import 'file.dart';

abstract class cleanIsolate {
  factory cleanIsolate() => _cleanIsolate._();
  external Future<void> start(String path, String name, int delay);
  external Future<void> stop();
}

class _cleanIsolate implements cleanIsolate {
  ReceivePort _receive;
  SendPort _send;
  Isolate _isolate;
  _cleanIsolate._();

  Future<dynamic> _sendReceive(SendPort port, msg) {
    ReceivePort response = ReceivePort();
    port.send([msg, response.sendPort]);
    return response.first;
  }

  Future<void> start(String path, String name, int delay) async {
    _receive = ReceivePort();

    _isolate =
        await Isolate.spawn(cleaning, [_receive.sendPort, path, name, delay]);
    _send = await _receive.first;
  }

  Future<void> stop() {
    return _sendReceive(_send, ['close']).then((msg) {
      if (msg != 'closed') {
        return;
      }
      _send = null;
      _receive.close();
      _isolate?.kill();
      _receive = null;
      _isolate = null;
      print('file close');
      return;
    });
  }
}

abstract class writeIsolate {
  factory writeIsolate() => _writeIsolate._();
  external Future<void> start(String path, String name);
  external Future<void> stop();
  external Future<void> addString(String msg);
  external Future<void> addStringLn(String msg);
  external String get path;
}

class _writeIsolate implements writeIsolate {
  ReceivePort _receive;
  SendPort _send;
  _writeIsolate._();
  String _path;
  Isolate _isolate;

  Future<dynamic> _sendReceive(SendPort port, msg) {
    ReceivePort response = ReceivePort();
    port.send([msg, response.sendPort]);
    return response.first;
  }

  Future<void> start(String path, String name) async {
    _receive = ReceivePort();
    _path = '${path}/${name}';

    _isolate = await Isolate.spawn(writing, [_receive.sendPort, path, name]);
    _send = await _receive.first;
  }

  Future<void> stop() {
    return _sendReceive(_send, ['close']).then((msg) {
      if (msg != 'closed') {
        return;
      }
      _send = null;
      _receive.close();
      _isolate?.kill();
      _receive = null;
      _isolate = null;
      print('file close');
      return;
    });
  }

  Future<void> addString(String msg) {
    return _sendReceive(_send, ['msg', msg]);
  }

  Future<void> addStringLn(String msg) {
    return _sendReceive(_send, ['msgln', msg]);
  }

  String get path => '${_path}.${hour()}';
}
