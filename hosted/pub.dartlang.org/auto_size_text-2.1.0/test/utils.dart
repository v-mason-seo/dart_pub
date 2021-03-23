import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

double effectiveFontSize(Text text) {
  return (text.textScaleFactor ?? 1) * text.style.fontSize;
}

bool testIfTextFits(
  Text text, [
  double maxWidth = double.infinity,
  double maxHeight = double.infinity,
  bool wrapWords = true,
]) {
  var span = text.textSpan ?? TextSpan(text: text.data, style: text.style);
  var maxLines = text.maxLines;
  if (!wrapWords) {
    var wordCount = span.toPlainText().split(RegExp('\\s+')).length;
    maxLines = maxLines.clamp(1, wordCount) as int;
  }

  var tp = TextPainter(
    text: span,
    textAlign: text.textAlign,
    textDirection: text.textDirection,
    textScaleFactor: text.textScaleFactor ?? 1,
    maxLines: text.maxLines,
    locale: text.locale,
    strutStyle: text.strutStyle,
  );

  tp.layout(maxWidth: maxWidth);

  return !(tp.didExceedMaxLines ||
      tp.height > maxHeight ||
      tp.width > maxWidth);
}

bool prepared = false;

Future prepareTests(WidgetTester tester) async {
  if (prepared) {
    return;
  }

  tester.binding.addTime(Duration(seconds: 10));
  prepared = true;
  final fontData = File('test/assets/Roboto-Regular.ttf')
      .readAsBytes()
      .then((bytes) => ByteData.view(Uint8List.fromList(bytes).buffer));

  final fontLoader = FontLoader('Roboto')..addFont(fontData);
  await fontLoader.load();
}

Future pump({
  @required WidgetTester tester,
  @required Widget widget,
}) async {
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: widget,
      ),
    ),
  );
}

Future<Text> pumpAndGetText({
  @required WidgetTester tester,
  @required Widget widget,
}) async {
  await pump(tester: tester, widget: widget);
  return tester.widget<Text>(find.byType(Text));
}

Future pumpAndExpectFontSize({
  @required WidgetTester tester,
  @required double expectedFontSize,
  @required Widget widget,
}) async {
  var text = await pumpAndGetText(tester: tester, widget: widget);
  expect(effectiveFontSize(text), expectedFontSize);
}

RichText getRichText(WidgetTester tester) {
  return tester.widget(find.byType(RichText));
}

class OverflowNotifier extends StatelessWidget {
  final VoidCallback overflowCallback;

  OverflowNotifier(this.overflowCallback);

  @override
  Widget build(BuildContext context) {
    overflowCallback();
    return Container();
  }
}
