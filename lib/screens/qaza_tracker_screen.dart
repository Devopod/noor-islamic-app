import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/qaza_provider.dart';
import '../utils/app_theme.dart';

class QazaTrackerScreen extends StatelessWidget {
  const QazaTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Consumer<QazaProvider>(
          builder: (context, qaza, _) {
            return Column(
              children: [
                _buildHeader(context, qaza),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      _buildToggle(qaza),
                      const SizedBox(height: 16),
                      _buildProgressOverview(qaza),
                      const SizedBox(height: 20),
                      ...List.generate(qaza.prayers.length, (i) => _buildPrayerCard(qaza, i)),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => _showResetConfirmation(context, qaza),
                          child: Text(
                            'Reset all data',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppTheme.textSecondary,
                              decoration: TextDecoration.underline,
                              decorationStyle: TextDecorationStyle.dashed,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, QazaProvider qaza) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF112215).withAlpha(242),
        border: Border(bottom: BorderSide(color: AppTheme.surfaceLight)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withAlpha(13),
                  ),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              const SizedBox(width: 12),
              const Text('Qaza Tracker', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withAlpha(13),
            ),
            child: Icon(Icons.settings, size: 22, color: AppTheme.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(QazaProvider qaza) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark2,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (!qaza.isNamaz) qaza.toggleMode();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: qaza.isNamaz ? AppTheme.surfaceLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: qaza.isNamaz ? Border.all(color: const Color(0xFF356140)) : null,
                ),
                child: Text(
                  'Namaz',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: qaza.isNamaz ? Colors.white : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                if (qaza.isNamaz) qaza.toggleMode();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: !qaza.isNamaz ? AppTheme.surfaceLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: !qaza.isNamaz ? Border.all(color: const Color(0xFF356140)) : null,
                ),
                child: Text(
                  'Roza (Fasts)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: !qaza.isNamaz ? Colors.white : Colors.grey[400],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(QazaProvider qaza) {
    final percent = (qaza.overallProgress * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark2,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircularPercentIndicator(
                radius: 40,
                lineWidth: 6,
                percent: qaza.overallProgress,
                center: Text(
                  '$percent%',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                progressColor: AppTheme.primary,
                backgroundColor: const Color(0xFF112215),
                circularStrokeCap: CircularStrokeCap.round,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Progress Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildStatChip('Total', '${qaza.totalMissed}', Colors.white),
                        const SizedBox(width: 12),
                        _buildStatChip('Done', '${qaza.totalOffered}', AppTheme.primary),
                        const SizedBox(width: 12),
                        _buildStatChip('Left', '${qaza.totalRemaining}', AppTheme.secondary),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w600)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  IconData _getPrayerIcon(String iconName) {
    switch (iconName) {
      case 'wb_twilight':
        return Icons.wb_twilight;
      case 'light_mode':
        return Icons.light_mode;
      case 'wb_sunny':
        return Icons.wb_sunny;
      case 'nights_stay':
        return Icons.nights_stay;
      case 'dark_mode':
        return Icons.dark_mode;
      case 'star':
        return Icons.star;
      default:
        return Icons.access_time;
    }
  }

  Widget _buildPrayerCard(QazaProvider qaza, int index) {
    final prayer = qaza.prayers[index];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceDark2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF112215),
                      border: Border.all(color: AppTheme.surfaceLight),
                    ),
                    child: Icon(_getPrayerIcon(prayer.icon), size: 20, color: AppTheme.textSecondary),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prayer.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text('${prayer.rakats} Rakats', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${prayer.remaining}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                  Text('REMAINING', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary, letterSpacing: 0.5)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: prayer.progress,
              backgroundColor: const Color(0xFF112215),
              valueColor: AlwaysStoppedAnimation(AppTheme.primary),
              minHeight: 6,
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF112215),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () => qaza.decrementOffered(index),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.transparent,
                    ),
                    child: Icon(Icons.remove, color: AppTheme.textSecondary),
                  ),
                ),
                Column(
                  children: [
                    Text('Offered', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                    Text('${prayer.offered}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                  ],
                ),
                GestureDetector(
                  onTap: () => qaza.incrementOffered(index),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [BoxShadow(color: AppTheme.primary.withAlpha(76), blurRadius: 8)],
                    ),
                    child: const Icon(Icons.add, color: Color(0xFF102215)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation(BuildContext context, QazaProvider qaza) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset All Data?', style: TextStyle(color: Colors.white)),
        content: Text('This will reset all prayer counts to zero.', style: TextStyle(color: Colors.grey[400])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[400])),
          ),
          TextButton(
            onPressed: () {
              qaza.resetAll();
              Navigator.pop(context);
            },
            child: const Text('Reset', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}
