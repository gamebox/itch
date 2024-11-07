import 'dart:io';

import './a_command.dart';
import './ansi.dart';
import './log_level.dart';

class InitCommand extends Logger implements ACommand {
  final String dir;
  final String projectName;

  InitCommand({required this.dir, required this.projectName}) {
    super.setLogLevel("info");
  }

  Future<Directory?> createDir(String path) async {
    final directory = Directory(path);
    if (await directory.exists()) {
      print(
          "Cannot create a project in an existing directory: ${directory.path}");
      return null;
    }
    try {
      final d = await directory.create();
      info("🗂️\tCreated ${d.path}");
      return d;
    } on FileSystemException catch (e) {
      error("Failed to create directory: ${e.message}");
      return null;
    }
  }

  Future<File?> createFile(String path, String content) async {
    final file = File(path);
    try {
      final f = await file.create(exclusive: true);
      await f.writeAsString(content);
      info("📄\tCreated ${f.path}");
      return f;
    } on PathExistsException catch (e) {
      error("Failed to create file $path: ${e.message}");
    } on FileSystemException catch (e) {
      error("Failed to create file $path: ${e.message}");
    } on Exception catch (_) {
      error("Failed to create file $path");
    }
    return null;
  }

  @override
  Future<bool> exec() async {
    // Create project.itch file
    final projectDir = await createDir(dir);
    if (projectDir == null) {
      return false;
    }
    final stageDir = await createDir("${projectDir.path}/stage");
    if (stageDir == null) {
      return false;
    }
    final spriteDir = await createDir("${projectDir.path}/sprite");
    if (spriteDir == null) {
      return false;
    }
    final assetsDir = await createDir("${projectDir.path}/assets");
    if (assetsDir == null) {
      return false;
    }
    final imagesDir = await createDir("${assetsDir.path}/images");
    if (imagesDir == null) {
      return false;
    }
    final soundsDir = await createDir("${assetsDir.path}/sounds");
    if (soundsDir == null) {
      return false;
    }
    final stageFile = await createFile(
      "${stageDir.path}/stage.itch",
      stageTemplate,
    );
    if (stageFile == null) {
      return false;
    }
    final backgroundFile = await createFile(
      "${imagesDir.path}/background1.svg",
      background1Template,
    );
    if (backgroundFile == null) {
      return false;
    }
    final projectFile = await createFile(
        "${projectDir.path}/project.itch", "project $projectName.\n");
    if (projectFile == null) {
      return false;
    }
    info(
      successPen(
        "🚀\tProject created.\nTo start run:\n\ncd $dir\n\nAnd then open the project in your editor of choice.",
      ),
    );

    return true;
  }
}

const stageTemplate = """
stage.

set currentCostume = 1.
set videoTransparency = 60.

var my variable = 0.

costume "backdrop1".
""";

const background1Template = """
<svg version="1.1" width="2" height="2" viewBox="-1 -1 2 2" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
</svg>
""";
