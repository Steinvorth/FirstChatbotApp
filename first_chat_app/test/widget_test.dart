import 'package:flutter_test/flutter_test.dart';
import 'package:first_chat_app/main.dart';

void main() {
  testWidgets('App renders ChatPage', (WidgetTester tester) async {
    await tester.pumpWidget(const FirstChatApp());
    expect(find.text('New Chat'), findsWidgets);
  });
}
