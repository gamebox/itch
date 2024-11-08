import 'dart:convert';
import 'dart:io';
import 'a_command.dart';
import 'log_level.dart';

bool compareList(dynamic fixture, dynamic built,
    bool Function(dynamic, dynamic) elementCompare) {
  switch ((fixture, built)) {
    case (List<dynamic> fixtureTargets, List<dynamic> targets):
      if (fixtureTargets.length != targets.length) {
        return false;
      }
      for (final (i, t) in targets.indexed) {
        if (!elementCompare(fixtureTargets[i]!, t)) {
          print("List item $i");
          return false;
        }
      }
      break;
    default:
      return false;
  }
  return true;
}

bool compareMapKeys(dynamic fixture, dynamic built,
    bool Function(dynamic, dynamic, String) compareEntry,
    {bool sameKeys = true}) {
  switch ((fixture, built)) {
    case (Map<String, dynamic> fixtureMap, Map<String, dynamic> map):
      if (fixtureMap.length != map.length) {
        print(
            "Maps have different number of keys: ${fixtureMap.length} != ${map.length}");
        return false;
      }
      final fixtureKeys = fixtureMap.keys.toSet();
      final builtKeys = map.keys.toSet();
      if (!sameKeys &&
          (!fixtureKeys.containsAll(builtKeys) ||
              !builtKeys.containsAll(fixtureKeys))) {
        print(
            "Maps do not have same keys:\n${fixtureKeys.join("\t")}\n${builtKeys.join("\t")}");
        return false;
      }
      for (final key in fixtureKeys) {
        if (!compareEntry(fixtureMap[key], map[key], key)) {
          print("key $key");
          return false;
        }
      }
      break;
    default:
      return false;
  }
  return true;
}

bool compareKeysAlwaysTrue(dynamic _a, dynamic _b, String _c) {
  return true;
}

List<dynamic> getTopLevelBlocks(dynamic blocks) {
  List<dynamic> bs = [];
  if (blocks case Map<String, dynamic> b) {
    if (b case {"topLevel": true}) {
      bs.add(b);
    }
  }
  return bs;
}

Map<String, int> getOpcodeUsage(dynamic blocks) {
  final usage = <String, int>{};
  if (blocks case Map<String, dynamic> bs) {
    for (final b in bs.values) {
      if (b["opcode"] case String opcode) {
        if (usage[opcode] == null) {
          usage[opcode] = 0;
        }
        usage[opcode] = usage[opcode]! + 1;
      }
    }
  }
  return usage;
}

bool compareTargetKeys(dynamic fixture, dynamic built, String key) {
  switch (key) {
    case "blocks":
      final fixtureTopLevel = getTopLevelBlocks(fixture);
      final builtTopLevel = getTopLevelBlocks(built);
      if (fixtureTopLevel.length != builtTopLevel.length) {
        print("Number of top level blocks");
        return false;
      }
      if (fixtureTopLevel
              .map((b) => b["opcode"])
              .toSet()
              .intersection(builtTopLevel.map((b) => b["opcode"]).toSet())
              .length !=
          fixtureTopLevel.length) {
        print("Top level opcodes");
        return false;
      }
      final fixtureOpcodes = getOpcodeUsage(fixture);
      final builtOpcodes = getOpcodeUsage(built);
      print("  ${"code".padRight(30)}\tfixture\t\tbuilt");
      var fixtureTotal = 0;
      var builtTotal = 0;
      for (final code
          in fixtureOpcodes.keys.toSet().union(builtOpcodes.keys.toSet())) {
        final fix = fixtureOpcodes[code] ?? 0;
        final blt = builtOpcodes[code] ?? 0;
        fixtureTotal += fix;
        builtTotal += blt;
        final sigil = fix == blt
            ? '='
            : fix < blt
                ? '+'
                : '-';
        if (sigil != '=') {
          print("$sigil ${code.padRight(30)}\t$fix\t\t$blt");
        }
      }
      print("  ${"TOTAL".padRight(30)}\t$fixtureTotal\t\t$builtTotal");
      if (!compareMapKeys(fixture, built, compareKeysAlwaysTrue,
          sameKeys: false)) {
        print("number of blocks");
        return false;
      }
    case "variables":
    case "lists":
    case "broadcasts":
    case "comments":
    case "costumes":
    case "sounds":
      break;
    case "currentCostume":
    case "direction":
    case "draggable":
    case "isStage":
    case "layerOrder":
    case "name":
    case "rotationStyle":
    case "size":
    case "visible":
    case "volume":
    case "x":
    case "y":
      if (fixture != built) {
        print("Value not the same: $fixture != $built");
        return false;
      }
      break;
  }
  return true;
}

bool compareTargets(dynamic fixture, dynamic built) {
  if (!compareMapKeys(fixture, built, compareTargetKeys)) {
    return false;
  }
  return true;
}

Future<bool> runCompare(String dir) async {
  final fixtureProjectFile =
      File.fromUri(Uri.file("./fixtures/$dir/project.json"));
  final builtProjectFile = File.fromUri(Uri.file("./out/project.json"));
  final fixtureProjectJson =
      jsonDecode(await fixtureProjectFile.readAsString());
  final builtProjectJson = jsonDecode(await builtProjectFile.readAsString());
  if (!compareList(
    fixtureProjectJson["targets"],
    builtProjectJson["targets"],
    compareTargets,
  )) {
    return false;
  }

  return true;
}

class CompareCommand implements ACommand {
  String dir;

  CompareCommand({required this.dir});

  @override
  Future<bool> exec(LoggerImpl _) {
    return runCompare(dir);
  }
}
