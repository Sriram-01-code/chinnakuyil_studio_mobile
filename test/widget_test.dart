import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:chinnakuyil_studio/main.dart';
import 'package:provider/provider.dart';
import 'package:chinnakuyil_studio/providers/app_state.dart';

void main() {
  testWidgets('Studio smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppState(),
        child: const MaterialApp(
          home: RootNavigator(),
        ),
      ),
    );

    // Verify loading or auth screen is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
