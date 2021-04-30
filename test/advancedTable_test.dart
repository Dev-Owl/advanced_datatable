import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

  testWidgets('Ensure rows per page works', (WidgetTester tester) async {
    int? rowsPerPage;

    await tester.pumpWidget(
      StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) => MaterialApp(
          home: MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: AdvancedPaginatedDataTable(
                    rowsPerPage: rowsPerPage ?? 10,
                    availableRowsPerPage: [
                      10,
                      20,
                      30,
                      45,
                    ],
                    columns: [
                      DataColumn(
                        label: Text('Id'),
                      ),
                    ],
                    source: TestSource(),
                    onRowsPerPageChanged: (r) {
                      setState(() {
                        rowsPerPage = r;
                      });
                    }),
              ),
            ),
          ),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    //Find the row
    expect(find.text('8'), findsOneWidget);
    //Find the totoal rows avalible
    expect(find.textContaining('100'), findsOneWidget);
    //Find the rows per page dialog
    expect(find.byKey(Key('rowsPerPage')), findsOneWidget);

    expect(
        (tester.widget(find.byKey(Key('rowsPerPage'))) as DropdownButton).value,
        10);
    await tester.tap(find.byKey(Key('rowsPerPage')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('45').last);
    await tester.pumpAndSettle();

    expect(rowsPerPage, 45);

    //45 rows per page
    expect(find.text('44'), findsOneWidget);
  });
}
