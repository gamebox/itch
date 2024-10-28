import 'dart:convert' as convert;
import 'dart:io';

import "package:crypto/crypto.dart" as crypto;

import './utils.dart';

class SoundInfo {
  String md5;
  String ext;
  int rate;
  int sampleCount;

  SoundInfo({
    required this.md5,
    required this.ext,
    required this.rate,
    required this.sampleCount,
  });
}

SoundInfo? decodeSound(String path) {
  final soundBytes = _loadWav(path);
  if (soundBytes == null) {
    return null;
  }
  return _decodeWav(soundBytes);
}

List<int>? _loadWav(String path) {
  final f = File.fromUri(Uri.file("$path.wav"));
  return f.readAsBytesSync();
}

List<int> toBigEndian(List<int> bytes) {
  return bytes.reversed.toList();
}

SoundInfo? _decodeWav(List<int> bytes) {
  // Turns out these aren't needed since they will be ignored and overwritten.
  int sampleCount = 0;
  int rate = 0;
  final md5 = crypto.md5.convert(bytes).toString();

  return SoundInfo(
    md5: md5,
    ext: 'wav',
    rate: rate,
    sampleCount: sampleCount,
  );
}
