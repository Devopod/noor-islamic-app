import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class HijriCalendarScreen extends StatefulWidget {
  const HijriCalendarScreen({super.key});

  @override
  State<HijriCalendarScreen> createState() => _HijriCalendarScreenState();
}

class _HijriCalendarScreenState extends State<HijriCalendarScreen> {
  late HijriCalendar _currentHijri;
  late int _displayMonth;
  late int _displayYear;
  String _apiHijriDate = '';

  final Map<String, List<_IslamicEvent>> _events = {
    '1-1': [_IslamicEvent('Islamic New Year', 'Beginning of the Hijri calendar year', Icons.celebration)],
    '1-10': [_IslamicEvent('Ashura', 'Day of Ashura - Fasting recommended', Icons.local_fire_department)],
    '3-12': [_IslamicEvent('Mawlid al-Nabi', 'Birth of Prophet Muhammad (PBUH)', Icons.mosque)],
    '7-27': [_IslamicEvent('Isra & Miraj', 'Night Journey & Ascension', Icons.nights_stay)],
    '8-15': [_IslamicEvent('Shab-e-Barat', 'Night of Fortune & Forgiveness', Icons.stars)],
    '9-1': [_IslamicEvent('Ramadan Begins', 'Start of the holy month of fasting', Icons.brightness_3)],
    '9-27': [_IslamicEvent('Laylat al-Qadr', 'Night of Power - Better than 1000 months', Icons.auto_awesome)],
    '10-1': [_IslamicEvent('Eid al-Fitr', 'Festival of Breaking the Fast', Icons.celebration)],
    '12-8': [_IslamicEvent('Day of Arafah', 'Day of Arafah - Fasting recommended', Icons.terrain)],
    '12-10': [_IslamicEvent('Eid al-Adha', 'Festival of Sacrifice', Icons.celebration)],
  };

  @override
  void initState() {
    super.initState();
    _currentHijri = HijriCalendar.now();
    _displayMonth = _currentHijri.hMonth;
    _displayYear = _currentHijri.hYear;
    _fetchHijriDate();
  }

  Future<void> _fetchHijriDate() async {
    try {
      final now = DateTime.now();
      final dateStr = '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
      final url = Uri.parse('https://api.aladhan.com/v1/gpiToH/$dateStr');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final hijri = data['data']['hijri'];
        if (mounted) {
          setState(() {
            _apiHijriDate = '${hijri['day']} ${hijri['month']['en']} ${hijri['year']} AH';
          });
        }
      }
    } catch (_) {}
  }

  void _previousMonth() {
    setState(() {
      if (_displayMonth == 1) { _displayMonth = 12; _displayYear--; }
      else { _displayMonth--; }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_displayMonth == 12) { _displayMonth = 1; _displayYear++; }
      else { _displayMonth++; }
    });
  }

  String _getMonthName(int month) {
    const months = ['Muharram', 'Safar', 'Rabi al-Awwal', 'Rabi al-Thani', 'Jumada al-Ula', 'Jumada al-Thani', 'Rajab', 'Shaban', 'Ramadan', 'Shawwal', 'Dhul Qadah', 'Dhul Hijjah'];
    return months[(month - 1) % 12];
  }

  List<_IslamicEvent> _getEventsForDay(int day) {
    final key = '$_displayMonth-$day';
    return _events[key] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(isDark),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  if (_apiHijriDate.isNotEmpty) _buildApiDateBanner(isDark),
                  _buildDateNavigation(isDark),
                  const SizedBox(height: 16),
                  _buildCalendarGrid(isDark),
                  const SizedBox(height: 24),
                  _buildUpcomingEvents(isDark),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        border: Border(bottom: BorderSide(color: isDark ? AppTheme.surfaceLight.withAlpha(128) : Colors.grey.withAlpha(50))),
      ),
      child: Row(children: [
        GestureDetector(onTap: () => Navigator.pop(context), child: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
        const SizedBox(width: 16),
        Expanded(child: Text('Hijri Calendar', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22)))),
        GestureDetector(
          onTap: () { setState(() { _displayMonth = _currentHijri.hMonth; _displayYear = _currentHijri.hYear; }); },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: AppTheme.primary.withAlpha(25), borderRadius: BorderRadius.circular(8)),
            child: Text('Today', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
          ),
        ),
      ]),
    );
  }

  Widget _buildApiDateBanner(bool isDark) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.primary.withAlpha(20) : AppTheme.primary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primary.withAlpha(50)),
      ),
      child: Row(children: [
        Icon(Icons.today, size: 20, color: AppTheme.primary),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Today's Hijri Date", style: TextStyle(fontSize: 11, color: isDark ? Colors.grey[400] : Colors.grey[600], fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(_apiHijriDate, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.primary.withAlpha(25), borderRadius: BorderRadius.circular(6)),
          child: Text('API', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary)),
        ),
      ]),
    );
  }

  Widget _buildDateNavigation(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(
          onTap: _previousMonth,
          child: Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? AppTheme.surfaceDark2 : Colors.grey[200], border: Border.all(color: isDark ? AppTheme.surfaceLight : Colors.grey.withAlpha(50))), child: Icon(Icons.chevron_left, color: isDark ? Colors.white : const Color(0xFF1A3A22), size: 20)),
        ),
        Column(children: [
          Text(_getMonthName(_displayMonth), style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
          Text('$_displayYear AH', style: TextStyle(fontSize: 13, color: AppTheme.primary)),
        ]),
        GestureDetector(
          onTap: _nextMonth,
          child: Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? AppTheme.surfaceDark2 : Colors.grey[200], border: Border.all(color: isDark ? AppTheme.surfaceLight : Colors.grey.withAlpha(50))), child: Icon(Icons.chevron_right, color: isDark ? Colors.white : const Color(0xFF1A3A22), size: 20)),
        ),
      ]),
    );
  }

  Widget _buildCalendarGrid(bool isDark) {
    const weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final daysInMonth = HijriCalendar().getDaysInMonth(_displayYear, _displayMonth);
    final firstDay = DateTime(2024, _displayMonth, 1).weekday;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark2 : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppTheme.surfaceLight : Colors.grey.withAlpha(50))),
      child: Column(children: [
        Row(children: weekDays.map((d) => Expanded(child: Center(child: Text(d, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: d == 'Fri' ? AppTheme.primary : Colors.grey[500]))))).toList()),
        const SizedBox(height: 10),
        ...List.generate(((firstDay - 1 + daysInMonth) / 7).ceil(), (week) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(children: List.generate(7, (dayOfWeek) {
              final dayNum = week * 7 + dayOfWeek - firstDay + 2;
              if (dayNum < 1 || dayNum > daysInMonth) return const Expanded(child: SizedBox(height: 40));
              final isToday = dayNum == _currentHijri.hDay && _displayMonth == _currentHijri.hMonth && _displayYear == _currentHijri.hYear;
              final events = _getEventsForDay(dayNum);
              final hasEvent = events.isNotEmpty;
              return Expanded(child: GestureDetector(
                onTap: hasEvent ? () => _showEventDetails(dayNum, events) : null,
                child: Container(
                  height: 40, margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: isToday ? AppTheme.primary : hasEvent ? AppTheme.secondary.withAlpha(50) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: hasEvent && !isToday ? Border.all(color: AppTheme.secondary.withAlpha(76)) : null,
                  ),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('$dayNum', style: TextStyle(fontSize: 13, fontWeight: isToday || hasEvent ? FontWeight.bold : FontWeight.w500, color: isToday ? AppTheme.backgroundDark : hasEvent ? AppTheme.secondary : (isDark ? Colors.white : const Color(0xFF1A3A22)))),
                    if (hasEvent && !isToday) Container(width: 4, height: 4, margin: const EdgeInsets.only(top: 2), decoration: BoxDecoration(shape: BoxShape.circle, color: AppTheme.secondary)),
                  ]),
                ),
              ));
            })),
          );
        }),
      ]),
    );
  }

  Widget _buildUpcomingEvents(bool isDark) {
    final allEvents = <MapEntry<String, _IslamicEvent>>[];
    _events.forEach((key, events) { for (final event in events) { allEvents.add(MapEntry(key, event)); } });

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Upcoming Events', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
      const SizedBox(height: 12),
      ...allEvents.take(5).map((entry) {
        final parts = entry.key.split('-');
        final month = int.parse(parts[0]);
        final day = int.parse(parts[1]);
        final event = entry.value;
        final isUpcoming = month > _currentHijri.hMonth || (month == _currentHijri.hMonth && day >= _currentHijri.hDay);
        if (!isUpcoming && month < _currentHijri.hMonth) return const SizedBox.shrink();

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark2 : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isDark ? AppTheme.surfaceLight.withAlpha(128) : Colors.grey.withAlpha(50))),
          child: Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: AppTheme.secondary.withAlpha(25), borderRadius: BorderRadius.circular(12)), child: Icon(event.icon, size: 24, color: AppTheme.secondary)),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(event.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
              const SizedBox(height: 2),
              Text(event.description, style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('$day', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.secondary)),
              Text(_getMonthName(month).split(' ').first, style: TextStyle(fontSize: 10, color: Colors.grey[400])),
            ]),
          ]),
        );
      }),
    ]);
  }

  void _showEventDetails(int day, List<_IslamicEvent> events) {
    showModalBottomSheet(
      context: context, backgroundColor: AppTheme.surfaceDark2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          Text('$day ${_getMonthName(_displayMonth)} $_displayYear AH', style: TextStyle(fontSize: 14, color: AppTheme.primary)),
          const SizedBox(height: 12),
          ...events.map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(children: [
              Icon(e.icon, size: 28, color: AppTheme.secondary),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(e.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text(e.description, style: TextStyle(fontSize: 13, color: Colors.grey[400])),
              ])),
            ]),
          )),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }
}

class _IslamicEvent {
  final String name;
  final String description;
  final IconData icon;
  const _IslamicEvent(this.name, this.description, this.icon);
}
