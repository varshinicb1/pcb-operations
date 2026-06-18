import 'package:flutter_test/flutter_test.dart';
import 'package:pcb_operations/main.dart' as app;

void main() {
  testWidgets('App renders without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const app.PCBApp());
    expect(find.byType(app.PCBApp), findsOneWidget);
  });
}
