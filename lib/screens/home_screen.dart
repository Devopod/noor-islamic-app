import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../models/dhikr.dart';
import '../providers/tasbeeh_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_theme.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _locationName = 'Loading...';
  String _nextPrayerName = '--';
  String _nextPrayerTime = '--:--';
  Map<String, String> _prayerTimes = {};
  bool _timerRunning = false;
  int _timerInterval = 2;

  @override
  void initState() {
    super.initState();
    _fetchPrayerTimes();
  }

  Future<void> _fetchPrayerTimes() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) { setState(() => _locationName = 'Location off'); return; }
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) { setState(() => _locationName = 'Permission denied'); return; }
      }
      if (permission == LocationPermission.deniedForever) { setState(() => _locationName = 'Permission denied'); return; }
      final position = await Geolocator.getCurrentPosition(locationSettings: const LocationSettings(accuracy: LocationAccuracy.high));
      final url = Uri.parse('https://api.aladhan.com/v1/timings?latitude=${position.latitude}&longitude=${position.longitude}&method=3&school=1');
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final timings = data['data']['timings'] as Map<String, dynamic>;
        setState(() {
          _locationName = '${position.latitude.toStringAsFixed(1)}\u00b0N, ${position.longitude.toStringAsFixed(1)}\u00b0E';
          _prayerTimes = { 'Fajr': timings['Fajr'] as String, 'Sunrise': timings['Sunrise'] as String, 'Dhuhr': timings['Dhuhr'] as String, 'Asr': timings['Asr'] as String, 'Maghrib': timings['Maghrib'] as String, 'Isha': timings['Isha'] as String };
        });
        _calculateNextPrayer();
      }
    } catch (_) { setState(() => _locationName = 'Unavailable'); }
  }

  void _calculateNextPrayer() {
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    for (final entry in _prayerTimes.entries) {
      if (entry.key == 'Sunrise') continue;
      final parts = entry.value.split(':');
      if (parts.length == 2) {
        final prayerMinutes = int.parse(parts[0]) * 60 + int.parse(parts[1]);
        if (prayerMinutes > nowMinutes) {
          final h = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final period = h >= 12 ? 'PM' : 'AM';
          final displayH = h > 12 ? h - 12 : (h == 0 ? 12 : h);
          setState(() { _nextPrayerName = entry.key; _nextPrayerTime = '$displayH:${m.toString().padLeft(2, '0')} $period'; });
          return;
        }
      }
    }
    if (_prayerTimes.isNotEmpty) {
      final first = _prayerTimes.entries.first;
      setState(() { _nextPrayerName = first.key; _nextPrayerTime = first.value; });
    }
  }

  void _startTimer(TasbeehProvider tasbeeh) { setState(() => _timerRunning = true); _runTimerLoop(tasbeeh); }
  void _stopTimer() { setState(() => _timerRunning = false); }

  Future<void> _runTimerLoop(TasbeehProvider tasbeeh) async {
    while (_timerRunning && mounted) {
      await Future.delayed(Duration(seconds: _timerInterval));
      if (_timerRunning && mounted && tasbeeh.activeDhikr.count < tasbeeh.activeDhikr.target) { HapticFeedback.lightImpact(); tasbeeh.increment(); }
      else { _stopTimer(); }
    }
  }

  @override
  void dispose() { _timerRunning = false; super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeProvider>().isDarkMode;
    return Consumer<TasbeehProvider>(
      builder: (context, tasbeeh, _) {
        return CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, isDark)),
            SliverToBoxAdapter(child: _buildDailyVerse(isDark)),
            SliverToBoxAdapter(child: _buildTasbeehCounter(tasbeeh, isDark)),
            SliverToBoxAdapter(child: _buildTimerSection(tasbeeh, isDark)),
            SliverToBoxAdapter(child: _buildActionButtons(context, tasbeeh, isDark)),
            SliverToBoxAdapter(child: _buildDhikrList(context, tasbeeh, isDark)),
            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
        border: Border(bottom: BorderSide(color: isDark ? AppTheme.surfaceLight.withAlpha(128) : Colors.grey.withAlpha(50))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.location_on, size: 16, color: isDark ? Colors.grey[400] : Colors.grey[600]),
              const SizedBox(width: 4),
              Text('LOCATION', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[600], letterSpacing: 1.2)),
            ]),
            const SizedBox(height: 4),
            Text(_locationName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
          ])),
          Row(children: [
            GestureDetector(
              onTap: () => context.read<ThemeProvider>().toggleTheme(),
              child: Container(width: 36, height: 36, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(shape: BoxShape.circle, color: isDark ? AppTheme.surfaceDark2 : Colors.grey[200]), child: Icon(isDark ? Icons.light_mode : Icons.dark_mode, size: 18, color: isDark ? AppTheme.primary : AppTheme.primaryDark)),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark2 : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: isDark ? AppTheme.surfaceLight : Colors.grey.withAlpha(76))),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text('NEXT', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text('$_nextPrayerName $_nextPrayerTime', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
                ]),
                const SizedBox(width: 6),
                Container(width: 28, height: 28, decoration: BoxDecoration(color: AppTheme.primary.withAlpha(25), shape: BoxShape.circle), child: Icon(Icons.schedule, size: 16, color: AppTheme.primary)),
              ]),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildDailyVerse(bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: isDark ? [const Color(0xFF162E1C), const Color(0xFF0F2415)] : [const Color(0xFFE8F5E9), const Color(0xFFDCEDC8)]),
          border: Border.all(color: isDark ? AppTheme.surfaceLight : Colors.green.withAlpha(50)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Row(children: [Container(width: 3, height: 16, decoration: BoxDecoration(color: AppTheme.secondary, borderRadius: BorderRadius.circular(2))), const SizedBox(width: 8), Text('DAILY VERSE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.secondary, letterSpacing: 2))]),
              Icon(Icons.share, size: 18, color: isDark ? Colors.grey[400] : Colors.grey[600]),
            ]),
            Padding(padding: const EdgeInsets.only(top: 12, bottom: 8), child: Container(height: 1, color: isDark ? Colors.white.withAlpha(25) : Colors.black.withAlpha(13))),
            const Text('\u0625\u0650\u0646\u0651\u064e \u0627\u0644\u0644\u0651\u064e\u0647\u064e \u0648\u064e\u0645\u064e\u0644\u064e\u0627\u0626\u0650\u0643\u064e\u062a\u064e\u0647\u064f \u064a\u064f\u0635\u064e\u0644\u0651\u064f\u0648\u0646\u064e \u0639\u064e\u0644\u064e\u0649 \u0627\u0644\u0646\u0651\u064e\u0628\u0650\u064a\u0651\u0650', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, height: 1.8, color: Colors.white)),
            const SizedBox(height: 8),
            Text('"Indeed, Allah and His angels send blessings upon the Prophet."', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: isDark ? Colors.grey[300] : Colors.grey[700], height: 1.5)),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: AppTheme.primary.withAlpha(25), borderRadius: BorderRadius.circular(4)), child: Text('SURAH AL-AHZAB 33:56', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.primary, letterSpacing: 0.5))),
              Row(children: [Text('Read More', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))), const SizedBox(width: 4), Icon(Icons.arrow_forward, size: 14, color: isDark ? Colors.white : const Color(0xFF1A3A22))]),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _buildTasbeehCounter(TasbeehProvider tasbeeh, bool isDark) {
    final dhikr = tasbeeh.activeDhikr;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(children: [
        Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), decoration: BoxDecoration(color: AppTheme.primary.withAlpha(25), borderRadius: BorderRadius.circular(20)), child: Text('CURRENT DHIKR', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primary, letterSpacing: 1.5))),
        const SizedBox(height: 8),
        Text(dhikr.name, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
        const SizedBox(height: 4),
        Text(dhikr.translation, style: TextStyle(fontSize: 13, color: isDark ? Colors.grey[400] : Colors.grey[600])),
        const SizedBox(height: 24),
        GestureDetector(
          onTap: () { HapticFeedback.lightImpact(); tasbeeh.increment(); },
          child: SizedBox(width: 240, height: 240, child: Stack(alignment: Alignment.center, children: [
            Container(width: 260, height: 260, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: AppTheme.primary.withAlpha(13), blurRadius: 60, spreadRadius: 20)])),
            CustomPaint(size: const Size(240, 240), painter: _ProgressRingPainter(progress: dhikr.progress, primaryColor: AppTheme.primary, trackColor: isDark ? AppTheme.surfaceDark2 : Colors.grey[200]!)),
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('${dhikr.count}', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w800, color: isDark ? Colors.white : const Color(0xFF1A3A22), letterSpacing: -2)),
              Container(width: 32, height: 1, color: isDark ? Colors.grey[600] : Colors.grey[400], margin: const EdgeInsets.symmetric(vertical: 8)),
              Text('Target: ${dhikr.target}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[500] : Colors.grey[600])),
            ]),
          ])),
        ),
        const SizedBox(height: 8),
        Text(_timerRunning ? 'Auto-counting...' : 'Tap to Count', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: _timerRunning ? AppTheme.secondary : AppTheme.primary.withAlpha(128))),
      ]),
    );
  }

  Widget _buildTimerSection(TasbeehProvider tasbeeh, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark2 : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: isDark ? AppTheme.surfaceLight : Colors.grey.withAlpha(50))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [Icon(Icons.timer, size: 18, color: AppTheme.secondary), const SizedBox(width: 8), Text('Auto Tasbeeh Timer', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22)))]),
            GestureDetector(
              onTap: () { if (_timerRunning) { _stopTimer(); } else { _startTimer(tasbeeh); } },
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: _timerRunning ? Colors.red.withAlpha(25) : AppTheme.primary.withAlpha(25), borderRadius: BorderRadius.circular(20), border: Border.all(color: _timerRunning ? Colors.red.withAlpha(76) : AppTheme.primary.withAlpha(76))), child: Text(_timerRunning ? 'Stop' : 'Start', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: _timerRunning ? Colors.red : AppTheme.primary))),
            ),
          ]),
          const SizedBox(height: 12),
          Text('Interval: $_timerInterval seconds', style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
          const SizedBox(height: 8),
          Row(children: [for (final sec in [1, 2, 3, 5, 10]) Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(onTap: _timerRunning ? null : () => setState(() => _timerInterval = sec), child: Container(width: 40, height: 32, decoration: BoxDecoration(color: _timerInterval == sec ? AppTheme.primary.withAlpha(50) : (isDark ? AppTheme.backgroundDark : Colors.grey[200]), borderRadius: BorderRadius.circular(8), border: _timerInterval == sec ? Border.all(color: AppTheme.primary.withAlpha(128)) : null), child: Center(child: Text('${sec}s', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: _timerInterval == sec ? AppTheme.primary : (isDark ? Colors.grey[400] : Colors.grey[600])))))))]),
        ]),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, TasbeehProvider tasbeeh, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 24),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _actionBtn(Icons.restart_alt, () { _stopTimer(); tasbeeh.reset(); }, isDark),
        const SizedBox(width: 24),
        _actionBtn(Icons.save, () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Progress saved!'), backgroundColor: AppTheme.surfaceDark2, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)))); }, isDark),
        const SizedBox(width: 24),
        _actionBtn(Icons.settings, () {}, isDark),
      ]),
    );
  }

  Widget _actionBtn(IconData icon, VoidCallback onTap, bool isDark) {
    return GestureDetector(onTap: onTap, child: Container(width: 48, height: 48, decoration: BoxDecoration(color: isDark ? AppTheme.surfaceDark2 : Colors.white, shape: BoxShape.circle, border: Border.all(color: isDark ? AppTheme.surfaceLight : Colors.grey.withAlpha(76))), child: Icon(icon, size: 22, color: isDark ? Colors.grey[400] : Colors.grey[600])));
  }

  Widget _buildDhikrList(BuildContext context, TasbeehProvider tasbeeh, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('Your Dhikrs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : const Color(0xFF1A3A22))),
          GestureDetector(onTap: () => _showAddDhikrDialog(context, tasbeeh), child: Row(children: [Icon(Icons.add, size: 18, color: AppTheme.primary), const SizedBox(width: 4), Text('Add New', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.primary))])),
        ]),
        const SizedBox(height: 16),
        ...List.generate(tasbeeh.dhikrs.length, (index) {
          final dhikr = tasbeeh.dhikrs[index];
          final isActive = index == tasbeeh.activeIndex;
          return GestureDetector(
            onTap: () => tasbeeh.setActive(index),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(color: isDark ? (isActive ? AppTheme.surfaceDark2 : AppTheme.surfaceDark) : (isActive ? Colors.white : Colors.grey[50]), borderRadius: BorderRadius.circular(16), border: Border.all(color: isActive ? AppTheme.primary.withAlpha(76) : (isDark ? AppTheme.surfaceLight : Colors.grey.withAlpha(50)))),
              child: Stack(children: [
                if (isActive) Positioned(right: 0, top: 0, bottom: 0, child: Container(width: 3, decoration: BoxDecoration(color: AppTheme.primary, borderRadius: const BorderRadius.only(topRight: Radius.circular(16), bottomRight: Radius.circular(16))))),
                Padding(padding: const EdgeInsets.all(16), child: Row(children: [
                  Container(width: 40, height: 40, decoration: BoxDecoration(color: isActive ? AppTheme.primary.withAlpha(25) : (isDark ? const Color(0xFF112215) : Colors.grey[100]), shape: BoxShape.circle), child: Icon(Icons.spa, size: 20, color: isActive ? AppTheme.primary : (isDark ? Colors.grey[500] : Colors.grey[400]))),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(dhikr.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: isDark ? (isActive ? Colors.white : Colors.grey[200]) : (isActive ? const Color(0xFF1A3A22) : Colors.grey[800]))),
                    const SizedBox(height: 2),
                    Text(dhikr.translation, style: TextStyle(fontSize: 12, color: isDark ? Colors.grey[400] : Colors.grey[600])),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text('${dhikr.target}', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: isActive ? AppTheme.primary : (isDark ? Colors.grey[600] : Colors.grey[400]))),
                    Text('TARGET', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w600, color: isDark ? Colors.grey[400] : Colors.grey[500], letterSpacing: 1)),
                  ]),
                ])),
              ]),
            ),
          );
        }),
      ]),
    );
  }

  void _showAddDhikrDialog(BuildContext context, TasbeehProvider tasbeeh) {
    final nc = TextEditingController();
    final tc = TextEditingController();
    final tgc = TextEditingController(text: '33');
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: AppTheme.surfaceDark2,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Add New Dhikr', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 16),
          TextField(controller: nc, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Dhikr Name', hintStyle: TextStyle(color: Colors.grey[600]))),
          const SizedBox(height: 12),
          TextField(controller: tc, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Translation', hintStyle: TextStyle(color: Colors.grey[600]))),
          const SizedBox(height: 12),
          TextField(controller: tgc, keyboardType: TextInputType.number, style: const TextStyle(color: Colors.white), decoration: InputDecoration(hintText: 'Target Count', hintStyle: TextStyle(color: Colors.grey[600]))),
          const SizedBox(height: 20),
          SizedBox(width: double.infinity, child: ElevatedButton(
            onPressed: () { if (nc.text.isNotEmpty) { tasbeeh.addDhikr(Dhikr(id: DateTime.now().millisecondsSinceEpoch.toString(), name: nc.text, translation: tc.text, target: int.tryParse(tgc.text) ?? 33)); Navigator.pop(ctx); } },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Add Dhikr', style: TextStyle(fontWeight: FontWeight.bold)),
          )),
        ]),
      ),
    );
  }
}

class _ProgressRingPainter extends CustomPainter {
  final double progress;
  final Color primaryColor;
  final Color trackColor;
  _ProgressRingPainter({required this.progress, required this.primaryColor, required this.trackColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 12;
    final trackPaint = Paint()..color = trackColor..style = PaintingStyle.stroke..strokeWidth = 10;
    canvas.drawCircle(center, radius, trackPaint);
    final progressPaint = Paint()..color = primaryColor..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -pi / 2, 2 * pi * progress, false, progressPaint);
    final innerPaint = Paint()..color = AppTheme.surfaceDark.withAlpha(128)..style = PaintingStyle.stroke..strokeWidth = 1;
    final innerRadius = radius - 16;
    for (int i = 0; i < 60; i++) {
      final angle = 2 * pi * i / 60;
      canvas.drawLine(Offset(center.dx + innerRadius * cos(angle), center.dy + innerRadius * sin(angle)), Offset(center.dx + (innerRadius + 4) * cos(angle), center.dy + (innerRadius + 4) * sin(angle)), innerPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ProgressRingPainter oldDelegate) => oldDelegate.progress != progress;
}
