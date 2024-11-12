import 'dart:io';
import 'dart:math';

import 'package:args/args.dart';

import 'a_command.dart';
import 'compare.dart';
import 'compile.dart';
import 'init.dart';
import 'log_level.dart';
import 'import.dart';

const String cHelp = 'help';
const String cVersion = 'version';
const String cCompile = 'compile';
const String cCompare = 'compare';
const String cInit = 'init';
const String cImportProj = 'import-project';

ArgParser _buildParser() {
  return ArgParser()
    ..addOption(
      'logLevel',
      abbr: 'l',
      mandatory: false,
      help: 'One of: debug, info, warn, error, fatal, quiet',
      defaultsTo: "",
    )
    ..addCommand(cHelp, ArgParser(allowTrailingOptions: true))
    ..addCommand(cVersion, ArgParser(allowTrailingOptions: false))
    ..addCommand(
      cCompile,
      ArgParser(allowTrailingOptions: true)
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
    )
    ..addCommand(
      cInit,
      ArgParser(allowTrailingOptions: true)
        ..addOption(
          'dir',
          abbr: 'd',
          mandatory: true,
          help: 'The path to a itch project',
        )
        ..addOption(
          'name',
          abbr: 'n',
          mandatory: true,
          help: 'The name of your project',
        ),
    )
    ..addCommand(
        cImportProj,
        ArgParser()
          ..addOption(
            'src',
            mandatory: true,
            help: 'The Scratch project file you wish to import',
          )
          ..addOption(
            'dest',
            mandatory: false,
            help: 'The path where the new project should be created',
            defaultsTo: '.',
          ));
}

class HelpCommand implements ACommand {
  ArgParser parser;
  ArgResults results;
  Map<String, String> commandUsage;

  HelpCommand({
    required this.parser,
    required this.commandUsage,
    required this.results,
  });

  @override
  Future<bool> exec(LoggerImpl _) async {
    ArgParser? helpForCommand =
        parser.commands[results.command!.rest.firstOrNull ?? ""];
    if (helpForCommand != null) {
      print("itch ${results.command!.rest.first}\n");
      print("${commandUsage[results.command!.rest.first]}\n");
      final usage = helpForCommand.usage;
      if (usage != "") {
        print("Command flags:");
        for (final line in usage.split("\n")) {
          print("  $line");
        }
        print("");
      }
      if (parser.usage != "") {
        print("Global flags:");
        for (final line in parser.usage.split("\n")) {
          print("  $line");
        }
      }
      return true;
    }
    print(
        "itch - a tool for the Itch programming language.  Write Scratch as text!\n");
    print('Usage: itch <command> [flags] [arguments]\n');
    if (parser.usage != "") {
      print("Global flags:");
      for (final line in parser.usage.split("\n")) {
        print("  $line");
      }
      print("");
    }
    print("Available commands:");
    int longestCommandName = parser.commands.keys
        .fold(0, (longest, name) => max(longest, name.length));
    for (final entry in parser.commands.entries) {
      if (entry.key == cCompare) {
        continue;
      }
      print(
          "  ${entry.key.padRight(longestCommandName + 2)}${commandUsage[entry.key]}");
    }
    return true;
  }
}

class VersionCommand implements ACommand {
  String version;

  VersionCommand({required this.version});

  @override
  Future<bool> exec(LoggerImpl _) async {
    print("Itch version $version");
    return true;
  }
}

Map<String, String> commandUsage = {
  cHelp: "Show this help",
  cVersion: "Print the current version of the itch executable",
  cCompile: "Compile a project.  Must supply a path to an itch project",
  cInit: "Start a new project in a new directory with a given name",
  cImportProj: "Import an existing Scratch project into a new Itch project",
};

LoggerImpl getLogger(ArgResults results) {
  return LoggerImpl(level: results.option("logLevel") ?? "");
}

(ACommand, LoggerImpl) getCommand(
    Iterable<String> args, String currentVersion) {
  final p = _buildParser();
  final result = p.parse(args);
  final logger = getLogger(result);
  switch (result.command?.name) {
    case cVersion:
      return (
        VersionCommand(
          version: currentVersion,
        ),
        logger
      );
    case cCompile:
      return (
        CompileCommand(
          dir: result.command!.option('dir') ?? Directory('.').path,
        ),
        logger
      );
    case cCompare:
      return (
        CompareCommand(
          dir: result.command!.option('dir')!,
        ),
        logger
      );
    case cInit:
      return (
        InitCommand(
          projectName: result.command!.option('name')!,
          dir: result.command!.option('dir')!,
        ),
        logger
      );
    case cImportProj:
      return (
        ImportProjectCommand(
          src: result.command!.option('src')!,
          dest: result.command!.option('dest')!,
        ),
        logger
      );
    default:
      return (
        HelpCommand(
          parser: p,
          commandUsage: commandUsage,
          results: result,
        ),
        logger
      );
  }
}
