import 'package:flutter_test/flutter_test.dart';
import 'package:muslim/app.dart';

void main() {
  testWidgets('MuslimApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const MuslimApp(isDesktop: false));
  });
}
