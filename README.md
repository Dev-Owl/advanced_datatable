# advanced_datatable
Advanced Datatable uses the Fultter [PaginatedDataTable Widget](https://api.flutter.dev/flutter/material/PaginatedDataTable-class.html) and adds a few more functions to it.

# New features

* Do not add empty/blank lines
* Support for asny row loading, connect the table to a huge data source and only load the current page
* Custom loading and error widgets
* Correct display of data size and position (1 of 10 from 100) in the footer


## Hide blank rows

Set the addEmptyRows property to false, by default its true (to behave as the Flutter Original Widget). 

```dart
addEmptyRows: false    
```

## Support for asnyc row loading

The Original DataSource requires you to load all data in advance and just render it paged, in case your data source is huge and contains a lot of information this might not be the best options.
AdvancedDataTableSource requires you to define a model that is used for the rows like shown below:
```dart

//Example model
class RowData {
  final int index;
  final String value;
  RowData(this.index, this.value);
}

class ExampleSource extends AdvancedDataTableSource<RowData>{
      //....
}

```
You also need to implement the getNextPage function, this function is always called when the view wants to render a new page.
You will get the following details:

* pageSize as int
* offset as int

You need to return a RemoteDataSourceDetails object that contains the current page rows and always the total rows available.
```dart
class ExampleSource extends AdvancedDataTableSource<RowData>{
  
  //Mockup for requesting data from some external source
  Future<RemoteDataSourceDetails<RowData>> getNextPage(NextPageRequest pageRequest) async {
    await Future.delayed(Duration(seconds: 5));
    return RemoteDataSourceDetails(
      data.length,
      data.skip(pageRequest.offset).take(pageRequest.pageSize).toList(),
    );
  }
  
}
```
While the getNextPage function is running the table shows a loading Widget (see below).

## Custom load and error widget

You can set a custom loading and error widget by using the following props:

* loadingWidget
* errorWidget

The above props. are functions that will be run when the widget is needed and have to return a single widget.


# Example

You can find a simple example in the example folder, below is the code of the main.dart file:

```dart
import 'package:advanced_datatable/advancedDataTableSource.dart';
import 'package:advanced_datatable/datatable.dart';
import 'package:flutter/material.dart';

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
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, this.title}) : super(key: key);
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
          availableRowsPerPage: [1, 5, 10, 50],
          onRowsPerPageChanged: (newRowsPerPage) {
            if (newRowsPerPage != null) {
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
  final data = List<RowData>.generate(
      13, (index) => RowData(index, 'Value for no. $index'));

  @override
  DataRow? getRow(int index) {
    final currentRowData = lastDetails!.rows[index];
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
      NextPageRequest pageRequest) async {
    return RemoteDataSourceDetails(
      data.length,
      data
          .skip(pageRequest.offset)
          .take(pageRequest.pageSize)
          .toList(), //again in a real world example you would only get the right amount of rows
    );
  }
}

```
