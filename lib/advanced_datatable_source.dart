import 'package:flutter/material.dart';

typedef LoadPageCallback = Future<RemoteDataSourceDetails<F>> Function<F>(
  int pagesize,
  int offset,
);

abstract class AdvancedDataTableSource<T> extends DataTableSource {
  /// True if there is any data loaded in this source
  bool get initialRequestCompleted => lastDetails != null;

  /// Last loaded data from the remote data source
  RemoteDataSourceDetails<T>? lastDetails;

  /// Called by the base data source class to load data, implement your backend
  /// call in this function
  Future<RemoteDataSourceDetails<T>> getNextPage(NextPageRequest pageRequest);

  @override
  int get rowCount => lastDetails?.totalRows ?? 0;

  @override
  bool get isRowCountApproximate => false;

  /// Set this to true to indicate that a reload should happen even if the page
  /// details did not change
  bool forceRemoteReload = false;

  /// The index for the next page to start
  int? nextStartIndex;

  ///Sets the next view state for the table, this can be used to go back to
  ///any start view index (page), will trigger a reload
  void setNextView({int startIndex = 0}) {
    forceRemoteReload = true;
    nextStartIndex = startIndex;
    notifyListeners();
  }

  /// Called by the advanced datatable controll to trigger a page load
  Future<int> loadNextPage(
    int pageSize,
    int offset,
    int? columnSortIndex, {
    bool? sortAscending,
  }) async {
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
  /// The total amount of rows by page
  final int pageSize;

  /// The offset from the start of the remote data source
  ///
  /// Example:
  /// If amount by page is 10 and the offset is 10 you are viewing the 2nd page
  final int offset;

  /// What column should be sorted by the remote backend
  final int? columnSortIndex;

  /// Sort order
  final bool? sortAscending;

  NextPageRequest(
    this.pageSize,
    this.offset, {
    this.columnSortIndex,
    this.sortAscending,
  });
}

class RemoteDataSourceDetails<T> {
  /// The total amount of rows after a filter was applied
  final int? filteredRows;

  /// All avalible rows in the remote data source without any filter
  final int totalRows;

  ///The data retured by the remote data source
  final List<T> rows;

  RemoteDataSourceDetails(
    this.totalRows,
    this.rows, {
    this.filteredRows,
  });
}
