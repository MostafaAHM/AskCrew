import 'package:aflam/core/helpers/extensions.dart';

class PaginationOptions {
  final int page;
  final int? limit;
  final String? search;

  final bool? sendLang;
  const PaginationOptions({
    this.page = 1,
    this.limit,
    this.search,
    this.sendLang,
  });

  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'limit': limit,
      if (sendLang == true && search?.isNotEmpty == true)
        'lang': search?.detectLanguage(),
      if (search != null) 'search': search,
    };
  }

  String detectLanguage(String text) {
    final arabicRegex = RegExp(r'[\u0600-\u06FF]');
    return arabicRegex.hasMatch(text) ? 'ar' : 'en';
  }
}

class CategoryPaginationOptions extends PaginationOptions {
  final bool? mazadCategories;
  const CategoryPaginationOptions({
    super.page = 1,
    super.limit,
    super.search,
    super.sendLang,
    this.mazadCategories,
  });
}

class GetSavedSearchOptions extends PaginationOptions {
  final String? userId;
  const GetSavedSearchOptions({super.page = 1, super.limit, this.userId});
}

class PromotedAdsOptions extends PaginationOptions {
  final String? categoryId;
  const PromotedAdsOptions({super.page = 1, super.limit, this.categoryId});
  @override
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': limit,
      if (categoryId != null) 'categoryId': categoryId,
    };
  }
}

class PackagesOptions extends PaginationOptions {
  final String? categoryId;
  const PackagesOptions({super.page = 1, super.limit, this.categoryId});
  @override
  Map<String, dynamic> toJson() {
    return {
      'page': page,
      'per_page': limit,
      if (categoryId != null) 'categoryId': categoryId,
    };
  }
}

class FollowedUsersOptions extends PaginationOptions {
  final String? userId;
  const FollowedUsersOptions({super.page = 1, super.limit, this.userId});
  @override
  Map<String, dynamic> toJson() {
    return {'page': page, 'per_page': limit};
  }
}
