// To parse this JSON data, do
//
//     final barcodeModel = barcodeModelFromJson(jsonString);

import 'dart:convert';

BarcodeModel barcodeModelFromJson(String str) =>
    BarcodeModel.fromJson(json.decode(str));

String barcodeModelToJson(BarcodeModel data) => json.encode(data.toJson());

class BarcodeModel {
  String ucsdaffiliation;
  String userId;
  int scannedDate;
  String results;

  BarcodeModel({
    this.ucsdaffiliation,
    this.userId,
    this.scannedDate,
    this.results,
  });

  factory BarcodeModel.fromJson(Map<String, dynamic> json) => BarcodeModel(
        ucsdaffiliation:
            json["ucsdaffiliation"] == null ? null : json["ucsdaffiliation"],
        userId: json["userId"] == null ? null : json["userId"],
        scannedDate: json["scannedDate"] == null ? null : json["scannedDate"],
        results: json["results"] == null ? null : json["results"],
      );

  Map<String, dynamic> toJson() => {
        "ucsdaffiliation": ucsdaffiliation == null ? null : ucsdaffiliation,
        "userId": userId == null ? null : userId,
        "scannedDate": scannedDate == null ? null : scannedDate,
        "results": results == null ? null : results,
      };
}
