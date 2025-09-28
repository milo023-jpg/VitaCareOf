import 'package:flutter/material.dart';
//import 'package:vitacareof/presentation/screens/login/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'presentation/screens/login/auth_gate.dart';

const clientId = 'ClientID';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp(clientId: clientId));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: AuthGate(clientId: clientId),
    );
  }
}
