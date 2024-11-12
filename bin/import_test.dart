import 'dart:convert';
import 'dart:io';
import 'package:test/test.dart';

import 'scratch_format.dart' as scratch;
import 'import.dart' as i;
import 'log_level.dart';
import 'standard_lib.dart' as stdlib;

const String whenKeyPressedBlockId = 'QH,JsE!||N59qWVNs[d-';
void main() {
  late scratch.Project project;
  try {
    project = scratch.Project.fromJson(
        jsonDecode(File('./fixtures/test_1/project.json').readAsStringSync()));
  } on scratch.ParseError catch (e) {
    print(e.message);
    fail("Failed due to above exception");
  }
  final testLogger = LoggerImpl(level: "error", sink: stdout);
  stdlib.loadBlockDefs(testLogger);
  test("astBlockFromScratch", () {
    final imp = i.Importer(
      logger: testLogger,
      projectPath: './fixtures/test_1/project.json',
    );
    final result = imp.astBlockFromScratch(
      project.targets[1].blocks[whenKeyPressedBlockId]!,
      project.targets[1].blocks,
    );
    final fixture = """
when [space] key pressed {
	point towards [mouse-pointer].
	change [pitch] sound effect by 10.
	turn right 15 degrees.
	if (([abs] of (pick random 1 to 10)) > 5) then {
		ask "What's your name?" and wait.
		create clone of [myself].
	} else {
		add "thing" to (baz).
		broadcast [message1].
		set drag mode [draggable].
		say (baz) for 2 seconds.
		reset timer.
		stop [all].
	}.
	if (key [space] pressed?) then {
		start sound [Meow].
		go [forward] 1 layers.
		change [color] effect by 25.
		switch backdrop to [backdrop1].
		switch costume to [costume2].
		set rotation style [left-right].
		glide 1 secs to [random position].
	}.
	delete (pick random 1 to (length of list (baz))) of (baz).
}
"""
        .trim();
    expect("$result", fixture);
  });
}
