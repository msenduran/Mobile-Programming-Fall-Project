import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/empty_state.dart';

/// The Bills tab on the home screen. For now it only shows an empty state.
class BillsTab extends StatelessWidget {
  const BillsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return EmptyState(
      icon: Icons.receipt_long_outlined,
      title: l10n.billsEmptyTitle,
      message: l10n.billsEmptyMessage,
    );
  }
}
