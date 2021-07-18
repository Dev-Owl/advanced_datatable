[![pub points](https://badges.bar/advanced_datatable/pub%20points)](https://pub.dev/packages/advanced_datatable/score)
[![likes](https://badges.bar/advanced_datatable/likes)](https://pub.dev/packages/advanced_datatable/score)
[![popularity](https://badges.bar/advanced_datatable/popularity)](https://pub.dev/packages/advanced_datatable/score)

# advanced_datatable
Advanced Datatable uses the Flutter [PaginatedDataTable Widget](https://api.flutter.dev/flutter/material/PaginatedDataTable-class.html) and adds a few more functions to it.

# New features

* Do not add empty/blank lines
* Support for async row loading, connect the table to a huge data source and only load the current page
* Custom loading and error widgets
* Correct display of data size and position (1 of 10 from 100) in the footer

## Web demo

You can find a demo using a remote server following the link below, while using the page check your Network Monitor F12 to see what data is actually loaded when you switch pages or change the number of rows. The remote server has 1000 rows, your client will only get a subset of it at any time. The remote server will also take care of the selected order (otherwise it would not be able to page the data correctly).

[Online Demo](https://dev-owl.github.io/advanced_datatable/)

## Hide blank rows

Set the addEmptyRows property to false, by default its true (to behave as the Flutter Original Widget). 

```dart
addEmptyRows: false    
```

## Support for async row loading

The Original DataSource requires you to load all data in advance and just render it paged, in case your data source is huge and contains a lot of information this might not be the best options.
AdvancedDataTableSource requires you to define a model that is used for the rows as shown below:
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

The above props are functions that will be run when the widget is needed and have to return a single widget.

## Server side filter

To show the user that a filter is live you should return from your data backend always two numbers:

* total number of rows without any filter
* total number of rows with the current active filter (or null if no filter is set, the default)

This can be done by setting filteredRows to a none null value. If filteredRows is set, advanced_datatable will treat
this as the new total rows but still shows the user the amount of unfiltered rows. If you want to define how this is shown check the [Custom row number label](#custom-row-number-label)

```dart

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
          .toList(),
      filteredRows: data.length, //the total amount of filtered rows, null by default
    );
  }
}
```

## Custom row number label

You can override the footer row label to include custom text, this makes sense in case you have server side filter
and want to include another local or structure in the label:
```dart
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
              amountText += ' filtered from ($totalFilter)';
            }

            return amountText;
          },
```




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
