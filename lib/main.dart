import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Order/order_screen.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart'; // Add Firebase import
import 'screens/home/home_screen.dart';
import 'screens/Promo/promo_screen.dart';
import 'screens/Profile/profile_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/auth/auth_wrapper.dart'; // Add AuthWrapper import
import 'utils/app_localizations.dart';
import 'utils/language_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(
    ChangeNotifierProvider(
      create: (_) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'Union Space App',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          locale: languageProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''),
            Locale('id', ''),
          ],
          home: const SplashScreen(),
        );
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const OrderScreen(),
    const PromoScreen(),
    const ProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/images/Home.png')),
            label: l10n.translate('home'),
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/images/Ticket.png')),
            label: l10n.translate('orders'),
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/images/Discount.png')),
            label: l10n.translate('promos'),
          ),
          BottomNavigationBarItem(
            icon: const ImageIcon(AssetImage('assets/images/Profile.png')),
            label: l10n.translate('account'),
          ),
        ],
      ),
    );
  }
}
