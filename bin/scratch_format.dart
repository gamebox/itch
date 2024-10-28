import 'dart:convert';

class Project {
  final List<Target> targets;
  final List<Monitor> monitors;
  final List<String> extensions;
  final Metadata meta;

  Project({
    required this.targets,
    required this.monitors,
    required this.extensions,
    required this.meta,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    List<Target> tgts = [];
    List<Monitor> mtrs = [];
    List<String> exts = [];
    Metadata? m;
    if (json["targets"] case List<dynamic> targets) {
      for (var t in targets) {
        tgts.add(Target.fromJson(t));
      }
    }
    if (json["monitors"] case List<dynamic> monitors) {
      for (var m in monitors) {
        mtrs.add(Monitor.fromJson(m));
      }
    }
    if (json["extensions"] case List<String> extensions) {
      exts = extensions;
    }
    if (json["meta"] case Map<String, dynamic> meta) {
      m = Metadata.fromJson(meta);
    }
    if (m == null) {
      throw TypeError();
    }
    return Project(
      targets: tgts,
      monitors: mtrs,
      extensions: exts,
      meta: m,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "targets": targets.map((t) => t.toJson()).toList(),
      "monitors": monitors.map((t) => t.toJson()).toList(),
      "extensions": extensions,
      "meta": meta.toJson(),
    };
  }
}

class Variable {
  final String name;
  final dynamic value;

  Variable({required this.name, required this.value});

  factory Variable.fromJson(dynamic json) => switch (json) {
        [String name, dynamic value] => Variable(name: name, value: value),
        _ => throw TypeError(),
      };

  dynamic toJson() => [name, value];
}

class ListVar {
  final String name;
  final List<dynamic> values;

  ListVar({required this.name, required this.values});

  factory ListVar.fromJson(dynamic json) => switch (json) {
        [String name, List<dynamic> values] =>
          ListVar(name: name, values: values),
        _ => throw TypeError(),
      };

  dynamic toJson() => [name, values];
}

sealed class Target {
  bool isStage;
  String name;
  Map<String, Variable> variables;
  Map<String, ListVar> lists;
  Map<String, String> broadcasts;
  Map<String, Block> blocks;
  Map<String, Comment> comments;
  int currentCostume;
  List<Asset> costumes;
  List<Asset> sounds;
  int layerOrder;
  int volume;

  Target({
    required this.isStage,
    required this.name,
    required this.variables,
    required this.lists,
    required this.broadcasts,
    required this.blocks,
    required this.comments,
    required this.currentCostume,
    required this.costumes,
    required this.sounds,
    required this.layerOrder,
    required this.volume,
  });

  factory Target.fromJson(Map<String, dynamic> json) {
    final isStage = json["isStage"] as bool;
    if (isStage) {
      return Stage(
        name: json["name"] as String,
        variables: (json["variables"] as Map<String, dynamic>)
            .map((key, v) => MapEntry(key, Variable.fromJson(v))),
        currentCostume: json["currentCostume"] as int,
        costumes: (json["costumes"] as List<dynamic>)
            .map((s) => Asset.fromJson(s))
            .toList(),
        layerOrder: json["layerOrder"] as int,
        volume: json["volume"] as int,
        broadcasts:
            (json["broadcasts"] as Map<String, dynamic>).cast<String, String>(),
        tempo: json["tempo"] as int,
        lists: (json["lists"] as Map<String, dynamic>)
            .map((key, v) => MapEntry(key, ListVar.fromJson(v))),
        blocks: (json["blocks"] as Map<String, dynamic>)
            .map((key, val) => MapEntry(key, Block.fromJson(val))),
        comments: (json["comments"] as Map<String, dynamic>)
            .map((key, val) => MapEntry(key, Comment.fromJson(val))),
        sounds: (json["sounds"] as List<dynamic>)
            .map((s) => Asset.fromJson(s))
            .toList(),
        videoState: VideoState.fromJson(json["videoState"] as String),
        videoTransparency: json["videoTransparency"] as int,
        textToSpeechLanguage: json["textToSpeechLanguage"] as String?,
      );
    } else {
      return Sprite(
        name: json["name"] as String,
        variables: (json["variables"] as Map<String, dynamic>)
            .map((key, v) => MapEntry(key, Variable.fromJson(v))),
        currentCostume: json["currentCostume"] as int,
        costumes: (json["costumes"] as List<dynamic>)
            .map((s) => Asset.fromJson(s))
            .toList(),
        layerOrder: json["layerOrder"] as int,
        volume: json["volume"] as int,
        broadcasts:
            (json["broadcasts"] as Map<String, dynamic>).cast<String, String>(),
        lists: (json["lists"] as Map<String, dynamic>)
            .map((key, v) => MapEntry(key, ListVar.fromJson(v))),
        blocks: (json["blocks"] as Map<String, dynamic>)
            .map((key, val) => MapEntry(key, Block.fromJson(val))),
        comments: (json["comments"] as Map<String, dynamic>)
            .map((key, val) => MapEntry(key, Comment.fromJson(val))),
        sounds: (json["sounds"] as List<dynamic>)
            .map((s) => Asset.fromJson(s))
            .toList(),
        visible: json["visible"] as bool,
        x: json["x"] as int,
        y: json["y"] as int,
        size: json["size"] as int,
        direction: json["direction"] as int,
        draggable: json["draggable"] as bool,
        rotationStyle: RotationStyle.fromJson(json["rotationStyle"] as String),
      );
    }
  }

  Map<String, dynamic> toJson() => switch (this) {
        Stage(
          isStage: bool isStage,
          name: String name,
          variables: Map<String, Variable> variables,
          lists: Map<String, ListVar> lists,
          broadcasts: Map<String, String> broadcasts,
          blocks: Map<String, Block> blocks,
          comments: Map<String, Comment> comments,
          currentCostume: int currentCostume,
          sounds: List<Asset> sounds,
          layerOrder: int layerOrder,
          volume: int volume,
          tempo: int tempo,
          videoState: VideoState videoState,
          videoTransparency: int videoTransparency,
          textToSpeechLanguage: String? textToSpeechLanguage,
        ) =>
          {
            "isStage": isStage,
            "name": name,
            "variables": variables.map((key, v) => MapEntry(key, v.toJson())),
            "lists": lists.map((key, l) => MapEntry(key, l.toJson())),
            "blocks": blocks.map((key, b) => MapEntry(key, b.toJson())),
            "comments": comments.map((key, c) => MapEntry(key, c.toJson())),
            "sounds": sounds.map((s) => s.toJson()).toList(),
            "costumes": costumes.map((s) => s.toJson()).toList(),
            "broadcasts": broadcasts,
            "currentCostume": currentCostume,
            "layerOrder": layerOrder,
            "volume": volume,
            "tempo": tempo,
            "videoState": videoState.toJson(),
            "videoTransparency": videoTransparency,
            "textToSpeechLanguage": textToSpeechLanguage,
          }..removeWhere(
              (k, dynamic v) => k != 'textToSpeechLanguage' && v == null),
        Sprite(
          isStage: bool isStage,
          name: String name,
          variables: Map<String, Variable> variables,
          lists: Map<String, ListVar> lists,
          broadcasts: Map<String, String> broadcasts,
          blocks: Map<String, Block> blocks,
          comments: Map<String, Comment> comments,
          currentCostume: int currentCostume,
          sounds: List<Asset> sounds,
          layerOrder: int layerOrder,
          volume: int volume,
          visible: bool visible,
          x: int x,
          y: int y,
          size: int size,
          direction: int direction,
          draggable: bool draggable,
          rotationStyle: RotationStyle rotationStyle,
        ) =>
          {
            "isStage": isStage,
            "name": name,
            "variables": variables.map((key, v) => MapEntry(key, v.toJson())),
            "lists": lists.map((key, l) => MapEntry(key, l.toJson())),
            "blocks": blocks.map((key, b) => MapEntry(key, b.toJson())),
            "comments": comments.map((key, c) => MapEntry(key, c.toJson())),
            "sounds": sounds.map((s) => s.toJson()).toList(),
            "costumes": costumes.map((s) => s.toJson()).toList(),
            "currentCostume": currentCostume,
            "broadcasts": broadcasts,
            "layerOrder": layerOrder,
            "volume": volume,
            "visible": visible,
            "x": x,
            "y": y,
            "size": size,
            "direction": direction,
            "draggable": draggable,
            "rotationStyle": rotationStyle,
          }..removeWhere((k, dynamic v) => v == null),
      };
}

enum VideoState {
  on,
  off,
  onFlipped;

  static VideoState fromJson(String json) => switch (json) {
        "on" => VideoState.on,
        "off" => VideoState.off,
        "on-flipped" => VideoState.onFlipped,
        _ => throw ParseError("Expected a valid VideoState, got $json"),
      };

  dynamic toJson() => switch (this) {
        VideoState.on => "on",
        VideoState.off => "off",
        VideoState.onFlipped => "on-flipped",
      };
}

class Stage extends Target {
  int tempo;
  VideoState videoState;
  int videoTransparency;
  String? textToSpeechLanguage;

  Stage({
    required super.name,
    required super.variables,
    required super.lists,
    required super.broadcasts,
    required super.blocks,
    required super.comments,
    required super.currentCostume,
    required super.costumes,
    required super.sounds,
    required super.layerOrder,
    required super.volume,
    required this.tempo,
    required this.videoState,
    required this.videoTransparency,
    this.textToSpeechLanguage,
  }) : super(
          isStage: true,
        );
}

enum RotationStyle {
  allAround,
  leftRight,
  dontRotate;

  static RotationStyle fromJson(String json) => switch (json) {
        "left right" => RotationStyle.leftRight,
        "all around" => RotationStyle.allAround,
        "dont rotate" => RotationStyle.dontRotate,
        _ => throw ParseError("Expected a valid RotationStyle, got $json"),
      };

  dynamic toJson() => switch (this) {
        RotationStyle.leftRight => "left-right",
        RotationStyle.allAround => "all around",
        RotationStyle.dontRotate => "don't rotate",
      };
}

class Sprite extends Target {
  bool visible;
  int x;
  int y;
  int size;
  int direction;
  bool draggable;
  RotationStyle rotationStyle;

  Sprite({
    required super.name,
    required super.variables,
    required super.lists,
    required super.broadcasts,
    required super.blocks,
    required super.comments,
    required super.currentCostume,
    required super.costumes,
    required super.sounds,
    required super.layerOrder,
    required super.volume,
    required this.visible,
    required this.x,
    required this.y,
    required this.size,
    required this.direction,
    required this.draggable,
    required this.rotationStyle,
  }) : super(isStage: false);
}

class ParseError extends Error {
  String message;

  ParseError(this.message);

  static T Function(A a) attempt<T, A>(String message, T Function(A a) fn) {
    return (A a) {
      try {
        return fn(a);
      } on ParseError catch (e) {
        throw ParseError("${e.message}\nWhile $message");
      }
    };
  }

  static T Function(A a, B b) attempt2<T, A, B>(
      String Function(A a, B b) messageFn, T Function(A a, B b) fn) {
    return (A a, B b) {
      try {
        return fn(a, b);
      } on ParseError catch (e) {
        throw ParseError("${e.message}\nWhile ${messageFn(a, b)}");
      }
    };
  }
}

sealed class Block {
  Block();

  void setNext(String? next) {
    switch (this) {
      case BasicBlock b:
        b.next = next;
      default:
        break;
    }
  }

  int? getX() => switch (this) {
        ReporterBlock b => b.x,
        BasicBlock b => b.x,
      };
  int? getY() => switch (this) {
        ReporterBlock b => b.y,
        BasicBlock b => b.y,
      };

  factory Block.fromJson(dynamic json) => switch (json) {
        List list => ReporterBlock.fromJson(list),
        {
          "opcode": String opcode,
          "next": String? next,
          "parent": String? parent,
          "inputs": Map<String, dynamic> inputs,
          "fields": Map<String, dynamic> fields,
          "shadow": bool shadow,
          "topLevel": bool topLevel,
        } =>
          BasicBlock(
            opcode: opcode,
            next: next,
            parent: parent,
            inputs: inputs.map((key, i) => MapEntry(key, Input.fromJson(i))),
            fields: fields.map(
              ParseError.attempt2(
                (key, i) =>
                    "Parsing field '$key' in ${jsonEncode(json["fields"])}",
                (key, i) => MapEntry(key, Field.fromJson(i)),
              ),
            ),
            shadow: shadow,
            topLevel: topLevel,
            x: json["x"] as int?,
            y: json["y"] as int?,
          ),
        _ => throw ParseError("Expected valid block, got ${jsonEncode(json)}"),
      };

  dynamic toJson() => switch (this) {
        ReporterBlock b => b.toJson(),
        BasicBlock(
          opcode: String opcode,
          next: String? next,
          parent: String? parent,
          inputs: Map<String, Input> inputs,
          fields: Map<String, Field> fields,
          shadow: bool shadow,
          topLevel: bool topLevel,
          x: int? x,
          y: int? y,
          comment: String? comment,
          mutation: Mutation? mutation,
        ) =>
          {
            "opcode": opcode,
            "next": next,
            "parent": parent,
            "inputs": inputs.map((key, i) => MapEntry(key, i.toJson())),
            "fields": fields.map((key, f) => MapEntry(key, f.toJson())),
            "shadow": shadow,
            "topLevel": topLevel,
            "x": x,
            "y": y,
            "comment": comment,
            "mutation": mutation?.toJson(),
          }..removeWhere(
              (k, dynamic v) => (k != "next" && k != "parent") && v == null),
      };
}

class BasicBlock extends Block {
  String opcode;
  String? next;
  String? parent;
  Map<String, Input> inputs;
  Map<String, Field> fields;
  bool shadow;
  bool topLevel;
  int? x;
  int? y;
  String? comment;
  Mutation? mutation;

  BasicBlock({
    required this.opcode,
    this.next,
    this.parent,
    required this.inputs,
    required this.fields,
    required this.shadow,
    required this.topLevel,
    required this.x,
    required this.y,
    this.comment,
    this.mutation,
  }) : super();
}

class ReporterBlock extends Block {
  int code;
  String value;
  String? id;
  int? x;
  int? y;

  ReporterBlock.number(String num)
      : code = 4,
        value = num;
  ReporterBlock.positiveNumber(String num)
      : code = 5,
        value = num;
  ReporterBlock.postiveInteger(String num)
      : code = 6,
        value = num;
  ReporterBlock.integer(String num)
      : code = 7,
        value = num;
  ReporterBlock.angle(String angle)
      : code = 8,
        value = angle;
  ReporterBlock.color(String hex)
      : code = 9,
        value = hex;
  ReporterBlock.string(String str)
      : code = 10,
        value = str;
  ReporterBlock.broadcast({required String name, required this.id})
      : code = 11,
        value = name;
  ReporterBlock.variable(
      {required String name, required this.id, int? posX, int? posY})
      : code = 12,
        value = name,
        x = posX,
        y = posY;
  ReporterBlock.list(
      {required String name, required this.id, int? posX, int? posY})
      : code = 13,
        value = name,
        x = posX,
        y = posY;

  factory ReporterBlock.fromJson(dynamic json) {
    return switch (json) {
      [4, String value] => ReporterBlock.number(value),
      [5, String value] => ReporterBlock.positiveNumber(value),
      [6, String value] => ReporterBlock.postiveInteger(value),
      [7, String value] => ReporterBlock.integer(value),
      [8, String value] => ReporterBlock.angle(value),
      [9, String value] => ReporterBlock.color(value),
      [10, String value] => ReporterBlock.string(value),
      [11, String value, String id] =>
        ReporterBlock.broadcast(name: value, id: id),
      [12, String value, String id] =>
        ReporterBlock.variable(name: value, id: id, posX: null, posY: null),
      [13, String value, String id] =>
        ReporterBlock.list(name: value, id: id, posX: null, posY: null),
      [12, String value, String id, int x, int y] =>
        ReporterBlock.variable(name: value, id: id, posX: x, posY: y),
      [13, String value, String id, int x, int y] =>
        ReporterBlock.list(name: value, id: id, posX: x, posY: y),
      _ => throw ParseError(
          "Expected a valid ReporterBlock, got ${jsonEncode(json)}"),
    };
  }

  @override
  dynamic toJson() => switch (this) {
        ReporterBlock(code: 4) => [4, value],
        ReporterBlock(code: 5) => [5, value],
        ReporterBlock(code: 6) => [6, value],
        ReporterBlock(code: 7) => [7, value],
        ReporterBlock(code: 8) => [8, value],
        ReporterBlock(code: 9) => [9, value],
        ReporterBlock(code: 10) => [10, value],
        ReporterBlock(code: 11) => [11, value, id],
        ReporterBlock(code: 12, x: int x, y: int y) => [12, value, id, x, y],
        ReporterBlock(code: 13, x: int x, y: int y) => [13, value, id, x, y],
        ReporterBlock(code: 12) => [12, value, id],
        ReporterBlock(code: 13) => [13, value, id],
        ReporterBlock() => throw TypeError(),
      };
}

class Comment {
  String blockId;
  int x;
  int y;
  int width;
  int height;
  bool minimized;
  String text;

  Comment({
    required this.blockId,
    this.x = 0,
    this.y = 0,
    this.width = 200,
    this.height = 200,
    this.minimized = true,
    required this.text,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      blockId: json["blockId"] as String,
      x: json["x"] as int,
      y: json["y"] as int,
      width: json["width"] as int,
      height: json["height"] as int,
      minimized: json["minimized"] as bool,
      text: json["text"] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "blockId": blockId,
      "x": x,
      "y": y,
      "width": width,
      "height": height,
      "minimized": minimized,
      "text": text,
    };
  }
}

class Mutation {
  // Always include tagName: "mutation"
  // Always include children: []
  String proccode;
  List<String> argumentids;
  bool warp;
  List<String>? argumentnames;
  List<dynamic>? argumentdefaults;
  bool? hasNext;

  Mutation({
    required this.proccode,
    required this.argumentids,
    required this.warp,
    this.argumentnames,
    this.argumentdefaults,
    this.hasNext,
  });

  factory Mutation.fromJson(Map<String, dynamic> json) {
    return Mutation(
      proccode: json["proccode"] as String,
      argumentids: json["argumentids"] as List<String>,
      warp: json["warp"] as bool,
      argumentnames: json["argumentnames"] as List<String>?,
      argumentdefaults: json["argumentdefaults"] as List<dynamic>?,
      hasNext: json["hasNext"] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "proccode": proccode,
      "argumentids": argumentids,
      "warp": warp,
      "argumentnames": argumentnames,
      "argumentdefaults": argumentdefaults,
      "hasNext": hasNext,
    };
  }
}

sealed class Asset {
  String assetId;
  String name;
  String md5ext;
  String dataFormat;

  Asset({
    required this.assetId,
    required this.name,
    required this.md5ext,
    required this.dataFormat,
  });

  factory Asset.fromJson(Map<String, dynamic> json) => switch (json) {
        {
          "assetId": String assetId,
          "name": String name,
          "md5ext": String md5ext,
          "dataFormat": String dataFormat,
          "rotationCenterX": int rotationCenterX,
          "rotationCenterY": int rotationCenterY,
        } =>
          Costume(
            assetId: assetId,
            name: name,
            md5ext: md5ext,
            dataFormat: dataFormat,
            bitmapResolution: json["bitmapResolution"] as int?,
            rotationCenterX: rotationCenterX,
            rotationCenterY: rotationCenterY,
          ),
        {
          "assetId": String assetId,
          "name": String name,
          "md5ext": String md5ext,
          "dataFormat": String dataFormat,
          "rate": int rate,
          "sampleCount": int sampleCount,
        } =>
          Sound(
            assetId: assetId,
            name: name,
            md5ext: md5ext,
            dataFormat: dataFormat,
            rate: rate,
            sampleCount: sampleCount,
          ),
        _ =>
          throw ParseError("Expected a valid asset, got ${jsonEncode(json)}"),
      };

  Map<String, dynamic> toJson() => switch (this) {
        Costume(
          assetId: String assetId,
          name: String name,
          md5ext: String md5ext,
          dataFormat: String dataFormat,
          bitmapResolution: int? bitmapResolution,
          rotationCenterX: int rotationCenterX,
          rotationCenterY: int rotationCenterY,
        ) =>
          {
            "assetId": assetId,
            "name": name,
            "md5ext": md5ext,
            "dataFormat": dataFormat,
            "bitmapResolution": bitmapResolution,
            "rotationCenterX": rotationCenterX,
            "rotationCenterY": rotationCenterY,
          }..removeWhere((k, dynamic v) => v == null),
        Sound(
          assetId: String assetId,
          name: String name,
          md5ext: String md5ext,
          dataFormat: String dataFormat,
          rate: int rate,
          sampleCount: int sampleCount,
        ) =>
          {
            "assetId": assetId,
            "name": name,
            "md5ext": md5ext,
            "dataFormat": dataFormat,
            "format": "",
            "rate": rate,
            "sampleCount": sampleCount,
          }..removeWhere((k, dynamic v) => v == null),
      };
}

class Costume extends Asset {
  int? bitmapResolution;
  int rotationCenterX;
  int rotationCenterY;

  Costume({
    required super.assetId,
    required super.name,
    required super.md5ext,
    required super.dataFormat,
    required this.rotationCenterX,
    required this.rotationCenterY,
    required this.bitmapResolution,
  });
}

class Sound extends Asset {
  int rate;
  int sampleCount;

  Sound({
    required super.assetId,
    required super.name,
    required super.md5ext,
    required super.dataFormat,
    required this.rate,
    required this.sampleCount,
  });
}

enum MonitorMode {
  def,
  large,
  slider,
  list;

  static MonitorMode fromJson(String json) => switch (json) {
        "default" => MonitorMode.def,
        "large" => MonitorMode.large,
        "slider" => MonitorMode.slider,
        "list" => MonitorMode.list,
        _ => throw ParseError("Expected a valid MonitorMode, got $json"),
      };

  dynamic toJson() => switch (this) {
        MonitorMode.def => "default",
        MonitorMode.large => "large",
        MonitorMode.slider => "slider",
        MonitorMode.list => "list",
      };
}

class Monitor {
  String id;
  MonitorMode mode;
  String opcode;
  Map<String, dynamic> params;
  String? spriteName;
  dynamic value;
  int width;
  int height;
  int x;
  int y;
  bool visible;
  int? sliderMin;
  int? sliderMax;
  bool? isDiscrete;

  Monitor({
    required this.id,
    required this.mode,
    required this.opcode,
    required this.params,
    required this.spriteName,
    required this.value,
    required this.width,
    required this.height,
    required this.x,
    required this.y,
    required this.visible,
    required this.sliderMin,
    required this.sliderMax,
    required this.isDiscrete,
  });

  factory Monitor.fromJson(Map<String, dynamic> json) {
    return Monitor(
      id: json["id"] as String,
      mode: MonitorMode.fromJson(json["mode"] as String),
      opcode: json["opcode"] as String,
      params: (json["params"] as Map<String, dynamic>),
      spriteName: json["spriteName"] as String?,
      value: json["value"] as dynamic,
      width: json["width"] as int,
      height: json["height"] as int,
      x: json["x"] as int,
      y: json["y"] as int,
      visible: json["visible"] as bool,
      sliderMin: json["sliderMin"] as int?,
      sliderMax: json["sliderMax"] as int?,
      isDiscrete: json["isDiscrete"] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "mode": mode.toJson(),
      "opcode": opcode,
      "params": params,
      "spriteName": spriteName,
      "value": value,
      "width": width,
      "height": height,
      "x": x,
      "y": y,
      "visible": visible,
      "sliderMin": sliderMin,
      "sliderMax": sliderMax,
      "isDiscrete": isDiscrete,
    }..removeWhere((k, dynamic v) => k != 'spriteName' && v == null);
  }
}

class Metadata {
  String semver;
  String vm;
  String agent;

  Metadata()
      : semver = '3.0.0',
        vm = '0.2.0-prerelease.20220222132735',
        agent = '';

  factory Metadata.fromJson(Map<String, dynamic> json) {
    final m = Metadata();
    m.vm = json["vm"];
    m.agent = json["agent"];
    return m;
  }

  Map<String, dynamic> toJson() {
    return {
      "semver": "3.0.0",
      "vm": vm,
      "agent": agent,
    };
  }
}

enum InputKind {
  notused,
  shadow,
  noShadow,
  obscured,
}

sealed class Input {
  InputKind kind;
  ReporterBlock? shadowValue;

  Input({required this.kind, required this.shadowValue});

  factory Input.fromJson(dynamic json) => switch (json) {
        [3, String id, List block] => IdInput(
            kind: InputKind.values[3],
            id: id,
            shadowValue: ReporterBlock.fromJson(block),
          ),
        [3, List block, List shadowBlock] => BlockInput(
            kind: InputKind.values[3],
            block: ReporterBlock.fromJson(block),
            shadowValue: ReporterBlock.fromJson(shadowBlock),
          ),
        [int kind, String id] when kind >= 1 && kind < 3 =>
          IdInput(kind: InputKind.values[kind], id: id),
        [int kind, [int _, ...]] when kind >= 1 && kind < 3 => BlockInput(
            kind: InputKind.values[kind],
            block: ReporterBlock.fromJson(json[1]),
          ),
        _ =>
          throw ParseError("Expected a valid Input, got ${jsonEncode(json)}"),
      };

  dynamic toJson() => switch (this) {
        IdInput(
          kind: var kind,
          id: var id,
          shadowValue: ReporterBlock shadowValue
        ) =>
          [kind.index, id, shadowValue],
        IdInput(kind: var kind, id: var id) => [kind.index, id],
        BlockInput(
          kind: var kind,
          block: var block,
          shadowValue: ReporterBlock shadowValue
        ) =>
          [kind.index, block.toJson(), shadowValue.toJson()],
        BlockInput(kind: var kind, block: var block) => [
            kind.index,
            block.toJson()
          ],
      };
}

class IdInput extends Input {
  IdInput({
    required super.kind,
    super.shadowValue,
    required this.id,
  });

  final String id;
}

class BlockInput extends Input {
  BlockInput({
    required super.kind,
    super.shadowValue,
    required this.block,
  });

  ReporterBlock block;
}

class Field {
  Field();

  dynamic value;
  String? id;

  Field.value({required this.value}) : id = null;
  Field.varOrList({required this.value, required this.id});

  factory Field.fromJson(dynamic json) => switch (json) {
        [dynamic value, String? id] => Field.varOrList(value: value, id: id),
        [dynamic value] => Field.value(value: value),
        _ =>
          throw ParseError("Expected a valid Field, got ${jsonEncode(json)}"),
      };

  dynamic toJson() => [value, id];
}
