import 'package:go_router/go_router.dart';

import 'package:flutter/material.dart';
import 'package:vitacareof/presentation/widgets/side_menu.dart';
import 'package:vitacareof/services/firebase_services.dart';

class PruebaDatos extends StatefulWidget {
  const PruebaDatos({super.key});

  @override
  State<PruebaDatos> createState() => _PruebaDatosState();
}

class _PruebaDatosState extends State<PruebaDatos> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: SideMenu(),
      appBar: AppBar(title: const Text("Datos")),
      body: FutureBuilder(
        future: getUsuarios(),
        builder: (context, snapshot) {
          if (snapshot.data == null) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data?.length,
            itemBuilder: (context, index) {
              return Dismissible(
                onDismissed: (direction) async {
                  await deleteUsuarios(snapshot.data?[index]['uid']);
                  setState(() {});
                  snapshot.data?.removeAt(index);
                },
                confirmDismiss: (direction) async {
                  bool result = false;

                  result = await showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text(
                          "¿Estás seguro de eliminar a ${snapshot.data?[index]['name']}",
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              return context.pop(false);
                            },
                            child: Text(
                              "Cancelar",
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              return context.pop(true);
                            },
                            child: Text("Sí, estoy seguro"),
                          ),
                        ],
                      );
                    },
                  );

                  return result;
                },
                background: Container(
                  color: Colors.red,
                  child: Icon(Icons.delete),
                ),
                direction: DismissDirection.endToStart,
                key: Key(snapshot.data?[index]['uid']),
                child: ListTile(
                  title: Text(snapshot.data?[index]['name']),
                  onTap: () async {
                    await context.push(
                      '/edit',
                      extra: {
                        "name": snapshot.data?[index]['name'],
                        "uid": snapshot.data?[index]['uid'],
                      },
                    );
                    setState(() {});
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/add');
          setState(() {});
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
