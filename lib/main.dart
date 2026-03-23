import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/game_service.dart';
import 'provider/auth_provider.dart';
import 'provider/game_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';

const String kBaseUrl = 'https://api.rawg.io/api';
const String kRawgApiKey = 'xx';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final apiService = ApiService(kBaseUrl, apiKey: kRawgApiKey);
  final authService = AuthService();
  final gameService = GameService(apiService);

  runApp(MyApp(
    apiService: apiService,
    authService: authService,
    gameService: gameService,
  ));
}

class MyApp extends StatelessWidget {
  final ApiService apiService;
  final AuthService authService;
  final GameService gameService;

  const MyApp({
    super.key,
    required this.apiService,
    required this.authService,
    required this.gameService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(
          create: (_) => AuthProvider(authService)..init(),
        ),
        ChangeNotifierProxyProvider<AuthProvider, GameProvider>(
          create: (context) => GameProvider(
            gameService,
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) => GameProvider(
            gameService,
            auth,
          ),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return MaterialApp(
            title: 'Game Catalog',
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            home: auth.isLoading
                ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
                : auth.isAuthenticated
                ? const HomeScreen()
                : const LoginScreen(),
          );
        },
      ),
    );
  }
}
