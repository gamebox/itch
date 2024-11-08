import 'command.dart';

const String version = '1.0.0-rc';

void main(List<String> arguments) async {
  final (command, logger) = getCommand(arguments, version);
  await command.exec(logger);
}
