import 'dart:convert';
import 'dart:io';

import 'parser.dart';
import 'ast.dart';
import 'standard_lib.dart';
import 'gen.dart' as gen;
import "a_command.dart";

class CompileCommand implements ACommand {
  String dir;
  String logLevel;

  CompileCommand({required this.dir, required this.logLevel});

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
    g.setLogLevel(logLevel);
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
}
