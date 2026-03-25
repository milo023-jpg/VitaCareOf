import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:vitacareof/presentation/widgets/side_menu.dart';
import 'package:vitacareof/presentation/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameController = TextEditingController();

  void _showEditProfileModal(BuildContext context, AuthNotifier authProvider, User? user) {
    _nameController.text = user?.displayName ?? '';
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            top: 24, left: 24, right: 24
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Editar Perfil', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre Completo',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () async {
                    if (_nameController.text.trim().isEmpty) return;
                    if (user != null) {
                      await user.updateDisplayName(_nameController.text.trim());
                      await user.reload();
                      authProvider.refreshUser();
                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Guardar Modificaciones', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthNotifier>();
    final user = authProvider.user;
    final themeUrl = Theme.of(context).primaryColor;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      drawer: const SideMenu(),
      body: CustomScrollView(
        slivers: [
          // HEADER APPBAR
          SliverAppBar(
            expandedHeight: 180,
            pinned: true,
            backgroundColor: themeUrl,
            elevation: 0,
            title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
            iconTheme: const IconThemeData(color: Colors.white),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                   Container(
                     decoration: BoxDecoration(
                       gradient: LinearGradient(
                         colors: [themeUrl, themeUrl.withOpacity(0.7)],
                         begin: Alignment.topCenter,
                         end: Alignment.bottomCenter,
                       )
                     ),
                   ),
                   // Decorative circles
                   Positioned(
                     right: -50,
                     top: -50,
                     child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.1)),
                   ),
                   Positioned(
                     left: -30,
                     bottom: -20,
                     child: CircleAvatar(radius: 60, backgroundColor: Colors.white.withOpacity(0.1)),
                   ),
                ],
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Transform.translate(
                offset: const Offset(0, 40),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 46,
                      backgroundColor: Colors.white,
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: themeUrl.withOpacity(0.1),
                        child: Text(
                          (user?.displayName != null && user!.displayName!.isNotEmpty) ? user.displayName![0].toUpperCase() : 'U',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: themeUrl),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 50, left: 24, right: 24, bottom: 40),
              child: Column(
                children: [
                  // Nombre y correo
                  Text(
                    user?.displayName ?? 'Usuario Nuevo',
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'correo@ejemplo.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 20),
                  
                  // Botón Editar Perfil
                  OutlinedButton.icon(
                    onPressed: () => _showEditProfileModal(context, authProvider, FirebaseAuth.instance.currentUser),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Editar Perfil'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: themeUrl,
                      side: BorderSide(color: themeUrl),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                    ),
                  ),

                  const SizedBox(height: 32),
                  
                  // LISTA DE MÓDULOS (Settings)
                  _buildProfileMenu(
                    context, 
                    icon: Icons.notifications_none, 
                    title: 'Notificaciones', 
                    subtitle: 'Configura tus alertas y recordatorios',
                    onTap: () {},
                  ),
                  _buildProfileMenu(
                    context, 
                    icon: Icons.security, 
                    title: 'Seguridad y Privacidad', 
                    subtitle: 'Contraseña y accesos',
                    onTap: () {},
                  ),
                  _buildProfileMenu(
                    context, 
                    icon: Icons.help_outline, 
                    title: 'Ayuda y Soporte', 
                    subtitle: 'Preguntas frecuentes y contacto',
                    onTap: () {},
                  ),
                  _buildProfileMenu(
                    context, 
                    icon: Icons.info_outline, 
                    title: 'Acerca de VitaCare', 
                    subtitle: 'Términos, condiciones y versión',
                    onTap: () {},
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // LOGOUT
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
                      ],
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: Colors.red.shade50, shape: BoxShape.circle),
                        child: Icon(Icons.logout, color: Colors.red.shade400, size: 22),
                      ),
                      title: Text('Cerrar Sesión', style: TextStyle(fontWeight: FontWeight.w600, color: Colors.red.shade600)),
                      onTap: () {
                        authProvider.logout();
                        context.go('/login');
                      },
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  const Text('VitaCare v1.0.0', style: TextStyle(color: Colors.grey, fontSize: 12)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildProfileMenu(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))
        ]
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 22),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
        trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
        onTap: onTap,
      ),
    );
  }
}
