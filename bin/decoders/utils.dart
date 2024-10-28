num numberFromBytes(List<int> bytes) {
  num res = 0;
  for (final (i, b) in bytes.reversed.indexed) {
    if (b <= 0) {
      continue;
    }
    res += (256 * i) + b;
  }
  return res;
}
