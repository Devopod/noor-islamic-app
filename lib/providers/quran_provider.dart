import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../data/quran_data.dart';

class QuranProvider extends ChangeNotifier {
  static const String _baseUrl = 'https://api.quran.com/api/v4';
  static const int _translationId = 85;

  List<Surah> _surahs = surahs;
  List<Ayah> _currentAyahs = [];
  bool _isLoading = false;
  bool _chaptersLoaded = false;
  String _searchQuery = '';
  int? _currentSurahNumber;
  String? _errorMessage;

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
  String? get errorMessage => _errorMessage;

  QuranProvider() {
    _loadChapters();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> _loadChapters() async {
    if (_chaptersLoaded) return;
    try {
      final response = await http.get(Uri.parse('$_baseUrl/chapters?language=en'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final chapters = data['chapters'] as List<dynamic>;
        _surahs = chapters.map((ch) {
          final c = ch as Map<String, dynamic>;
          final translated = c['translated_name'] as Map<String, dynamic>?;
          return Surah(
            number: c['id'] as int,
            name: c['name_arabic'] as String? ?? '',
            englishName: c['name_simple'] as String? ?? '',
            englishTranslation: translated?['name'] as String? ?? '',
            ayahCount: c['verses_count'] as int? ?? 0,
            revelationType: (c['revelation_place'] as String? ?? 'makkah') == 'makkah' ? 'Meccan' : 'Medinan',
          );
        }).toList();
        _chaptersLoaded = true;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading chapters from quran.com API: $e');
    }
  }

  Future<void> loadSurah(int surahNumber) async {
    _isLoading = true;
    _currentSurahNumber = surahNumber;
    _currentAyahs = [];
    _errorMessage = null;
    notifyListeners();

    try {
      final allAyahs = <Ayah>[];
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final url = Uri.parse(
          '$_baseUrl/verses/by_chapter/$surahNumber'
          '?translations=$_translationId'
          '&fields=text_uthmani'
          '&per_page=50'
          '&page=$page'
        );
        final response = await http.get(url);

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as Map<String, dynamic>;
          final verses = data['verses'] as List<dynamic>;
          final pagination = data['pagination'] as Map<String, dynamic>?;

          for (final v in verses) {
            final verse = v as Map<String, dynamic>;
            final translations = verse['translations'] as List<dynamic>?;
            String translationText = '';
            if (translations != null && translations.isNotEmpty) {
              final t = translations[0] as Map<String, dynamic>;
              translationText = (t['text'] as String? ?? '')
                  .replaceAll(RegExp(r'<[^>]*>'), '');
            }
            allAyahs.add(Ayah(
              number: verse['verse_number'] as int,
              text: verse['text_uthmani'] as String? ?? '',
              translation: translationText,
              surahNumber: surahNumber,
            ));
          }

          final totalPages = pagination?['total_pages'] as int? ?? 1;
          hasMore = page < totalPages;
          page++;
        } else {
          _errorMessage = 'API error: ${response.statusCode}';
          hasMore = false;
        }
      }

      _currentAyahs = allAyahs;
    } catch (e) {
      debugPrint('Error loading surah from quran.com API: $e');
      _errorMessage = 'Failed to load surah. Check your connection.';
      _currentAyahs = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
