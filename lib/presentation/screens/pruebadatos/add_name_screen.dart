import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacareof/services/firebase_services.dart';

class AddNameScreen extends StatefulWidget {
  const AddNameScreen({super.key});

  @override
  State<AddNameScreen> createState() => _AddNameScreenState();
}

class _AddNameScreenState extends State<AddNameScreen> {
  TextEditingController nameController = TextEditingController(text: "");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Name')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: 'Ingrese el nuevo nombre',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await addUsuarios(nameController.text).then((_) {
                  if (!context.mounted) return;
                  context.pop('/datos');
                });
              },
              child: Text("Guardar"),
            ),
          ],
        ),
      ),
    );
  }
}
