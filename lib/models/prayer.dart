class QazaPrayer {
  final String name;
  final String icon;
  final int rakats;
  int totalMissed;
  int offered;

  QazaPrayer({
    required this.name,
    required this.icon,
    required this.rakats,
    required this.totalMissed,
    this.offered = 0,
  });

  int get remaining => (totalMissed - offered).clamp(0, totalMissed);
  double get progress =>
      totalMissed > 0 ? (offered / totalMissed).clamp(0.0, 1.0) : 0.0;

  Map<String, dynamic> toJson() => {
        'name': name,
        'icon': icon,
        'rakats': rakats,
        'totalMissed': totalMissed,
        'offered': offered,
      };

  factory QazaPrayer.fromJson(Map<String, dynamic> json) => QazaPrayer(
        name: json['name'] as String,
        icon: json['icon'] as String,
        rakats: json['rakats'] as int,
        totalMissed: json['totalMissed'] as int,
        offered: json['offered'] as int? ?? 0,
      );
}
