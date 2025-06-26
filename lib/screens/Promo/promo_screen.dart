import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/screens/Promo/promo_card.dart';
import 'package:flutter_application_1/utils/app_localizations.dart';
import 'package:flutter_application_1/utils/firebase_data.dart';

class PromoScreen extends StatefulWidget {
  const PromoScreen({super.key});

  @override
  _PromoScreenState createState() => _PromoScreenState();
}

class _PromoScreenState extends State<PromoScreen> {
  final CollectionReference _promosCollection =
      FirebaseFirestore.instance.collection('promos');
  List<Promo> promos = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPromos();
  }

  Future<void> _fetchPromos() async {
    setState(() {
      isLoading = true;
      hasError = false;
    });
    try {
      final querySnapshot = await _promosCollection.get();
      if (querySnapshot.docs.isNotEmpty) {
        final List<Promo> loadedPromos = querySnapshot.docs
            .map((doc) => Promo.fromJson(
                  doc.id,
                  doc.data() as Map<String, dynamic>,
                ))
            .toList();
        setState(() {
          promos = loadedPromos;
          isLoading = false;
        });
      } else {
        setState(() {
          promos = [];
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            l10n.translate(
              'failed_to_load_promos',
              args: {'error': e.toString()},
            ),
          ),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: l10n.translate('retry'),
            onPressed: _fetchPromos,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          l10n.translate('promo'),
          style: AppTheme.headingStyle(size: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate('error_loading_promos'),
                        style: AppTheme.contentStyle(
                          size: 16,
                          color: Colors.red.shade600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _fetchPromos,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.translate('retry'),
                          style: AppTheme.headingStyle(
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : promos.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.local_offer_outlined,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            l10n.translate('no_promos'),
                            style: AppTheme.contentStyle(
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    )
                  : CustomScrollView(
                      slivers: [
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: PromoCard(promo: promos[index]),
                              ),
                              childCount: promos.length,
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}
