import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/views/container_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'QR_scanner_view.dart';

class SSOLoginView extends StatefulWidget {
  @override
  _SSOLoginViewState createState() => _SSOLoginViewState();
}

class _SSOLoginViewState extends State<SSOLoginView> {
  final _emailTextFieldController = TextEditingController();
  final _passwordTextFieldController = TextEditingController();
  UserDataProvider _userDataProvider;

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();
    _userDataProvider = Provider.of<UserDataProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return ContainerView(
      child:
          _userDataProvider.isLoggedIn ? QRViewExample() : buildLoginWidget(),
    );
  }

  Widget buildLoginWidget() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text('Single Sign-On'),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder(),
                labelText: 'Email',
              ),
              keyboardType: TextInputType.emailAddress,
              controller: _emailTextFieldController,
            ),
            SizedBox(height: 10),
            TextField(
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              obscureText: true,
              controller: _passwordTextFieldController,
            ),
            SizedBox(height: 10),
            Row(
              children: <Widget>[
                Expanded(
                  child: FlatButton(
                    child: _userDataProvider.isLoading
                        ? buildLoadingIndicator()
                        : Text('Sign In'),
                    onPressed: _userDataProvider.isLoading
                        ? null
                        : () => _userDataProvider.login(
                            _emailTextFieldController.text,
                            _passwordTextFieldController.text),
                    color: Theme.of(context).buttonColor,
                    textColor: Theme.of(context).textTheme.button.color,
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
