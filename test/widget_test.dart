import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fsm2_viewer/main.dart';

void main() {
  testWidgets('viewer starts without a selected file', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    expect(find.text('FSM2 SMCAT Viewer'), findsOneWidget);
    expect(find.text('Please open an smcat file.'), findsOneWidget);
  });
}
