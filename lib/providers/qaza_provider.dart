import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/prayer.dart';

class QazaProvider extends ChangeNotifier {
  List<QazaPrayer> _namazPrayers = [];
  List<QazaPrayer> _rozaFasts = [];
  bool _isNamaz = true;

  List<QazaPrayer> get prayers => _isNamaz ? _namazPrayers : _rozaFasts;
  bool get isNamaz => _isNamaz;

  QazaProvider() {
    _initDefaults();
    _loadData();
  }

  void _initDefaults() {
    _namazPrayers = [
      QazaPrayer(name: 'Fajr', icon: 'wb_twilight', rakats: 2, totalMissed: 500, offered: 100),
      QazaPrayer(name: 'Dhuhr', icon: 'light_mode', rakats: 4, totalMissed: 462, offered: 42),
      QazaPrayer(name: 'Asr', icon: 'wb_sunny', rakats: 4, totalMissed: 462, offered: 14),
      QazaPrayer(name: 'Maghrib', icon: 'nights_stay', rakats: 3, totalMissed: 462, offered: 7),
      QazaPrayer(name: 'Isha', icon: 'dark_mode', rakats: 4, totalMissed: 462, offered: 22),
      QazaPrayer(name: 'Witr', icon: 'star', rakats: 3, totalMissed: 462, offered: 2),
    ];
    _rozaFasts = [
      QazaPrayer(name: 'Ramadan Fasts', icon: 'brightness_3', rakats: 0, totalMissed: 30, offered: 0),
      QazaPrayer(name: 'Shawwal Fasts', icon: 'light_mode', rakats: 0, totalMissed: 6, offered: 0),
      QazaPrayer(name: 'Monday Fasts', icon: 'wb_sunny', rakats: 0, totalMissed: 52, offered: 0),
      QazaPrayer(name: 'Thursday Fasts', icon: 'wb_sunny', rakats: 0, totalMissed: 52, offered: 0),
      QazaPrayer(name: 'Ayyam al-Bidh', icon: 'nights_stay', rakats: 0, totalMissed: 36, offered: 0),
      QazaPrayer(name: 'Day of Arafah', icon: 'terrain', rakats: 0, totalMissed: 1, offered: 0),
      QazaPrayer(name: 'Ashura Fasts', icon: 'star', rakats: 0, totalMissed: 2, offered: 0),
    ];
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final namazData = prefs.getString('qaza_namaz_data');
    if (namazData != null) {
      final List<dynamic> jsonList = json.decode(namazData) as List<dynamic>;
      _namazPrayers = jsonList.map((e) => QazaPrayer.fromJson(e as Map<String, dynamic>)).toList();
    }
    final rozaData = prefs.getString('qaza_roza_data');
    if (rozaData != null) {
      final List<dynamic> jsonList = json.decode(rozaData) as List<dynamic>;
      _rozaFasts = jsonList.map((e) => QazaPrayer.fromJson(e as Map<String, dynamic>)).toList();
    }
    _isNamaz = prefs.getBool('qaza_is_namaz') ?? true;
    notifyListeners();
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('qaza_namaz_data', json.encode(_namazPrayers.map((e) => e.toJson()).toList()));
    await prefs.setString('qaza_roza_data', json.encode(_rozaFasts.map((e) => e.toJson()).toList()));
    await prefs.setBool('qaza_is_namaz', _isNamaz);
  }

  void toggleMode() {
    _isNamaz = !_isNamaz;
    notifyListeners();
    _saveData();
  }

  void incrementOffered(int index) {
    final list = _isNamaz ? _namazPrayers : _rozaFasts;
    if (index >= 0 && index < list.length) {
      final prayer = list[index];
      if (prayer.offered < prayer.totalMissed) {
        prayer.offered++;
        notifyListeners();
        _saveData();
      }
    }
  }

  void decrementOffered(int index) {
    final list = _isNamaz ? _namazPrayers : _rozaFasts;
    if (index >= 0 && index < list.length) {
      final prayer = list[index];
      if (prayer.offered > 0) {
        prayer.offered--;
        notifyListeners();
        _saveData();
      }
    }
  }

  void updateMissedCount(int index, int newTotal) {
    final list = _isNamaz ? _namazPrayers : _rozaFasts;
    if (index >= 0 && index < list.length) {
      list[index].totalMissed = newTotal;
      if (list[index].offered > newTotal) list[index].offered = newTotal;
      notifyListeners();
      _saveData();
    }
  }

  void resetAll() {
    final list = _isNamaz ? _namazPrayers : _rozaFasts;
    for (final prayer in list) {
      prayer.offered = 0;
    }
    notifyListeners();
    _saveData();
  }

  int get totalRemaining => prayers.fold<int>(0, (sum, p) => sum + p.remaining);
  int get totalOffered => prayers.fold<int>(0, (sum, p) => sum + p.offered);
  int get totalMissed => prayers.fold<int>(0, (sum, p) => sum + p.totalMissed);
  double get overallProgress => totalMissed > 0 ? (totalOffered / totalMissed).clamp(0.0, 1.0) : 0.0;
}
