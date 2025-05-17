import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/home/data/article_data.dart';
import 'package:flutter_application_1/utils/app_theme.dart';

class ArticleDetailScreen extends StatelessWidget {
  final Article article;

  const ArticleDetailScreen({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
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
          'Artikel',
          style: AppTheme.headingStyle(size: 18),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              article.imageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),

            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
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
                        article.date,
                        style:
                            AppTheme.contentStyle(size: 12, color: Colors.grey),
                      ),
                      const SizedBox(width: 16),
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        article.author,
                        style:
                            AppTheme.contentStyle(size: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    article.description,
                    style: AppTheme.contentStyle(
                        size: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    article.content,
                    style: AppTheme.contentStyle(size: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Etiam euismod, nibh a congue tempus, quam nunc eleifend nisl, vitae lacinia arcu nisi id mi. Nulla facilisi. Donec auctor, nisl ac ultricies faucibus, orci elit volutpat libero, in bibendum nisl lectus id magna. Phasellus ac nisi at nisl dignissim efficitur ut a elit. Nunc volutpat, lacus vel hendrerit convallis, dui risus tincidunt purus, quis condimentum felis nulla vel dui. Proin ac magna euismod, fermentum nisi id, imperdiet dui. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Praesent eget tortor eu dui aliquam pellentesque.',
                    style: AppTheme.contentStyle(size: 14),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Fusce vulputate, nibh non pretium varius, ligula nisl feugiat arcu, sit amet ultrices mi augue at est. Donec et ultricies orci. Cras rhoncus purus in mauris facilisis volutpat. Etiam blandit lacus vel risus varius, in vehicula nibh finibus.',
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
