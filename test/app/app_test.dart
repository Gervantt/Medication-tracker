import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medtrack/app/app.dart';
import 'package:medtrack/core/router/app_router.dart';

void main() {
  group('MedTrackApp', () {
    testWidgets('opens Today tab and switches to Medications', (tester) async {
      await tester.pumpWidget(MedTrackApp(router: createAppRouter()));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Сегодня'), findsOneWidget);

      await tester.tap(find.text('Лекарства'));
      await tester.pumpAndSettle();

      expect(find.widgetWithText(AppBar, 'Лекарства'), findsOneWidget);
    });
  });
}
