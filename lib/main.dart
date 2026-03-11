import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacareof/config/routes/go_router.dart';
import 'package:vitacareof/config/theme/app_theme.dart';
import 'package:vitacareof/data/datasources/firebase_auth_datasource.dart';
import 'package:vitacareof/firebase_options.dart';
import 'package:vitacareof/presentation/providers/auth_provider.dart';
import 'package:vitacareof/services/notifications_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await NotificationsService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              AuthNotifier(FirebaseAuthDatasource(FirebaseAuth.instance)),
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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme(selectedColor: 0).getTheme(),
      routerConfig: appRouter,
    );
  }
}
