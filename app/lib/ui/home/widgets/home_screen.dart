import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../balances/widgets/balances_tab.dart';
import '../../bills/widgets/bills_tab.dart';
import '../../chat/widgets/chat_tab.dart';

/// First screen of the app, with a bottom bar for bills, balances and chat.
///
/// The selected tab is short-lived UI state, so it is kept in this widget's
/// State instead of a ViewModel.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedTab = 0;

  static const _tabs = [BillsTab(), BalancesTab(), ChatTab()];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.appTitle)),
      body: _tabs[_selectedTab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedTab,
        onDestinationSelected: (index) => setState(() => _selectedTab = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.tabBills,
          ),
          NavigationDestination(
            icon: const Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: const Icon(Icons.account_balance_wallet),
            label: l10n.tabBalances,
          ),
          NavigationDestination(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat_bubble),
            label: l10n.tabChat,
          ),
        ],
      ),
    );
  }
}
