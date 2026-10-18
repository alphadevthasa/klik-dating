import 'package:flutter_test/flutter_test.dart';
import 'package:klik/app.dart';

void main() {
  testWidgets('KLiK shell shows brand and four navigation tabs', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const KliKApp());

    expect(find.text('KLiK'), findsOneWidget);
    expect(find.text('Discover'), findsOneWidget);
    expect(find.text('Like'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Profil'), findsOneWidget);
  });
}
