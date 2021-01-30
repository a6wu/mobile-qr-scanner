import 'package:backtoschool/data_provider/locale_data_provider.dart';
import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/navigation/route_paths.dart';
import 'package:backtoschool/views/container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../app_theme.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  UserDataProvider _userDataProvider;
  FocusNode myFocusNode;
  bool _passwordObscured = true;

  final _emailTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();

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

  // Toggles the password show status
  void _toggle() {
    setState(() {
      _passwordObscured = !_passwordObscured;
    });
  }

  void resetLoginDataOnScreen() {
    _emailTextFieldController.clear();
    _passwordTextFieldController.clear();
  }

  String getDeviceType() {
    final data = MediaQueryData.fromWindow(WidgetsBinding.instance.window);
    return data.size.shortestSide < 550 ? 'phone' : 'tablet';
  }

  var localeSelectedStyle = TextStyle(
    shadows: [Shadow(color: Color(0xff006A96), offset: Offset(0, -5))],
    color: Colors.transparent,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    decoration: TextDecoration.underline,
    decorationColor: Color(0xff006A96),
    decorationThickness: 4,
    decorationStyle: TextDecorationStyle.solid,
  );

  var localeUnselectedStyle = TextStyle(
    shadows: [Shadow(color: Color(0xff666666), offset: Offset(0, -5))],
    color: Colors.transparent,
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  navigateScanner(BuildContext context) async {
    await _userDataProvider.login(
        _emailTextFieldController.text, _passwordTextFieldController.text);

    /// Verify that user is logged in
    if (_userDataProvider.isLoggedIn) {
      //clear credentials before moving to next screen
      Navigator.pushNamed(
        context,
        RoutePaths.ScanditScanner,
      );
      resetLoginDataOnScreen();
    }
  }

  Widget buildLocalizationButtons(BuildContext context) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            child: Text(
              "English",
              style: Provider.of<LocaleDataProvider>(context).locale ==
                      Locale('en', '')
                  ? localeSelectedStyle
                  : localeUnselectedStyle,
            ),
            onPressed: () =>
                Provider.of<LocaleDataProvider>(context, listen: false)
                    .setLocaleEn(),
          ),
          TextButton(
            child: Text(
              "Español",
              style: Provider.of<LocaleDataProvider>(context).locale ==
                      Locale('es', '')
                  ? localeSelectedStyle
                  : localeUnselectedStyle,
            ),
            onPressed: () =>
                Provider.of<LocaleDataProvider>(context, listen: false)
                    .setLocaleEs(),
          ),
        ],
      ),
    );
  }

  Widget buildLoginWidget(BuildContext context) {
    return Card(
      child: Padding(
        padding: getDeviceType() == 'tablet'
            ? EdgeInsets.all(50.0)
            : EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            getDeviceType() == 'phone'
                ? Row(children: [buildLocalizationButtons(context)])
                : Container(),
            Row(
              children: [
                Text(
                  AppLocalizations.of(context).login_title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: ColorPrimary,
                  ),
                ),
                getDeviceType() == 'tablet'
                    ? buildLocalizationButtons(context)
                    : Container(),
              ],
            ),
            SizedBox(height: 20),
            TextField(
              focusNode: myFocusNode,
              autofocus: true,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).login_email,
                border: OutlineInputBorder(),
                labelText: AppLocalizations.of(context).login_email,
              ),
              keyboardType: TextInputType.emailAddress,
              controller: _emailTextFieldController,
            ),
            SizedBox(height: 20),
            TextField(
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context).login_password,
                suffixIcon: IconButton(
                  icon: Icon(
                    // Based on passwordObscured state choose the icon
                    _passwordObscured ? Icons.visibility_off : Icons.visibility,
                    color: Theme.of(context).primaryColorDark,
                  ),
                  onPressed: () => _toggle(),
                ),
                border: OutlineInputBorder(),
                labelText: AppLocalizations.of(context).login_password,
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
                          : Text(AppLocalizations.of(context).login_submit,
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
