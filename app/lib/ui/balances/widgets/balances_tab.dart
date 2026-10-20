import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/empty_state.dart';

/// The Balances tab on the home screen. For now it only shows an empty state.
class BalancesTab extends StatelessWidget {
  const BalancesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return EmptyState(
      icon: Icons.account_balance_wallet_outlined,
      title: l10n.balancesEmptyTitle,
      message: l10n.balancesEmptyMessage,
    );
  }
}
