import 'package:args/args.dart';

import 'a_command.dart';
import 'compare.dart';
import 'compile.dart';

const String cHelp = 'help';
const String cVersion = 'version';
const String cCompile = 'compile';
const String cCompare = 'compare';

ArgParser _buildParser() {
  return ArgParser()
    ..addCommand(cHelp, ArgParser(allowTrailingOptions: true))
    ..addCommand(cVersion, ArgParser(allowTrailingOptions: false))
    ..addCommand(
      cCompile,
      ArgParser(allowTrailingOptions: true)
        ..addOption(
          'logLevel',
          abbr: 'l',
          mandatory: false,
          help: 'One of: debug, info, warn, error, fatal, quiet',
          defaultsTo: "",
        )
        ..addOption(
          'dir',
          abbr: 'd',
          mandatory: true,
          help: 'The path to a itch project',
        ),
    )
    ..addCommand(
      cCompare,
      ArgParser(allowTrailingOptions: true)
        ..addOption(
          'dir',
          abbr: 'd',
          mandatory: true,
          help: 'The path to a itch project',
        ),
    );
}

class HelpCommand implements ACommand {
  ArgParser parser;
  Map<String, String> commandUsage;

  HelpCommand({required this.parser, required this.commandUsage});

  @override
  Future<bool> exec() async {
    print('Usage: itch <command> [flags] [arguments]');
    print("Commands");
    print("========");
    for (final entry in parser.commands.entries) {
      if (entry.key == cCompare) {
        continue;
      }
      print("${entry.key}\t\t${commandUsage[entry.key]}");
      final usage = entry.value.usage;
      if (usage != "") {
        print("  Command Flags");
        print("  -------------");
        for (final line in usage.split("\n")) {
          print("  $line");
        }
      }
    }
    return true;
  }
}

class VersionCommand implements ACommand {
  String version;

  VersionCommand({required this.version});

  @override
  Future<bool> exec() async {
    print("Itch version $version");
    return true;
  }
}

Map<String, String> commandUsage = {
  cHelp: "Show this help",
  cVersion: "Print the current version of the itch executable",
  cCompile: "Compile a project.  Must supply a path to an itch project",
};

ACommand getCommand(Iterable<String> args, String currentVersion) {
  final p = _buildParser();
  final result = p.parse(args);
  print("Rest:\t${result.rest}");
  switch (result.command?.name) {
    case cVersion:
      return VersionCommand(version: currentVersion);
    case cCompile:
      final logLevel = result.command!.option("logLevel");
      return CompileCommand(
          dir: result.command!.option('dir')!, logLevel: logLevel ?? "");
    case cCompare:
      return CompareCommand(dir: result.command!.option('dir')!);
    default:
      return HelpCommand(parser: p, commandUsage: commandUsage);
  }
}
