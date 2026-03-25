import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacareof/config/routes/go_router.dart';
import 'package:vitacareof/config/theme/app_theme.dart';
import 'package:vitacareof/data/datasources/firebase_auth_datasource.dart';
import 'package:vitacareof/firebase_options.dart';
import 'package:vitacareof/presentation/providers/auth_provider.dart';
import 'package:vitacareof/presentation/providers/theme_provider.dart';

import 'package:vitacareof/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  await NotificationService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthNotifier(FirebaseAuthDatasource(FirebaseAuth.instance)),
        ),
        ChangeNotifierProvider(
          create: (_) => ThemeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme(
        selectedColor: themeProvider.selectedColor,
        isDarkmode: themeProvider.isDarkmode,
      ).getTheme(),
      routerConfig: appRouter,
    );
  }
}
