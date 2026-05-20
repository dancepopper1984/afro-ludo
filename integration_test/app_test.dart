import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:afro_ludo_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration', () {
    testWidgets('app launches and shows main menu', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Afro Ludo'), findsOneWidget);
      expect(find.text('Classic Board Games'), findsOneWidget);
    });

    testWidgets('Play Ludo button is visible', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Play Ludo'), findsOneWidget);
    });

    testWidgets('menu buttons are present', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Play Ludo'), findsOneWidget);
      expect(find.text('Play Whot'), findsOneWidget);
      expect(find.text('Lucky Wheel'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('Shop'), findsOneWidget);
      expect(find.text('Stats'), findsOneWidget);
      expect(find.text('Achievements'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
    });
  });
}
