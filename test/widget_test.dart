import 'package:flutter_test/flutter_test.dart';
import 'package:fb_booster/main.dart';

void main() {
  testWidgets('shows FB BOOSTER dashboard', (tester) async {
    await tester.pumpWidget(const FbBoosterApp());
    expect(find.text('FB BOOSTER'), findsOneWidget);
    expect(find.text('ภาพรวมผู้ติดตาม'), findsOneWidget);
  });
}
