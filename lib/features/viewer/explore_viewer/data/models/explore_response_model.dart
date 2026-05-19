import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/category_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/movie_model.dart';
import 'package:aflam/features/viewer/home_viewer/data/model/movies_with_series_model.dart';

class ExploreResponseModel {
  final List<ExploreItemModel> items;

  ExploreResponseModel({required this.items});

  factory ExploreResponseModel.fromJson(List<dynamic> json) {
    return ExploreResponseModel(
      items: json.map((e) => ExploreItemModel.fromJson(e)).toList(),
    );
  }
}

class ExploreItemModel {
  final String type;
  final String createdAt;
  final ExploreSeasonData? seasonData;
  final ExploreMovieData? movieData;

  ExploreItemModel({
    required this.type,
    required this.createdAt,
    this.seasonData,
    this.movieData,
  });

  factory ExploreItemModel.fromJson(Map<String, dynamic> json) {
    final type = json['type'] as String? ?? '';
    final data = json['data'] as Map<String, dynamic>?;

    if ((type == 'season' || type == 'episode') && data != null) {
      return ExploreItemModel(
        type: type,
        createdAt: json['created_at'] ?? '',
        seasonData: ExploreSeasonData.fromJson(data),
      );
    } else if ((type == 'movie' || type == 'advertise') && data != null) {
      return ExploreItemModel(
        type: type,
        createdAt: json['created_at'] ?? '',
        movieData: ExploreMovieData.fromJson(data),
      );
    }

    return ExploreItemModel(type: type, createdAt: json['created_at'] ?? '');
  }

  String? get coverImage {
    if (type == 'season' || type == 'episode') {
      return seasonData?.coverPhoto;
    } else if (type == 'movie' || type == 'advertise') {
      return movieData?.coverImage;
    }
    return null;
  }

  String? get title {
    if (type == 'season' || type == 'episode') {
      return seasonData?.series?.title;
    } else if (type == 'movie' || type == 'advertise') {
      return movieData?.name;
    }
    return null;
  }

  int get id {
    if (type == 'season' || type == 'episode') {
      return seasonData?.id ?? 0;
    } else if (type == 'movie' || type == 'advertise') {
      return movieData?.id ?? 0;
    }
    return 0;
  }

  String get contentType {
    if (type == 'season' || type == 'episode') {
      return 'season';
    }
    return type;
  }

  MovieOrSeriesItem toMovieOrSeriesItem() {
    if (type == 'season' || type == 'episode') {
      return MovieOrSeriesItem(
        id: seasonData?.id ?? 0,
        name: seasonData?.series?.title,
        title: seasonData?.series?.title,
        about: seasonData?.series?.about ?? '',
        price: seasonData?.price ?? '0.00',
        coverImage: seasonData?.coverPhoto,
        coverPhoto: seasonData?.coverPhoto,
        actors: seasonData?.actors ?? [],
        trailer: seasonData?.trailer ?? seasonData?.series?.trailer,
        viewsCount: 0,
        category: seasonData?.series?.category,
        isReady: true,
        adminApproved: true,
        video: null,
        isFavorite: false,
        isRated: false,
        isPaid: false,
        userRating: 0.0,
        ratingMean: 0.0,
        ratingCount: 0,
        artWorkType: 'series',
        createdAt: seasonData?.createdAt ?? '',
        updatedAt: seasonData?.updatedAt ?? '',
      );
    } else {
      return MovieOrSeriesItem(
        id: movieData?.id ?? 0,
        name: movieData?.name,
        title: movieData?.name,
        about: movieData?.about ?? '',
        price: movieData?.price ?? '0.00',
        coverImage: movieData?.coverImage,
        coverPhoto: movieData?.coverImage,
        actors: movieData?.actors ?? [],
        trailer: movieData?.trailer,
        viewsCount: movieData?.viewsCount ?? 0,
        category: movieData?.category,
        isReady: movieData?.isReady ?? true,
        adminApproved: movieData?.adminApproved ?? true,
        video: movieData?.video,
        isFavorite: movieData?.isFavorite ?? false,
        isRated: movieData?.isRated ?? false,
        isPaid: movieData?.isPaid,
        userRating: movieData?.userRating,
        ratingMean: movieData?.ratingMean,
        ratingCount: movieData?.ratingCount ?? 0,
        artWorkType: 'movie',
        createdAt: movieData?.createdAt ?? '',
        updatedAt: movieData?.updatedAt ?? '',
      );
    }
  }
}

class ExploreSeasonData {
  final int id;
  final ExploreSeriesData? series;
  final int seasonNumber;
  final String price;
  final String? coverPhoto;
  final String? trailer;
  final List<MovieActorModel> actors;
  final String artWorkType;
  final String createdAt;
  final String updatedAt;

  ExploreSeasonData({
    required this.id,
    this.series,
    required this.seasonNumber,
    required this.price,
    this.coverPhoto,
    this.trailer,
    required this.actors,
    required this.artWorkType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExploreSeasonData.fromJson(Map<String, dynamic> json) {
    return ExploreSeasonData(
      id: json['id'] ?? 0,
      series: json['series'] != null
          ? ExploreSeriesData.fromJson(json['series'])
          : null,
      seasonNumber: json['season_number'] ?? 1,
      price: json['price'] ?? '0.00',
      coverPhoto: json['cover_photo'],
      trailer: json['trailer'],
      actors: json['actors'] != null
          ? (json['actors'] as List)
                .map((e) => MovieActorModel.fromJson(e))
                .toList()
          : [],
      artWorkType: json['art_work_type'] ?? 'series',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class ExploreSeriesData {
  final int id;
  final String title;
  final String about;
  final String? coverPhoto;
  final CategoryModel? category;
  final int createdBy;
  final String createdAt;
  final String updatedAt;
  final String? trailer;

  ExploreSeriesData({
    required this.id,
    required this.title,
    required this.about,
    this.coverPhoto,
    this.category,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
    this.trailer,
  });

  factory ExploreSeriesData.fromJson(Map<String, dynamic> json) {
    return ExploreSeriesData(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      about: json['about'] ?? '',
      coverPhoto: json['cover_photo'],
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      createdBy: json['created_by'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      trailer: json['trailer'],
    );
  }
}

class ExploreMovieData {
  final int id;
  final String name;
  final String about;
  final String price;
  final String? coverImage;
  final List<MovieActorModel> actors;
  final String? trailer;
  final int viewsCount;
  final CategoryModel? category;
  final bool isReady;
  final bool adminApproved;
  final String? adminApprovedAt;
  final int? adminApprovedBy;
  final String? video;
  final bool isFavorite;
  final bool isRated;
  final double? userRating;
  final double ratingMean;
  final int ratingCount;
  final bool? isPaid;
  final String artWorkType;
  final String createdAt;
  final String updatedAt;

  ExploreMovieData({
    required this.id,
    required this.name,
    required this.about,
    required this.price,
    this.coverImage,
    required this.actors,
    this.trailer,
    required this.viewsCount,
    this.category,
    required this.isReady,
    required this.adminApproved,
    this.adminApprovedAt,
    this.adminApprovedBy,
    this.video,
    required this.isFavorite,
    required this.isRated,
    this.userRating,
    required this.ratingMean,
    required this.ratingCount,
    this.isPaid,
    required this.artWorkType,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExploreMovieData.fromJson(Map<String, dynamic> json) {
    return ExploreMovieData(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      about: json['about'] ?? '',
      price: json['price'] ?? '0.00',
      coverImage: json['cover_image'],
      actors: json['actors'] != null
          ? (json['actors'] as List)
                .map((e) => MovieActorModel.fromJson(e))
                .toList()
          : [],
      trailer: json['trailer'],
      viewsCount: json['views_count'] ?? 0,
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'])
          : null,
      isReady: json['is_ready'] ?? false,
      adminApproved: json['admin_approved'] ?? false,
      adminApprovedAt: json['admin_approved_at'],
      adminApprovedBy: json['admin_approved_by'],
      video: json['video'],
      isFavorite: json['is_favorite'] ?? false,
      isRated: json['is_rated'] ?? false,
      userRating: json['user_rating'] != null
          ? (json['user_rating'] as num).toDouble()
          : null,
      ratingMean: json['rating_mean'] != null
          ? (json['rating_mean'] as num).toDouble()
          : 0.0,
      ratingCount: json['rating_count'] ?? 0,
      isPaid: json['is_paid'] == null
          ? null
          : (json['is_paid'] == true ||
                json['is_paid'] == 1 ||
                json['is_paid'] == 'true'),
      artWorkType: json['art_work_type'] ?? 'movie',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}
