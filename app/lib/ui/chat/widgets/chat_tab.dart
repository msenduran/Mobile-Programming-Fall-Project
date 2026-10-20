import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../core/empty_state.dart';

/// The Chat tab on the home screen. For now it only shows an empty state.
class ChatTab extends StatelessWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return EmptyState(
      icon: Icons.chat_bubble_outline,
      title: l10n.chatEmptyTitle,
      message: l10n.chatEmptyMessage,
    );
  }
}
