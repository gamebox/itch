import "log_level.dart";

abstract class ACommand {
  Future<bool> exec(LoggerImpl logger);
}
