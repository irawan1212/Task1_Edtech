// article_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/firebase_data.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';

class ArticleCard extends StatelessWidget {
  final Article article;

  const ArticleCard({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            child: Image.network(
              article.image.isNotEmpty
                  ? article.image
                  : 'https://via.placeholder.com/150',
              height: 150,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey.shade300,
                child: const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey, size: 40),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  article.title.isNotEmpty
                      ? article.title
                      : l10n.translate('untitled'),
                  style: AppTheme.headingStyle(size: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article.date.isNotEmpty
                          ? article.date
                          : l10n.translate('unknown_date'),
                      style: AppTheme.contentStyle(
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(
                      Icons.person_outline,
                      size: 12,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article.author?.isNotEmpty == true
                          ? article.author!
                          : l10n.translate('unknown_author'),
                      style: AppTheme.contentStyle(
                        size: 10,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
