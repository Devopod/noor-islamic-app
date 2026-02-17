import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/quran_data.dart';

class QuranProvider extends ChangeNotifier {
  final List<Surah> _surahs = surahs;
  List<Ayah> _currentAyahs = [];
  bool _isLoading = false;
  String _searchQuery = '';
  int? _currentSurahNumber;

  List<Surah> get filteredSurahs {
    if (_searchQuery.isEmpty) return _surahs;
    return _surahs.where((s) =>
      s.englishName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      s.name.contains(_searchQuery) ||
      s.number.toString() == _searchQuery
    ).toList();
  }

  List<Surah> get allSurahs => _surahs;
  List<Ayah> get currentAyahs => _currentAyahs;
  bool get isLoading => _isLoading;
  int? get currentSurahNumber => _currentSurahNumber;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> loadSurah(int surahNumber) async {
    _isLoading = true;
    _currentSurahNumber = surahNumber;
    _currentAyahs = [];
    notifyListeners();

    try {
      final arabicResponse = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber'),
      );
      final translationResponse = await http.get(
        Uri.parse('https://api.alquran.cloud/v1/surah/$surahNumber/en.asad'),
      );

      if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body) as Map<String, dynamic>;
        final translationData = json.decode(translationResponse.body) as Map<String, dynamic>;

        final arabicAyahs = (arabicData['data'] as Map<String, dynamic>)['ayahs'] as List<dynamic>;
        final translationAyahs = (translationData['data'] as Map<String, dynamic>)['ayahs'] as List<dynamic>;

        _currentAyahs = List.generate(arabicAyahs.length, (i) {
          final arabicAyah = arabicAyahs[i] as Map<String, dynamic>;
          final translationAyah = i < translationAyahs.length ? translationAyahs[i] as Map<String, dynamic> : <String, dynamic>{};
          return Ayah(
            number: arabicAyah['numberInSurah'] as int,
            text: arabicAyah['text'] as String,
            translation: translationAyah['text'] as String? ?? '',
            surahNumber: surahNumber,
          );
        });
      }
    } catch (e) {
      debugPrint('Error loading surah: $e');
      _currentAyahs = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
