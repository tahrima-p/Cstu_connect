import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/firestore_service.dart';
import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firestoreService = FirestoreService.instance;
  await firestoreService.initialize();

  runApp(
    ChangeNotifierProvider<FirestoreService>.value(
      value: firestoreService,
      child: const CSTUConnectApp(),
    ),
  );
}

class CSTUConnectApp extends StatelessWidget {
  final FirestoreService? firestoreService;
  const CSTUConnectApp({super.key, this.firestoreService});

  @override
  Widget build(BuildContext context) {
    // If a provider already exists above, use it; otherwise provide FirestoreService.instance
    Widget app = Consumer<FirestoreService>(
      builder: (context, fs, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CSTU Connect',
          theme: AppTheme.lightTheme,
          home: fs.isAuthenticated
              ? const MainNavigation()
              : const LoginScreen(),
        );
      },
    );

    try {
      context.read<FirestoreService>();
      return app;
    } catch (_) {
      return ChangeNotifierProvider<FirestoreService>.value(
        value: firestoreService ?? FirestoreService.instance,
        child: app,
      );
    }
  }
}