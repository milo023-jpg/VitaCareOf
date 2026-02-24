import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:vitacareof/presentation/screens/home/advice_page.dart';

class TipDetailPage extends StatelessWidget {
  final HealthArticle article;

  const TipDetailPage({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Consejo')),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                article.imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: theme.dividerColor.withOpacity(0.15),
                  alignment: Alignment.center,
                  child: const Icon(Icons.image_not_supported_outlined, size: 34),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            article.title,
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              Chip(label: Text(article.category)),
              Chip(label: Text('⏱ ${article.readMinutes} min')),
            ],
          ),
          const SizedBox(height: 10),
          MarkdownBody(
            data: article.markdown,
            selectable: true,
          ),
        ],
      ),
    );
  }
}
