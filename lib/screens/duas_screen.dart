import 'package:flutter/material.dart';
import '../data/dua_data.dart';
import '../models/dua.dart';
import '../utils/app_theme.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});

  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

class _DuasScreenState extends State<DuasScreen> {
  String _searchQuery = '';

  List<Dua> get _filteredDuas {
    if (_searchQuery.isEmpty) return allDuas;
    return allDuas.where((d) =>
      d.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      d.translation.toLowerCase().contains(_searchQuery.toLowerCase()) ||
      d.category.toLowerCase().contains(_searchQuery.toLowerCase())
    ).toList();
  }

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
                  _buildSearchBar(),
                  const SizedBox(height: 20),
                  _buildFeaturedDua(),
                  const SizedBox(height: 24),
                  _buildCategoriesGrid(),
                  const SizedBox(height: 24),
                  _buildPopularDuas(),
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
            child: Text(
              'Duas & Azkar',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
          Icon(Icons.bookmark_border, color: Colors.grey[400]),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
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
              onChanged: (v) => setState(() => _searchQuery = v),
              style: const TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search duas...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedDua() {
    final dua = morningEveningDuas[2];
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF162E1C), Color(0xFF0F2415)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.surfaceLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.secondary.withAlpha(50),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text('FEATURED', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppTheme.secondary, letterSpacing: 1)),
              ),
              const Spacer(),
              Icon(Icons.share, size: 18, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            dua.arabic,
            textDirection: TextDirection.rtl,
            style: const TextStyle(fontSize: 20, height: 1.8, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            dua.translation,
            style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: Colors.grey[300], height: 1.5),
          ),
          const SizedBox(height: 8),
          Text(dua.reference, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.primary)),
        ],
      ),
    );
  }

  Widget _buildCategoriesGrid() {
    final icons = {
      'Morning & Evening': Icons.wb_twilight,
      'After Prayer': Icons.mosque,
      'Before Sleeping': Icons.bedtime,
      'Food & Drink': Icons.restaurant,
      'Travel': Icons.flight,
      'Hajj & Umrah': Icons.terrain,
    };

    final colors = [
      const Color(0xFFF59E0B),
      AppTheme.primary,
      const Color(0xFF8B5CF6),
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
      const Color(0xFF06B6D4),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categories', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 0.9,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: duaCategories.length,
          itemBuilder: (context, index) {
            final cat = duaCategories[index];
            final color = colors[index % colors.length];
            return GestureDetector(
              onTap: () => _showCategoryDuas(cat),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceDark2,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppTheme.surfaceLight.withAlpha(128)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: color.withAlpha(25),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icons[cat.name] ?? Icons.star, size: 22, color: color),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      cat.name,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                    Text('${cat.count} duas', style: TextStyle(fontSize: 9, color: Colors.grey[500])),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPopularDuas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Popular Duas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        ...(_searchQuery.isEmpty ? popularDuas : _filteredDuas).map((dua) => _buildDuaListItem(dua)),
      ],
    );
  }

  Widget _buildDuaListItem(Dua dua) {
    return GestureDetector(
      onTap: () => _showDuaDetail(dua),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceDark2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.surfaceLight.withAlpha(64)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.auto_stories, size: 20, color: AppTheme.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dua.title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 2),
                  Text(dua.category, style: TextStyle(fontSize: 11, color: Colors.grey[400])),
                ],
              ),
            ),
            Icon(Icons.chevron_right, size: 20, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }

  void _showDuaDetail(Dua dua) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(dua.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 4),
            Text(dua.category, style: TextStyle(fontSize: 12, color: AppTheme.primary)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                dua.arabic,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, height: 2, color: Colors.white),
              ),
            ),
            if (dua.transliteration.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Transliteration', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400])),
              const SizedBox(height: 4),
              Text(dua.transliteration, style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: Colors.grey[300])),
            ],
            const SizedBox(height: 16),
            Text('Translation', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey[400])),
            const SizedBox(height: 4),
            Text(dua.translation, style: TextStyle(fontSize: 14, color: Colors.grey[300], height: 1.6)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(dua.reference, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.primary)),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDuas(DuaCategory category) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surfaceDark2,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, controller) => ListView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(color: Colors.grey[600], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(category.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            Text('${category.duas.length} duas', style: TextStyle(fontSize: 12, color: Colors.grey[400])),
            const SizedBox(height: 16),
            ...category.duas.map((dua) => _buildDuaListItem(dua)),
          ],
        ),
      ),
    );
  }
}
