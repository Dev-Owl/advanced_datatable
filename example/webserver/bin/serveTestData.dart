import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

import 'company_contact.dart';

var targetFile =
    File(p.join(p.dirname(Platform.script.toFilePath()), 'data.json'));

class ResponseModel {
  final int totalRows;
  final List<CompanyContact> rows;

  ResponseModel(this.totalRows, this.rows);

  Map<String, dynamic> toJson() {
    return {
      'totalRows': totalRows,
      'rows': rows.map((e) => e.toJson()).toList()
    };
  }
}

int sortContacts(CompanyContact a, CompanyContact b, int sortIndex, bool asc) {
  late int result;
  switch (sortIndex) {
    case 1:
      result = a.id.compareTo(b.id);
      break;
    case 2:
      result = a.companyName.compareTo(b.companyName);
      break;
    case 3:
      result = a.firstName.compareTo(b.firstName);
      break;
    case 4:
      result = a.lastName.compareTo(b.lastName);
      break;
    case 5:
      result = a.phone.compareTo(b.phone);
      break;
    default:
      result = a.id.compareTo(b.id);
      break;
  }
  if (!asc) result *= -1;
  return result;
}

Future main() async {
  var server;
  late final List<CompanyContact> fileContent;
  if (await targetFile.exists()) {
    print('Serving data from $targetFile');
    fileContent = (jsonDecode(await targetFile.readAsString()) as List<dynamic>)
        .map((e) => CompanyContact.fromJson(e))
        .toList();
  } else {
    print("$targetFile doesn't exists, stopping");
    exit(-1);
  }
  try {
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 4044);
  } catch (e) {
    print("Couldn't bind to port 4044: $e");
    exit(-1);
  }
  print('Listening on http://${server.address.address}:${server.port}/');

  await for (HttpRequest req in server) {
    req.response.headers.contentType = ContentType.json;
    //CORS Header, so the anybody can use this
    req.response.headers.add(
      'Access-Control-Allow-Origin',
      '*',
      preserveHeaderCase: true,
    );

    try {
      final offset =
          int.parse(req.requestedUri.queryParameters['offset'] ?? '0');
      final pageSize =
          int.parse(req.requestedUri.queryParameters['pageSize'] ?? '10');
      final sortIndex =
          int.parse(req.requestedUri.queryParameters['sortIndex'] ?? '1');
      final sortAsc =
          int.parse(req.requestedUri.queryParameters['sortAsc'] ?? '1') == 1;

      fileContent.sort((a, b) => sortContacts(a, b, sortIndex, sortAsc));
      req.response.write(
        jsonEncode(
          ResponseModel(
            fileContent.length,
            fileContent.skip(offset).take(pageSize).toList(),
          ),
        ),
      );
    } catch (e) {
      print('Something went wrong: $e');
      req.response.statusCode = HttpStatus.internalServerError;
    }
    await req.response.close();
  }
}
