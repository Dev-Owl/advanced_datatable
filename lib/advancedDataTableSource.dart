import 'package:flutter/material.dart';

typedef LoadPageCallback = Future<RemoteDataSourceDetails<F>> Function<F>(
    int pagesize, int offset);

abstract class AdvancedDataTableSource<T> extends DataTableSource {
  bool get initalRequestCompleted => lastDetails == null ? false : true;
  RemoteDataSourceDetails<T>? lastDetails;

  Future<RemoteDataSourceDetails<T>> getNextPage(int pagesize, int offset);

  @override
  int get rowCount => lastDetails?.totalRows ?? 0;

  @override
  bool get isRowCountApproximate => false;

  Future<int> loadNextPage(int pageSize, int offset) async {
    try {
      lastDetails = await getNextPage(pageSize, offset);
      return lastDetails?.totalRows ?? 0;
    } catch (error) {
      return Future.error(error);
    }
  }
}

class RemoteDataSourceDetails<T> {
  final int totalRows;
  final List<T> rows;

  RemoteDataSourceDetails(this.totalRows, this.rows);
}
