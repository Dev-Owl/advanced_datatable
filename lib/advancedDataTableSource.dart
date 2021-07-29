import 'package:flutter/material.dart';

typedef LoadPageCallback = Future<RemoteDataSourceDetails<F>> Function<F>(
    int pagesize, int offset);

abstract class AdvancedDataTableSource<T> extends DataTableSource {
  bool get initialRequestCompleted => lastDetails == null ? false : true;
  RemoteDataSourceDetails<T>? lastDetails;

  Future<RemoteDataSourceDetails<T>> getNextPage(NextPageRequest pageRequest);

  @override
  int get rowCount => lastDetails?.totalRows ?? 0;

  @override
  bool get isRowCountApproximate => false;

  bool forceRemoteReload = false;

  Future<int> loadNextPage(int pageSize, int offset, int? columnSortIndex,
      bool? sortAscending) async {
    try {
      lastDetails = await getNextPage(
        NextPageRequest(
          pageSize,
          offset,
          columnSortIndex: columnSortIndex,
          sortAscending: sortAscending,
        ),
      );
      //If the remote source is filtered, its the important upper limit
      return lastDetails?.filteredRows ?? lastDetails?.totalRows ?? 0;
    } catch (error) {
      return Future.error(error);
    }
  }

  ///Override this function to ensure  a remote reload is done
  ///If you override this function ensure to reset the state once a reload has happend
  ///Consider the reload as done once this funciton is called
  bool requireRemoteReload() => forceRemoteReload;
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
  final int? filteredRows;
  final int totalRows;
  final List<T> rows;

  RemoteDataSourceDetails(
    this.totalRows,
    this.rows, {
    this.filteredRows,
  });
}
