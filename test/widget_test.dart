import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:collabify/core/providers/theme_provider.dart';
import 'package:collabify/main.dart';

void main() {
  testWidgets('App renders without crashing', (WidgetTester tester) async {
    final themeProvider = ThemeProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: themeProvider,
        child: const CollabifyApp(),
      ),
    );

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
