import 'package:aflam/core/widgets/shimmer/custom_shimmer_widget.dart';
import 'package:aflam/features/shared/categories/presentation/cubit/categories_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../core/app_config/app_colors.dart';

class CategoryTabs extends StatefulWidget {
  final ValueChanged<int?>? onCategorySelected;

  const CategoryTabs({
    super.key,
    this.onCategorySelected,
  });

  @override
  State<CategoryTabs> createState() => _CategoryTabsState();
}

class _CategoryTabsState extends State<CategoryTabs> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    // Fetch categories from API
    context.read<CategoriesCubit>().getCategories();
    // Notify parent that "All" is selected initially (index 0 = null category)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onCategorySelected?.call(null);
    });
  }

  void _handleCategoryTap(int index, int? categoryId) {
    setState(() {
      _selectedIndex = index;
    });
    // Notify parent about category selection
    widget.onCategorySelected?.call(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoriesCubit, CategoriesState>(
      builder: (context, state) {
        // Show shimmer skeleton while loading (better UX than loading indicator)
        if (state.status == CategoriesStatus.loading) {
          return SizedBox(
            height: 32.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 5, // Show 5 shimmer chips
              separatorBuilder: (_, __) => SizedBox(width: 8.w),
              itemBuilder: (context, index) {
                return CustomShimmerWidget(
                  width: 80.w,
                  height: 32.h,
                  borderRadius: BorderRadius.circular(20.r),
                );
              },
            ),
          );
        }

        // Show error or empty state - hide completely
        if (state.status == CategoriesStatus.error || state.categories.isEmpty) {
          return const SizedBox.shrink();
        }

        // Show categories from API
        return SizedBox(
          height: 32.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length,
            separatorBuilder: (_, __) => SizedBox(width: 8.w),
            itemBuilder: (context, index) {
              final bool isSelected = index == _selectedIndex;
              final category = state.categories[index];

              return GestureDetector(
                onTap: () => _handleCategoryTap(index, category.id),
                child: CategoryChip(
                  label: category.name,
                  isSelected: isSelected,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;

  const CategoryChip({
    super.key,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      height: 32.h,
      padding: EdgeInsets.symmetric(horizontal: 13.w),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Center(
        child: Text(
          label.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected
                ? AppColors.whiteColor
                : AppColors.bodyText,
          ),
        ),
      ),
    );
  }
}
