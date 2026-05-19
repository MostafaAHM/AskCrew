import 'dart:async';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_roles.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/app_config/app_urls.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/data/models/response/enterprise_onboarding_data.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MyWorksSection extends StatefulWidget {
  final List<ContentCatalogItem> searchResults;
  final List<SelectedWorkItem> selectedWorkItems;
  final bool isSearching;
  final List<String> availableRoles;
  final Function(String) onSearch;
  final Function(ContentCatalogItem) onAddWorkItem;
  final Function(int, String) onRemoveWorkItem;
  final Function(int, String, String) onUpdateWorkItemRole;
  final Function onClearSearch;

  const MyWorksSection({
    super.key,
    required this.searchResults,
    required this.selectedWorkItems,
    this.isSearching = false,
    this.availableRoles = const [],
    required this.onSearch,
    required this.onAddWorkItem,
    required this.onRemoveWorkItem,
    required this.onUpdateWorkItemRole,
    required this.onClearSearch,
  });

  @override
  State<MyWorksSection> createState() => _MyWorksSectionState();
}

class _MyWorksSectionState extends State<MyWorksSection> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
    });
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      widget.onSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasSelectedItems = widget.selectedWorkItems.isNotEmpty;
    final hasSearchContent =
        widget.isSearching || widget.searchResults.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.work.tr(),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        8.verticalSpace,
        _buildSearchBar(),
        if (hasSelectedItems) ...[
          12.verticalSpace,
          _buildSelectedWorkItems(),
        ],
        if (hasSearchContent) ...[
          12.verticalSpace,
          _buildSearchResults(),
        ],
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.borderColor),
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: _onSearchChanged,
        style: TextStyle(fontSize: 14.sp, color: Colors.black87),
        decoration: InputDecoration(
          hintText: AppStrings.selectYourWork.tr(),
          hintStyle: TextStyle(fontSize: 14.sp, color: AppColors.hintColor),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.secondaryColor,
            size: 22.sp,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? GestureDetector(
                  onTap: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                    widget.onClearSearch();
                  },
                  child: Icon(
                    Icons.close,
                    color: AppColors.greyText,
                    size: 20.sp,
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (widget.isSearching) {
      return Container(
        constraints: BoxConstraints(maxHeight: 220.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderColor),
        ),
        padding: EdgeInsets.all(16.w),
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.secondaryColor,
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (widget.searchResults.isEmpty) return const SizedBox.shrink();

    // Create a local copy to avoid index out of range errors
    final results = List<ContentCatalogItem>.from(widget.searchResults);

    return Container(
      constraints: BoxConstraints(maxHeight: 220.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: results.length,
        separatorBuilder: (_, __) =>
            Divider(height: 1, color: AppColors.borderColor, indent: 60.w),
        itemBuilder: (context, index) {
          if (index >= results.length) return const SizedBox.shrink();
          final item = results[index];
          final isSelected = widget.selectedWorkItems.any(
            (s) => s.id == item.id && s.type == item.type,
          );

          return ListTile(
            dense: true,
            visualDensity: VisualDensity.compact,
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: item.poster != null
                  ? CachedNetworkImage(
                      imageUrl: item.poster!.startsWith('http')
                          ? item.poster!
                          : AppUrls.imageLink(item.poster!),
                      width: 40.w,
                      height: 56.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 40.w,
                        height: 56.h,
                        color: AppColors.lightBGColor,
                        child: Icon(
                          Icons.movie_outlined,
                          size: 20.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 40.w,
                        height: 56.h,
                        color: AppColors.lightBGColor,
                        child: Icon(
                          Icons.movie_outlined,
                          size: 20.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                    )
                  : Container(
                      width: 40.w,
                      height: 56.h,
                      color: AppColors.lightBGColor,
                      child: Icon(
                        Icons.movie_outlined,
                        size: 20.sp,
                        color: AppColors.greyText,
                      ),
                    ),
            ),
            title: Text(
              item.name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              item.type,
              style: TextStyle(fontSize: 12.sp, color: AppColors.greyText),
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: AppColors.secondaryColor,
                    size: 22.sp,
                  )
                : Icon(
                    Icons.add_circle_outline,
                    color: AppColors.greyText,
                    size: 22.sp,
                  ),
            onTap: () {
              if (isSelected) {
                widget.onRemoveWorkItem(item.id, item.type);
              } else {
                widget.onAddWorkItem(item);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildSelectedWorkItems() {
    if (widget.selectedWorkItems.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widget.selectedWorkItems.map((item) {
        return KeyedSubtree(
          key: ValueKey('${item.id}-${item.type}'),
          child: _SelectedWorkItemCard(
            item: item,
            onRemove: () {
              widget.onRemoveWorkItem(item.id, item.type);
            },
            onRoleChanged: (role) {
              widget.onUpdateWorkItemRole(item.id, item.type, role);
            },
          ),
        );
      }).toList(),
    );
  }
}

class _SelectedWorkItemCard extends StatefulWidget {
  final SelectedWorkItem item;
  final VoidCallback onRemove;
  final ValueChanged<String> onRoleChanged;

  const _SelectedWorkItemCard({
    required this.item,
    required this.onRemove,
    required this.onRoleChanged,
  });

  @override
  State<_SelectedWorkItemCard> createState() => _SelectedWorkItemCardState();
}

class _SelectedWorkItemCardState extends State<_SelectedWorkItemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isRemoving = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.25, 0.0),
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleRemove() {
    setState(() {
      _isRemoving = true;
    });
    _controller.forward().then((_) {
      widget.onRemove();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        if (!_isRemoving) {
          return child!;
        }
        return FadeTransition(
          opacity: _opacityAnimation,
          child: SlideTransition(position: _slideAnimation, child: child),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.secondaryColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: widget.item.poster != null
                  ? CachedNetworkImage(
                      imageUrl: widget.item.poster!.startsWith('http')
                          ? widget.item.poster!
                          : AppUrls.imageLink(widget.item.poster!),
                      width: 48.w,
                      height: 64.h,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 48.w,
                        height: 64.h,
                        color: AppColors.lightBGColor,
                        child: Icon(
                          Icons.movie_outlined,
                          size: 24.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 48.w,
                        height: 64.h,
                        color: AppColors.lightBGColor,
                        child: Icon(
                          Icons.movie_outlined,
                          size: 24.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                    )
                  : Container(
                      width: 48.w,
                      height: 64.h,
                      color: AppColors.lightBGColor,
                      child: Icon(
                        Icons.movie_outlined,
                        size: 24.sp,
                        color: AppColors.greyText,
                      ),
                    ),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: _handleRemove,
                        child: Icon(
                          Icons.close,
                          size: 20.sp,
                          color: AppColors.greyText,
                        ),
                      ),
                    ],
                  ),
                  4.verticalSpace,
                  Text(
                    widget.item.type,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                  8.verticalSpace,
                  Container(
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: AppColors.lightBGColor,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(
                        color: widget.item.role != null
                            ? AppColors.secondaryColor
                            : AppColors.borderColor,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 12.w),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor: Colors.white,
                        value: widget.item.role,
                        hint: Text(
                          "Your role".tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.hintColor,
                          ),
                        ),
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: AppColors.secondaryColor,
                          size: 18.sp,
                        ),
                        isExpanded: true,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.black87,
                        ),
                        items: AppRoles.roles.map((String role) {
                          return DropdownMenuItem<String>(
                            value: role,
                            child: Text(
                              role.replaceAll('_', ' ').tr(),
                              style: TextStyle(fontSize: 12.sp),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            widget.onRoleChanged(value);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
