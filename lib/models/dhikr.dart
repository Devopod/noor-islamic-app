class Dhikr {
  final String id;
  final String name;
  final String translation;
  final String arabic;
  int target;
  int count;

  Dhikr({
    required this.id,
    required this.name,
    required this.translation,
    this.arabic = '',
    required this.target,
    this.count = 0,
  });

  double get progress => target > 0 ? (count / target).clamp(0.0, 1.0) : 0.0;
  bool get isComplete => count >= target;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'translation': translation,
        'arabic': arabic,
        'target': target,
        'count': count,
      };

  factory Dhikr.fromJson(Map<String, dynamic> json) => Dhikr(
        id: json['id'] as String,
        name: json['name'] as String,
        translation: json['translation'] as String,
        arabic: json['arabic'] as String? ?? '',
        target: json['target'] as int,
        count: json['count'] as int? ?? 0,
      );
}
