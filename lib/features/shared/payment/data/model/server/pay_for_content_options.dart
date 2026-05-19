enum ContentType {
  movie,
  season,
  advertise,
  series;

  String get value {
    switch (this) {
      case ContentType.movie:
        return 'movie';
      case ContentType.season:
        return 'season';
      case ContentType.advertise:
        return 'advertise';
      case ContentType.series:
        return 'series';
    }
  }
}

class PayForContentOptions {
  final int contentId;
  final ContentType contentType;
  final bool? withWallet;
  final String? code;
  final bool? usePoints;

  PayForContentOptions({
    required this.contentId,
    required this.contentType,
    this.withWallet,
    this.code,
    this.usePoints,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'content_id': contentId,
      'content_type': contentType.value,
    };
  
    if (withWallet != null && withWallet == true) {
      json['with_wallet'] = 1;
    }

    if (code != null && code!.isNotEmpty) {
      json['code'] = code;
    }

    if (usePoints != null && usePoints == true) {
      json['use_points'] = 1;
    }

    return json;
  }
}
