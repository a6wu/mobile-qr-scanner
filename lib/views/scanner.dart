import 'dart:async';

import 'package:backtoschool/app_theme.dart';
import 'package:backtoschool/constants.dart';
import 'package:backtoschool/data_provider/scanner_data_provider.dart';
import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/navigation/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_scandit_plugin/flutter_scandit_plugin.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class ScanditScanner extends StatelessWidget {
  ScannerDataProvider _scannerDataProvider;
  UserDataProvider _userDataProvider;
  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

  @override
  Widget build(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);
    _scannerDataProvider = Provider.of<ScannerDataProvider>(context);
    _scannerDataProvider.requestCameraPermissions();
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(42),
        child: AppBar(
          centerTitle: true,
          title: Text(AppLocalizations.of(context).scanner_appbar),
        ),
      ),
      body: !_scannerDataProvider.hasScanned
          ? renderScanner(context)
          : renderSubmissionView(context),
      floatingActionButton: IconButton(
        onPressed: () {},
        icon: Container(),
      ),
    );
  }

  Widget renderScanner(BuildContext context) {
    if (_scannerDataProvider.cameraPermissionsStatus ==
        PermissionStatus.granted) {
      return (Stack(
        children: [
          Scandit(
              scanned: _scannerDataProvider.verifyBarcodeScanning,
              onError: (e) => (_scannerDataProvider.message = e.message),
              symbologies: [Symbology.CODE128, Symbology.DATA_MATRIX],
              onScanditCreated: (controller) =>
                  _scannerDataProvider.controller = controller,
              licenseKey: _scannerDataProvider.licenseKey),
          Center(
            child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.2,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Colors.white),
                )),
          ),
          Center(child: Text(_scannerDataProvider.message)),
        ],
      ));
    } else {
      return (Center(
        child: Text(AppLocalizations.of(context).scanner_cam_permissions),
      ));
    }
  }

  Widget renderSubmissionView(BuildContext context) {
    if (_scannerDataProvider.isLoading) {
      return (Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Center(
            child: SizedBox(
                height: 40, width: 40, child: CircularProgressIndicator()),
          ),
          Padding(
            padding: EdgeInsets.only(top: 20.0),
            child: Text(AppLocalizations.of(context).scanner_loading,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ));
    } else if (_scannerDataProvider.successfulSubmission) {
      if(_scannerDataProvider.isBloodScreen) {
        return (renderBloodScreenSuccessScreen(context));
      }
      else {
        return (renderSuccessScreen(context));
      }
    } else if (_scannerDataProvider.didError) {
      return (renderFailureScreen(context));
    } else {
      return (renderFailureScreen(context));
    }
  }

  Widget renderBloodScreenSuccessScreen(BuildContext context) {
    final dateFormat = new DateFormat('dd-MM-yyyy hh:mm:ss a');
    final String scanTime = dateFormat.format(new DateTime.now());
    timeout(context);

    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: (Column(children: <Widget>[
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(AppLocalizations.of(context).success_heading,
                    style:
                    TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
              Text(AppLocalizations.of(context).success_time + scanTime,
                  style: TextStyle(color: Theme.of(context).iconTheme.color)),
              Text(
                  AppLocalizations.of(context).success_value +
                      _scannerDataProvider.barcode,
                  style: TextStyle(color: Theme.of(context).iconTheme.color)),
            ])),
          ),
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                AppLocalizations.of(context).success_next_steps,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            )),
        ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
                title: Text(String.fromCharCode(0x2022) +
                    AppLocalizations.of(context).blood_success_step_one)),
            ListTile(
                title: Text(String.fromCharCode(0x2022) +
                    AppLocalizations.of(context).blood_success_step_two)),
          ],
        ),
      ],
    );
  }

  Widget renderFailureScreen(BuildContext context) {
    return (Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: (Column(children: <Widget>[
              ClipOval(
                child: Container(
                  color: (!_scannerDataProvider.isValidBarcode ||
                          _scannerDataProvider.isDuplicate)
                      ? Colors.orange
                      : Colors.red,
                  height: 75,
                  width: 75,
                  child: Icon(Icons.clear, color: Colors.white, size: 60),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(AppLocalizations.of(context).failure_heading,
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(buildErrorText(context),
                    style:
                        TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text(AppLocalizations.of(context).failure_contact,
                    style: TextStyle(fontSize: 15)),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: FlatButton(
                  padding: EdgeInsets.only(left: 32.0, right: 32.0),
                  onPressed: () {
                    _scannerDataProvider.setDefaultStates();
                  },
                  child: Text(
                    AppLocalizations.of(context).failure_tryagain,
                    style: TextStyle(fontSize: 18.0),
                  ),
                  color: lightButtonColor,
                  textColor: Colors.white,
                ),
              ),
            ])),
          ),
        )
      ],
    ));
  }

  void timeout(BuildContext context) async {
    // delay for 5s and then navigate back to login
    // logout
    Timer(Duration(seconds: 10), () {
      _userDataProvider.logout();
      Navigator.pushNamedAndRemoveUntil(
          context, RoutePaths.Home, (route) => false);
    });
  }

  Widget renderSuccessScreen(BuildContext context) {
    final dateFormat = new DateFormat('dd-MM-yyyy hh:mm:ss a');
    final String scanTime = dateFormat.format(new DateTime.now());
    timeout(context);

    return Column(
      children: [
        Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: (Column(children: <Widget>[
              Icon(Icons.check_circle, color: Colors.green, size: 60),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(AppLocalizations.of(context).success_heading,
                    style:
                        TextStyle(fontSize: 25, fontWeight: FontWeight.bold)),
              ),
              Text(AppLocalizations.of(context).success_time + scanTime,
                  style: TextStyle(color: Theme.of(context).iconTheme.color)),
              Text(
                  AppLocalizations.of(context).success_value +
                      _scannerDataProvider.barcode,
                  style: TextStyle(color: Theme.of(context).iconTheme.color)),
            ])),
          ),
        ),
        Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 16.0),
              child: Text(
                AppLocalizations.of(context).success_next_steps,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            )),
        ListView(
          shrinkWrap: true,
          children: <Widget>[
            ListTile(
                title: Text(String.fromCharCode(0x2022) +
                    AppLocalizations.of(context).success_step_one)),
            ListTile(
                title: Text(String.fromCharCode(0x2022) +
                    AppLocalizations.of(context).success_step_two)),
            ListTile(title: buildChartText(context)),
            ListTile(
                title: Text(String.fromCharCode(0x2022) +
                    AppLocalizations.of(context).success_step_four)),
          ],
        ),
      ],
    );
  }

  String buildErrorText(BuildContext context) {
    switch (_scannerDataProvider.scannerError) {
      case LocalizationErrors.duplicate:
        {
          return AppLocalizations.of(context).failure_error_duplicate;
        }
        break;

      case LocalizationErrors.invalid:
        {
          return AppLocalizations.of(context).failure_error_invalid;
        }
        break;

      case LocalizationErrors.other:
        {
          return AppLocalizations.of(context).failure_error_other;
        }

      default:
        {
          return AppLocalizations.of(context).failure_error_other;
        }
    }
  }

  Text buildChartText(BuildContext context) {
    final studentPattern = RegExp('[BGJMU]');
    final staffPattern = RegExp('[E]');

    if ((_userDataProvider.authenticationModel.ucsdaffiliation ?? "")
        .contains(studentPattern)) {
      // is a student
      return Text(String.fromCharCode(0x2022) +
          AppLocalizations.of(context).success_step_three_student);
    } else if ((_userDataProvider.authenticationModel.ucsdaffiliation ?? "")
        .contains(staffPattern)) {
      // is staff
      return Text(String.fromCharCode(0x2022) +
          AppLocalizations.of(context).success_step_three_staff);
    } else {
      /// is not staff or student
      return Text(String.fromCharCode(0x2022) +
          AppLocalizations.of(context).success_step_three_visitor);
    }
  }
}
