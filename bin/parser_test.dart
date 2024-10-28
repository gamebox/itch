import "package:test/test.dart";
import "./parser.dart";
import "./ast.dart" as ast;

void main() {
  group("Parser", () {
    group("parseStaticValue", () {
      test("Static string value", () {
        final p = Parser(
          contents: '"Hello world!".',
          fileName: "test.itch",
        );
        final value = p.parseStaticValue();
        expect(value, "Hello world!");
      });
      test("Static integer value", () {
        final p = Parser(
          contents: '23',
          fileName: "test.itch",
        );
        final value = p.parseStaticValue();
        expect(value, "23");
      });
      test("Static decimal value", () {
        final p = Parser(
          contents: '23.14',
          fileName: "test.itch",
        );
        final value = p.parseStaticValue();
        expect(value, "23.14");
      });
      test("Static signed integer value", () {
        final p = Parser(
          contents: '-23',
          fileName: "test.itch",
        );
        final value = p.parseStaticValue();
        expect(value, "-23");
      });
      test("Static signed decimal value", () {
        final p = Parser(
          contents: '-23.14',
          fileName: "test.itch",
        );
        final value = p.parseStaticValue();
        expect(value, "-23.14");
      });
    });

    group("parseWordSegment", () {
      final List<({String name, String contents, String word})> testCases = [
        (name: "simple", contents: "foo", word: "foo"),
        (
          name: "long",
          contents: "this is a long word segment",
          word: "this is a long word segment"
        ),
        (
          name: "using weird chars",
          contents: "isn't this weird & not fun?",
          word: "isn't this weird & not fun?"
        ),
        (
          name: "won't parse reporters",
          contents: "this (foo) is something",
          word: "this"
        ),
        (
          name: "won't parse fields",
          contents: "this [foo] is something",
          word: "this"
        ),
      ];
      for (final c in testCases) {
        test(c.name, () {
          final p = Parser(
            contents: c.contents,
            fileName: "${c.name}_test.itch",
          );

          final seg = p.parseWordSegment();
          expect(seg, isNotNull);
          switch (seg) {
            case ast.SWord(word: String word):
              expect(word, c.word);
            default:
              fail("Should never happen");
          }
        });
      }
    });

    group("parseDecl", () {
      group("parsing set", () {
        final List<({String name, String contents, ast.DSet decl})>
            setTestCases = [
          (
            name: "simple",
            contents: "set x = 0.\n",
            decl: ast.DSet(name: "x", value: "0")
          ),
          (
            name: "Weird name",
            contents: 'set tony\'s weird name = "Hi".',
            decl: ast.DSet(name: "tony's weird name", value: "Hi")
          ),
        ];
        for (final c in setTestCases) {
          test(c.name, () {
            final p =
                Parser(contents: c.contents, fileName: "${c.name}_test.itch");
            final decl = p.parseDecl();
            if (decl case ast.DSet s) {
              expect(s.name, c.decl.name);
              expect(s.value, c.decl.value);
            } else {
              fail(
                  "Expected: ${c.decl}\nGot: $decl\nParse Errors:\n${p.errors().join('\n')}");
            }
          });
        }
      });
      group("parsing var", () {
        final List<({String name, String contents, ast.DVar decl})>
            setTestCases = [
          (
            name: "simple",
            contents: "var x = 0.\n",
            decl: ast.DVar(name: "x", value: "0")
          ),
          (
            name: "Weird name",
            contents: 'var tony\'s weird name = "Hi".',
            decl: ast.DVar(name: "tony's weird name", value: "Hi")
          ),
        ];
        for (final c in setTestCases) {
          test(c.name, () {
            final p =
                Parser(contents: c.contents, fileName: "${c.name}_test.itch");
            final decl = p.parseDecl();
            if (decl case ast.DVar s) {
              expect(s.name, c.decl.name);
              expect(s.value, c.decl.value);
            } else {
              fail(
                  "Expected: ${c.decl}\nGot: $decl\nParse Errors:\n${p.errors().join('\n')}");
            }
          });
        }
      });
      group("parsing list", () {
        final List<({String name, String contents, ast.DList decl})>
            setTestCases = [
          (
            name: "simple",
            contents: "list x = [0].\n",
            decl: ast.DList(name: "x", values: ["0"])
          ),
          (
            name: "Weird name",
            contents: 'list tony\'s weird name = ["Hi"].',
            decl: ast.DList(name: "tony's weird name", values: ["Hi"])
          ),
          (
            name: "Weird name with multiple string values",
            contents: 'list tony\'s weird name = ["Hi", "There"].',
            decl: ast.DList(name: "tony's weird name", values: ["Hi", "There"])
          ),
          (
            name: "Weird name with multiple numeric values",
            contents: 'list tony\'s weird name = [0, 1, -8.503].',
            decl: ast.DList(
                name: "tony's weird name", values: ["0", "1", "-8.503"])
          ),
          (
            name: "Weird name with multiple mixed values",
            contents: 'list tony\'s weird name = [0, "one", -8.503].',
            decl: ast.DList(
                name: "tony's weird name", values: ["0", "one", "-8.503"])
          ),
        ];
        for (final c in setTestCases) {
          test(c.name, () {
            final p =
                Parser(contents: c.contents, fileName: "${c.name}_test.itch");
            final decl = p.parseDecl();
            if (decl case ast.DList s) {
              expect(s.name, c.decl.name);
              expect(s.values.length, c.decl.values.length);
              for (final (i, v) in s.values.indexed) {
                expect(v, c.decl.values[i]);
              }
            } else {
              fail(
                  "Expected: ${c.decl}\nGot: $decl\nParse Errors:\n${p.errors().join('\n')}");
            }
          });
        }
      });
      group("parsing costume", () {
        final List<({String name, String contents, String costumeName})>
            testCases = [
          (
            name: 'simple',
            contents: 'costume "simple".',
            costumeName: 'simple'
          ),
          (
            name: 'weird asset name',
            contents:
                'costume "It\'s the weirdest name%20you could see (hahaha!)".',
            costumeName: 'It\'s the weirdest name%20you could see (hahaha!)'
          ),
        ];
        for (final c in testCases) {
          test(c.name, () {
            final p =
                Parser(contents: c.contents, fileName: "${c.name}_test.itch");
            final decl = p.parseDecl();
            if (decl case ast.DAsset d) {
              expect(d.assetName, c.costumeName);
            } else {
              fail(
                  "Expected: a DCostume with assetName = ${c.costumeName}\nGot: $decl\nParse Errors:\n${p.errors().join('\n')}");
            }
          });
        }
      });
      group("parsing block", () {
        final List<({String name, String contents, ast.Block block})>
            testCases = [
          (
            name: "single word",
            contents: "block stop.",
            block: ast.Block(
              [ast.SWord(word: "stop")],
            ),
          ),
          (
            name: "multiword",
            contents: "block stop all.",
            block: ast.Block(
              [ast.SWord(word: "stop all")],
            ),
          ),
          (
            name: "with simple mouth",
            contents: "block when flag clicked {\n\tstop all.\n}.",
            block: ast.Block(
              [
                ast.SWord(word: "when flag clicked"),
                ast.SCMouth([
                  ast.Block([ast.SWord(word: "stop all")])
                ])
              ],
            ),
          ),
          (
            name: "with field",
            contents: "block stop [this script].",
            block: ast.Block(
              [
                ast.SWord(word: "stop"),
                ast.SField(value: "this script"),
              ],
            ),
          ),
          (
            name: "with reporter",
            contents: "block turn left (foo) degrees.",
            block: ast.Block(
              [
                ast.SWord(word: "turn left"),
                ast.SReporter(
                  block: ast.Block(
                    [
                      ast.SWord(word: "foo"),
                    ],
                    reporter: true,
                  ),
                ),
                ast.SWord(word: "degrees"),
              ],
            ),
          ),
          (
            name: "with static values",
            contents: 'block say "Woah!" for 5 seconds.',
            block: ast.Block(
              [
                ast.SWord(word: "say"),
                ast.SValue(value: "Woah!"),
                ast.SWord(word: "for"),
                ast.SValue(value: "5"),
                ast.SWord(word: "seconds"),
              ],
            ),
          ),
        ];
        for (final c in testCases) {
          test(c.name, () {
            final p =
                Parser(contents: c.contents, fileName: "${c.name}_test.itch");
            final decl = p.parseDecl();
            if (decl case ast.DBlock(block: ast.Block block)) {
              expect(block.segments.length, c.block.segments.length,
                  reason: "$block");
              for (final (i, s) in block.segments.indexed) {
                expect(s, c.block.segments[i]);
              }
            }
          });
        }
      });
      group("parsing comment", () {
        final List<({String name, String contents, String comment})> testCases =
            [
          (name: "simple", contents: "# Hello", comment: "Hello"),
          (
            name: "multi-line",
            contents: "# Hello\n# World!",
            comment: "Hello\nWorld!"
          ),
        ];
        for (final c in testCases) {
          test(c.name, () {
            final p =
                Parser(contents: c.contents, fileName: "${c.name}_test.itch");
            p.parseDecl();
            expect(p.freeComment, c.comment);
          });
        }
      });
    });
  });
}
