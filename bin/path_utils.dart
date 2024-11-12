import 'dart:io';

String absolutePath(String path) {
  return File(path).absolute.path;
}

String joinPath(List<String> segments) {
  return segments.join(Platform.pathSeparator);
}
