import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/dhikr.dart';

class TasbeehProvider extends ChangeNotifier {
  List<Dhikr> _dhikrs = [];
  int _activeIndex = 0;

  List<Dhikr> get dhikrs => _dhikrs;
  int get activeIndex => _activeIndex;
  Dhikr get activeDhikr => _dhikrs.isNotEmpty ? _dhikrs[_activeIndex] : Dhikr(id: '0', name: 'SubhanAllah', translation: 'Glory be to Allah', target: 33);

  TasbeehProvider() {
    _initDefaults();
    _loadData();
  }

  void _initDefaults() {
    _dhikrs = [
      Dhikr(id: '1', name: 'SubhanAllah', translation: 'Glory be to Allah', arabic: 'سُبْحَانَ اللَّهِ', target: 33),
      Dhikr(id: '2', name: 'Alhamdulillah', translation: 'All praise is due to Allah', arabic: 'الْحَمْدُ لِلَّهِ', target: 33),
      Dhikr(id: '3', name: 'Allahu Akbar', translation: 'Allah is the Greatest', arabic: 'اللَّهُ أَكْبَرُ', target: 34),
      Dhikr(id: '4', name: 'Astaghfirullah', translation: 'I seek forgiveness from Allah', arabic: 'أَسْتَغْفِرُ اللَّهَ', target: 100),
      Dhikr(id: '5', name: 'La ilaha illallah', translation: 'There is no god but Allah', arabic: 'لَا إِلَٰهَ إِلَّا اللَّهُ', target: 100),
    ];
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('tasbeeh_data');
    if (data != null) {
      final List<dynamic> jsonList = json.decode(data) as List<dynamic>;
      _dhikrs = jsonList.map((e) => Dhikr.fromJson(e as Map<String, dynamic>)).toList();
      _activeIndex = prefs.getInt('active_dhikr_index') ?? 0;
      if (_activeIndex >= _dhikrs.length) _activeIndex = 0;
      notifyListeners();
    }
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('tasbeeh_data', json.encode(_dhikrs.map((e) => e.toJson()).toList()));
    await prefs.setInt('active_dhikr_index', _activeIndex);
  }

  void increment() {
    if (_dhikrs.isNotEmpty && activeDhikr.count < activeDhikr.target) {
      activeDhikr.count++;
      notifyListeners();
      _saveData();
    }
  }

  void reset() {
    if (_dhikrs.isNotEmpty) {
      activeDhikr.count = 0;
      notifyListeners();
      _saveData();
    }
  }

  void setActive(int index) {
    if (index >= 0 && index < _dhikrs.length) {
      _activeIndex = index;
      notifyListeners();
      _saveData();
    }
  }

  void addDhikr(Dhikr dhikr) {
    _dhikrs.add(dhikr);
    notifyListeners();
    _saveData();
  }

  void removeDhikr(int index) {
    if (index >= 0 && index < _dhikrs.length) {
      _dhikrs.removeAt(index);
      if (_activeIndex >= _dhikrs.length) {
        _activeIndex = _dhikrs.isEmpty ? 0 : _dhikrs.length - 1;
      }
      notifyListeners();
      _saveData();
    }
  }

  void updateTarget(int index, int newTarget) {
    if (index >= 0 && index < _dhikrs.length) {
      _dhikrs[index].target = newTarget;
      notifyListeners();
      _saveData();
    }
  }

  double get dailyProgress {
    if (_dhikrs.isEmpty) return 0.0;
    final total = _dhikrs.fold<int>(0, (sum, d) => sum + d.target);
    final done = _dhikrs.fold<int>(0, (sum, d) => sum + d.count);
    return total > 0 ? (done / total).clamp(0.0, 1.0) : 0.0;
  }
}
