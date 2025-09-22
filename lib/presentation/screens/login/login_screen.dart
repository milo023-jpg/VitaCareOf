import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _auth = FirebaseAuth.instance;

  Future<void> _login() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Lo hiciste bien, login exitoso")),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = "Ocurrió un error";

      if (e.code == 'user-not-found') {
        message = "No existe un usuario con ese correo";
      } else if (e.code == 'wrong-password') {
        message = "La contraseña es incorrecta";
      }

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final focusNodeEmail = FocusNode();
    final focusNodePassword = FocusNode();

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // correo
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _emailController,
                  focusNode: focusNodeEmail,
                  onTapOutside: (_) => focusNodeEmail.unfocus(),
                  decoration: InputDecoration(
                    labelText: 'Correo',
                    hintText: 'correo@example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // contraseña
              SizedBox(
                width: 300,
                child: TextField(
                  controller: _passwordController,
                  focusNode: focusNodePassword,
                  obscureText: true,
                  onTapOutside: (_) => focusNodePassword.unfocus(),
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    hintText: '********',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              FilledButton(onPressed: _login, child: const Text('Iniciar')),
            ],
          ),
        ),
      ),
    );
  }
}
