import 'dart:convert';
import 'dart:io';

class ScratchBlockDef {
  final String opcode;
  final String identifier;
  final List<SlotDef> args;
  final String? category;
  final String srcLabel;

  const ScratchBlockDef({
    required this.opcode,
    required this.args,
    required this.identifier,
    required this.category,
    required this.srcLabel,
  });

  factory ScratchBlockDef.fromJson(dynamic json) {
    if (json case Map<String, dynamic> obj) {
      final opcode = obj["opcode"];
      String identifier = obj["blockLabel"];
      String srcLabel = identifier;
      final category = obj["category"] ?? "operator";
      final args = <SlotDef>[];
      if (obj["args"] case List<dynamic> argList) {
        if (identifier == "()" && argList.length == 1) {
          if (argList[0] case {"type": FIELD_DROPDOWN}) {
            identifier = "[${argList[0]["name"]}]";
          }
          if (argList[0] case {"type": FIELD_NUMBERDROPDOWN}) {
            identifier = "[${argList[0]["name"]}]";
          }
          if (argList[0] case {"type": FIELD_VARIABLE_GETTER}) {
            identifier = "(${argList[0]["name"]})";
          }
          if (argList[0] case {"type": FIELD_VARIABLE}) {
            identifier = "(${argList[0]["name"]})";
          }
        }
        for (final a in argList) {
          if (a case <String, dynamic>{"type": FIELD_IMAGE}) {
            continue;
          }
          args.add(SlotDef.fromJson(a));
        }
      }
      return ScratchBlockDef(
        opcode: opcode,
        args: args,
        identifier: identifier,
        category: category,
        srcLabel: srcLabel,
      );
    }
    throw Error();
  }

  bool isMenu() {
    if (srcLabel == "()" && args.length == 1) {
      return true;
    }
    return false;
  }

  bool validMenuOption(String value) {
    if (!isMenu()) {
      return false;
    }
    if (args[0] case FieldDef(options: final options)) {
      final opt = options.firstWhere(
        (opt) => opt.value == value,
        orElse: () => DropdownOption(value: null, label: ''),
      );
      if (opt.value == null && opt.label == '') {
        return false;
      }
      return true;
    }
    return false;
  }

  String? menuValueForLabel(String label) {
    if (!isMenu()) {
      return null;
    }
    if (args[0] case FieldDef(options: final options)) {
      final opt = options.singleWhere(
        (opt) => opt.label == label,
        orElse: () => DropdownOption(value: null, label: ''),
      );
      if (opt.value == null && opt.label == '') {
        return null;
      }
      return opt.value;
    }
    return null;
  }

  @override
  String toString() {
    var str = identifier;
    for (final arg in args) {
      final a = switch (arg) {
        InputDef(name: String name, check: Check.boolean) => "<$name>",
        InputDef(name: String name, check: Check.none) => "($name)",
        FieldDef(name: String name) => "[$name]",
        MouthDef(name: String name) => "{$name}",
        VarDef(name: String name) => name,
        VarGetterDef(name: String name) => name,
      };

      str = str.replaceFirst(RegExp(r"(\(\)|\{\})"), a);
    }
    return "$str :: ($category/$opcode)";
  }
}

// ignore: constant_identifier_names
const FIELD_DROPDOWN = "field_dropdown";
// ignore: constant_identifier_names
const FIELD_IMAGE = "field_image";
// ignore: constant_identifier_names
const FIELD_NUMBERDROPDOWN = "field_numberdropdown";
// ignore: constant_identifier_names
const FIELD_VARIABLE = "field_variable";
// ignore: constant_identifier_names
const FIELD_VARIABLE_GETTER = "field_variable_getter";
// ignore: constant_identifier_names
const INPUT_STATEMENT = "input_statement";
// ignore: constant_identifier_names
const INPUT_VALUE = "input_value";

sealed class SlotDef {
  final String name;
  SlotDef({required this.name});

  factory SlotDef.fromJson(dynamic json) {
    if (json case Map<String, dynamic> obj) {
      switch (obj["type"]) {
        case FIELD_DROPDOWN:
        case FIELD_NUMBERDROPDOWN:
          // Parse FieldDef
          final options = <DropdownOption>[];
          if (obj["options"] case List<dynamic> opts) {
            for (final opt in opts) {
              options.add(DropdownOption.fromJson(opt));
            }
          }
          return FieldDef(
            name: obj["name"],
            options: options,
          );
        case FIELD_VARIABLE:
          return VarDef(name: obj["name"]);
        case FIELD_VARIABLE_GETTER:
          return VarGetterDef(name: obj["name"]);
        case INPUT_STATEMENT:
          return MouthDef(name: obj["name"]);
        // Parse MouthDef
        case INPUT_VALUE:
          return InputDef(
            name: obj["name"],
            check: Check.fromJson(obj["check"]),
            hasMenu: obj["hasMenu"] ?? false,
          );
        // Parse InputDef
      }
    }
    throw Error();
  }
}

enum Check {
  none,
  boolean;

  factory Check.fromJson(dynamic json) {
    if (json case "Boolean") {
      return Check.boolean;
    }
    return Check.none;
  }
}

class InputDef extends SlotDef {
  final Check check;
  final bool hasMenu;

  InputDef({required super.name, required this.check, this.hasMenu = false});
}

class DropdownOption {
  final String label;
  final String? value;

  DropdownOption({required this.label, required this.value});

  factory DropdownOption.fromJson(dynamic json) {
    if (json case [String label, String? value]) {
      return DropdownOption(label: label, value: value);
    } else {
      print("Got json: ${jsonEncode(json)}");
    }
    throw Error();
  }
}

class FieldDef extends SlotDef {
  final List<DropdownOption> options;
  FieldDef({required super.name, required this.options});
}

class MouthDef extends SlotDef {
  MouthDef({required super.name});
}

class VarDef extends SlotDef {
  VarDef({required super.name});
}

class VarGetterDef extends SlotDef {
  VarGetterDef({required super.name});
}

final Map<String, ScratchBlockDef> blockDefs = {};

void printDefs() {
  int long = 0;
  for (final key in blockDefs.keys) {
    final l = key.length;
    if (l > long) {
      long = l;
    }
  }
  print("Showing ${blockDefs.length} blocks");
  for (final entry in blockDefs.entries) {
    print("${entry.key.padRight(long + 1, ' ')}: ${entry.value}");
  }
}

Future<void> loadBlockDefs() async {
  if (blockDefs.isNotEmpty) {
    print("Block defs already loaded");
    return;
  }
  final f = File.fromUri(Uri.file("./data/blocks.json"));
  final blocksJson = jsonDecode(await f.readAsString());
  if (blocksJson case List<dynamic> json) {
    print("Loading ${json.length} block definitions");
    for (final b in json) {
      final block = ScratchBlockDef.fromJson(b);
      if (blockDefs.containsKey(block.identifier)) {
        print(
            "Trying to insert:\n\n'${jsonEncode(b)}'\n\nBut the identifier '${block.identifier}' already exists");
      }
      if (block.isMenu()) {
        menus[block.identifier] = block;
        continue;
      }
      blockDefs[block.identifier] = block;
    }
  } else {
    throw Error();
  }
}

final Map<String, ScratchBlockDef> menus = {};
