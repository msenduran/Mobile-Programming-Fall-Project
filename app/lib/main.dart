import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/dependencies.dart';
import 'data/services/notification_service.dart';

Future<void> main() async {
  // Plugins can only be used after this.
  WidgetsFlutterBinding.ensureInitialized();

  final notificationService = NotificationService();
  await notificationService.init();
  // Android 13+ asks the user once; later calls return without a dialog.
  await notificationService.requestPermission();

  runApp(
    MultiProvider(
      providers: providers(notificationService),
      child: const OgrenciEvimApp(),
    ),
  );
}
