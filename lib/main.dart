import 'package:backtoschool/app_theme.dart';
import 'package:backtoschool/data_provider/locale_data_provider.dart';
import 'package:backtoschool/data_provider/provider_setup.dart';
import 'package:backtoschool/navigation/router.dart' as appRouter;
import 'package:backtoschool/views/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeStorage();
  runApp(TabBarApp());
}

Future<void> initializeStorage() async {
  /// initialize hive storage
  Hive.initFlutter('.');
  FlutterSecureStorage storage = FlutterSecureStorage();

  /// delete any saved data
  await Hive.deleteFromDisk();
  await storage.deleteAll();
}

class TabBarApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: Consumer<LocaleDataProvider>(
        builder: (context, _localeDataProvider, child) => MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: _localeDataProvider.locale,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('en', ''),
            const Locale('es', ''),
          ],
          theme: ThemeData(
            primarySwatch: ColorPrimary,
            accentColor: lightAccentColor,
            brightness: Brightness.light,
            buttonColor: lightButtonColor,
            textTheme: lightThemeText,
            iconTheme: lightIconTheme,
            appBarTheme: lightAppBarTheme,
          ),
          home: LoginView(),
          onGenerateRoute: appRouter.Router.generateRoute,
        ),
      ),
    );
  }
}
