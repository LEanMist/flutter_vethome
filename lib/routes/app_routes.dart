import 'package:flutter/material.dart';
import '../presentation/pets_list_screen/pets_list_screen.dart';

import '../presentation/app_navigation_screen/app_navigation_screen.dart';

class AppRoutes {
  static const String petsListScreen = '/pets_list_screen';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String initialRoute = '/';

  static Map<String, WidgetBuilder> get routes => {
    petsListScreen: (context) => PetsListScreen(),
    appNavigationScreen: (context) => AppNavigationScreen(),
    initialRoute: (context) => AppNavigationScreen(),
  };
}
