import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacareof/presentation/providers/auth_provider.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthNotifier>();
    final user = authProvider.user;
    return NavigationDrawer(
      children: [
        Padding(
          padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 20),
          child: CircleAvatar(radius: 35, child: Icon(Icons.edit)),
        ),
        NavigationDrawerDestination(
          icon: Icon(Icons.person),
          label: Text('${user?.email}'),
        ),
      ],
    );
  }
}
