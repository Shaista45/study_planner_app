import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:smart_study_planner/main.dart';

void main() {
  testWidgets('Shows redesigned dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));

    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
