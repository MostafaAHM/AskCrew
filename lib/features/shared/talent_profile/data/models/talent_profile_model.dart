import 'talent_work_model.dart';

class TalentProfileModel {
  final int id;
  final String name;
  final String imageUrl;
  final bool isVerified;
  final bool isOnline;
  final double rating;
  final int reviewsCount;
  final String jobTitle;
  final String about;
  final String location;
  final String specialization;
  final List<TalentWorkModel> works;

  const TalentProfileModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.isVerified = false,
    this.isOnline = false,
    this.rating = 0.0,
    this.reviewsCount = 0,
    required this.jobTitle,
    required this.about,
    required this.location,
    required this.specialization,
    this.works = const [],
  });

  static String? _specToString(dynamic spec) {
    if (spec == null) return null;
    if (spec is String) return spec;
    if (spec is Map) {
      final values = spec.values.whereType<String>();
      return values.isNotEmpty ? values.join(', ') : null;
    }
    return spec.toString();
  }

  factory TalentProfileModel.fromJson(Map<String, dynamic> json) {
    String? imgUrl;
    if (json['profile'] != null && json['profile']['images'] != null) {
      final images = json['profile']['images'] as List;
      if (images.isNotEmpty) {
        final firstImg = images.first;
        if (firstImg is Map && firstImg['image'] != null) {
          imgUrl = firstImg['image'];
        } else if (firstImg is String) {
          imgUrl = firstImg;
        }
      }
    }

    final spec = json['profile']?['specification'];
    final specStr = _specToString(spec) ?? '';

    List<TalentWorkModel> worksList = [];
    if (json['profile'] != null && json['profile']['images'] != null) {
      final images = json['profile']['images'] as List;
      worksList = images
          .asMap()
          .entries
          .map((entry) {
            final index = entry.key;
            final item = entry.value;
            String workImg = '';
            if (item is Map && item['image'] != null) {
              workImg = item['image'];
            } else if (item is String) {
              workImg = item;
            }

            final firstSpec = specStr
                .split(',')
                .firstWhere((s) => s.trim().isNotEmpty, orElse: () => '')
                .trim();
            return TalentWorkModel(
              id: index,
              title: '',
              posterUrl: workImg,
              category: firstSpec,
            );
          })
          .where((w) => w.posterUrl.isNotEmpty)
          .toList();
    }

    return TalentProfileModel(
      id: json['id'] ?? 0,
      name: json['fullname'] ?? '',
      imageUrl: imgUrl ?? json['profile_photo'] ?? '',
      isVerified: json['is_verified'] ?? false,
      isOnline: json['is_active'] ?? false,
      rating: (json['rating_mean'] as num?)?.toDouble() ?? 0.0,
      reviewsCount: json['rating_count'] ?? 0,
      jobTitle: specStr,
      about: json['personal_info'] ?? '',
      location:
          '${json['profile']?['city'] ?? ''}, ${json['profile']?['country'] ?? ''}',
      specialization: specStr,
      works: worksList,
    );
  }
}
