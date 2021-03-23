import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'utils.dart';

class GroupTest extends StatefulWidget {
  @override
  GroupTestState createState() => GroupTestState();
}

class GroupTestState extends State<GroupTest> {
  var group = AutoSizeGroup();
  var width1 = 300.0;
  var width2 = 300.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Column(
        children: <Widget>[
          SizedBox(
            width: width1,
            height: 100,
            child: AutoSizeText(
              'XXXXXX',
              style: TextStyle(fontSize: 60),
              minFontSize: 1,
              maxLines: 1,
              group: group,
            ),
          ),
          SizedBox(
            width: width2,
            height: 100.0,
            child: AutoSizeText(
              'XXXXXX',
              style: TextStyle(fontSize: 60),
              minFontSize: 1,
              maxLines: 1,
              group: group,
            ),
          ),
        ],
      ),
    );
  }

  void refresh() {
    setState(() {});
  }
}

_expectFontSizes(WidgetTester tester, double fontSize) {
  var texts = tester.widgetList(find.byType(Text));
  for (var text in texts) {
    expect(effectiveFontSize(text as Text), fontSize);
  }
}

void main() {
  testWidgets('Group sync', (tester) async {
    await tester.pumpWidget(GroupTest());

    _expectFontSizes(tester, 50);

    var state = tester.state(find.byType(GroupTest)) as GroupTestState;

    state.width1 = 200;
    state.refresh();
    await tester.pump(Duration.zero);
    _expectFontSizes(tester, 33);

    state.width2 = 150;
    state.refresh();
    await tester.pump(Duration.zero);
    _expectFontSizes(tester, 25);

    state.width2 = 100;
    state.refresh();
    await tester.pump(Duration.zero);
    _expectFontSizes(tester, 16);

    state.width1 = 60;
    state.width2 = 60;
    state.refresh();
    await tester.pump(Duration.zero);
    _expectFontSizes(tester, 10);

    state.width1 = 200;
    state.refresh();
    await tester.pump(Duration.zero);
    _expectFontSizes(tester, 10);

    state.width2 = 250;
    state.refresh();
    await tester.pump(Duration.zero);
    _expectFontSizes(tester, 33);

    state.width1 = 250;
    state.refresh();
    await tester.pump(Duration.zero);
    _expectFontSizes(tester, 41);

    state.width1 = 300;
    state.width2 = 300;
    state.refresh();
    await tester.pump(Duration.zero);
    await tester.pump(Duration.zero);
    _expectFontSizes(tester, 50);

    //TODO remove when flutter bug is fixed https://github.com/flutter/flutter/issues/24166
    await tester.pumpWidget(Container());
    await tester.pump(Duration.zero);
  });
}
