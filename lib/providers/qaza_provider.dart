import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer.dart';

class QazaProvider extends ChangeNotifier {
  List<QazaPrayer> _prayers = [];
  bool _isNamaz = true;

  List<QazaPrayer> get prayers => _prayers;
  bool get isNamaz => _isNamaz;

  QazaProvider() {
    _initDefaults();
    _loadData();
  }

  void _initDefaults() {
    _prayers = [
      QazaPrayer(name: 'Fajr', icon: 'wb_twilight', rakats: 2, totalMissed: 500, offered: 100),
      QazaPrayer(name: 'Dhuhr', icon: 'light_mode', rakats: 4, totalMissed: 462, offered: 42),
      QazaPrayer(name: 'Asr', icon: 'wb_sunny', rakats: 4, totalMissed: 462, offered: 14),
      QazaPrayer(name: 'Maghrib', icon: 'nights_stay', rakats: 3, totalMissed: 462, offered: 7),
      QazaPrayer(name: 'Isha', icon: 'dark_mode', rakats: 4, totalMissed: 462, offered: 22),
      QazaPrayer(name: 'Witr', icon: 'star', rakats: 3, totalMissed: 462, offered: 2),
    ];
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('qaza_data');
    if (data != null) {
      final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
      _prayers = jsonList.map((e) => QazaPrayer.fromJson(e as Map<String, dynamic>)).toList();
      _isNamaz = prefs.getBool('qaza_is_namaz') ?? true;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('qaza_data', json.encode(_prayers.map((e) => e.toJson()).toList()));
    await prefs.setBool('qaza_is_namaz', _isNamaz);
  }

  void toggleMode() {
    _isNamaz = !_isNamaz;
    notifyListeners();
  }

  void incrementOffered(int index) {
    if (index >= 0 && index < _prayers.length) {
      final prayer = _prayers[index];
      if (prayer.offered < prayer.totalMissed) {
        prayer.offered++;
        notifyListeners();
        _saveData();
      }
    }
  }

  void decrementOffered(int index) {
    if (index >= 0 && index < _prayers.length) {
      final prayer = _prayers[index];
      if (prayer.offered > 0) {
        prayer.offered--;
        notifyListeners();
        _saveData();
      }
    }
  }

  void resetAll() {
    for (final prayer in _prayers) {
      prayer.offered = 0;
    }
    notifyListeners();
    _saveData();
  }

  int get totalRemaining => _prayers.fold<int>(0, (sum, p) => sum + p.remaining);
  int get totalOffered => _prayers.fold<int>(0, (sum, p) => sum + p.offered);
  int get totalMissed => _prayers.fold<int>(0, (sum, p) => sum + p.totalMissed);
  double get overallProgress => totalMissed > 0 ? (totalOffered / totalMissed).clamp(0.0, 1.0) : 0.0;
}
