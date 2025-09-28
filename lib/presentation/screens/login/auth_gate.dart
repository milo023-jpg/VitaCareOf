import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/material.dart';
import 'package:vitacareof/presentation/screens/apointments/apointments_screen.dart';


class AuthGate extends StatelessWidget {
  const AuthGate({super.key, required this.clientId});

  final String clientId;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return SignInScreen(                                         // Modify from here...
            providers: [EmailAuthProvider()],
            headerBuilder: (context, constraints, shrinkOffset) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Image.asset('assets/flutterfire_300x.png'),
                ),
              );
            },
          );                                                           // To here.
        }

        return const HomeScreen();
      },
    );
  }
}

/* The headerBuilder argument requires a function of the type HeaderBuilder, which
is defined in the FlutterFire UI package.
 */


typedef HeaderBuilder = Widget Function(
 BuildContext context,
 BoxConstraints constraints,
 double shrinkOffset,
);