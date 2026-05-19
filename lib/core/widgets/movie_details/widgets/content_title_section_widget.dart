import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:aflam/features/viewer/favorites/presentation/widgets/favorite_button.dart';

/// Title section with content name, date, and favorite icon
class ContentTitleSectionWidget extends StatelessWidget {
  final String title;
  final String createdAt;
  final String contentType;
  final int objectId;

  const ContentTitleSectionWidget({
    super.key,
    required this.title,
    required this.createdAt,
    required this.contentType,
    required this.objectId,
  });

  /// Format date from ISO string to readable format (e.g., "4 Oct 2025")
  String _formatDate(String dateString) {
    if (dateString.isEmpty) return '';

    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('d MMM yyyy');
      return formatter.format(date);
    } catch (e) {
      // If parsing fails, return original string
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formattedDate = _formatDate(createdAt);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    fontSize: 22.sp,
                    color: Colors.black,
                  ),
                ),
                if (formattedDate.isNotEmpty) ...[
                  5.height,
                  Text(
                    formattedDate,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 12.sp,
                      color: AppColors.bottomBarColor,
                    ),
                  ),
                ],
              ],
            ),
          ),
          FavoriteButton(
            contentType: contentType,
            objectId: objectId,
            variant: FavoriteStyleVariant.details,
          ),
        ],
      ),
    );
  }
}
