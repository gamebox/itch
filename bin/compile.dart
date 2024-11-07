import 'dart:convert';
import 'dart:io';

import 'parser.dart';
import 'ast.dart';
import 'standard_lib.dart';
import 'gen.dart' as gen;
import "a_command.dart";
import 'log_level.dart';

extension WhitespaceChecked on String {
  bool isWhitespace() {
    for (final c in runes) {
      switch (c) {
        case 9:
          break;
        case 10:
          break;
        case 11:
          break;
        case 12:
          break;
        case 13:
          break;
        case 32:
          break;
        default:
          return false;
      }
    }
    return true;
  }
}

class CompileCommand extends Logger implements ACommand {
  String dir;
  String logLevel;

  CompileCommand({required this.dir, required this.logLevel}) {
    super.setLogLevel('info');
  }

  @override
  Future<bool> exec() async {
    try {
      runCompile(dir);
      return true;
    } on FormatException catch (e) {
      // Print usage information if an invalid argument was provided.
      print(e.message);
      return false;
    } on ParserError catch (e) {
      print(e.message);
      return false;
    }
  }

  Future<ItchFile?> runCompileFile(String filepath) async {
    print("Compiling $filepath");
    final file = File(filepath);
    final contents = await file.readAsString();
    final parser = Parser(contents: contents, fileName: filepath);
    parser.setLogLevel(logLevel);
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

  Future<String?> getProjectName() async {
    final projectFile = File.fromUri(Uri.file("$dir/project.itch"));
    if (!await projectFile.exists()) {
      warn("No project file found at: ${projectFile.path}");
      return null;
    }
    final contents = await projectFile.readAsString();
    for (final line in contents.split('\n')) {
      if (line.startsWith("project")) {
        final matches =
            RegExp(r"project ([a-zA-Z0-9'_-\s]+).").matchAsPrefix(line);
        if (matches == null) {
          error("""
Invalid project file:

Expected something like

project My Project.

Instead, I see

$line"""
              .trimLeft());
          return null;
        }
        if (matches.groups([1]) case [String name, ...]) {
          return name;
        }
      }
      if (line.startsWith("#") || line.isWhitespace()) {
        continue;
      }
      error("""
Unexpected content in project file:

Got

$line

But I don't know what that is...."""
          .trimLeft());
    }
    info("Never found a valid project file or name, defaulting to 'Project'");
    return null;
  }

  Future<void> runCompile(String path) async {
    await loadBlockDefs();
    final entries = await Directory(path)
        .list(recursive: true)
        .where(
            (e) => e.path.endsWith(".itch") && !e.path.endsWith("project.itch"))
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
    g.setLogLevel(logLevel);
    final project = g.generate(files, path);
    if (project == null) {
      print("ERROR");
      return;
    }
    print("Compilation successful. Assembling project");
    print("Writing program data");
    final projectJson = File.fromUri(Uri.file('./out/project.json'));
    if (!await projectJson.exists()) {
      await projectJson.create(recursive: true);
    }
    final encoder = JsonEncoder.withIndent("  ");
    projectJson.writeAsString(encoder.convert(project.toJson()));
    print("Moving assets...");
    for (final move in g.assetMoves) {
      final src = File.fromUri(Uri.file(move.from));
      final dest = File.fromUri(Uri.file("./out/${move.to}"));
      await dest.writeAsBytes(await src.readAsBytes());
    }
    // Get project name
    final projectName = await getProjectName() ?? 'Project';
    // clean old resources
    print("Cleaning up");
    try {
      await File.fromUri(Uri.file("out.zip")).delete();
      await File.fromUri(Uri.file("$projectName.sb3")).delete();
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
    final p2 = await Process.run("mv", ["out.zip", "$projectName.sb3"]);
    if (p2.exitCode != 0) {
      print("Could not create project file");
      print(p.stdout);
      return;
    }
    print("Project file created: $projectName.sb3");
    return;
  }
}
