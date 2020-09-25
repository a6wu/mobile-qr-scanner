import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/views/webview_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

const String cardId = 'QRScanner';

class ScannerCard extends StatefulWidget {
  @override
  _ScannerState createState() => _ScannerState();
  // @override
}

class _ScannerState extends State<ScannerCard> {
  final _url =
      'https://mobile.ucsd.edu/replatform/v1/qa/webview/scanner-ipad/index.html';
  UserDataProvider _userDataProvider;

  @override
  Widget build(BuildContext context) {
    print("Building with url");
    _userDataProvider = Provider.of<UserDataProvider>(context);
    var url = generateScannerUrl();
    print(url);

    return WebViewContainer(generateScannerUrl());
  }

  set userDataProvider(UserDataProvider value) => _userDataProvider = value;

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

    // openLink(url);
    return url;
  }
}

// Widget buildActionButton(BuildContext context) {
//   _userDataProvider = Provider.of<UserDataProvider>(context);
//   return FlatButton(
//     child: Text(
//       getActionButtonText(context),
//     ),
//     onPressed: () {
//       getActionButtonNavigateRoute(context);
//     },
//   );
// }

// openLink(String url) async {
//   try {
//     launch(url, forceSafariVC: true);
//   } catch (e) {
//     // an error occurred, do nothing
//   }
// }

// String getCardContentText(BuildContext context) {
//   return Provider.of<UserDataProvider>(context, listen: false).isLoggedIn
//       ? ButtonText.ScanNowFull
//       : ButtonText.SignInFull;
// }

// String getActionButtonText(BuildContext context) {
//   return Provider.of<UserDataProvider>(context, listen: false).isLoggedIn
//       ? ButtonText.ScanNow
//       : ButtonText.SignIn;
// }

// getActionButtonNavigateRoute(BuildContext context) {
//   if (Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
//     generateScannerUrl();
//   } else {
//     Provider.of<BottomNavigationBarProvider>(context, listen: false)
//         .currentIndex = NavigationConstants.ProfileTab;
//   }
// }
