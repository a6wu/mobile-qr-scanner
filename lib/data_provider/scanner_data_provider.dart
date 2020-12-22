import 'package:backtoschool/constants.dart';
import 'package:backtoschool/services/barcode.dart';
import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_scandit_plugin/flutter_scandit_plugin.dart';


class ScannerDataProvider extends ChangeNotifier {
  ScannerDataProvider() {
    ///DEFAULT STATES
    isLoading = false;
    ///INITIALIZE SERVICES
    _barcodeService = BarcodeService();
  }

  bool hasScanned;
  bool hasSubmitted;
  bool didError;
  String licenseKey;
  BarcodeService _barcodeService;
  UserDataProvider _userDataProvider;
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;
  var ucsdAffiliation = "";
  var accessToken = "";
  String _barcode;
  bool isLoading;
  bool isDuplicate;
  bool successfulSubmission;
  bool isValidBarcode;
  String _errorText;

  Map<String, dynamic> createUserData() {
    ucsdAffiliation = _userDataProvider.authenticationModel.ucsdaffiliation;
    accessToken = _userDataProvider.authenticationModel.accessToken;
    return {'barcode': _barcode, 'ucsdaffiliation': ucsdAffiliation};
  }

  Future<void> handleBarcodeResult(BarcodeResult result) async {
    hasScanned = true;
    _barcode = result.data;
    var data = createUserData();
    var headers = {
      "Content-Type": "application/json",
      'Authorization': 'Bearer ${accessToken}'
    };
    isLoading = true;
    var results = await _barcodeService.uploadResults(headers, data);

    if (results) {
      isLoading = false;
      didError = false;
      successfulSubmission = true;
    } else {
      print(_barcodeService.error);
      print("error constant: " + ErrorConstants.duplicateRecord);
      successfulSubmission = false;
      didError = true;
      isLoading = false;
      if (_barcodeService.error.contains(ErrorConstants.invalidBearerToken)) {
        await _userDataProvider.refreshToken();
      } else if (_barcodeService.error
          .contains(ErrorConstants.duplicateRecord)) {
        print("in correct if");
        _errorText = "Submission failed due to barcode already scanned. Please scan another barcode.";
        isDuplicate = true;
      } else if (_barcodeService.error.contains(ErrorConstants.invalidMedia)) {
        _errorText = "Barcode is not valid. Please scan another barcode.";
        isValidBarcode = false;
      }
      //_submitted = true;
    }
  }
}
