import 'isolate.dart';

abstract class AntLogger {
  factory AntLogger(String path, String name, int delay) =>
      _AntLogger._(path, name, delay);
  external Future<void> start();
  external Future<void> stop();
  external void addString(String msg);
  external void addStringLn(String msg);
  external String get filepath;
}

class _AntLogger implements AntLogger {
  final String path;
  final String name;
  final int delay;

  final cleanIsolate _cleaner;
  final writeIsolate _writer;

  _AntLogger._(this.path, this.name, this.delay)
      : _cleaner = cleanIsolate(),
        _writer = writeIsolate();

  Future<void> start() async {
    await this._cleaner.start(this.path, this.name, this.delay);
    await this._writer.start(this.path, this.name);
  }

  Future<void> stop() async {
    await this._cleaner.stop();
    await this._writer.stop();
  }

  void addString(String msg) {
    this._writer.addString(msg);
  }

  void addStringLn(String msg) {
    this._writer.addStringLn(msg);
  }

  String get filepath => this._writer.path;
}
