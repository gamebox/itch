import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'a_command.dart';
import 'ast.dart' as ast;
import 'log_level.dart';
import 'scratch_format.dart' as scratch;
import 'standard_lib.dart' as stdlib;

abstract class ImportCommand {
  final String _src;
  final String _dest;
  late LoggerImpl _logger;
  final String jsonFileName;
  Future<Map<String, String>?> Function(Importer importer, dynamic json)
      importer;

  ImportCommand(
      {required String src,
      required String dest,
      required this.importer,
      required this.jsonFileName})
      : _src = p.absolute(src),
        _dest = dest == "." ? p.absolute(p.current) : p.absolute(dest);

  Future<bool> _import(LoggerImpl logger) async {
    _logger = logger;
    final tempPath = await moveSb3toTempDir(_src, logger);
    if (tempPath == null) {
      return false;
    }
    final unzippedPath = await unzipSb3(tempPath, logger);
    if (unzippedPath == null) {
      return false;
    }
    final spriteJsonFile = File(p.join(unzippedPath, jsonFileName));
    final spriteJsonString = await spriteJsonFile.readAsString();
    final spriteJson = jsonDecode(spriteJsonString);
    print("Importing the project to $_dest");
    await Directory(_dest).create(recursive: true);
    final i = Importer(
      logger: _logger,
      projectPath: _dest,
    );
    final assetMoves = await importer(i, spriteJson);
    // Move assets
    if (assetMoves == null || !await moveAssets(assetMoves, logger)) {
      return false;
    }
    return true;
  }

  Future<String?> moveSb3toTempDir(String path, LoggerImpl logger) async {
    final dir = await Directory.systemTemp.createTemp();
    final filename = p.basename(path);
    final movedPath = p.join(dir.absolute.path, filename);
    var res = await Process.run("cp", [path, movedPath]);
    if (res.exitCode != 0) {
      print("We had a problem with moving this project:");
      print(res.stdout);
      print(res.stderr);
      return null;
    }
    return movedPath;
  }

  Future<String?> unzipSb3(String path, LoggerImpl logger) async {
    final zipFilePath = path.replaceFirst(r".sb3", ".zip");
    final projectPath = path.replaceFirst(r".sb3", "");
    var res = await Process.run("mv", [path, zipFilePath]);
    if (res.exitCode != 0) {
      print("We had a problem with moving this project:");
      print(res.stdout);
      print(res.stderr);
      return null;
    }
    res = await Process.run("unzip", [
      zipFilePath,
      '-d',
      projectPath,
    ]);
    if (res.exitCode != 0) {
      print("We had a problem with moving this project:");
      print(res.stdout);
      print(res.stderr);
      return null;
    }
    return projectPath;
  }

  Future<bool> moveAssets(
    Map<String, String> assetMoves,
    LoggerImpl logger,
  ) async {
    for (final move in assetMoves.entries) {
      try {
        final src = await File(p.absolute(move.key)).create(recursive: true);
        final dest = await File(p.absolute(move.value)).create(recursive: true);
        print("Moving ${src.path} to ${dest.path}");
        await dest.writeAsBytes(await src.readAsBytes());
      } on FileSystemException catch (e) {
        logger.error("Could not write asset file: ${e.message}");
        return false;
      }
    }
    return true;
  }
}

class ImportProjectCommand extends ImportCommand implements ACommand {
  ImportProjectCommand({required super.src, required super.dest})
      : super(
            importer: (Importer importer, dynamic json) =>
                importer.importProject(json),
            jsonFileName: "project.json");

  @override
  Future<bool> exec(LoggerImpl logger) async {
    return await _import(logger);
  }
}

class ImportSpriteCommand extends ImportCommand implements ACommand {
  ImportSpriteCommand({required super.src, required super.dest})
      : super(
            importer: (Importer importer, dynamic json) =>
                importer.importSprite(json),
            jsonFileName: "sprite.json");

  @override
  Future<bool> exec(LoggerImpl logger) async {
    return await _import(logger);
  }
}

class Importer {
  final LoggerImpl logger;
  final String projectPath;
  late dynamic json;
  Map<String, String> assetMoves = {};

  Importer({required this.logger, required this.projectPath});

  Future<Map<String, String>?> importSprite(dynamic json) async {
    assetMoves = {};
    if (json case Map<String, dynamic> spriteJson) {
      final sprite = scratch.Target.fromJson(spriteJson);
      stdlib.loadBlockDefs(logger);
      final itchFile = importTarget(sprite);
      if (itchFile == null) {
        return null;
      }
      return assetMoves;
    }
    return null;
  }

  Future<Map<String, String>?> importProject(dynamic json) async {
    assetMoves = {};
    if (json case Map<String, dynamic> projectJson) {
      final project = scratch.Project.fromJson(projectJson);
      stdlib.loadBlockDefs(logger);
      for (final target in project.targets) {
        final itchFile = importTarget(target);
        if (itchFile == null) {
          return null;
        }
        await persistItchFile(itchFile);
      }
    }
    return null;
  }

  ast.ItchFile? importTarget(scratch.Target target) {
    final decls = <ast.Decl>[];
    final comments = <String, ast.Comment>{};
    switch (target) {
      case scratch.Stage _:
        stageSetDecls(target, decls);
        break;
      case scratch.Sprite _:
        spriteSetDecls(target, decls);
        break;
    }
    _commonDecls(target, decls);
    if (target.isStage) {
      return ast.ItchFile.stage(
        decls: decls,
        comments: comments,
      );
    }
    return ast.ItchFile.sprite(
      target.name,
      decls: decls,
      comments: comments,
    );
  }

  void _commonDecls(scratch.Target target, List<ast.Decl> decls) {
    _varDecls(target, decls);
    _listDecls(target, decls);
    _broadcastDecls(target, decls);
    _costumeDecls(target, decls);
    _soundDecls(target, decls);
    _blockDecls(target, decls);
  }

  void _varDecls(scratch.Target target, List<ast.Decl> decls) {
    for (final entry in target.variables.entries) {
      decls
          .add(ast.DVar(name: entry.value.name, value: "${entry.value.value}"));
    }
  }

  void _listDecls(scratch.Target target, List<ast.Decl> decls) {
    for (final entry in target.lists.entries) {
      decls.add(
        ast.DList(
          name: entry.value.name,
          values: entry.value.values.map((v) => v.toString()).toList(),
        ),
      );
    }
  }

  void _broadcastDecls(scratch.Target target, List<ast.Decl> decls) {
    for (final entry in target.broadcasts.entries) {
      decls.add(
        ast.DBroadcast(
          name: entry.value,
        ),
      );
    }
  }

  void _costumeDecls(scratch.Target target, List<ast.Decl> decls) {
    for (final entry in target.costumes) {
      decls.add(ast.DAsset(assetName: entry.name));
      assetMoves[entry.md5ext] = p.join(
          projectPath, "assets", "images", "${entry.name}.${entry.dataFormat}");
    }
  }

  void _soundDecls(scratch.Target target, List<ast.Decl> decls) {
    for (final entry in target.sounds) {
      decls.add(ast.DAsset.sound(assetName: entry.name));
      assetMoves[entry.md5ext] = p.join(
          projectPath, "assets", "sounds", "${entry.name}.${entry.dataFormat}");
    }
  }

  void _blockDecls(scratch.Target target, List<ast.Decl> decls) {
    List<scratch.Block> topLevelBlocks = [];
    for (final entry in target.blocks.entries) {
      if (entry.value.isTopLevel) {
        topLevelBlocks.add(entry.value);
      }
    }

    for (final block in topLevelBlocks) {
      final b = astBlockFromScratch(block, target.blocks);
      if (b == null) {
        throw Exception("Could not create block");
      }
      decls.add(ast.DBlock(block: b));
    }
  }

  ast.Block? astBlockFromScratch(
    scratch.Block block,
    Map<String, scratch.Block> blocks,
  ) {
    if (block case scratch.BasicBlock b) {
      final opcode = block.opcode;
      final def = stdlib.blockDefsByOpcode[b.opcode];
      if (def == null) {
        throw Exception(
            "Could not find definition for block with opcode: ${b.opcode}");
      }
      final pieces = def.identifier.split(" ");
      int argNo = 0;
      String words = "";
      List<ast.Segment> segments = [];
      void addSegment(ast.Segment seg, String message) {
        logger.debug("$opcode: addingSegment <$seg> reason: $message");
        segments.add(seg);
      }

      for (final piece in pieces) {
        logger.debug("piece: $piece, argNo: $argNo");
        switch (piece) {
          case "()":
            if (words.isNotEmpty) {
              addSegment(ast.SWord(word: words), "Adding plain words to input");
              words = "";
            }

            final arg = def.args[argNo];
            switch (arg) {
              case stdlib.InputDef d:
                final input = b.inputs[d.name];
                if (input == null) {
                  throw Exception("no input for arg ${d.name}");
                }
                switch ((input, input.kind)) {
                  case (scratch.IdInput i, scratch.InputKind.shadow):
                    final shadowBlock = blocks[i.id];
                    if (shadowBlock case scratch.BasicBlock b) {
                      final value = b.fields[d.name]?.value;
                      if (value == null) {
                        throw Exception(
                            "no value for field for arg ${d.name} @ ${i.id}");
                      }
                      final menu = stdlib.menus["[${d.name}]"];
                      if (menu == null) {
                        throw Exception("No menu for ${d.name}");
                      }
                      String label = menu.menuLabelForValue(value) ?? value;
                      addSegment(ast.SField(value: label),
                          "Menu value, IdInput shadow, for input");
                    } else {
                      throw Exception(
                          "No menu for item ${d.name} @ id ${i.id}");
                    }
                    i.shadowValue;
                    break;
                  case (scratch.IdInput i, scratch.InputKind.noShadow):
                    final idBlock = blocks[i.id];
                    if (idBlock == null) {
                      throw Exception(
                          "Referenced block does not exist: ${i.id}");
                    }
                    final block = astBlockFromScratch(idBlock, blocks);
                    if (block == null) {
                      throw Exception("Could not create block for id: ${i.id}");
                    }
                    addSegment(ast.SReporter(block: block),
                        "IdInput noShadow for input");
                    break;
                  case (scratch.BlockInput i, _):
                    switch (i.block.code) {
                      case 11:
                        addSegment(ast.SField(value: i.block.value),
                            "Broadcast name for input");
                        break;
                      case 12:
                        addSegment(
                            ast.SReporter(
                              block:
                                  ast.Block([ast.SWord(word: i.block.value)]),
                            ),
                            "Var name for input");
                        break;
                      case 13:
                        addSegment(
                            ast.SReporter(
                              block:
                                  ast.Block([ast.SWord(word: i.block.value)]),
                            ),
                            "List name for input");
                        break;
                      default:
                        addSegment(ast.SValue(value: i.block.value),
                            "Any old value: ${d.name} / ${i.kind} / ${i.block.code} / ${i.block.value} / ${i.shadowId} / ${i.shadowValue}");
                        break;
                    }
                    break;
                  case (scratch.IdInput i, scratch.InputKind.obscured):
                    final b = blocks[i.id];
                    if (b == null) {
                      throw Exception("No block for id ${i.id}");
                    }
                    final blk = astBlockFromScratch(b, blocks);
                    if (blk == null) {
                      throw Exception("Could not create block");
                    }
                    addSegment(ast.SReporter(block: blk),
                        "IdInput obscured for input");
                  default:
                    logger.debug("InputDef default, $input, ${input.kind}");
                    break;
                }
                break;
              case stdlib.FieldDef d:
                final field = b.fields[d.name];
                if (field == null) {
                  throw Exception("No field with name: ${d.name}");
                }
                final value = d.menuLabelForValue(field.value);
                if (value == null) {
                  throw Exception(
                      "No label for value '${field.value}' in ${d.name}");
                }
                addSegment(
                    ast.SField(value: value), "FieldDef value ${field.value}");
                break;
              case stdlib.VarDef d:
                logger.debug("VarDef for Input: ${d.name} / $arg / $opcode");
                final varName = block.fields[d.name]?.value;
                if (varName == null) {
                  throw Exception("No field value for ${d.name}");
                }
                addSegment(
                  ast.SReporter(block: ast.Block([ast.SWord(word: varName)])),
                  "Var name reporter for VarDef in Input",
                );
                break;
              case stdlib.VarGetterDef _:
                logger.debug("VarGetterDef for Input");
                break;
              case stdlib.MouthDef _:
                logger.debug("MouthDef for Input");
                break;
            }

            argNo++;
            break;
          case "{}":
            if (words.isNotEmpty) {
              addSegment(ast.SWord(word: words), "Words");
              words = "";
            }

            final arg = def.args[argNo];
            switch (arg) {
              case stdlib.MouthDef d:
                final input = b.inputs[d.name];
                if (input == null) {
                  throw Exception("no input for arg ${d.name}");
                }
                switch ((input, input.kind)) {
                  case (scratch.IdInput i, scratch.InputKind.noShadow):
                    final bs = astBlocksForMouth(i.id, blocks);
                    if (bs == null) {
                      throw Exception("Could not generate blocks for mouth");
                    }
                    addSegment(ast.SCMouth(bs), "Mouth");
                    break;
                  default:
                    break;
                }
                break;
              default:
                break;
            }

            argNo++;
            break;
          default:
            if (words == "") {
              words = piece;
            } else {
              words = "$words $piece";
            }
            break;
        }
      }
      if (words.isNotEmpty) {
        addSegment(ast.SWord(word: words), "Words");
      }
      if (segments[0] case ast.SWord(word: String word)
          when word.startsWith("when")) {
        final bs = astBlocksForMouth(b.next, blocks);
        if (bs == null) {
          throw Exception("Couldn't find blocks for mouth");
        }
        addSegment(ast.SCMouth(bs), "Mouth");
      }
      return ast.Block(segments);
    }
    return null;
  }

  List<ast.Block>? astBlocksForMouth(
      String? next, Map<String, scratch.Block> blocks) {
    if (next == null) {
      return [];
    }
    String? n = next;
    final bs = <ast.Block>[];
    while (n != null) {
      final scratchBlock = blocks[n];
      late scratch.BasicBlock b;
      if (scratchBlock case scratch.BasicBlock bb) {
        b = bb;
      } else {
        throw Exception("Couldn't find next block with id: $n");
      }
      final blk = astBlockFromScratch(b, blocks);
      if (blk == null) {
        return null;
      }
      bs.add(blk);
      n = b.next;
    }
    return bs;
  }

  void stageSetDecls(scratch.Stage target, List<ast.Decl> decls) {
    decls.addAll([
      ast.DSet(name: "currentCostume", value: target.currentCostume.toString()),
      ast.DSet(name: "layerOrder", value: target.layerOrder.toString()),
      ast.DSet(name: "volume", value: target.volume.toString()),
      ast.DSet(name: "tempo", value: target.tempo.toString()),
      ast.DSet(name: "videoState", value: target.videoState.toString()),
      ast.DSet(
          name: "videoTransparency",
          value: target.videoTransparency.toString()),
    ]);
    if (target.textToSpeechLanguage case String lang) {
      decls.add(ast.DSet(name: "textToSpeechLanguage", value: lang));
    }
  }

  void spriteSetDecls(scratch.Sprite target, List<ast.Decl> decls) {
    decls.addAll([
      ast.DSet(name: "visible", value: target.visible ? "true" : "false"),
      ast.DSet(name: "x", value: target.x.toString()),
      ast.DSet(name: "y", value: target.y.toString()),
      ast.DSet(name: "size", value: target.size.toString()),
      ast.DSet(name: "direction", value: target.direction.toString()),
      ast.DSet(name: "draggable", value: target.draggable ? "true" : "false"),
      ast.DSet(name: "rotationStyle", value: target.rotationStyle.toString()),
    ]);
  }

  Future<bool> persistItchFile(ast.ItchFile file) async {
    switch (file.fileType) {
      case ast.StageFile():
        final filePath = p.join(projectPath, "stage", "stage.itch");
        try {
          final f = await File(filePath).create(recursive: true);
          await f.writeAsString(file.toString());
          return true;
        } on FileSystemException catch (e) {
          logger.error("Could not write file to $filePath: ${e.message}");
          return false;
        }
      case ast.SpriteFile(name: String name):
        final filePath = p.join(projectPath, "sprites", "$name.itch");
        try {
          final f = await File(filePath).create(recursive: true);
          await f.writeAsString(file.toString());
          return true;
        } on FileSystemException catch (e) {
          logger.error("Could not write file to $filePath: ${e.message}");
          return false;
        }
    }
  }
}
