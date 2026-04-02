import 'package:flutter/material.dart';
import 'constants/app_theme.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main/main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FishFresh',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      initialRoute: '/',
      routes: {
        '/': (_) => SplashScreen(),
        '/login': (_) => LoginScreen(),
        '/register': (_) => RegisterScreen(),
        '/home': (_) => MainScreen(),
      },
    );
  }
}