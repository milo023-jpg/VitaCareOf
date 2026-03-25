import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vitacareof/config/theme/app_theme.dart';
import 'package:vitacareof/presentation/providers/theme_provider.dart';
import 'package:vitacareof/presentation/widgets/side_menu.dart';

class ThemeScreen extends StatelessWidget {
  const ThemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final colors = colorsList;

    return Scaffold(
      drawer: const SideMenu(),
      appBar: AppBar(title: const Text("Personalización")),
      body: CustomScrollView(
        slivers: [
          // Banner decorativo superior
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.05),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tu estilo, tus reglas.',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Haz que VitaCare se adapte a ti cambiando el modo de visualización o los colores de acento.',
                    style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7)),
                  ),
                ],
              ),
            ),
          ),

          // Control del Modo Oscuro
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.1)),
                ),
                child: SwitchListTile(
                  title: const Text('Modo Oscuro', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Activa tonos oscuros para descansar tu vista'),
                  value: themeProvider.isDarkmode,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) => themeProvider.toggleDarkmode(),
                  secondary: Icon(
                    themeProvider.isDarkmode ? Icons.dark_mode : Icons.dark_mode_outlined,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ),

          // Título de categoría: Colores
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(24, 10, 24, 10),
              child: Text(
                'Color Principal',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),

          // Selector de grilla de colores
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
                childAspectRatio: 1.0, // forzar cuadrados
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final color = colors[index];
                  final isSelected = themeProvider.selectedColor == index;

                  return GestureDetector(
                    onTap: () => themeProvider.changeColorIndex(index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.fastOutSlowIn,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: isSelected 
                            ? Border.all(color: Theme.of(context).colorScheme.onSurface, width: 3) 
                            : null,
                        boxShadow: isSelected ? [
                          BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, offset: const Offset(0, 6))
                        ] : [],
                      ),
                      child: isSelected 
                          ? const Icon(Icons.check, color: Colors.white, size: 30)
                          : null,
                    ),
                  );
                },
                childCount: colors.length,
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}
