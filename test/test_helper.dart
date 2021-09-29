import 'package:advanced_datatable/advanced_datatable_source.dart';
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

  void forceReload() {
    forceRemoteReload = true;
  }

  void triggerListeners() {
    notifyListeners();
  }

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
        const DataCell(
          Text(
            'Column two',
          ),
        ),
      );
    }

    return DataRow(cells: cells);
  }

  DateTime? lastLoad;

  @override
  int get selectedRowCount => 0;

  @override
  Future<RemoteDataSourceDetails<TestData>> getNextPage(
    NextPageRequest pageRequest,
  ) async {
    lastOffset = pageRequest.offset;
    lastLoad = DateTime.now();
    return RemoteDataSourceDetails<TestData>(
      totalRows,
      List<TestData>.generate(pageRequest.pageSize, (index) => TestData(index)),
    );
  }
}
