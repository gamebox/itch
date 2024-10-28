import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';
import 'scratch_format.dart';
import 'parser.dart';
import 'ast.dart';
import 'standard_lib.dart';
import 'gen.dart' as gen;
import 'compare.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show additional command output.',
    )
    ..addFlag(
      'version',
      negatable: false,
      help: 'Print the tool version.',
    )
    ..addCommand(
        'compile',
        ArgParser()
          ..addOption(
            'file',
            abbr: 'f',
            mandatory: true,
            help: "The path to a itch project directory",
          ))
    ..addCommand(
      'parse',
      ArgParser()
        ..addOption(
          'file',
          abbr: 'f',
          mandatory: true,
          help: 'The path to a project.json file',
        )
        ..addOption(
          'output',
          abbr: 'o',
          mandatory: false,
          help: 'The path to output any errors',
          defaultsTo: '.',
        ),
    )
    ..addCommand(
        'compare',
        ArgParser()
          ..addOption(
            'dir',
            abbr: 'd',
            mandatory: true,
            help: 'The directory name to compare',
          ));
}

void printUsage(ArgParser argParser) {
  print('Usage: dart itch.dart <flags> [arguments]');
  print(argParser.usage);
  print("\nCommands\n------");
  argParser.commands.forEach((name, p) {
    print(name);
    print(p.usage);
    print('\n');
  });
}

Future<void> runParse(String path, String output) async {
  final file = File(path);
  final contents = jsonEncode(jsonDecode(await file.readAsString()));
  final project = Project.fromJson(jsonDecode(contents));
  final json = jsonEncode(project.toJson());
  if (json != contents) {
    final originalFile = File("$output${Platform.pathSeparator}original.json");
    originalFile.writeAsString(contents);
    final roundTripFile =
        File("$output${Platform.pathSeparator}roundTrip.json");
    roundTripFile.writeAsString(json);
    print(
        "Parse succeeded, but results did not match.  Saved results to:\nOriginal\t${originalFile.path}\nRound trip\t${roundTripFile.path}\n");
  } else {
    print("Roundtrip successful");
  }
}

Future<ItchFile?> runCompileFile(String filepath) async {
  print("Compiling $filepath");
  final file = File(filepath);
  final contents = await file.readAsString();
  final parser = Parser(contents: contents, fileName: filepath);
  final parseResult = parser.parse();
  final parseErrors = parser.errors();
  if (parseResult == null || parseErrors.isNotEmpty) {
    print("Failed to parse $filepath:");
    for (final e in parseErrors) {
      print(e);
    }
    return null;
  } else {
    print("Success");
    return parseResult;
  }
}

Future<void> runCompile(String path) async {
  await loadBlockDefs();
  final entries = await Directory(path)
      .list(recursive: true)
      .where((e) => e.path.endsWith(".itch"))
      .toList();
  final files = <String, ItchFile>{};
  bool error = false;
  for (final e in entries) {
    try {
      final f = await runCompileFile(e.path);
      if (f != null) {
        files[f.name] = f;
      } else {
        error = true;
      }
    } on FormatException catch (e) {
      print(e.message);
      error = true;
    }
  }
  if (error) {
    print("Could not compile project due to above errors.");
  }
  final g = gen.Generator();
  final project = g.generate(files, path);
  if (project == null) {
    print("ERROR");
    return;
  }
  print("Compilation successful. Assembling project");
  print("Writing program data");
  final projectJson = File.fromUri(Uri.file('./out/project.json'));
  final encoder = JsonEncoder.withIndent("  ");
  projectJson.writeAsString(encoder.convert(project.toJson()));
  print("Moving assets...");
  for (final move in g.assetMoves) {
    final src = File.fromUri(Uri.file(move.from));
    final dest = File.fromUri(Uri.file("./out/${move.to}"));
    await dest.writeAsBytes(await src.readAsBytes());
  }
  // clean old resources
  print("Cleaning up");
  try {
    await File.fromUri(Uri.file("out.zip")).delete();
    await File.fromUri(Uri.file("project.sb3")).delete();
  } on PathNotFoundException catch (_) {
    // Not handling
  }
  // generate zip
  print("Create project file");
  final p = await Process.run("zip", ["-r", "out", "out"]);
  if (p.exitCode != 0) {
    print("Could not create zip");
    print(p.stdout);
    return;
  }
  // move zip to sb3
  final p2 = await Process.run("mv", ["out.zip", "project.sb3"]);
  if (p2.exitCode != 0) {
    print("Could not create project file");
    print(p.stdout);
    return;
  }
  print("Project file created: project.sb3");
  return;
}

void main(List<String> arguments) async {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);

    // Process the parsed arguments.
    if (results.wasParsed('help')) {
      printUsage(argParser);
      return;
    }
    if (results.wasParsed('version')) {
      print('itch version: $version');
      return;
    }
    switch (results.command?.name) {
      case 'parse':
        final path = results.command!.option('file')!;
        final output = results.command!.option('output')!;
        await runParse(path, output);
        break;
      case 'compile':
        final path = results.command!.option('file')!;
        await runCompile(path);
        break;
      case 'compare':
        final dir = results.command!.option('dir')!;
        final res = await runCompare(dir);
        print(res ? "Success" : "Failed");
        break;
    }
  } on FormatException catch (e) {
    // Print usage information if an invalid argument was provided.
    print(e.message);
    print('');
    printUsage(argParser);
  } on ParseError catch (e) {
    print(e.message);
  }
}
