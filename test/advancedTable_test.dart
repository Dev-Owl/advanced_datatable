import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'testHelper.dart';

void main() {
  testWidgets('Ensure normal load', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
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
    ));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byType(CircularProgressIndicator), findsNothing);
    //Find the row
    expect(find.textContaining('5'), findsOneWidget);
    //Find the totoal rows avalible
    expect(find.textContaining('100'), findsOneWidget);
  });
}
