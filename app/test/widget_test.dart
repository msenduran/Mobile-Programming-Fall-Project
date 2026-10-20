import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:ogrenci_evim/app.dart';
import 'package:ogrenci_evim/config/dependencies.dart';

void main() {
  testWidgets('App starts on the home screen', (tester) async {
    await tester.pumpWidget(
      MultiProvider(providers: providers, child: const OgrenciEvimApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Öğrenci Evim'), findsOneWidget);
    expect(find.text("Öğrenci Evim'e hoş geldin!"), findsOneWidget);
  });
}
