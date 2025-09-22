import 'package:flutter/material.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();
    final focusNode1 = FocusNode();
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
           // Image(image: AssetImage('assets/images/vitacarelogo.png'),),          
            // correo
            SizedBox(
              width: 300,
              child: TextField(
                focusNode: focusNode,
                onTapOutside: (event) => focusNode.unfocus(),
                decoration: InputDecoration(
                  labelText: 'Correo',
                  hintText: 'correo@example.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            // contraseña
            SizedBox(
              width: 300,
              child: TextField(
                focusNode: focusNode1,
                onTapOutside: (event) => focusNode1.unfocus(),
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  hintText: 'Contraseña',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            // contraseña
            SizedBox(height: 10),
            FilledButton(onPressed: () {}, child: Text('Inciar')),
          ],
        ),
      ),
    );
  }
}
