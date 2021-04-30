import 'package:flutter/material.dart';

typedef LoadPageCallback = Future<RemoteDataSourceDetails<F>> Function<F>(
    int pagesize, int offset);

abstract class AdvancedDataTableSource<T> extends DataTableSource {
  bool get initalRequestCompleted => lastDetails == null ? false : true;
  RemoteDataSourceDetails<T>? lastDetails;

  Future<RemoteDataSourceDetails<T>> getNextPage(NextPageRequest pageRequest);

  @override
  int get rowCount => lastDetails?.totalRows ?? 0;

  @override
  bool get isRowCountApproximate => false;

  Future<int> loadNextPage(int pageSize, int offset, int? columnSortIndex,
      bool? sortAsceding) async {
    try {
      lastDetails = await getNextPage(
        NextPageRequest(
          pageSize,
          offset,
          columnSortIndex: columnSortIndex,
          sortAscending: sortAsceding,
        ),
      );
      return lastDetails?.totalRows ?? 0;
    } catch (error) {
      return Future.error(error);
    }
  }
}

class NextPageRequest {
  final int pageSize;
  final int offset;
  final int? columnSortIndex;
  final bool? sortAscending;

  NextPageRequest(this.pageSize, this.offset,
      {this.columnSortIndex, this.sortAscending});
}

class RemoteDataSourceDetails<T> {
  final int totalRows;
  final List<T> rows;

  RemoteDataSourceDetails(this.totalRows, this.rows);
}
