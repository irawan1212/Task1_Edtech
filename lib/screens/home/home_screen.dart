import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_1/utils/app_theme.dart';
import 'package:flutter_application_1/screens/home/data/location_data.dart';
import 'package:flutter_application_1/screens/home/data/property_data.dart';
import 'package:flutter_application_1/screens/home/data/promo_data.dart';
import 'package:flutter_application_1/screens/home/data/article_data.dart';
import 'package:flutter_application_1/screens/home/widgets/location_screen.dart';
import 'package:flutter_application_1/screens/home/widgets/property_detail_screen.dart';
import 'package:flutter_application_1/screens/home/widgets/article_detail_screen.dart';
import 'package:flutter_application_1/screens/home/widgets/location_card.dart';
import 'package:flutter_application_1/screens/home/widgets/promo_card.dart';
import 'package:flutter_application_1/screens/home/widgets/property_card.dart';
import 'package:flutter_application_1/screens/home/widgets/article_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ));

    final locations = locationPages;
    final frequentlyVisited = propertyPages;
    final promos = promoPages;
    final articles = articlePages;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(0),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).padding.top + 180,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFFC107),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).padding.top + 80,
                      padding: EdgeInsets.only(
                        top: MediaQuery.of(context).padding.top + 16,
                        left: 16,
                        right: 16,
                        bottom: 16,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Image.asset(
                                  'assets/images/cropped-Logo-US-Header-1 1.png',
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Image.asset(
                              'assets/images/Group 3.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          image: const DecorationImage(
                            image: AssetImage(
                                'assets/images/Frame 1000001269.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                        
                      ),
                    ),

                    const SizedBox(height: 24),

                    SizedBox(
                      height: 110,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: locations.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => LocationScreen(
                                        location: locations[index]),
                                  ),
                                );
                              },
                              child: LocationCard(location: locations[index]),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paling Sering dikunjungi',
                                style: AppTheme.headingStyle(size: 16),
                              ),
                               
                             
                              Text(
                                'Maksimalkan Bisnis Anda bersama Union Space',
                                style: AppTheme.contentStyle(
                                  size: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          
                        ],
                      ),
                    ),


                    const SizedBox(height: 16),

                    SizedBox(
                      height: 240,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: frequentlyVisited.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PropertyDetailScreen(
                                        property: frequentlyVisited[index]),
                                  ),
                                );
                              },
                              child: PropertyCard(
                                  property: frequentlyVisited[index]),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                   Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Promo',
                                style: AppTheme.headingStyle(size: 16),
                              ),
                              Text(
                                'Kemudahan Dengan Promo',
                                style: AppTheme.contentStyle(
                                  size: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Lihat Semua',
                            style: AppTheme.contentStyle(
                              size: 12,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: promos.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: PromoCard(promo: promos[index]),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Artikel',
                                style: AppTheme.headingStyle(size: 16),
                              ),
                              Text(
                                'Kemudahan Dengan Promo',
                                style: AppTheme.contentStyle(
                                  size: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Lihat Semua',
                            style: AppTheme.contentStyle(
                              size: 12,
                              color: Colors.amber,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),
                    SizedBox(
                      height: 220,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        scrollDirection: Axis.horizontal,
                        itemCount: articles.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArticleDetailScreen(
                                        article: articles[index]),
                                  ),
                                );
                              },
                              child: ArticleCard(article: articles[index]),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedLabelStyle: AppTheme.contentStyle(size: 12),
        unselectedLabelStyle: AppTheme.contentStyle(size: 12),
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/Home.png')),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/Ticket.png')),
            label: 'Pesanan',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/Discount.png')),
            label: 'Promo',
          ),
          BottomNavigationBarItem(
            icon: ImageIcon(AssetImage('assets/images/Profile.png')),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
