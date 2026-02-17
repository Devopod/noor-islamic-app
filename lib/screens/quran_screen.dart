import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/quran_provider.dart';
import '../utils/app_theme.dart';
import 'surah_detail_screen.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<QuranProvider>(
      builder: (context, quran, _) {
        return Column(
          children: [
            _buildHeader(context, quran),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 100),
                itemCount: quran.filteredSurahs.length,
                itemBuilder: (context, index) {
                  final surah = quran.filteredSurahs[index];
                  return _buildSurahTile(context, surah, quran);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, QuranProvider quran) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: AppTheme.backgroundDark,
        border: Border(
          bottom: BorderSide(color: AppTheme.surfaceLight.withAlpha(128)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Al-Quran',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '114 Surahs',
            style: TextStyle(fontSize: 13, color: Colors.grey[400]),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: AppTheme.surfaceDark2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.surfaceLight),
            ),
            child: Row(
              children: [
                Icon(Icons.search, size: 20, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    onChanged: quran.setSearchQuery,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search Surah...',
                      hintStyle: TextStyle(color: Colors.grey[600]),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSurahTile(BuildContext context, surah, QuranProvider quran) {
    return InkWell(
      onTap: () {
        quran.loadSurah(surah.number);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SurahDetailScreen(surah: surah),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppTheme.surfaceLight.withAlpha(64)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.surfaceDark2,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.surfaceLight.withAlpha(128)),
              ),
              child: Center(
                child: Text(
                  '${surah.number}',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    surah.englishName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${surah.englishTranslation} - ${surah.ayahCount} Ayahs',
                    style: TextStyle(fontSize: 12, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
            Text(
              surah.name,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
              textDirection: TextDirection.rtl,
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: surah.revelationType == 'Meccan'
                    ? AppTheme.primary.withAlpha(25)
                    : AppTheme.secondary.withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                surah.revelationType,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w600,
                  color: surah.revelationType == 'Meccan'
                      ? AppTheme.primary
                      : AppTheme.secondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
