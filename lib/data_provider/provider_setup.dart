import 'package:backtoschool/data_provider/locale_data_provider.dart';
import 'package:backtoschool/data_provider/scanner_data_provider.dart';
import 'package:backtoschool/data_provider/user_data_provider.dart';
import 'package:backtoschool/navigation/app_bar.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = [
  ...independentServices,
  ...uiConsumableProviders,
];

List<SingleChildWidget> independentServices = [
  ChangeNotifierProvider<UserDataProvider>(
    create: (_) {
      var _userDataProvider = UserDataProvider();

      /// try to load any persistent saved data
      /// once loaded from memory reauthenticate user
      _userDataProvider.loadSavedData();
      return _userDataProvider;
    },
  ),
  ChangeNotifierProvider<CustomAppBar>(
    create: (_) => CustomAppBar(),
  ),
  ChangeNotifierProvider<LocaleDataProvider>(
    create: (_) => LocaleDataProvider(),
  ),
  ChangeNotifierProxyProvider<UserDataProvider, ScannerDataProvider>(
    create: (_) {
      var _scannerDataProvider = ScannerDataProvider();
      _scannerDataProvider.requestCameraPermissions();
      _scannerDataProvider.initState();
      _scannerDataProvider.setDefaultStates();
      return _scannerDataProvider;
    },
    update: (_, _userDataProvider, scannerDataProvider) {
      scannerDataProvider.userDataProvider = _userDataProvider;
      scannerDataProvider.initState();
      scannerDataProvider.setDefaultStates();
      return scannerDataProvider;
    },
    lazy: false,
  )
];

List<SingleChildWidget> uiConsumableProviders = [];
