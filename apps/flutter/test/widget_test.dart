import 'package:flutter_test/flutter_test.dart';

import 'package:powercan_liquid_vision_flutter/main.dart';

void main() {
  testWidgets('app renders dashboard tab label', (tester) async {
    await tester.pumpWidget(const PowerCanLiquidVisionApp());
    await tester.pump();
    expect(find.text('Dashboard'), findsOneWidget);
  });
}
