import 'package:aflam/core/app_config/content_types.dart';
import 'package:aflam/core/helpers/authorization_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:aflam/features/viewer/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:aflam/features/viewer/favorites/presentation/cubit/favorites_state.dart';

enum FavoriteStyleVariant {
  standard, // Used in cards, lists
  banner, // Used in banner with circle background
  details, // Used in details screen
}

class FavoriteButton extends StatelessWidget {
  final String contentType;
  final int objectId;
  final double? size;
  final FavoriteStyleVariant variant;
  final Color? color;

  const FavoriteButton({
    super.key,
    required this.contentType,
    required this.objectId,
    this.size,
    this.variant = FavoriteStyleVariant.standard,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Limited rebuild using BlocSelector
    return BlocSelector<FavoritesCubit, FavoritesState, bool>(
      selector: (state) {
        final key = '${AppContentTypes.mapForFavorite(contentType)}_$objectId';
        return state.favoritesKeys.contains(key);
      },
      builder: (context, isFavorite) {
        switch (variant) {
          case FavoriteStyleVariant.banner:
            return _buildBannerStyle(context, isFavorite);
          case FavoriteStyleVariant.details:
            return _buildDetailsStyle(context, isFavorite);
          case FavoriteStyleVariant.standard:
            return _buildStandardStyle(context, isFavorite);
        }
      },
    );
  }

  Widget _buildStandardStyle(BuildContext context, bool isFavorite) {
    return GestureDetector(
      onTap: () => _toggle(context),
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : (color ?? Colors.white),
        size: size ?? 24.sp,
      ),
    );
  }

  Widget _buildBannerStyle(BuildContext context, bool isFavorite) {
    return GestureDetector(
      onTap: () => _toggle(context),
      child: Container(
        padding: EdgeInsets.all(5.w),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.45),
        ),
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          size: size ?? 16.sp,
          color: isFavorite ? Colors.red : Colors.white,
        ),
      ),
    );
  }

  Widget _buildDetailsStyle(BuildContext context, bool isFavorite) {
    return GestureDetector(
      onTap: () => _toggle(context),
      child: Icon(
        isFavorite ? Icons.favorite : Icons.favorite_border,
        color: isFavorite ? Colors.red : (color ?? Colors.white70),
        size: size ?? 24.sp,
      ),
    );
  }

  void _toggle(BuildContext context) {
    AuthorizationHelper.checkLoggedIn(context, () {
      context.read<FavoritesCubit>().toggleFavorite(
        contentType: contentType,
        objectId: objectId,
      );
    });
  }
}
