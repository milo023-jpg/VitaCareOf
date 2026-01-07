import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vitacareof/presentation/screens/advices/tip_detail_page.dart';

enum AdviceCategory { todos, sueno, alimentacion, ejercicio, estres, medicacion, prevencion }

AdviceCategory _categoryFromString(String value) {
  switch (value.trim().toLowerCase()) {
    case 'sueno':
      return AdviceCategory.sueno;
    case 'alimentacion':
      return AdviceCategory.alimentacion;
    case 'ejercicio':
      return AdviceCategory.ejercicio;
    case 'estres':
      return AdviceCategory.estres;
    case 'medicacion':
      return AdviceCategory.medicacion;
    case 'prevencion':
      return AdviceCategory.prevencion;
    default:
      return AdviceCategory.todos;
  }
}

String _categoryLabel(AdviceCategory c) {
  switch (c) {
    case AdviceCategory.todos:
      return 'Todos';
    case AdviceCategory.sueno:
      return 'Sueño';
    case AdviceCategory.alimentacion:
      return 'Alimentación';
    case AdviceCategory.ejercicio:
      return 'Ejercicio';
    case AdviceCategory.estres:
      return 'Estrés';
    case AdviceCategory.medicacion:
      return 'Medicación';
    case AdviceCategory.prevencion:
      return 'Prevención';
  }
}

class HealthArticle {
  final String id;
  final String title;
  final String subtitle;
  final String category; // string original para mostrar/buscar
  final AdviceCategory categoryEnum;
  final List<String> tags;
  final String imageAsset;
  final int readMinutes;
  final String markdown;

  HealthArticle({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.categoryEnum,
    required this.tags,
    required this.imageAsset,
    required this.readMinutes,
    required this.markdown,
  });

  factory HealthArticle.fromJson(Map<String, dynamic> json) {
    final catStr = (json['category'] ?? '').toString();
    return HealthArticle(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      subtitle: (json['subtitle'] ?? '').toString(),
      category: catStr,
      categoryEnum: _categoryFromString(catStr),
      tags: (json['tags'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList(),
      imageAsset: (json['image'] ?? '').toString(),
      readMinutes: int.tryParse((json['readMinutes'] ?? '0').toString()) ?? 0,
      markdown: (json['markdown'] ?? '').toString(),
    );
  }
}

class AdvicePage extends StatefulWidget {
  const AdvicePage({super.key});

  @override
  State<AdvicePage> createState() => _AdvicePageState();
}

class _AdvicePageState extends State<AdvicePage> {
  final TextEditingController _searchCtrl = TextEditingController();

  List<HealthArticle> _all = [];
  List<HealthArticle> _filtered = [];

  AdviceCategory _selectedCategory = AdviceCategory.todos;

  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadArticles();
    _searchCtrl.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchCtrl.removeListener(_applyFilters);
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadArticles() async {
    try {
      setState(() {
        _loading = true;
        _error = null;
      });

      final raw = await rootBundle.loadString('assets/data/health_articles.json');
      final decoded = jsonDecode(raw);

      if (decoded is! List) {
        throw Exception('El JSON debe ser una lista de artículos.');
      }

      final list = decoded.map((e) => HealthArticle.fromJson(e as Map<String, dynamic>)).toList();
      setState(() {
        _all = list;
        _filtered = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'No se pudieron cargar los consejos: $e';
        _loading = false;
      });
    }
  }

  void _applyFilters() {
    final q = _searchCtrl.text.trim().toLowerCase();

    List<HealthArticle> temp = _all;

    // filtro por categoría
    if (_selectedCategory != AdviceCategory.todos) {
      temp = temp.where((a) => a.categoryEnum == _selectedCategory).toList();
    }

    // búsqueda eficiente: title + subtitle + category + tags
    if (q.isNotEmpty) {
      temp = temp.where((a) {
        final haystack = [
          a.title,
          a.subtitle,
          a.category,
          ...a.tags,
        ].join(' ').toLowerCase();
        return haystack.contains(q);
      }).toList();
    }

    setState(() => _filtered = temp);
  }

  void _selectCategory(AdviceCategory c) {
    setState(() => _selectedCategory = c);
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // OJO: HomeScreen ya tiene AppBar, aquí no ponemos otro.
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            _SearchBar(
              controller: _searchCtrl,
              onClear: () {
                _searchCtrl.clear();
                _applyFilters();
              },
            ),
            const SizedBox(height: 10),
            _CategoryChips(
              selected: _selectedCategory,
              onSelected: _selectCategory,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Text(
          _error!,
          textAlign: TextAlign.center,
        ),
      );
    }

    if (_filtered.isEmpty) {
      return Center(
        child: Text(
          _searchCtrl.text.trim().isEmpty
              ? 'No hay consejos disponibles.'
              : 'No encontramos resultados para "${_searchCtrl.text.trim()}".',
          textAlign: TextAlign.center,
        ),
      );
    }

    return ListView.separated(
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final a = _filtered[index];
        return _AdviceCard(
          article: a,
          categoryLabel: _categoryLabel(a.categoryEnum),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TipDetailPage(article: a),
              ),
            );
          },
        );
      },
    );
  }
}

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onClear;

  const _SearchBar({
    required this.controller,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Buscar consejos (sueño, ejercicio, alimentación...)',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (_, value, __) {
            if (value.text.isEmpty) return const SizedBox.shrink();
            return IconButton(
              icon: const Icon(Icons.close),
              onPressed: onClear,
              tooltip: 'Limpiar',
            );
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        isDense: true,
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final AdviceCategory selected;
  final ValueChanged<AdviceCategory> onSelected;

  const _CategoryChips({
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final cats = AdviceCategory.values;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final c = cats[i];
          final isSel = c == selected;

          return ChoiceChip(
            label: Text(_categoryLabel(c)),
            selected: isSel,
            onSelected: (_) => onSelected(c),
          );
        },
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  final HealthArticle article;
  final String categoryLabel;
  final VoidCallback onTap;

  const _AdviceCard({
    required this.article,
    required this.categoryLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Ink(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            // Texto (izquierda)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    article.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: [
                      Chip(
                        label: Text(categoryLabel),
                        visualDensity: VisualDensity.compact,
                      ),
                      Chip(
                        label: Text('⏱ ${article.readMinutes} min'),
                        visualDensity: VisualDensity.compact,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // Imagen (derecha)
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: 110,
                height: 90,
                child: Image.asset(
                  article.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: theme.dividerColor.withOpacity(0.15),
                    alignment: Alignment.center,
                    child: const Icon(Icons.image_not_supported_outlined),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
