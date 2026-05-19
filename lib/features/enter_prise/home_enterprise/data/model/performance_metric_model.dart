class PerformanceMetricModel {
  final String id;
  final String type; // 'views', 'bookings', 'topWork'
  final String label;
  final String value;
  final String? topWorkTitle; // Only for 'topWork' type

  const PerformanceMetricModel({
    required this.id,
    required this.type,
    required this.label,
    required this.value,
    this.topWorkTitle,
  });

  factory PerformanceMetricModel.fromJson(Map<String, dynamic> json) {
    return PerformanceMetricModel(
      id: json['id'] ?? '',
      type: json['type'] ?? '',
      label: json['label'] ?? '',
      value: json['value'] ?? '',
      topWorkTitle: json['topWorkTitle'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'label': label,
      'value': value,
      'topWorkTitle': topWorkTitle,
    };
  }
}
