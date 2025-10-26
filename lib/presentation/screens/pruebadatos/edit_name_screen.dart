import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacareof/services/firebase_services.dart';

class EditNameScreen extends StatefulWidget {
  final Map<String, dynamic>? data;
  const EditNameScreen({super.key, this.data});

  @override
  State<EditNameScreen> createState() => _EditNameScreenState();
}

class _EditNameScreenState extends State<EditNameScreen> {
  TextEditingController nameController = TextEditingController(text: "");

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.data?['name'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Name')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                hintText: widget.data?['name'] ?? 'Ingrese el nuevo nombre',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await updateUsuarios(widget.data?['uid'], nameController.text).then((_) {
                  if (!context.mounted) return;
                  context.pop('/datos');
                });
              },
              child: Text("Actualizar"),
            ),
          ],
        ),
      ),
    );
  }
}
