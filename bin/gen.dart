import "dart:io";

import "./ast.dart" as ast;
import "./scratch_format.dart" as scratch;
import './standard_lib.dart' as std;

import "./log_level.dart";

import './decoders/decoders.dart' as decoders;

class _TargetSettings {
  int currentCostume;
  int layerOrder;
  int volume;
  int tempo;
  int videoTransparency;
  bool visible;
  int x;
  int y;
  int size;
  int direction;
  bool draggable;
  scratch.RotationStyle rotationStyle;
  scratch.VideoState? videoState;
  final List<String> keysSet = [];

  _TargetSettings()
      : currentCostume = 0,
        layerOrder = 0,
        volume = 100,
        tempo = 30,
        videoTransparency = 100,
        visible = true,
        x = 0,
        y = 0,
        size = 100,
        direction = 90,
        draggable = false,
        rotationStyle = scratch.RotationStyle.allAround;

  void set(String key, String value) {
    bool wasSet = false;
    switch (key) {
      case "currentCostume":
        currentCostume = int.tryParse(value) ?? currentCostume;
        wasSet = true;
        break;
      case "layerOrder":
        layerOrder = int.tryParse(value) ?? layerOrder;
        wasSet = true;
        break;
      case "volume":
        volume = int.tryParse(value) ?? volume;
        wasSet = true;
        break;
      case "tempo":
        tempo = int.tryParse(value) ?? tempo;
        wasSet = true;
        break;
      case "videoTransparency":
        videoTransparency = int.tryParse(value) ?? videoTransparency;
        wasSet = true;
        break;
      case "visible":
        visible = value == "true";
        wasSet = true;
        break;
      case "x":
        x = int.tryParse(value) ?? x;
        wasSet = true;
        break;
      case "y":
        y = int.tryParse(value) ?? y;
        wasSet = true;
        break;
      case "size":
        size = int.tryParse(value) ?? size;
        wasSet = true;
        break;
      case "direction":
        direction = int.tryParse(value) ?? direction;
        wasSet = true;
        break;
      case "draggable":
        draggable = value == "true";
        wasSet = true;
        break;
      case "rotationStyle":
        rotationStyle = scratch.RotationStyle.fromJson(value);
        wasSet = true;
        break;
    }
    if (wasSet) {
      keysSet.add(key);
    }
  }
}

class Generator with Logger {
  final List<String> errors = [];
  final List<({String from, String to})> assetMoves = [];
  // The key is opcode, the value is the number of times used
  final Map<String, int> blockIds = {};
  String projectPath = '';
  String target = 'stage';

  final Map<String, List<String>> targetVars = {
    "stage": [],
  };
  final Map<String, List<String>> targetLists = {
    "stage": [],
  };
  final Map<String, List<String>> targetBroadcasts = {
    "stage": [],
  };
  final Map<String, List<String>> targetCostumes = {
    "stage": [],
  };
  final Map<String, List<String>> targetSounds = {
    "stage": [],
  };

  Generator();

  String listId(String name) {
    if ((targetLists[target] != null && targetLists[target]!.contains(name)) ||
        !targetLists['stage']!.contains(name)) {
      return "(($target))_list_(($name))";
    }
    return "((stage))_list_(($name))";
  }

  String varId(String name) {
    if ((targetVars[target] != null && targetVars[target]!.contains(name)) ||
        !targetVars['stage']!.contains(name)) {
      return "(($target))_var_(($name))";
    }
    return "((stage))_var_(($name))";
  }

  String broadcastId(String name) {
    if ((targetBroadcasts[target] != null &&
            targetBroadcasts[target]!.contains(name)) ||
        !targetBroadcasts['stage']!.contains(name)) {
      return "(($target))_broadcast_(($name))";
    }
    return "((stage))_broadcast_(($name))";
  }

  void addListToTarget(String name) {
    if (targetLists[target] == null) {
      targetLists[target] = [];
    }
    if (targetLists[target]!.contains(name)) {
      return;
    }
    targetLists[target]!.add(name);
  }

  void addVarToTarget(String name) {
    if (targetVars[target] == null) {
      targetVars[target] = [];
    }
    if (targetVars[target]!.contains(name)) {
      return;
    }
    targetVars[target]!.add(name);
  }

  void addBroadcastToTarget(String name) {
    if (targetBroadcasts[target] == null) {
      targetBroadcasts[target] = [];
    }
    if (targetBroadcasts[target]!.contains(name)) {
      return;
    }
    targetBroadcasts[target]!.add(name);
  }

  void addSoundToTarget(String name) {
    if (targetSounds[target] == null) {
      targetSounds[target] = [];
    }
    if (targetSounds[target]!.contains(name)) {
      return;
    }
    targetSounds[target]!.add(name);
  }

  void addCostumeToTarget(String name) {
    if (targetCostumes[target] == null) {
      targetCostumes[target] = [];
    }
    if (targetCostumes[target]!.contains(name)) {
      return;
    }
    targetCostumes[target]!.add(name);
  }

  scratch.Variable? generateVariable(ast.DVar v) {
    return scratch.Variable(name: v.name, value: v.value);
  }

  scratch.ListVar? generateListVar(ast.DList l) {
    return scratch.ListVar(name: l.name, values: l.values);
  }

  String? getOpForBlock(ast.Block block) {
    return null;
  }

  ({
    Map<String, scratch.Input> inputs,
    Map<String, scratch.Field> fields,
    Map<String, scratch.Block> blocks,
    String? next,
  })? genInputsAndFields(
      ast.Block block, List<std.SlotDef> slots, String owningBlockId) {
    int slotsCovered = 0;
    int words = 0;

    final Map<String, scratch.Input> inputs = {};
    final Map<String, scratch.Field> fields = {};
    final Map<String, scratch.Block> blocks = {};

    bool hat = false;
    String? next;

    bool valueIsNumber(String value) {
      if ((RegExp(r"-?[0-9]{1,}(\.[0-9]{1,})?").firstMatch(value)?[0] ?? "") ==
          value) {
        return true;
      }
      return false;
    }

    (scratch.Input, scratch.Block?)? wrapShadowInput(
        scratch.ReporterBlock block) {
      return (
        scratch.BlockInput(kind: scratch.InputKind.shadow, block: block),
        null
      );
    }

    (scratch.Input, scratch.Block?)? inputForValue(
        String value, String slotName, bool hasMenu) {
      if (hasMenu) {
        final menu = std.menus[slotName];
        if (menu != null) {
          return null;
        }
        // final instanceInfo = blockInstanceInfo(menu);
        return null;
      } else {
        switch (slotName) {
          case "ALIGNMENT":
            break;
          case "BACKDROP":
            break;
          case "BROADCAST_INPUT":
            break;
          case "BROADCAST_OPTION":
            break;
          case "CHANGE":
            return (
              scratch.BlockInput(
                  kind: scratch.InputKind.shadow,
                  block: scratch.ReporterBlock.number(value)),
              null
            );
          case "CLONE_OPTION":
            break;
          case "COLOR":
            break;
          case "COLOR2":
            break;
          case "CONDITION":
            break;
          case "COSTUME":
            break;
          case "CURRENTMENU":
            break;
          case "DEGREES":
            return (
              scratch.BlockInput(
                  kind: scratch.InputKind.shadow,
                  block: scratch.ReporterBlock.number(value)),
              null
            );
          case "DIRECTION":
            break;
          case "DISTANCE":
            break;
          case "DISTANCETOMENU":
            break;
          case "DRAG_MODE":
            break;
          case "DURATION":
            break;
          case "DX":
            break;
          case "DY":
            break;
          case "EFFECT":
            break;
          case "FORWARD_BACKWARD":
            break;
          case "FROM":
            return (
              scratch.BlockInput(
                  kind: scratch.InputKind.shadow,
                  block: scratch.ReporterBlock.number(value)),
              null
            );
          case "FRONT_BACK":
            break;
          case "INDEX":
            break;
          case "ITEM":
            return wrapShadowInput(scratch.ReporterBlock.string(value));
          case "KEY_OPTION":
            break;
          case "LETTER":
            break;
          case "LIST":
            break;
          case "MESSAGE":
            break;
          case "NUM":
            return wrapShadowInput(scratch.ReporterBlock.integer(value));
          case "NUM1":
            break;
          case "NUM2":
            break;
          case "NUMBER_NAME":
            break;
          case "OBJECT":
            break;
          case "OPERAND":
            break;
          case "OPERAND1":
            break;
          case "OPERAND2":
            return wrapShadowInput(scratch.ReporterBlock.string(value));
          case "OPERATOR":
            break;
          case "PROPERTY":
            break;
          case "QUESTION":
            return wrapShadowInput(scratch.ReporterBlock.string(value));
          case "SECS":
            return (
              scratch.BlockInput(
                  kind: scratch.InputKind.shadow,
                  block: scratch.ReporterBlock.number(value)),
              null
            );
          case "SIZE":
            break;
          case "SOUND_MENU":
            break;
          case "STEPS":
            break;
          case "STOP_OPTION":
            break;
          case "STRETCH":
            break;
          case "STRING":
            return wrapShadowInput(scratch.ReporterBlock.string(value));
          case "STRING1":
            return wrapShadowInput(scratch.ReporterBlock.string(value));
          case "STRING2":
            return wrapShadowInput(scratch.ReporterBlock.string(value));
          case "STYLE":
            break;
          case "SUBSTACK":
            break;
          case "SUBSTACK2":
            break;
          case "TIMES":
            break;
          case "TO":
            return (
              scratch.BlockInput(
                  kind: scratch.InputKind.shadow,
                  block: scratch.ReporterBlock.number(value)),
              null
            );
          case "TOUCHINGOBJECTMENU":
            break;
          case "TOWARDS":
            break;
          case "VALUE":
            return (
              scratch.BlockInput(
                  kind: scratch.InputKind.shadow,
                  block: scratch.ReporterBlock.number(value)),
              null
            );
          case "VARIABLE":
            break;
          case "VOLUME":
            break;
          case "WHENGREATERTHANMENU":
            break;
          case "X":
            break;
          case "Y":
            break;
        }
      }
      return null;
    }

    for (final seg in block.segments) {
      if (slotsCovered - 1 > slots.length) {
        debug(
            "We are trying to cover $slotsCovered slots, but only have ${slots.length}.\nslots: $slots\nsegments: ${block.segments}");
        break;
      }
      switch (seg) {
        case ast.SValue(value: String value):
          switch (slots[slotsCovered]) {
            case std.InputDef(name: String name, hasMenu: bool hasMenu):
              if (hasMenu) {
                final info = menuInstanceInfo(name);
                if (info == null) {
                  break;
                }
                if (!validValueForMenu(info.$1, name, value)) {
                  debug("ERROR: '$value' is not a valid menu option for $name");
                }
                generateMenu(blocks, name, value, info, owningBlockId);
                inputs[name] = scratch.IdInput(
                    kind: scratch.InputKind.shadow, id: info.$2);
                break;
              } else {
                inputs[name] = scratch.BlockInput(
                  kind: scratch.InputKind.shadow,
                  block: valueIsNumber(value)
                      ? scratch.ReporterBlock.number(value)
                      : scratch.ReporterBlock.string(value),
                );
              }
              break;
            case std.FieldDef _:
              debug(
                  "VALUE Segment is $seg\t\t${slots[slotsCovered]}\t\tSlot is ${slots[slotsCovered].name}\t\t$owningBlockId\n");
              break;
            case std.VarDef _:
              debug(
                  "VALUE Segment is $seg\t\t${slots[slotsCovered]}\t\tSlot is ${slots[slotsCovered].name}\t\t$owningBlockId\n");
              break;
            case std.VarGetterDef _:
              debug(
                  "VALUE Segment is $seg\t\t${slots[slotsCovered]}\t\tSlot is ${slots[slotsCovered].name}\t\t$owningBlockId\n");
              break;
            case std.MouthDef _:
              debug(
                  "VALUE Segment is $seg\t\t${slots[slotsCovered]}\t\tSlot is ${slots[slotsCovered].name}\t\t$owningBlockId\n");
              break;
          }
          break;
        case ast.SField(value: String value):
          switch (slots[slotsCovered]) {
            case std.InputDef(name: String name, hasMenu: bool hasMenu):
              if (hasMenu) {
                final info = menuInstanceInfo(name);
                if (info == null) {
                  break;
                }
                String? actualValue = valueForMenuLabel(info.$1, name, value);
                if (actualValue == null) {
                  debug("ERROR: '$value' is not a valid menu option for $name");
                }
                generateMenu(
                    blocks, name, actualValue ?? value, info, owningBlockId);
                inputs[name] = scratch.IdInput(
                    kind: scratch.InputKind.shadow, id: info.$2);
              } else {
                switch (name) {
                  case "BROADCAST_INPUT":
                    inputs[name] = scratch.BlockInput(
                      kind: scratch.InputKind.shadow,
                      block: scratch.ReporterBlock.broadcast(
                        name: name,
                        id: broadcastId(value),
                      ),
                    );
                    break;
                  default:
                }
              }
              break;
            case std.FieldDef(name: String name):
              final menu = std.menus[name];
              if (menu != null) {
                fields[name] =
                    scratch.Field.varOrList(value: value, id: "menu_$name");
              } else {
                fields[name] = scratch.Field.value(value: value);
              }
            case std.VarDef(name: String name):
              fields[name] = scratch.Field.varOrList(
                  value: value,
                  id: name == "LIST"
                      ? listId(value)
                      : name == "VAR"
                          ? varId(value)
                          : broadcastId(value));
              break;
            case std.VarGetterDef _:
              debug(
                  "FIELD Segment is $seg\t\tSlot is ${slots[slotsCovered].name}");
              break;
            case std.MouthDef _:
              debug(
                  "FIELD Segment is $seg\t\tSlot is ${slots[slotsCovered].name}");
              break;
          }
          break;
        case ast.SReporter(block: ast.Block b):
          final instanceInfo = blockInstanceInfo(b);
          if (instanceInfo != null) {
            String id = instanceInfo.$2;
            generateBlock(blocks, b, instanceInfo, parent: owningBlockId);
            final slot = slots[slotsCovered];
            switch (slot) {
              case std.InputDef(name: String name):
                inputs[name] =
                    scratch.IdInput(id: id, kind: scratch.InputKind.shadow);
                break;
              case std.FieldDef _:
                debug(
                    "REPORTER Segment is $seg\t\t${slots[slotsCovered]}\t\tSlot is ${slots[slotsCovered].name}\t\t$owningBlockId");
                break;
              case std.VarDef _:
                debug(
                    "REPORTER Segment is $seg\t\t${slots[slotsCovered]}\t\tSlot is ${slots[slotsCovered].name}\t\t$owningBlockId");
                break;
              case std.VarGetterDef _:
                debug(
                    "REPORTER Segment is $seg\t\t${slots[slotsCovered]}\t\t${slots[slotsCovered].name}\t\t$owningBlockId");
                break;
              case std.MouthDef _:
                break;
            }
          } else {
            // See if this is a variable, list, or broadcast dependeing on the input name;
            final slot = slots[slotsCovered];
            switch (slot) {
              case std.InputDef(name: String name):
                scratch.ReporterBlock? block;
                String? value = getValueFromSingleWordBlock(b);
                if (value == null) {
                  return null;
                }
                switch (name) {
                  case "BROADCAST_OPTION":
                    // This is selecting a broadcast that exists
                    final id = broadcastId(value);
                    block =
                        scratch.ReporterBlock.broadcast(name: value, id: id);
                  case "BROADCAST_INPUT":
                    // This is stating a broadcast that belongs to target
                    final id = broadcastId(value);
                    block =
                        scratch.ReporterBlock.broadcast(name: value, id: id);
                  case "LIST":
                    final id = listId(value);
                    block = scratch.ReporterBlock.list(name: value, id: id);
                  default:
                    final id = varId(value);
                    block = scratch.ReporterBlock.variable(name: value, id: id);
                }
                inputs[name] = scratch.BlockInput(
                    kind: scratch.InputKind.obscured,
                    block: block,
                    shadowValue: scratch.ReporterBlock.string(""));
                break;
              default:
                debug("Reporter going into non-input");
                break;
            }
          }
          break;
        case ast.SCMouth(blocks: List<ast.Block> bs):
          if (hat) {
            bool first = true;
            String? last;
            for (final b in bs) {
              final instanceInfo = blockInstanceInfo(b);
              if (instanceInfo == null) {
                return null;
              }
              if (last != null) {
                blocks[last]!.setNext(instanceInfo.$2);
              }
              if (first) {
                first = false;
                last = generateBlock(blocks, b, instanceInfo,
                    parent: owningBlockId);
                next = last;
              } else {
                last = generateBlock(blocks, b, instanceInfo, parent: last);
              }
            }
            continue;
          }
          switch (slots[slotsCovered]) {
            case std.InputDef(name: String _):
              debug(
                  "MOUTH Segment is $seg {TYPE: ${seg.runtimeType}}\t\tSlot is ${slots[slotsCovered].name}");
              break;
            case std.FieldDef _:
              debug(
                  "MOUTH Segment is $seg {TYPE: ${seg.runtimeType}}\t\tSlot is ${slots[slotsCovered].name}");
              break;
            case std.VarDef _:
              debug(
                  "MOUTH Segment is $seg {TYPE: ${seg.runtimeType}}\t\tSlot is ${slots[slotsCovered].name}");
              break;
            case std.VarGetterDef _:
              debug(
                  "MOUTH Segment is $seg {TYPE: ${seg.runtimeType}}\t\tSlot is ${slots[slotsCovered].name}");
              break;
            case std.MouthDef(name: String name):
              bool first = true;
              String? last;
              for (final b in bs) {
                final instanceInfo = blockInstanceInfo(b);
                if (instanceInfo == null) {
                  return null;
                }
                if (first) {
                  last = generateBlock(blocks, b, instanceInfo,
                      parent: owningBlockId);
                  if (last == null) {
                    return null;
                  }
                  inputs[name] = scratch.IdInput(
                    kind: scratch.InputKind.values[1],
                    id: last,
                  );
                  first = false;
                  blocks.addAll(blocks);
                } else {
                  blocks[last]?.setNext(instanceInfo.$2);
                  generateBlock(blocks, b, instanceInfo, parent: last);
                  last = instanceInfo.$2;
                }
              }
              break;
          }
          break;
        case ast.SWord(word: String word):
          if (slotsCovered == 0 && word.startsWith("when")) {
            hat = true;
          }
          words++;
          continue;
      }
      slotsCovered++;
    }
    int total = slotsCovered + words;
    if (total != block.segments.length && !hat) {
      debug("Only processed $total segments: $owningBlockId");
    }
    return (inputs: inputs, fields: fields, blocks: blocks, next: next);
  }

  String? getValueFromSingleWordBlock(ast.Block block) {
    return switch (block.segments) {
      [ast.SWord(word: String word)] => word,
      _ => null,
    };
  }

  (std.ScratchBlockDef, String)? menuInstanceInfo(String menu) {
    final def = std.menus["[$menu]"];
    if (def == null) {
      debug("NO menu def for: $menu");
      return null;
    }
    final curr = blockIds[def.opcode];
    if (curr != null) {
      blockIds[def.opcode] = curr + 1;
    } else {
      blockIds[def.opcode] = 0;
    }
    final id = "${def.opcode}_${blockIds[def.opcode]!}";
    return (def, id);
  }

  (std.ScratchBlockDef, String)? blockInstanceInfo(ast.Block block) {
    final op = block.op();
    final def = std.blockDefs[op];
    if (def == null) {
      debug("NO block def for: $op");
      return null;
    }
    final curr = blockIds[def.opcode];
    if (curr != null) {
      blockIds[def.opcode] = curr + 1;
    } else {
      blockIds[def.opcode] = 0;
    }
    final id = "${def.opcode}_${blockIds[def.opcode] ?? 'N/A'}";
    return (def, id);
  }

  void generateMenu(Map<String, scratch.Block> blocks, String fieldName,
      String value, (std.ScratchBlockDef, String) instanceInfo, String parent) {
    final (def, id) = instanceInfo;
    blocks[id] = scratch.BasicBlock(
      opcode: def.opcode,
      x: 0,
      y: 0,
      parent: parent,
      next: null,
      topLevel: false,
      shadow: false,
      fields: {fieldName: scratch.Field.value(value: value)},
      inputs: {},
    );
  }

  String? generateBlock(Map<String, scratch.Block> blocks, ast.Block block,
      (std.ScratchBlockDef, String) instanceInfo,
      {String? parent, bool topLevel = false, String? next}) {
    final (def, id) = instanceInfo;
    final ({
      Map<String, scratch.Input> inputs,
      Map<String, scratch.Field> fields,
      Map<String, scratch.Block> blocks,
      String? next,
    })? result = genInputsAndFields(block, def.args, id);
    if (result == null) {
      return null;
    }
    blocks.addAll(result.blocks);
    blocks[id] = scratch.BasicBlock(
      opcode: def.opcode,
      x: 0,
      y: 0,
      parent: parent,
      next: topLevel ? result.next : next,
      topLevel: topLevel,
      shadow: false,
      fields: result.fields,
      inputs: result.inputs,
    );
    return id;
  }

  scratch.Variable? genVariable(ast.DVar decl) {
    return scratch.Variable(name: decl.name, value: decl.value);
  }

  scratch.ListVar? genList(ast.DList decl) {
    return scratch.ListVar(name: decl.name, values: decl.values);
  }

  scratch.Asset? genAsset(ast.DAsset decl) {
    if (decl.isSound) {
      final uri = "$projectPath/assets/sounds/${decl.assetName}";
      final soundInfo = decoders.decodeSound(uri);
      if (soundInfo == null) {
        debug("Could not find a sound for '${decl.assetName}'.");
        return null;
      }
      assetMoves.add((
        from: "$uri.${soundInfo.ext}",
        to: '${soundInfo.md5}.${soundInfo.ext}'
      ));

      return scratch.Sound(
        assetId: soundInfo.md5,
        name: decl.assetName,
        md5ext: "${soundInfo.md5}.${soundInfo.ext}",
        dataFormat: soundInfo.ext,
        rate: soundInfo.rate,
        sampleCount: soundInfo.sampleCount,
      );
    }
    final uri = "$projectPath/assets/images/${decl.assetName}";
    final imageInfo = decoders.decodeImage(uri);
    if (imageInfo == null) {
      debug("Could not find an image for '${decl.assetName}'.");
      return null;
    }
    assetMoves.add((
      from: "$uri.${imageInfo.ext}",
      to: '${imageInfo.md5}.${imageInfo.ext}'
    ));
    return scratch.Costume(
      assetId: imageInfo.md5,
      name: decl.assetName,
      md5ext: "${imageInfo.md5}.${imageInfo.ext}",
      dataFormat: imageInfo.ext,
      rotationCenterX: imageInfo.centerX,
      rotationCenterY: imageInfo.centerY,
      bitmapResolution: 1,
    );
  }

  bool validValueForMenu(
      std.ScratchBlockDef menu, String menuName, String value) {
    switch (menuName) {
      case "BROADCAST_OPTION":
        final targetBs = targetBroadcasts[target];
        final stageBs = targetBroadcasts['stage']!;
        return (targetBs != null && targetBs.contains(value)) ||
            stageBs.contains(value);
      case "BROADCAST_INPUT":
        final targetBs = targetBroadcasts[target];
        return targetBs != null && targetBs.contains(value);
      case "COSTUME":
        final targetBs = targetCostumes[target];
        return targetBs != null && targetBs.contains(value);
      case "SOUND_MENU":
        final targetBs = targetSounds[target];
        return targetBs != null && targetBs.contains(value);
    }
    return menu.validMenuOption(value);
  }

  String? valueForMenuLabel(
      std.ScratchBlockDef menu, String menuName, String value) {
    switch (menuName) {
      case "BROADCAST_OPTION":
        return broadcastId(value);
      case "BROADCAST_INPUT":
        final targetBs = targetBroadcasts[target];
        if (targetBs == null || !targetBs.contains(value)) {
          return null;
        }
        return broadcastId(value);
      case "COSTUME":
        final targetBs = targetCostumes[target];
        if (targetBs == null || !targetBs.contains(value)) {
          return null;
        }
        return value;
      case "SOUND_MENU":
        final targetBs = targetSounds[target];
        if (targetBs == null || !targetBs.contains(value)) {
          return null;
        }
        return value;
    }
    return menu.menuValueForLabel(value);
  }

  scratch.Target? generateTarget(ast.ItchFile file) {
    target = file.name;

    final Map<String, scratch.Variable> vars = {};
    final Map<String, scratch.ListVar> lists = {};
    final Map<String, String> broadcasts = {};
    final blockDecls = <ast.Block>[];
    final Map<String, scratch.Block> blocks = {};
    final Map<String, scratch.Comment> comments = {};
    final List<scratch.Asset> costumes = [];
    final List<scratch.Asset> sounds = [];
    final _TargetSettings settings = _TargetSettings();

    for (final d in file.decls) {
      switch (d) {
        case ast.DBlock():
          blockDecls.add(d.block);
          break;
        case ast.DList _:
          final l = genList(d);
          if (l != null) {
            addListToTarget(d.name);
            lists[listId(d.name)] = l;
          } else {
            debug("Generation error: could not generate list variable for $d");
            return null;
          }
          break;
        case ast.DVar _:
          final v = genVariable(d);
          if (v != null) {
            addVarToTarget(d.name);
            vars[varId(d.name)] = v;
          } else {
            debug("Generation error: could not generate variable for $d");
            return null;
          }
          break;
        case ast.DBroadcast d:
          addBroadcastToTarget(d.name);
          broadcasts[broadcastId(d.name)] = d.name;
          break;
        case ast.DSet(name: String name, value: String value):
          settings.set(name, value);
          break;
        case ast.DAsset d:
          final asset = genAsset(d);
          if (asset == null) {
            debug("Generation error: could not generate costume for $d");
            return null;
          } else if (d.isSound) {
            sounds.add(asset);
            addSoundToTarget(d.assetName);
          } else {
            costumes.add(asset);
            addCostumeToTarget(d.assetName);
          }
          break;
        // case ast.DSound _:
        //    break;
      }
    }
    for (final b in blockDecls) {
      final instanceInfo = blockInstanceInfo(b);
      if (instanceInfo == null) {
        return null;
      }
      generateBlock(blocks, b, instanceInfo, topLevel: true);
    }

    for (final entry in file.comments.entries) {
      final comment = scratch.Comment(
        text: entry.value.content,
        minimized: true,
        x: blocks[entry.key]?.getX() ?? 0,
        y: blocks[entry.key]?.getY() ?? 0,
        blockId: entry.key,
      );
      comments[entry.key] = comment;
    }

    switch (file.fileType) {
      case ast.StageFile():
        return scratch.Stage(
          name: 'Stage',
          variables: vars,
          lists: lists,
          broadcasts: broadcasts,
          blocks: blocks,
          comments: comments,
          costumes: costumes,
          sounds: sounds,
          currentCostume: settings.currentCostume,
          layerOrder: settings.layerOrder,
          volume: settings.volume,
          videoTransparency: settings.videoTransparency,
          videoState: settings.videoState ?? scratch.VideoState.on,
          tempo: settings.tempo,
        );
      case ast.SpriteFile(name: String name):
        return scratch.Sprite(
          name: name,
          variables: vars,
          lists: lists,
          broadcasts: broadcasts,
          blocks: blocks,
          comments: comments,
          costumes: costumes,
          sounds: sounds,
          currentCostume: settings.currentCostume,
          layerOrder: settings.layerOrder,
          volume: settings.volume,
          size: settings.size,
          x: settings.x,
          y: settings.y,
          visible: settings.visible,
          direction: settings.direction,
          draggable: settings.draggable,
          rotationStyle: settings.rotationStyle,
        );
    }
  }

  scratch.Project? generate(Map<String, ast.ItchFile> files, String path) {
    projectPath = path;
    final targets = <scratch.Target>[];
    for (final entry in files.entries) {
      final target = generateTarget(entry.value);
      if (target != null) {
        targets.add(target);
      }
    }
    return scratch.Project(
      meta: scratch.Metadata(),
      targets: targets,
      monitors: [],
      extensions: [],
    );
  }
}
