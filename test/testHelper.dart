import 'package:advanced_datatable/advancedDataTableSource.dart';
import 'package:flutter/material.dart';

class TestData {
  final int index;

  TestData(this.index);
}

class TestSource extends AdvancedDataTableSource<TestData> {
  static int totalRows = 100;

  @override
  Future<RemoteDataSourceDetails<TestData>> getNextPage(
      int pagesize, int offset) async {
    return RemoteDataSourceDetails<TestData>(totalRows,
        List<TestData>.generate(pagesize, (index) => TestData(index)));
  }

  @override
  DataRow? getRow(int index) {
    return DataRow(cells: [
      DataCell(
        Text(
          index.toString(),
        ),
      ),
    ]);
  }

  @override
  int get selectedRowCount => 0;
}
