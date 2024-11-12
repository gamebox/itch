import "dart:math";

import "ast.dart";
import "log_level.dart";

class ParserError extends Error {
  final int offset;
  final String message;
  final ParserError? childError;

  ParserError({required this.message, required this.offset})
      : childError = null;
  ParserError.withChild(
      {required this.message, required this.offset, required ParserError child})
      : childError = child;

  String printWithSourceAndFilename(String source, String filename) {
    final substring = source.substring(0, offset);
    final lines = substring.runes.where((r) => r == 0x000A).length + 1;
    final lastNewLine = substring.lastIndexOf(RegExp(r"\n"));
    final col = offset - lastNewLine;
    return "($lines, $col): $message\n${childError?.printWithSourceAndFilename(source, filename)}";
  }
}

class Input {
  String _source;
  int _offset;
  int _length;

  Input(this._source)
      : _offset = 0,
        _length = _source.length;

  String context(int size) {
    int start = max(0, _offset - size);
    int end = min(max(start, _length - 1), _offset + size);
    return "($_offset, $_length, $size, $start, $end):${_source.substring(start, end).replaceAll(RegExp(r" "), "~")}";
  }

  String apply(int length) {
    if (length == 0) {
      return _source[_offset];
    }
    return _source.substring(_offset, min(_length, _offset + length));
  }

  bool matches(String str) {
    var i = 0;
    final l = str.length;
    while (i < l) {
      if (_source[_offset + i] != str[i]) {
        return false;
      }
      i = i + 1;
    }
    return true;
  }

  advance(int increment) {
    _offset = _offset + increment;
  }

  regress(int decrement) {
    _offset = max(0, _offset - decrement);
  }

  regressTo(int offset) {
    _offset = max(0, offset);
  }

  bool isPastEOF(int len) {
    return (_offset + (len - 1)) >= _length;
  }

  bool isEOF() {
    return isPastEOF(1);
  }

  bool atEnd() {
    return isEOF();
  }

  int pos() {
    return _offset;
  }

  int offset() {
    return _offset;
  }

  String source() {
    return _source;
  }

  reset(String source) {
    _offset = 0;
    _source = source;
    _length = source.length;
  }
}

class Parser {
  final String fileName;
  final Input input;
  final List<ParserError> _errors;
  String? freeComment;
  final Map<String, Comment> comments;
  final LoggerImpl logger;

  Parser(
      {required String contents, required this.fileName, required this.logger})
      : input = Input(contents),
        _errors = [],
        comments = {};

  void addComment(String comment) {
    freeComment = freeComment != null ? "$freeComment\n$comment" : comment;
  }

  void associateBlockWithComment(String hash) {
    if (freeComment != null) {
      comments[hash] = Comment(freeComment!);
      freeComment = null;
    }
  }

  void addError(String expected, String got, [String? reason]) {
    _errors.add(ParserError(
      message:
          "Expected $expected, got $got${reason != null ? '. $reason' : ''}",
      offset: input._offset,
    ));
  }

  void addContextToError(String message) {
    final last = _errors.lastOrNull;
    if (last != null) {
      _errors.removeLast();
      _errors.add(ParserError.withChild(
          message: message, offset: input.pos(), child: last));
    }
  }

  bool checkChars(Runes chars) {
    if (input.isPastEOF(1)) {
      return false;
    }
    for (final char in chars) {
      if (input.matches(String.fromCharCode(char))) {
        return true;
      }
    }
    return false;
  }

  bool _checkStr(String str) {
    final length = str.length;
    if (!input.isPastEOF(length) && input.matches(str)) {
      input.advance(length);
      return true;
    }
    return false;
  }

  String any(int length) {
    if (input.isEOF()) {
      return "";
    } else {
      final s = input.apply(length);
      input.advance(length);
      return s;
    }
  }

  String anyUntil(bool Function(String) fn, bool inclusive) {
    final sb = StringBuffer();
    while (!input.isPastEOF(1) && !fn(input.apply(1))) {
      sb.write(any(1));
    }
    if (inclusive && !input.isPastEOF(1)) {
      sb.write(any(1));
    }
    return sb.toString();
  }

  String anyUntilStr(String stop, bool inclusive) {
    final sb = StringBuffer();
    final stopLength = stop.length;
    while (!input.isPastEOF(stopLength) && !input.matches(stop)) {
      sb.write(any(1));
    }
    if (inclusive && !input.isPastEOF(stopLength)) {
      sb.write(any(stopLength));
    }
    return sb.toString();
  }

  FileType? parseFileType() {
    if (_checkStr("stage.")) {
      return StageFile();
    }
    if (_checkStr("sprite ")) {
      final name = anyUntilStr(".", false);
      input.advance(1);
      return SpriteFile(name);
    }
    return null;
  }

  T? parseBetween<T>(String start, String end, T? Function() parser) {
    int offset = input.pos();
    if (!_checkStr(start)) {
      addError("'$start'", "'${input.apply(start.length)}'");
      input.regressTo(offset);
      return null;
    }

    offset = input.pos();
    final T? parsed = parser();
    if (parsed == null) {
      return null;
    }
    offset = input.pos();
    if (!_checkStr(end)) {
      if (input.isPastEOF(start.length)) {
        addError("'$end'", "EOF");
      } else {
        addError("'$end'", "'${input.apply(start.length)}'");
      }
      input.regressTo(offset);
      return null;
    }
    return parsed;
  }

  List<T>? sepBy<T>(String sep, T? Function() parser) {
    final ts = <T>[];
    while (true) {
      final T? p = parser();
      if (p == null) {
        break;
      }
      ts.add(p);
      if (!_checkStr(sep)) {
        return ts;
      }
      whitespace();
    }
    return ts;
  }

  void whitespace() {
    while (_checkStr(" ")) {}
  }

  String parseStringValue() {
    return anyUntil((c) => c == '"', false);
  }

  String parseNumberPart() {
    return anyUntil((c) => !numberChars.contains(c), false);
  }

  String numberChars = "0123456789";
  Runes numberStartRunes = "0123456789-".runes;

  String? parseStaticValue() {
    final offset = input.offset();
    if (_checkStr('"')) {
      input.regressTo(offset);
      return parseBetween('"', '"', parseStringValue);
    }
    if (checkChars(numberStartRunes)) {
      input.regressTo(offset);
      var value = "";
      if (_checkStr("-")) {
        value += "-";
      }
      final integer = parseNumberPart();
      if (integer.isEmpty) {
        final span = input.offset() - offset;
        input.regressTo(offset);
        addError("valid number", input.apply(span));
        return null;
      }
      value += integer;
      // When checking for decimal portion, if we don't have a number part after the '.',
      // we need to regress to the point before the '.' and return that value.
      final beforeDot = input.offset();
      if (_checkStr('.')) {
        final decimal = parseNumberPart();
        if (decimal.isEmpty) {
          input.regressTo(beforeDot);
          return value;
        }
        value += ".$decimal";
      }

      return value;
    }
    return null;
  }

  List<Block> parseBlocks() {
    logger.debug("\n\nparseBlocks:");
    List<Block> blocks = [];
    Block? block;
    do {
      block = parseBlock();
      if (block != null) {
        logger.debug("Adding block: $block");
        blocks.add(block);
      }
      whitespace();
      newlines();
      whitespace();
    } while (block != null);
    logger.debug("parsed $blocks\n\n");
    return blocks;
  }

  Segment? parseReporterSegment() {
    logger.debug("parsing reporter");
    whitespace();
    final block = parseBlock(end: ")");
    if (block == null) {
      return null;
    }
    block.reporter = true;
    return SReporter(block: block);
  }

  Segment? parseFieldSegment() {
    logger.debug("parsing field");
    whitespace();
    final value = anyUntilStr("]", false).trim();
    input.advance(1);
    whitespace();
    return SField(value: value);
  }

  Segment? parseCMouthSegment() {
    logger.debug("parsing c mouth");
    whitespace();
    newlines();
    final blocks = parseBlocks();
    newlines();
    whitespace();
    if (!_checkStr("}")) {
      logger.debug("no closing brace: '${input.context(5)}'");
      return null;
    }
    whitespace();
    logger.debug("parsed blocks: ${blocks.length} blocks");
    return SCMouth(blocks);
  }

  Segment? parseWordSegment() {
    logger.debug("parsing word");
    whitespace();
    final value = anyUntil(invalidValueChar, false).trim();
    whitespace();
    logger.debug("parsed word: '$value'");
    if (value.isEmpty) {
      return null;
    }
    return SWord(word: value);
  }

  Block? parseBlock({String end = "."}) {
    logger.debug("\nparseBlock\n----------------------------\n");
    final List<Segment> segments = [];
    while (true) {
      logger.debug("parsing segment");
      if (input.isEOF()) {
        addError("block", "end of file");
        return null;
      }

      if (_checkStr(end)) {
        final b = Block(segments);
        logger.debug("end: $b\n----------------------------\n");
        return b;
      }

      var p = parseWordSegment;
      final offset = input.offset();
      if (_checkStr('"') || checkChars(numberStartRunes)) {
        input.regressTo(offset);
        final value = parseStaticValue();
        if (value == null) {
          addError("a valid value", input.apply(1));
          input.regressTo(offset);
          return null;
        }
        final seg = SValue(value: value);
        logger.debug("Adding segment: $seg\n");
        whitespace();
        segments.add(seg);
        continue;
      }
      if (_checkStr("(")) {
        p = parseReporterSegment;
      } else if (_checkStr("[")) {
        p = parseFieldSegment;
      } else if (_checkStr("{")) {
        p = parseCMouthSegment;
      }

      final seg = p();

      if (seg != null) {
        logger.debug("Adding segment: $seg\n");
        whitespace();
        segments.add(seg);
      } else {
        logger.debug("No segment :-(");
        return null;
      }
    }
  }

  bool invalidValueChar(String c) {
    return c == "." ||
        c == "}" ||
        c == "]" ||
        c == "(" ||
        c == '{' ||
        c == ")" ||
        c == "[" ||
        c == '"' ||
        c == '-' ||
        c == '0' ||
        c == '1' ||
        c == '2' ||
        c == '3' ||
        c == '4' ||
        c == '5' ||
        c == '6' ||
        c == '7' ||
        c == '8' ||
        c == '9';
  }

  Decl? parseDecl() {
    if (_checkStr("var ")) {
      logger.debug("Parsing var");
      final name = anyUntilStr("=", false).trim();
      input.advance(1);
      whitespace();
      final value = parseStaticValue();
      int offset = input.offset();
      if (!_checkStr(".")) {
        addError("'.'", "'${input.apply(1)}'");
        input.regressTo(offset);
        return null;
      }
      if (value == null) {
        addError("a value", "'${input.apply(1)}'");
        input.regressTo(offset);
        return null;
      }
      return DVar(name: name, value: value);
    }
    if (_checkStr("list ")) {
      logger.debug("Parsing list");
      final name = anyUntilStr("=", false).trim();
      input.advance(1);
      whitespace();
      final values =
          parseBetween("[", "]", () => sepBy<String>(",", parseStaticValue));
      if (values == null) {
        addContextToError("When parsing list");
        return null;
      }
      whitespace();
      int offset = input.offset();
      if (!_checkStr(".")) {
        addError("'.'", "'${input.apply(1)}'");
        input.regressTo(offset);
        return null;
      }
      return DList(name: name, values: values);
    }
    if (_checkStr("set ")) {
      logger.debug("Parsing set");
      int offset = input.offset();
      final name = anyUntilStr("=", false).trim();
      if (name == "") {
        addError("the name of a variable in '\"'s", "''",
            "the name must have at least one character");
        input.regressTo(offset);
        return null;
      }
      input.advance(1);
      whitespace();
      final value = parseStaticValue();
      offset = input.offset();
      if (!_checkStr(".")) {
        input.regressTo(offset);
        addError("'.'", "'${input.apply(1)}'");
        return null;
      }
      if (value == null) {
        addError("a value", "'${input.apply(1)}'");
        input.regressTo(offset);
        return null;
      }
      return DSet(name: name, value: value);
    }
    if (_checkStr("#")) {
      logger.debug("Parsing comment");
      final content = anyUntilStr("\n", false).trim();
      addComment(content);
      newlines();
      return parseDecl();
    }
    if (_checkStr("broadcast ")) {
      logger.debug("Parsing broadcast");
      final offset = input.offset();
      final name = parseBetween('"', '"', parseStringValue);
      if (name == null) {
        addError("the name of a broadcast in '\"'s", "'${input.apply(1)}'");
        input.regressTo(offset);
        return null;
      }
      if (name == "") {
        addError("the name of a broadcast in '\"'s", "''",
            "the name must have at least one character");
        input.regressTo(offset);
        return null;
      }
      if (!_checkStr(".")) {
        input.regressTo(offset);
        addError("'.'", "'${input.apply(1)}'");
        return null;
      }
      return DBroadcast(name: name);
    }
    if (_checkStr("costume ")) {
      logger.debug("Parsing costume");
      final offset = input.offset();
      final assetName = parseBetween('"', '"', parseStringValue);
      if (assetName == null) {
        addError("the name of an asset in '\"'s", "'${input.apply(1)}'");
        input.regressTo(offset);
        return null;
      }
      if (assetName == "") {
        addError("the name of an asset in '\"'s", "''",
            "the name must have at least one character");
        input.regressTo(offset);
        return null;
      }
      if (!_checkStr(".")) {
        input.regressTo(offset);
        addError("'.'", "'${input.apply(1)}'");
        return null;
      }
      return DAsset(assetName: assetName);
    }
    if (_checkStr("sound ")) {
      logger.debug("Parsing sound");
      final offset = input.offset();
      final assetName = parseBetween('"', '"', parseStringValue);
      if (assetName == null) {
        addError("the name of an asset in '\"'s", "'${input.apply(1)}'");
        input.regressTo(offset);
        return null;
      }
      if (assetName == "") {
        addError("the name of an asset in '\"'s", "''",
            "the name must have at least one character");
        input.regressTo(offset);
        return null;
      }
      if (!_checkStr(".")) {
        input.regressTo(offset);
        addError("'.'", "'${input.apply(1)}'");
        return null;
      }
      return DAsset.sound(assetName: assetName);
    }
    if (_checkStr("block ")) {
      logger.debug(
          "\n\n\nParsing block at pos ${input.offset()}\n===============================\n");
      whitespace();
      final block = parseBlock();
      if (block != null) {
        logger.debug("Parsed block\n\n\n");
        associateBlockWithComment("${block.hashCode}");
        return DBlock(block: block);
      }
      logger.debug("No block parsed :-(");
    }
    return null;
  }

  bool newlines() {
    bool hasOne = false;
    while (_checkStr('\n')) {
      hasOne = true;
    }

    return hasOne;
  }

  List<Decl> parseDecls() {
    Decl? decl;
    List<Decl> decls = [];
    do {
      decl = parseDecl();
      if (decl != null) {
        decls.add(decl);
        if (!newlines()) {
          logger.debug("No newlines '${input.apply(1)}'");
          break;
        }
      }
    } while (decl != null);
    return decls;
  }

  List<String> errors() => _errors
      .map((ParserError e) =>
          e.printWithSourceAndFilename(input._source, "test.itch"))
      .toList();

  ItchFile? parse() {
    final fileType = parseFileType();
    if (fileType == null) {
      return null;
    }

    if (!newlines()) {
      switch (fileType) {
        case StageFile():
          return ItchFile.stage(decls: [], comments: {});
        case SpriteFile(name: String name):
          return ItchFile.sprite(name, decls: [], comments: {});
      }
    }

    final decls = parseDecls();

    switch (fileType) {
      case StageFile():
        return ItchFile.stage(decls: decls, comments: comments);
      case SpriteFile(name: String name):
        return ItchFile.sprite(name, decls: decls, comments: comments);
    }
  }
}
