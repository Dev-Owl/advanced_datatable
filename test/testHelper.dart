import 'package:advanced_datatable/advancedDataTableSource.dart';
import 'package:flutter/material.dart';

class TestData {
  final int index;

  TestData(this.index);
}

class TestSource extends AdvancedDataTableSource<TestData> {
  static int totalRows = 100;
  int lastOffset = 0;
  final bool twoColumn;

  TestSource({this.twoColumn = false});

  @override
  DataRow? getRow(int index) {
    final cells = [
      DataCell(
        Text(
          (lastOffset + index).toString(),
        ),
      ),
    ];
    if (twoColumn) {
      cells.add(
        DataCell(
          Text(
            'Column two',
          ),
        ),
      );
    }

    return DataRow(cells: cells);
  }

  @override
  int get selectedRowCount => 0;

  @override
  Future<RemoteDataSourceDetails<TestData>> getNextPage(
      NextPageRequest pageRequest) async {
    lastOffset = pageRequest.offset;
    return RemoteDataSourceDetails<TestData>(
        totalRows,
        List<TestData>.generate(
            pageRequest.pageSize, (index) => TestData(index)));
  }
}
