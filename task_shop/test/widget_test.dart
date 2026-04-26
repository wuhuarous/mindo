import 'package:flutter_test/flutter_test.dart';
import 'package:task_shop/app.dart';

void main() {
  testWidgets('App renders auth gate', (WidgetTester tester) async {
    await tester.pumpWidget(const TaskShopApp());
    await tester.pump();
    expect(find.text('一分钟差事铺'), findsOneWidget);
  });
}
