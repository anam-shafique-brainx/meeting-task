import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:client_brief/main.dart';
import 'package:client_brief/providers/brief_provider.dart';

void main() {
  testWidgets('App launches and shows home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => BriefProvider(),
        child: const ClientBriefApp(),
      ),
    );

    expect(find.text('Brief Analyzer'), findsOneWidget);
  });
}
