import 'package:flutter_test/flutter_test.dart';

import 'package:vision_career_mobile/app/app.dart';

void main() {
  testWidgets('renders college selection skeleton', (WidgetTester tester) async {
    await tester.pumpWidget(const VisionCareerApp());

    expect(find.text('Vision Career'), findsOneWidget);
    expect(find.text('Choose Your College'), findsOneWidget);
  });
}
