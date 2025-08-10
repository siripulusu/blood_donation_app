// import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:blood_donation_app/main.dart'; // Ensure this import path is correct

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const BloodDonationApp());

    // You can add more meaningful tests here
    expect(find.text('Save Lives Today'), findsOneWidget);
  });
}
