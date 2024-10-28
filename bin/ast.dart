class ItchFile {
  FileType fileType;
  List<Block> blocks;
  List<Decl> decls;
  Map<String, Comment> comments;

  get name => switch (fileType) {
        StageFile() => "stage",
        SpriteFile(name: String name) => name,
      };

  ItchFile.stage({required this.decls, required this.comments})
      : fileType = StageFile(),
        blocks = [];
  ItchFile.sprite(String name, {required this.decls, required this.comments})
      : fileType = SpriteFile(name),
        blocks = [];

  @override
  String toString() {
    final fileDesc = switch (fileType) {
      StageFile() => "stage.",
      SpriteFile(name: String name) => "sprite $name.",
    };

    return "$fileDesc\n${decls.map((d) => d.toString()).join('.\n')}";
  }
}

sealed class FileType {}

class StageFile extends FileType {}

class SpriteFile extends FileType {
  String name;

  SpriteFile(this.name);
}

sealed class Decl {
  @override
  String toString() => switch (this) {
        DSet(name: String name, value: String value) => "set $name = $value",
        DVar(name: String name, value: String value) => "var $name = $value",
        DList(name: String name, values: List<String> values) =>
          "list $name = [${values.join(", ")}]",
        DBroadcast(name: String name) => 'broadcast "$name".',
        DBlock(block: Block block) => "block ${block.toString()}",
        DAsset(assetName: String name) => 'costume "$name"',
      };
}

class DSet extends Decl {
  final String name;
  final String value;
  DSet({required this.name, required this.value});
}

class DVar extends Decl {
  final String name;
  final String value;
  DVar({required this.name, required this.value});
}

class DList extends Decl {
  final String name;
  final List<String> values;
  DList({required this.name, required this.values});
}

class DBroadcast extends Decl {
  final String name;
  DBroadcast({required this.name});
}

class DBlock extends Decl {
  final Block block;
  DBlock({required this.block});
}

class DAsset extends Decl {
  final String assetName;
  final bool isSound;
  DAsset({required this.assetName}) : isSound = false;
  DAsset.sound({required this.assetName}) : isSound = true;
}

sealed class Segment {
  @override
  String toString() => switch (this) {
        SWord(word: String word) => word,
        SValue(value: String value) => "($value)",
        SField(value: String value) => "[$value]",
        SReporter(block: Block block) => "($block)",
        SCMouth(blocks: List<Block> blocks) => "{\n\t${blocks.join("\n\t")}\n}",
      };
  @override
  get hashCode => switch (this) {
        SWord(word: String word) => Object.hash(0, word),
        SValue(value: String value) => Object.hash(1, value),
        SField(value: String value) => Object.hash(2, value),
        SReporter(block: Block block) => Object.hash(3, block),
        SCMouth(blocks: List<Block> blocks) => Object.hashAll([4, ...blocks]),
      };

  @override
  bool operator ==(Object other) => switch (this) {
        SWord(word: String word) => switch (other) {
            SWord(word: String oWord) => word == oWord,
            _ => false,
          },
        SValue(value: String value) => switch (other) {
            SValue(value: String oValue) => value == oValue,
            _ => false,
          },
        SField(value: String value) => switch (other) {
            SField(value: String oValue) => value == oValue,
            _ => false,
          },
        SReporter(block: Block block) => switch (other) {
            SReporter(block: Block oBlock) => block == oBlock,
            _ => false,
          },
        SCMouth(blocks: List<Block> blocks) => switch (other) {
            SCMouth(blocks: List<Block> oBlocks) =>
              blocks.indexed.every((arg) => arg.$2 == oBlocks[arg.$1]),
            _ => false,
          },
      };
}

class SWord extends Segment {
  final String word;
  SWord({required this.word});
}

class SValue extends Segment {
  final String value;
  SValue({required this.value});
}

class SField extends Segment {
  final String value;
  SField({required this.value});
}

class SReporter extends Segment {
  final Block block;
  SReporter({required this.block});
}

class SCMouth extends Segment {
  final List<Block> blocks;
  SCMouth(this.blocks);
}

class Block {
  List<Segment> segments;
  bool reporter;
  Block(this.segments, {this.reporter = false});

  String op() {
    final segs = switch (segments[0]) {
      SWord(word: String word) => word.startsWith("when")
          ? segments.sublist(0, segments.length - 1)
          : segments,
      _ => segments,
    };
    return segs
        .map((s) => switch (s) {
              SCMouth _ => '{}',
              SWord(word: String word) => word,
              _ => '()',
            })
        .join(" ");
  }

  @override
  String toString() {
    return segments.map((s) => s.toString()).toList().join(" ");
  }

  @override
  int get hashCode => Object.hashAll([reporter, ...segments]);

  @override
  bool operator ==(Object other) {
    if (other is! Block ||
        reporter != other.reporter ||
        segments.length != other.segments.length) {
      return false;
    }
    for (final (i, s) in segments.indexed) {
      if (s != other.segments[i]) {
        return false;
      }
    }
    return true;
  }
}

class Comment {
  final String content;
  Comment(this.content);
}

class BlockMeta {
  bool visible;
  int x;
  int y;

  BlockMeta({required this.visible, required this.x, required this.y});
}
