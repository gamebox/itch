import 'dart:io';

import './ansi.dart';

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

_LogLevel _logLevelfromString(String level) => switch (level) {
      "debug" => _LogLevel.debug,
      "info" => _LogLevel.info,
      "warn" => _LogLevel.warn,
      "error" => _LogLevel.error,
      "fatal" => _LogLevel.fatal,
      _ => _LogLevel.quiet,
    };

class LoggerImpl {
  _LogLevel _logLevel = _LogLevel.quiet;
  IOSink? sink;

  String get logLevel => _logLevel.name;

  LoggerImpl({required String level, this.sink})
      : _logLevel = _logLevelfromString(level);

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
        print("Did not find log level: '$level'");
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
      _print(warnPen(message));
    }
  }

  void error(String message) {
    if (_logLevel <= _LogLevel.error) {
      _print(errorPen(message));
    }
  }

  void fatal(String message) {
    if (_logLevel <= _LogLevel.fatal) {
      _print(errorPen(message));
    }
  }
}
