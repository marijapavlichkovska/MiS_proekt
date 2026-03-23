import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mis_proekt/main.dart';
import 'package:mis_proekt/services/api_service.dart';
import 'package:mis_proekt/services/auth_service.dart';
import 'package:mis_proekt/services/game_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

void main() {
  testWidgets('App builds successfully', (WidgetTester tester) async {
    final apiService = ApiService('https://test.com');
    final secureStorage = const FlutterSecureStorage();
    final authService = AuthService();
    final gameService = GameService(apiService);

    await tester.pumpWidget(
      MyApp(
        apiService: apiService,
        authService: authService,
        gameService: gameService,
      ),
    );

    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}