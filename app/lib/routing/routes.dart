import 'package:flutter/material.dart';

import '../ui/home/widgets/home_screen.dart';

/// Route names and the route table used by [MaterialApp].
///
/// To add a screen: add a name here and map it to the screen in [table].
abstract final class Routes {
  static const home = '/';

  static final Map<String, WidgetBuilder> table = {
    home: (context) => const HomeScreen(),
  };
}
