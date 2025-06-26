// article_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/utils/firebase_data.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          l10n.translate('article'), // Localized
          style: AppTheme.headingStyle(size: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              article.image.isNotEmpty
                  ? article.image
                  : 'https://via.placeholder.com/200',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/images/default_article.png',
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title.isNotEmpty
                        ? article.title
                        : l10n.translate('untitled'),
                    style: AppTheme.headingStyle(size: 20),
                  ),
                  const SizedBox(height: 8),
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
                          size: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.author?.isNotEmpty == true
                            ? article.author!
                            : l10n.translate('unknown_author'),
                        style: AppTheme.contentStyle(
                          size: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.description.isNotEmpty
                        ? article.description
                        : l10n.translate('no_description'),
                    style: AppTheme.contentStyle(size: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.content.isNotEmpty
                        ? article.content
                        : l10n.translate('no_content'),
                    style: AppTheme.contentStyle(size: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
