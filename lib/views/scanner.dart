import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/navigation/route_paths.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

const String cardId = 'QRScanner';

class ScannerCard extends StatelessWidget {
  UserDataProvider _userDataProvider;
  @override
  Widget build(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);
    generateScannerUrl();
    // _userDataProvider.logout();
    Navigator.pop(context);
    Navigator.of(context).pushNamed(RoutePaths.Home);

    return Container();
  }

  final _url =
      'https://mobile.ucsd.edu/replatform/v1/qa/webview/scanner-ipad/index.html';
  openLink(String url) async {
    try {
      launch(url, forceSafariVC: true);
    } catch (e) {
      // an error occurred, do nothing
    }
  }

  generateScannerUrl() {
    /// Verify that user is logged in
    if (_userDataProvider.isLoggedIn) {
      /// Initialize header
      final Map<String, String> header = {
        'Authorization':
            'Bearer ${_userDataProvider?.authenticationModel?.accessToken}'
      };
    }
    var tokenQueryString =
        "token=" + '${_userDataProvider.authenticationModel.accessToken}';

    var affiliationQueryString = "affiliation=" +
        '${_userDataProvider.authenticationModel.ucsdaffiliation}';

    var url = _url + "?" + tokenQueryString + "&" + affiliationQueryString;

    openLink(url);
  }
}
