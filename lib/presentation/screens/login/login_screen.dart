// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:vitacareof/presentation/providers/auth_provider.dart';

/// Pantalla de inicio de sesión de la aplicación.
/// 
/// Interfaz a nivel de Presentación que recopila las credenciales del usuario
/// y se comunica con el [AuthNotifier] para validar la autenticación.
/// Implementa manejo básico del teclado en pantalla y control de foco.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Controlador para capturar el email ingresado.
  final _emailController = TextEditingController();
  
  /// Controlador para capturar la contraseña ingresada.
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Al usar context.watch, este widget se reconstruirá si authProvider cambia de estado 
    // (ej: para mostrar un spinner de carga en el futuro al evaluar authProvider.isLoading).
    final authProvider = context.watch<AuthNotifier>();

    return SafeArea(
      child: Scaffold(
        // resizeToAvoidBottomInset en true permite que la vista principal
        // haga 'scroll' hacia arriba automáticamente al desplegarse el teclado
        resizeToAvoidBottomInset: true, 
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Image.asset('assets/images/LogoVitaCare.png', height: 150),
              const SizedBox(height: 20),
              
              // Widget de entrada de Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
                // Elimina el foco (oculta teclado) si se toca fuera del input
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
              ),
              const SizedBox(height: 20),
              
              // Widget de entrada de Contraseña
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true, // Oculta los caracteres escritos
                onTapOutside: (event) {
                  FocusScope.of(context).unfocus();
                },
              ),
              const SizedBox(height: 10),
              
              // Botón de redirección hacia el flujo de Registro
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    context.push('/register');
                  },
                  child: const Text('Registro'),
                ),
              ),
              const SizedBox(height: 20),
              
              // Botón primario que desencadena el flujo de autenticación
              ElevatedButton(
                onPressed: () async {
                  final email = _emailController.text.trim();
                  final password = _passwordController.text.trim();

                  // Solicita la validación a la capa de datos/estado a través del Provider
                  final success = await authProvider.login(email, password);

                  // Manejo de la navegación post-autenticación
                  if (success) {
                    context.push('/home');
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error al iniciar sesión")),
                    );
                  }
                },
                child: const Text("Login"),
              ),
              const SizedBox(
                height: 20,
              ), // Espacio final para evitar choque con teclado y UI apretada
            ],
          ),
        ),
      ),
    );
  }
}
