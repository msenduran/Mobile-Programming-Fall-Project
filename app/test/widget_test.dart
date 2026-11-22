import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ogrenci_evim/app.dart';
import 'package:ogrenci_evim/config/dependencies.dart';

import 'data/services/fake_notification_service.dart';

void main() {
  testWidgets('App starts on the bills tab and switches tabs', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: providers(FakeNotificationService()),
        child: const OgrenciEvimApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Öğrenci Evim'), findsOneWidget);
    expect(find.text('Henüz fatura yok'), findsOneWidget);

    await tester.tap(find.text('Borçlar'));
    await tester.pumpAndSettle();
    expect(find.text('Borç yok'), findsOneWidget);

    await tester.tap(find.text('Sohbet'));
    await tester.pumpAndSettle();
    expect(find.text('Ev sohbeti'), findsOneWidget);
  });
}
