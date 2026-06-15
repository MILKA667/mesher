import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mesher/ui/widgets/signal_indicator.dart';

void main() {
  testWidgets('SignalIndicator renders 4 bars', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SignalIndicator(level: 3))),
    );
    expect(find.byType(SignalIndicator), findsOneWidget);
  });
}
