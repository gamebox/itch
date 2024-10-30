import 'a_command.dart';
import 'command.dart';

const String version = '1.0.0-rc';

void main(List<String> arguments) async {
  ACommand command = getCommand(arguments, version);
  await command.exec();
}
