import 'package:flutter_test/flutter_test.dart';
import 'package:fsm2_viewer/main.dart' as app;
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('viewer starts without a selected file', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    expect(find.text('FSM2 SMCAT Viewer'), findsOneWidget);
    expect(find.text('Please open an smcat file.'), findsOneWidget);
  });
}
