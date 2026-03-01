import 'package:flutter/material.dart';
import '../utils/app_theme.dart';

class PrayerSettingsScreen extends StatefulWidget {
  const PrayerSettingsScreen({super.key});

  @override
  State<PrayerSettingsScreen> createState() => _PrayerSettingsScreenState();
}

class _PrayerSettingsScreenState extends State<PrayerSettingsScreen> {
  String _calculationMethod = 'Muslim World League';
  final Map<String, bool> _prayerAlerts = {
    'Fajr': true,
    'Sunrise': false,
    'Dhuhr': true,
    'Asr': true,
    'Maghrib': true,
    'Isha': true,
  };
  final Map<String, String> _notificationType = {
    'Fajr': 'Adhan',
    'Sunrise': 'Silent',
    'Dhuhr': 'Adhan',
    'Asr': 'Vibrate',
    'Maghrib': 'Adhan',
    'Isha': 'Adhan',
  };
  final Map<String, int> _corrections = {
    'Fajr': 0,
    'Sunrise': 0,
    'Dhuhr': 0,
    'Asr': 0,
    'Maghrib': 0,
    'Isha': 0,
  };

  final List<String> _methods = [
    'Muslim World League',
    'Egyptian Authority',
    'Karachi',
    'Umm al-Qura',
    'ISNA',
    'Tehran',
  ];

  final Map<String, IconData> _prayerIcons = {
    'Fajr': Icons.wb_twilight,
    'Sunrise': Icons.wb_sunny,
    'Dhuhr': Icons.light_mode,
    'Asr': Icons.wb_sunny,
    'Maghrib': Icons.nights_stay,
    'Isha': Icons.dark_mode,
  };

  final Map<String, String> _prayerTimes = {
    'Fajr': '5:23 AM',
    'Sunrise': '6:45 AM',
    'Dhuhr': '12:30 PM',
    'Asr': '3:45 PM',
    'Maghrib': '6:15 PM',
    'Isha': '7:45 PM',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 16),
                  _buildCalculationMethod(),
                  const SizedBox(height: 20),
                  _buildManualCorrection(),
                  const SizedBox(height: 20),
                  _buildPrayerAlerts(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(bottom: BorderSide(color: AppTheme.surfaceLight.withAlpha(128))),
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Text('Prayer Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.primary.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Save', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationMethod() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calculate, size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text('Calculation Method', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Method used to calculate prayer times', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceLight),
          ),
          child: DropdownButton<String>(
            value: _calculationMethod,
            isExpanded: true,
            dropdownColor: AppTheme.surfaceDark2,
            underline: const SizedBox.shrink(),
            icon: Icon(Icons.expand_more, color: Colors.grey[400]),
            style: const TextStyle(color: Colors.white, fontSize: 14),
            items: _methods.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
            onChanged: (v) {
              if (v != null) setState(() => _calculationMethod = v);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildManualCorrection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.tune, size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text('Manual Time Correction', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 4),
        Text('Fine-tune individual prayer times (minutes)', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppTheme.surfaceDark2,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppTheme.surfaceLight),
          ),
          child: Column(
            children: _corrections.keys.map((prayer) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(_prayerIcons[prayer], size: 16, color: AppTheme.textSecondary),
                        const SizedBox(width: 8),
                        Text(prayer, style: TextStyle(fontSize: 13, color: Colors.grey[300])),
                      ],
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => _corrections[prayer] = (_corrections[prayer] ?? 0) - 1),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: AppTheme.backgroundDark,
                            ),
                            child: const Icon(Icons.remove, size: 16, color: Colors.white),
                          ),
                        ),
                        SizedBox(
                          width: 40,
                          child: Text(
                            '${_corrections[prayer]}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => setState(() => _corrections[prayer] = (_corrections[prayer] ?? 0) + 1),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(6),
                              color: AppTheme.primary.withAlpha(50),
                            ),
                            child: Icon(Icons.add, size: 16, color: AppTheme.primary),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPrayerAlerts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.notifications_active, size: 18, color: AppTheme.primary),
            const SizedBox(width: 8),
            const Text('Prayer Alerts', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ],
        ),
        const SizedBox(height: 12),
        ..._prayerAlerts.keys.map((prayer) {
          final isEnabled = _prayerAlerts[prayer] ?? false;
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isEnabled ? AppTheme.primary.withAlpha(50) : AppTheme.surfaceLight,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isEnabled ? AppTheme.primary.withAlpha(25) : AppTheme.backgroundDark,
                  ),
                  child: Icon(
                    _prayerIcons[prayer],
                    size: 20,
                    color: isEnabled ? AppTheme.primary : Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(prayer, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(_prayerTimes[prayer] ?? '', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
                    ],
                  ),
                ),
                if (isEnabled)
                  GestureDetector(
                    onTap: () => _showNotificationTypePicker(prayer),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundDark,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _notificationType[prayer] ?? 'Adhan',
                        style: TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Switch(
                  value: isEnabled,
                  onChanged: (v) => setState(() => _prayerAlerts[prayer] = v),
                  activeThumbColor: AppTheme.primary,
                  activeTrackColor: AppTheme.primary.withAlpha(76),
                  inactiveThumbColor: Colors.grey[600],
                  inactiveTrackColor: AppTheme.backgroundDark,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  void _showNotificationTypePicker(String prayer) {
    final types = ['Adhan', 'Vibrate', 'Silent', 'Sound'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surfaceDark2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notification Type - $prayer', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 12),
            ...types.map((type) => ListTile(
              leading: Icon(
                type == 'Adhan' ? Icons.volume_up :
                type == 'Vibrate' ? Icons.vibration :
                type == 'Silent' ? Icons.volume_off : Icons.music_note,
                color: _notificationType[prayer] == type ? AppTheme.primary : Colors.grey[400],
              ),
              title: Text(type, style: TextStyle(color: _notificationType[prayer] == type ? Colors.white : Colors.grey[400])),
              trailing: _notificationType[prayer] == type
                  ? Icon(Icons.check_circle, color: AppTheme.primary)
                  : null,
              onTap: () {
                setState(() => _notificationType[prayer] = type);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }
}
