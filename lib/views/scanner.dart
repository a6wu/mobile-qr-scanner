// import 'package:backtoschool/data_provider/user_data_provider.dart';
// import 'package:backtoschool/views/container_view.dart';
// import 'package:backtoschool/views/webview_container.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/rendering.dart';
// import 'package:provider/provider.dart';
// import 'package:url_launcher/url_launcher.dart';

// const String cardId = 'QRScanner';

// class ScannerCard extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return WebViewContainer(url)
//   }

//   // Widget buildCardContent(BuildContext context) {
//   //   return GestureDetector(
//   //     onTap: () {
//   //       getActionButtonNavigateRoute(context);
//   //     },
//   //     behavior: HitTestBehavior.translucent,
//   //     child: Row(
//   //       children: <Widget>[
//   //         Container(
//   //           child: Image.asset(
//   //             'assets/images/QRScanIcon.png',
//   //             fit: BoxFit.contain,
//   //             height: 56,
//   //           ),
//   //           padding: EdgeInsets.only(
//   //             left: 10,
//   //             right: 10,
//   //           ),
//   //         ),
//   //         Flexible(
//   //           child: Text(
//   //             getCardContentText(context),
//   //             textAlign: TextAlign.left,
//   //           ),
//   //         )
//   //       ],
//   //     ),
//   //   );
//   // }

//   final _url =
//       'https://mobile.ucsd.edu/replatform/v1/qa/webview/mihir-test/index.html';
//   UserDataProvider _userDataProvider;

//   // Widget buildActionButton(BuildContext context) {
//   //   _userDataProvider = Provider.of<UserDataProvider>(context);
//   //   return FlatButton(
//   //     child: Text(
//   //       getActionButtonText(context),
//   //     ),
//   //     onPressed: () {
//   //       getActionButtonNavigateRoute(context);
//   //     },
//   //   );
//   // }

//   openLink(String url) async {
//     try {
//       launch(url, forceSafariVC: true);
//     } catch (e) {
//       // an error occurred, do nothing
//     }
//   }

//   // String getCardContentText(BuildContext context) {
//   //   return Provider.of<UserDataProvider>(context, listen: false).isLoggedIn
//   //       ? ButtonText.ScanNowFull
//   //       : ButtonText.SignInFull;
//   // }

//   // String getActionButtonText(BuildContext context) {
//   //   return Provider.of<UserDataProvider>(context, listen: false).isLoggedIn
//   //       ? ButtonText.ScanNow
//   //       : ButtonText.SignIn;
//   // }

//   // getActionButtonNavigateRoute(BuildContext context) {
//   //   if (Provider.of<UserDataProvider>(context, listen: false).isLoggedIn) {
//   //     generateScannerUrl();
//   //   } else {
//   //     Provider.of<BottomNavigationBarProvider>(context, listen: false)
//   //         .currentIndex = NavigationConstants.ProfileTab;
//   //   }
//   // }

//   generateScannerUrl() {
//     /// Verify that user is logged in
//     if (_userDataProvider.isLoggedIn) {
//       /// Initialize header
//       final Map<String, String> header = {
//         'Authorization':
//             'Bearer ${_userDataProvider?.authenticationModel?.accessToken}'
//       };
//     }
//     var tokenQueryString =
//         "token=" + '${_userDataProvider.authenticationModel.accessToken}';

//     var affiliationQueryString = "affiliation=" +
//         '${_userDataProvider.authenticationModel.ucsdaffiliation}';

//     var url = _url + "?" + tokenQueryString + "&" + affiliationQueryString;

//     openLink(url);
//   }
// }
