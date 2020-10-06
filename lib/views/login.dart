import 'dart:async';

import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/views/container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_links/uni_links.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_theme.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _emailTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();
  UserDataProvider _userDataProvider;
  StreamSubscription _sub;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    _userDataProvider = Provider.of<UserDataProvider>(context);
    return ContainerView(
      child: buildLoginWidget(context),
    );
  }

  // _userDataProvider.isLoggedIn ? logoutandReload() :

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
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

  generateScannerUrl(BuildContext context) async {
    await _userDataProvider.login(
        _emailTextFieldController.text, _passwordTextFieldController.text);

    /// Verify that user is logged in
    if (_userDataProvider.isLoggedIn) {
      /// Initialize header
      final Map<String, String> header = {
        'Authorization':
            'Bearer ${_userDataProvider?.authenticationModel?.accessToken}'
      };
      var tokenQueryString =
          "token=" + '${_userDataProvider.authenticationModel.accessToken}';

      var affiliationQueryString = "affiliation=" +
          '${_userDataProvider.authenticationModel.ucsdaffiliation}';

      var url = _url + "?" + tokenQueryString + "&" + affiliationQueryString;
      initUniLinks(context);

      _emailTextFieldController.clear();
      _passwordTextFieldController.clear();

      openLink(url);
    }
  }

  Future<Null> initUniLinks(BuildContext context) async {
    // Attach a listener to the stream
    _sub = getLinksStream().listen((String link) async {
      _userDataProvider.logout();
      await closeWebView();
      setState(() => {});
    }, onError: (err) {
      // Handle exception by warning the user their action did not succeed
    });
  }

  Widget buildLoginWidget(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(50.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Single Sign-On',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorPrimary,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              controller: _emailTextFieldController,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: true,
              controller: _passwordTextFieldController,
            ),
            SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    height: 60,
                    child: FlatButton(
                      child: _userDataProvider.isLoading
                          ? buildLoadingIndicator()
                          : Text('LOG IN',
                              style: TextStyle(
                                fontSize: 24,
                              )),
                      onPressed: _userDataProvider.isLoading
                          ? null
                          : () => generateScannerUrl(context),
                      color: ColorPrimary,
                      textColor: Theme.of(context).textTheme.button.color,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Center(
                child: Text('Need help logging in?',
                    style: TextStyle(
                      color: Colors.black,
                    ))),
          ],
        ),
      ),
    );
  }
}

class buildLoadingIndicator extends StatelessWidget {
  const buildLoadingIndicator({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 100, maxHeight: 100),
        child: CircularProgressIndicator(),
      ),
    );
  }
}
