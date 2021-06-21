import 'package:example_adv_datatable/main.dart';
import 'package:flutter/material.dart';

class CompanyContact {
  final int id;
  final String companyName;
  final String firstName;
  final String lastName;
  final String phone;

  const CompanyContact(
    this.id,
    this.companyName,
    this.firstName,
    this.lastName,
    this.phone,
  );

  DataRow getRow(
    SelectedCallBack callback,
    List<String> selectedIds,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(id.toString())),
        DataCell(Text(companyName)),
        DataCell(Text(firstName)),
        DataCell(Text(lastName)),
        DataCell(Text(phone)),
      ],
      onSelectChanged: (newState) {
        callback(id.toString(), newState ?? false);
      },
      selected: selectedIds.contains(id.toString()),
    );
  }

  factory CompanyContact.fromJson(Map<String, dynamic> json) {
    return CompanyContact(
      json['id'] as int,
      json['companyName'] as String,
      json['firstName'] as String,
      json['lastName'] as String,
      json['phone'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'companyName': companyName,
      'firstName': firstName,
      'lastName': lastName,
      'phone': phone,
    };
  }
}
