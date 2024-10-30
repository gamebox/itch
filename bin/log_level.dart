import 'dart:io';

enum _LogLevel {
  debug,
  info,
  warn,
  error,
  fatal,
  quiet;

  bool operator <=(_LogLevel b) {
    return index <= b.index;
  }
}

mixin class Logger {
  _LogLevel _logLevel = _LogLevel.quiet;
  IOSink? sink;

  void setLogLevel(String level) {
    switch (level) {
      case "debug":
        _logLevel = _LogLevel.debug;
        break;
      case "info":
        _logLevel = _LogLevel.info;
        break;
      case "warn":
        _logLevel = _LogLevel.warn;
        break;
      case "error":
        _logLevel = _LogLevel.error;
        break;
      case "fatal":
        _logLevel = _LogLevel.fatal;
        break;
      default:
        _logLevel = _LogLevel.quiet;
        break;
    }
  }

  void setOutput(IOSink s) {
    sink = s;
  }

  void _print(Object msg) {
    if (sink == null) {
      print(msg);
      return;
    }
    sink!.writeln(msg);
  }

  void debug(String message) {
    if (_logLevel <= _LogLevel.debug) {
      _print(message);
    }
  }

  void info(String message) {
    if (_logLevel <= _LogLevel.info) {
      _print(message);
    }
  }

  void warn(String message) {
    if (_logLevel <= _LogLevel.warn) {
      _print(message);
    }
  }

  void error(String message) {
    if (_logLevel <= _LogLevel.error) {
      _print(message);
    }
  }

  void fatal(String message) {
    if (_logLevel <= _LogLevel.fatal) {
      _print(message);
    }
  }
}
