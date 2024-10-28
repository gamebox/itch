import 'dart:io';
import 'dart:typed_data';

import "package:crypto/crypto.dart" as crypto;
import "package:xml/xml.dart";

import './utils.dart';

Uint8List pngSignature = Uint8List.fromList([137, 80, 78, 71, 13, 10, 26, 10]);
int clLength = 4;
int ihdrl = "IHDR".codeUnits.length;

class ImageInfo {
  int centerX;
  int centerY;
  String md5;
  String ext;

  ImageInfo({
    required this.centerX,
    required this.centerY,
    required this.md5,
    required this.ext,
  });
}

ImageInfo? decodeImage(String name) {
  var bytes = _loadImage(name, "png");
  if (bytes != null) {
    return _decodePng(bytes);
  }
  bytes = _loadImage(name, 'svg');
  if (bytes == null) {
    return null;
  }
  return _decodeSvg(bytes);
}

List<int>? _loadImage(String name, String ext) {
  try {
    final f = File.fromUri(Uri.file("$name.$ext"));
    return f.readAsBytesSync();
  } on PathNotFoundException catch (_) {
    return null;
  }
}

ImageInfo? _decodePng(List<int> imageData) {
  try {
    for (final (i, b) in imageData.take(pngSignature.length).indexed) {
      if (b != pngSignature[i]) {
        print("Got a PNG that's not actually a PNG");
        return null;
      }
    }

    final width = numberFromBytes(imageData
        .skip(pngSignature.length + clLength + ihdrl)
        .take(4)
        .toList());
    final height = numberFromBytes(imageData
        .skip(pngSignature.length + clLength + ihdrl + 4)
        .take(4)
        .toList());
    final md5 = crypto.md5.convert(imageData).toString();
    return ImageInfo(
      centerX: (height / 2).ceil(),
      centerY: (width / 2).ceil(),
      md5: md5,
      ext: 'png',
    );
  } on FormatException catch (e) {
    print("Could not decode PNG due to the following error: ${e.message}");
    return null;
  } catch (_) {
    print("Could not decode PNG due to an unknown error");
    return null;
  }
}

ImageInfo? _decodeSvg(List<int> imageData) {
  final doc = XmlDocument.parse(String.fromCharCodes(imageData));
  final el = doc.rootElement;
  final height = double.tryParse(
          (el.getAttribute("height") ?? "0").replaceAll("px", "")) ??
      0;
  final width =
      double.tryParse((el.getAttribute("width") ?? "0").replaceAll("px", "")) ??
          0;
  final md5 = crypto.md5.convert(imageData).toString();
  return ImageInfo(
    centerX: (height / 2).ceil(),
    centerY: (width / 2).ceil(),
    md5: md5,
    ext: 'svg',
  );
}
