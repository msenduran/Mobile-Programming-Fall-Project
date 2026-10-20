import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// First screen of the app. It will hold the tabs for bills, balances and chat.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: Center(child: Text(l10n.homeWelcome)),
    );
  }
}
