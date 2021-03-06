import 'dart:typed_data';

import '../../color.dart';

class GifColorMap {
  int bitsPerPixel;
  int numColors;
  int transparent;
  final Uint8List colors;

  GifColorMap(int numColors)
      : numColors = numColors,
        colors = Uint8List(numColors * 3) {
    bitsPerPixel = _bitSize(numColors);
  }

  int operator [](int index) => colors[index];

  operator []=(int index, int value) => colors[index] = value;

  int color(int index) {
    var ci = index * 3;
    var a = (index == transparent) ? 0 : 255;
    return getColor(colors[ci], colors[ci + 1], colors[ci + 2], a);
  }

  void setColor(int index, int r, int g, int b) {
    var ci = index * 3;
    colors[ci] = r;
    colors[ci + 1] = g;
    colors[ci + 2] = b;
  }

  int red(int color) => colors[color * 3];

  int green(int color) => colors[color * 3 + 1];

  int blue(int color) => colors[color * 3 + 2];

  int alpha(int color) => (color == transparent) ? 0 : 255;

  int _bitSize(int n) {
    for (var i = 1; i <= 8; i++) {
      if ((1 << i) >= n) {
        return i;
      }
    }
    return 0;
  }
}
