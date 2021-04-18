import 'package:advanced_datatable/advancedDataTableSource.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  final Function(int rowsPergPage) rowsChange;

  const MyApp(
    this.rowsChange, {
    Key? key,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(rowsChange, title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final Function(int rowsPergPage) rowsChange;
  MyHomePage(this.rowsChange, {Key? key, this.title}) : super(key: key);
  final String? title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var rowsPerPage = AdvancedPaginatedDataTable.defaultRowsPerPage;
  final source = ExampleSource();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title!),
      ),
      body: SingleChildScrollView(
        child: AdvancedPaginatedDataTable(
          addEmptyRows: false,
          source: source,
          showFirstLastButtons: true,
          rowsPerPage: rowsPerPage,
          availableRowsPerPage: [1, 5, 10, 45],
          onRowsPerPageChanged: (newRowsPerPage) {
            if (newRowsPerPage != null) {
              widget.rowsChange(newRowsPerPage);
              setState(() {
                rowsPerPage = newRowsPerPage;
              });
            }
          },
          columns: [
            DataColumn(label: Text('Row no')),
            DataColumn(label: Text('Value'))
          ],
        ),
      ),
    );
  }
}

class RowData {
  final int index;
  final String value;

  RowData(this.index, this.value);
}

class ExampleSource extends AdvancedDataTableSource<RowData> {
  //Generate some example data to use in the API
  final data = List<RowData>.generate(
      330, (index) => RowData(index, 'Value for no. $index'));

  @override
  DataRow? getRow(int index) {
    //Once this get called lastDetails will have a value
    final currentRowData = lastDetails!
        .rows[index]; //index will always be in the range of the current page
    //Generate the row based on the requested index
    return DataRow(cells: [
      DataCell(
        Text(currentRowData.index.toString()),
      ),
      DataCell(
        Text(currentRowData.value),
      )
    ]);
  }

  @override
  int get selectedRowCount => 0;

  @override
  Future<RemoteDataSourceDetails<RowData>> getNextPage(
      int pagesize, int offset) async {
    //Return the new data packages for the page, always including the total amount of rows
    return RemoteDataSourceDetails(
      data.length,
      data
          .skip(offset)
          .take(pagesize)
          .toList(), //again in a real world example you would only get the right amount of rows
    );
  }
}
