import 'package:backtoschool/navigation/route_paths.dart';
import 'package:backtoschool/views/login.dart';
import 'package:backtoschool/views/scanner.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutePaths.Home:
        return MaterialPageRoute(builder: (_) => LoginView());
      case RoutePaths.ScanditScanner:
        return MaterialPageRoute(builder: (_) => ScanditScanner());
    }
  }
}
