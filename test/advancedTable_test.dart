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

  //TODO Test below seems to not find the element for the dropdown
  testWidgets('Ensure rows per page works', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    //Find the row
    expect(find.textContaining('5'), findsOneWidget);
    //Find the totoal rows avalible
    expect(find.textContaining('330'), findsOneWidget);
    await tester.pumpAndSettle();
    //Find the rows per page dialog
    await tester.tap(find.byKey(Key('rowsPerPage')));
    await tester.pump();
    await tester.pumpAndSettle();
    //50 rows per page
    expect(find.textContaining('50'), findsOneWidget);

    await tester.tap(find.textContaining('50'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.textContaining('45'), findsOneWidget);
  });
}
