class DuaCategory {
  final String name;
  final String icon;
  final int count;
  final List<Dua> duas;

  const DuaCategory({
    required this.name,
    required this.icon,
    required this.count,
    required this.duas,
  });
}

class Dua {
  final String id;
  final String title;
  final String arabic;
  final String translation;
  final String transliteration;
  final String reference;
  final String category;
  bool isFavorite;

  Dua({
    required this.id,
    required this.title,
    required this.arabic,
    required this.translation,
    this.transliteration = '',
    required this.reference,
    required this.category,
    this.isFavorite = false,
  });
}
