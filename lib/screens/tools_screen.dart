import 'package:flutter/material.dart';
import '../utils/app_theme.dart';
import 'zakat_calculator_screen.dart';
import 'qaza_tracker_screen.dart';
import 'duas_screen.dart';
import 'hijri_calendar_screen.dart';
import 'prayer_settings_screen.dart';

class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: _buildHeader()),
        SliverToBoxAdapter(child: _buildToolsGrid(context)),
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Islamic Tools',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Essential tools for your daily Islamic practice',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildToolsGrid(BuildContext context) {
    final tools = [
      _ToolItem(
        icon: Icons.calculate,
        title: 'Zakat Calculator',
        subtitle: 'Calculate your Zakat',
        color: const Color(0xFF10B981),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZakatCalculatorScreen())),
      ),
      _ToolItem(
        icon: Icons.history,
        title: 'Qaza Tracker',
        subtitle: 'Track missed prayers',
        color: const Color(0xFF6366F1),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QazaTrackerScreen())),
      ),
      _ToolItem(
        icon: Icons.auto_stories,
        title: 'Duas & Azkar',
        subtitle: 'Daily supplications',
        color: const Color(0xFFF59E0B),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DuasScreen())),
      ),
      _ToolItem(
        icon: Icons.calendar_month,
        title: 'Hijri Calendar',
        subtitle: 'Islamic calendar & events',
        color: const Color(0xFFEF4444),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HijriCalendarScreen())),
      ),
      _ToolItem(
        icon: Icons.notifications_active,
        title: 'Prayer Settings',
        subtitle: 'Notification preferences',
        color: const Color(0xFF8B5CF6),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PrayerSettingsScreen())),
      ),
      _ToolItem(
        icon: Icons.mosque,
        title: 'Names of Allah',
        subtitle: '99 Beautiful Names',
        color: const Color(0xFF06B6D4),
        onTap: () {},
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          for (int i = 0; i < tools.length; i += 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(child: _buildToolCard(tools[i])),
                  const SizedBox(width: 12),
                  Expanded(
                    child: i + 1 < tools.length
                        ? _buildToolCard(tools[i + 1])
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildToolCard(_ToolItem tool) {
    return GestureDetector(
      onTap: tool.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark2,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.surfaceLight.withAlpha(128)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: tool.color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(tool.icon, size: 24, color: tool.color),
            ),
            const SizedBox(height: 14),
            Text(
              tool.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tool.subtitle,
              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ToolItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}
