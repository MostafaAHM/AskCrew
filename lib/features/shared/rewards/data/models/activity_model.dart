class ActivityModel {
  final int id;
  final String title;
  final String subtitle;
  final String date;
  final String status; // 'Supplemented', 'Awaiting'
  final int points;
  final bool
  isCredit; // true if points added, false if deducted (though design shows all positive?)
  final String iconType; // 'video', 'camera'

  const ActivityModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.date,
    required this.status,
    required this.points,
    required this.isCredit,
    required this.iconType,
  });
}
