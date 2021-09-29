import 'dart:convert';
import 'package:advanced_datatable/advanced_datatable_source.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'company_contact.dart';

//TODO Support server side filter in example
//First update server side to include a filter
//Add search bar
//Update remote data source to use filter

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Advanced DataTable Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;
  final _source = ExampleSource();
  var _sortIndex = 0;
  var _sortAsc = true;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 10),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        labelText: 'Search by company',
                      ),
                      onSubmitted: (vlaue) {
                        _source.filterServerSide(_searchController.text);
                      },
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _searchController.text = '';
                    });
                    _source.filterServerSide(_searchController.text);
                  },
                  icon: const Icon(Icons.clear),
                ),
                IconButton(
                  onPressed: () =>
                      _source.filterServerSide(_searchController.text),
                  icon: const Icon(Icons.search),
                ),
              ],
            ),
            AdvancedPaginatedDataTable(
              addEmptyRows: false,
              source: _source,
              sortAscending: _sortAsc,
              sortColumnIndex: _sortIndex,
              showFirstLastButtons: true,
              rowsPerPage: _rowsPerPage,
              availableRowsPerPage: const [10, 20, 30, 50],
              onRowsPerPageChanged: (newRowsPerPage) {
                if (newRowsPerPage != null) {
                  setState(() {
                    _rowsPerPage = newRowsPerPage;
                  });
                }
              },
              columns: [
                DataColumn(
                  label: const Text('ID'),
                  numeric: true,
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('Company'),
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('First name'),
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('Last name'),
                  onSort: setSort,
                ),
                DataColumn(
                  label: const Text('Phone'),
                  onSort: setSort,
                ),
              ],
              //Optianl override to support custom data row text / translation
              getFooterRowText:
                  (startRow, pageSize, totalFilter, totalRowsWithoutFilter) {
                final localizations = MaterialLocalizations.of(context);
                var amountText = localizations.pageRowsInfoTitle(
                  startRow,
                  pageSize,
                  totalFilter ?? totalRowsWithoutFilter,
                  false,
                );

                if (totalFilter != null) {
                  //Filtered data source show addtional information
                  amountText += ' filtered from ($totalRowsWithoutFilter)';
                }

                return amountText;
              },
            ),
          ],
        ),
      ),
    );
  }

  // ignore: avoid_positional_boolean_parameters
  void setSort(int i, bool asc) => setState(() {
        _sortIndex = i;
        _sortAsc = asc;
      });
}

typedef SelectedCallBack = Function(String id, bool newSelectState);

class ExampleSource extends AdvancedDataTableSource<CompanyContact> {
  List<String> selectedIds = [];
  String lastSearchTerm = '';

  @override
  DataRow? getRow(int index) =>
      lastDetails!.rows[index].getRow(selectedRow, selectedIds);

  @override
  int get selectedRowCount => selectedIds.length;

  // ignore: avoid_positional_boolean_parameters
  void selectedRow(String id, bool newSelectState) {
    if (selectedIds.contains(id)) {
      selectedIds.remove(id);
    } else {
      selectedIds.add(id);
    }
    notifyListeners();
  }

  void filterServerSide(String filterQuery) {
    lastSearchTerm = filterQuery.toLowerCase().trim();
    setNextView();
  }

  @override
  Future<RemoteDataSourceDetails<CompanyContact>> getNextPage(
    NextPageRequest pageRequest,
  ) async {
    //the remote data source has to support the pagaing and sorting
    final queryParameter = <String, dynamic>{
      'offset': pageRequest.offset.toString(),
      'pageSize': pageRequest.pageSize.toString(),
      'sortIndex': ((pageRequest.columnSortIndex ?? 0) + 1).toString(),
      'sortAsc': ((pageRequest.sortAscending ?? true) ? 1 : 0).toString(),
      if (lastSearchTerm.isNotEmpty) 'companyFilter': lastSearchTerm,
    };

    final requestUri = Uri.https(
      'example.devowl.de',
      '',
      queryParameter,
    );

    final response = await http.get(requestUri);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return RemoteDataSourceDetails(
        int.parse(data['totalRows'].toString()),
        (data['rows'] as List<dynamic>)
            .map(
              (json) => CompanyContact.fromJson(json as Map<String, dynamic>),
            )
            .toList(),
        filteredRows: lastSearchTerm.isNotEmpty
            ? (data['rows'] as List<dynamic>).length
            : null,
      );
    } else {
      throw Exception('Unable to query remote server');
    }
  }
}
