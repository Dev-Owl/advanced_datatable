import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'fullTestWidget.dart';
import 'testHelper.dart';

void main() {
  Widget testWidget() => MaterialApp(
        home: Scaffold(
          body: AdvancedPaginatedDataTable(
            columns: [
              DataColumn(
                label: Text('Id'),
              ),
            ],
            source: TestSource(),
          ),
        ),
      );

  testWidgets('Ensure normal load', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    //Find the row
    expect(find.textContaining('5'), findsOneWidget);
    //Find the totoal rows avalible
    expect(find.textContaining('100'), findsOneWidget);
  });

  testWidgets('Ensure paging works', (WidgetTester tester) async {
    await tester.pumpWidget(testWidget());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    //Find the row
    expect(find.textContaining('5'), findsOneWidget);
    //Find the totoal rows avalible
    expect(find.textContaining('100'), findsOneWidget);

    expect(find.byIcon(Icons.chevron_right), findsOneWidget);
    await tester.tap(find.byIcon(Icons.chevron_right));
    await tester.pumpAndSettle();
    expect(find.textContaining('15'), findsOneWidget);
  });

  //TODO Test below seems to not actually tap/change the dropdown...
  testWidgets('Ensure rows per page works', (WidgetTester tester) async {
    var rowsPerPage = 0;

    await tester.pumpWidget(MyApp((r) => rowsPerPage = r));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    //Find the row
    expect(find.text('8'), findsOneWidget);
    //Find the totoal rows avalible
    expect(find.textContaining('330'), findsOneWidget);
    //Find the rows per page dialog
    expect(find.byKey(Key('rowsPerPage')), findsOneWidget);

    expect(
        (tester.widget(find.byKey(Key('rowsPerPage'))) as DropdownButton).value,
        10);
    await tester.tap(find.byKey(Key('opt_10')));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    await tester.tap(find.byKey(Key('opt_45')));
    await tester.pumpAndSettle(const Duration(milliseconds: 200));

    expect(rowsPerPage, 45);

    //45 rows per page
    expect(find.text('30'), findsOneWidget);
  });
}
