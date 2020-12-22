import 'dart:async';

import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/views/container.dart';
import 'package:backtoschool/navigation/route_paths.dart';
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
  UserDataProvider _userDataProvider;
  StreamSubscription _sub;
  FocusNode myFocusNode;
  bool _passwordObscured = true;

  final _emailTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();
  final _iPadWebScannerURL =
      'https://mobile.ucsd.edu/replatform/v1/qa/webview/scanner-ipad/index.html';

  @override
  void initState() {
    super.initState();
    myFocusNode = FocusNode();
  }

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

  @override
  void setState(fn) {
    super.setState(fn);
  }

  @override
  void dispose() {
    _sub.cancel();
    myFocusNode.dispose();
    super.dispose();
  }

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _passwordObscured = !_passwordObscured;
    });
  }

  navigateScanner(BuildContext context) async {
    print(context);
    await _userDataProvider.login(
        _emailTextFieldController.text, _passwordTextFieldController.text);

    /// Verify that user is logged in
    if (_userDataProvider.isLoggedIn) {
      Navigator.pushNamed(
        context,
        RoutePaths.ScanditScanner,
      );
    }
  }

  Future<Null> initUniLinks(BuildContext context) async {
    // Attach a listener to the stream
    _sub = getLinksStream().listen((String link) async {
      _userDataProvider.logout();
      await closeWebView();
      FocusScope.of(context).requestFocus(myFocusNode);
      setState(() => {_passwordObscured = true});
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
              focusNode: myFocusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'UCSD Email',
                border: OutlineInputBorder(),
                labelText: 'UCSD Email',
              ),
              keyboardType: TextInputType.emailAddress,
              controller: _emailTextFieldController,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordObscured state choose the icon
                    _passwordObscured ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () => _toggle(),
                ),
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: _passwordObscured,
              keyboardType: TextInputType.emailAddress,
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
                          ? BuildLoadingIndicator()
                          : Text('LOG IN',
                              style: TextStyle(
                                fontSize: 24,
                              )),
                      onPressed: _userDataProvider.isLoading
                          ? null
                          : () => navigateScanner(context),
                      color: ColorPrimary,
                      textColor: Theme.of(context).textTheme.button.color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class BuildLoadingIndicator extends StatelessWidget {
  const BuildLoadingIndicator({
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
