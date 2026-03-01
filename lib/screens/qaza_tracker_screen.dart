import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../providers/qaza_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class QazaTrackerScreen extends StatelessWidget {
  const QazaTrackerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: Consumer<QazaProvider>(
          builder: (context, qaza, _) {
            return Column(
              children: [
                _buildHeader(context, qaza, isDark),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    children: [
                      _buildToggle(qaza, isDark),
                      const SizedBox(height: 16),
                      _buildProgressOverview(qaza, isDark),
                      const SizedBox(height: 20),
                      ...List.generate(qaza.prayers.length, (i) => _buildPrayerCard(context, qaza, i, isDark)),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton(
                          onPressed: () => _showResetConfirmation(context, qaza),
                          child: Text('Reset all data', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary, decoration: TextDecoration.underline, decorationStyle: TextDecorationStyle.dashed)),
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

  Widget _buildHeader(BuildContext context, QazaProvider qaza, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF112215).withAlpha(242) : Colors.white,
        border: Border(bottom: BorderSide(color: isDark ? AppTheme.surfaceLight : Colors.grey.withAlpha(50))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(width: 32, height: 32, decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? Colors.white.withAlpha(13) : Colors.grey.withAlpha(30)), child: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1A3A22), size: 20)),
            ),
            const SizedBox(width: 12),
            Text(qaza.isNamaz ? 'Qaza Namaz' : 'Qaza Roza', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
          ]),
          Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? Colors.white.withAlpha(13) : Colors.grey.withAlpha(30)), child: Icon(Icons.settings, size: 22, color: AppTheme.primary)),
        ],
      ),
    );
  }

  Widget _buildToggle(QazaProvider qaza, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark2 : Colors.grey[200], borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Expanded(child: GestureDetector(
            onTap: () { if (!qaza.isNamaz) qaza.toggleMode(); },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: qaza.isNamaz ? (isDark ? AppTheme.surfaceLight : Colors.white) : Colors.transparent, borderRadius: BorderRadius.circular(8), border: qaza.isNamaz ? Border.all(color: isDark ? const Color(0xFF356140) : AppTheme.primary.withAlpha(76)) : null),
              child: Text('Namaz', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: qaza.isNamaz ? (isDark ? Colors.white : const Color(0xFF1A3A22)) : Colors.grey[400])),
            ),
          )),
          Expanded(child: GestureDetector(
            onTap: () { if (qaza.isNamaz) qaza.toggleMode(); },
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(color: !qaza.isNamaz ? (isDark ? AppTheme.surfaceLight : Colors.white) : Colors.transparent, borderRadius: BorderRadius.circular(8), border: !qaza.isNamaz ? Border.all(color: isDark ? const Color(0xFF356140) : AppTheme.primary.withAlpha(76)) : null),
              child: Text('Roza (Fasts)', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: !qaza.isNamaz ? (isDark ? Colors.white : const Color(0xFF1A3A22)) : Colors.grey[400])),
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildProgressOverview(QazaProvider qaza, bool isDark) {
    final percent = (qaza.overallProgress * 100).toInt();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark2 : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppTheme.surfaceLight : Colors.grey.withAlpha(50))),
      child: Column(children: [
        Row(children: [
          CircularPercentIndicator(
            radius: 40, lineWidth: 6, percent: qaza.overallProgress,
            center: Text('$percent%', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
            progressColor: AppTheme.primary,
            backgroundColor: isDark ? const Color(0xFF112215) : Colors.grey[200]!,
            circularStrokeCap: CircularStrokeCap.round,
          ),
          const SizedBox(width: 20),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(qaza.isNamaz ? 'Namaz Progress' : 'Roza Progress', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
            const SizedBox(height: 8),
            Row(children: [
              _buildStatChip('Total', '${qaza.totalMissed}', isDark ? Colors.white : const Color(0xFF1A3A22)),
              const SizedBox(width: 12),
              _buildStatChip('Done', '${qaza.totalOffered}', AppTheme.primary),
              const SizedBox(width: 12),
              _buildStatChip('Left', '${qaza.totalRemaining}', AppTheme.secondary),
            ]),
          ])),
        ]),
      ]),
    );
  }

  Widget _buildStatChip(String label, String value, Color color) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[400], fontWeight: FontWeight.w600)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
    ]);
  }

  IconData _getPrayerIcon(String iconName) {
    switch (iconName) {
      case 'wb_twilight': return Icons.wb_twilight;
      case 'light_mode': return Icons.light_mode;
      case 'wb_sunny': return Icons.wb_sunny;
      case 'nights_stay': return Icons.nights_stay;
      case 'dark_mode': return Icons.dark_mode;
      case 'star': return Icons.star;
      case 'brightness_3': return Icons.brightness_3;
      case 'terrain': return Icons.terrain;
      default: return Icons.access_time;
    }
  }

  Widget _buildPrayerCard(BuildContext context, QazaProvider qaza, int index, bool isDark) {
    final prayer = qaza.prayers[index];
    final isRoza = !qaza.isNamaz;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark2 : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isDark ? AppTheme.surfaceLight : Colors.grey.withAlpha(50))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(width: 40, height: 40, decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? const Color(0xFF112215) : Colors.green.withAlpha(20), border: Border.all(color: isDark ? AppTheme.surfaceLight : Colors.green.withAlpha(30))), child: Icon(_getPrayerIcon(prayer.icon), size: 20, color: AppTheme.textSecondary)),
            const SizedBox(width: 12),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(prayer.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
              Text(isRoza ? '${prayer.totalMissed} total' : '${prayer.rakats} Rakats', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            ]),
          ]),
          GestureDetector(
            onTap: () => _showEditDialog(context, qaza, index),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('${prayer.remaining}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
              Text('REMAINING', style: TextStyle(fontSize: 9, color: AppTheme.textSecondary, letterSpacing: 0.5)),
            ]),
          ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(value: prayer.progress, backgroundColor: isDark ? const Color(0xFF112215) : Colors.grey[200], valueColor: AlwaysStoppedAnimation(AppTheme.primary), minHeight: 6),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: isDark ? const Color(0xFF112215) : Colors.grey[100], borderRadius: BorderRadius.circular(10)),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            GestureDetector(
              onTap: () => qaza.decrementOffered(index),
              child: Container(width: 40, height: 40, decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)), child: Icon(Icons.remove, color: AppTheme.textSecondary)),
            ),
            Column(children: [
              Text(isRoza ? 'Kept' : 'Offered', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
              Text('${prayer.offered}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.primary)),
            ]),
            GestureDetector(
              onTap: () => qaza.incrementOffered(index),
              child: Container(width: 40, height: 40, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(8), boxShadow: [BoxShadow(color: AppTheme.primary.withAlpha(76), blurRadius: 8)]), child: const Icon(Icons.add, color: Color(0xFF102215))),
            ),
          ]),
        ),
      ]),
    );
  }

  void _showEditDialog(BuildContext context, QazaProvider qaza, int index) {
    final prayer = qaza.prayers[index];
    final controller = TextEditingController(text: '${prayer.totalMissed}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceDark2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit ${prayer.name}', style: const TextStyle(color: Colors.white)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Set the total missed count:', style: TextStyle(color: Colors.grey[400])),
          const SizedBox(height: 12),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(hintText: 'Total missed', hintStyle: TextStyle(color: Colors.grey[600]), enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey[600]!))),
          ),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel', style: TextStyle(color: Colors.grey[400]))),
          TextButton(onPressed: () { final val = int.tryParse(controller.text); if (val != null && val > 0) { qaza.updateMissedCount(index, val); } Navigator.pop(ctx); }, child: Text('Save', style: TextStyle(color: AppTheme.primary))),
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
        content: Text(qaza.isNamaz ? 'This will reset all prayer counts to zero.' : 'This will reset all fast counts to zero.', style: TextStyle(color: Colors.grey[400])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.grey[400]))),
          TextButton(onPressed: () { qaza.resetAll(); Navigator.pop(context); }, child: const Text('Reset', style: TextStyle(color: Colors.redAccent))),
        ],
      ),
    );
  }
}
