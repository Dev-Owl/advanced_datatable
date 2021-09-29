import 'package:test/test.dart';

import 'test_helper.dart';

void main() {
  test('Load and check test source', () async {
    final source = TestSource();

    //Not loaded yet -> should report 0 rows
    expect(source.rowCount, 0);
    //Not loaded yet -> should be null
    expect(source.lastDetails, null);

    //Load the first 10 rows
    await source.loadNextPage(10, 0, null);

    //Always report back the total rows
    expect(source.rowCount, TestSource.totalRows);
    //Now we should be able to load last loaded page
    expect(source.lastDetails, isNotNull);
    //Should be the same as source.rowcount
    expect(source.lastDetails!.totalRows, TestSource.totalRows);
    //We requested 10 rows, the source should have 10
    expect(source.lastDetails!.rows.length, 10);
    //request rows
    expect(source.getRow(0), isNotNull);
  });

  test('Force reload off', () async {
    final source = TestSource();
    //By default off
    expect(source.requireRemoteReload(), equals(false));
  });

  test('Force next page off', () async {
    final source = TestSource();
    //By default off
    expect(source.nextStartIndex, isNull);
  });
}
