import 'dart:io';
import 'package:image/image.dart';
import 'package:test/test.dart';

import 'paths.dart';

void main() {
  final dir = Directory('test/res/jpg');
  final files = dir.listSync(recursive: true);

  group('JPEG', () {
    for (var f in files.whereType<File>()) {
      if (!f.path.endsWith('.jpg')) {
        continue;
      }

      final name = f.path.split(RegExp(r'(/|\\)')).last;
      test(name, () {
        final List<int> bytes = f.readAsBytesSync();
        expect(JpegDecoder().isValidFile(bytes), equals(true));

        final image = JpegDecoder().decodeImage(bytes);
        final outJpg = JpegEncoder().encodeImage(image);
        File('$tmpPath/out/jpg/$name')
          ..createSync(recursive: true)
          ..writeAsBytesSync(outJpg);

        // Make sure we can read what we just wrote.
        final image2 = JpegDecoder().decodeImage(outJpg);

        expect(image.width, equals(image2.width));
        expect(image.height, equals(image2.height));
      });
    }

    for (var i = 1; i < 9; ++i) {
      test('exif/orientation_$i/landscape', () {
        final image = JpegDecoder().decodeImage(
            File('test/res/jpg/landscape_$i.jpg').readAsBytesSync());
        expect(image.exif.hasOrientation, equals(true));
        expect(image.exif.orientation, equals(i));
        File('$tmpPath/out/jpg/landscape_$i.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(PngEncoder().encodeImage(bakeOrientation(image)));
      });

      test('exif/orientation_$i/portrait', () {
        final image = JpegDecoder().decodeImage(
            File('test/res/jpg/portrait_$i.jpg').readAsBytesSync());
        expect(image.exif.hasOrientation, equals(true));
        expect(image.exif.orientation, equals(i));
        File('$tmpPath/out/jpg/portrait_$i.png')
          ..createSync(recursive: true)
          ..writeAsBytesSync(PngEncoder().encodeImage(bakeOrientation(image)));
      });
    }
  });
}
