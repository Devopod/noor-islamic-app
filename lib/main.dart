import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/tasbeeh_provider.dart';
import 'providers/qaza_provider.dart';
import 'providers/quran_provider.dart';
import 'screens/home_screen.dart';
import 'screens/quran_screen.dart';
import 'screens/qibla_screen.dart';
import 'screens/tools_screen.dart';
import 'screens/manage_tasbeeh_screen.dart';
import 'utils/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const NoorIslamicApp());
}

class NoorIslamicApp extends StatelessWidget {
  const NoorIslamicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TasbeehProvider()),
        ChangeNotifierProvider(create: (_) => QazaProvider()),
        ChangeNotifierProvider(create: (_) => QuranProvider()),
      ],
      child: MaterialApp(
        title: 'Noor Islamic',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const MainShell(),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    QuranScreen(),
    SizedBox(),
    ToolsScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaScreen()));
      return;
    }
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(child: _screens[_currentIndex]),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark2,
          border: Border(
            top: BorderSide(color: AppTheme.surfaceLight.withAlpha(128)),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _onTabTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Quran'),
            BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Qibla'),
            BottomNavigationBarItem(icon: Icon(Icons.apps), label: 'Tools'),
          ],
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.surfaceDark2,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary.withAlpha(50), AppTheme.surfaceDark],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withAlpha(50),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(Icons.mosque, size: 32, color: AppTheme.primary),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Noor Islamic',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Your daily Islamic companion',
                    style: TextStyle(fontSize: 13, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _drawerItem(Icons.spa, 'Manage Tasbeeh', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ManageTasbeehScreen()));
            }),
            _drawerItem(Icons.explore, 'Qibla Finder', () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const QiblaScreen()));
            }),
            _drawerItem(Icons.calculate, 'Zakat Calculator', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            }),
            _drawerItem(Icons.history, 'Qaza Tracker', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            }),
            _drawerItem(Icons.auto_stories, 'Duas & Azkar', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            }),
            _drawerItem(Icons.calendar_month, 'Hijri Calendar', () {
              Navigator.pop(context);
              setState(() => _currentIndex = 3);
            }),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String label, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.textSecondary, size: 22),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      onTap: onTap,
      dense: true,
    );
  }
}
