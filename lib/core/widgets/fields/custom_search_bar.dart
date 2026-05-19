import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../app_config/app_icons.dart';
import '../../app_config/app_strings.dart';
import '../../app_config/font_styles.dart';

class CustomSearchBar extends StatefulWidget {
  final TextEditingController? controller;
  final bool autoFocus, enabled;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final String? hint;
  final Color? borderColor, backgroundColor;
  final double? height;
  final bool showClearButton;
  const CustomSearchBar({
    super.key,
    this.controller,
    this.autoFocus = false,
    this.onChanged,
    this.hint,
    this.borderColor,
    this.backgroundColor,
    this.height,
    this.enabled = true,
    this.onTap,
    this.showClearButton = false,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? TextEditingController();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    } else {
      _controller.removeListener(_onTextChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
  }

  void _clearText() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final hasText = _controller.text.isNotEmpty;

    return SizedBox(
      height: widget.height ?? 38.h,
      child: SearchBar(
        enabled: widget.enabled,
        onTap: widget.onTap,
        onTapOutside: (_) => FocusScope.of(context).unfocus(),
        onChanged: widget.onChanged,
        controller: _controller,
        hintText: widget.hint ?? AppStrings.search.tr(),
        autoFocus: widget.autoFocus,
        hintStyle: WidgetStatePropertyAll(FontStyles.textStyle14),
        leading: SvgPicture.asset(AppIcons.search, width: 14.w, height: 14.h),
        trailing: widget.showClearButton && hasText
            ? [
                GestureDetector(
                  onTap: _clearText,
                  child: SvgPicture.asset(
                    AppIcons.close,
                    width: 16.w,
                    height: 16.h,
                  ),
                ),
              ]
            : null,
        backgroundColor: WidgetStatePropertyAll(
          widget.backgroundColor ?? Colors.white,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            side: BorderSide(color: widget.borderColor ?? Colors.transparent),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        elevation: const WidgetStatePropertyAll(0),
        shadowColor: const WidgetStatePropertyAll(Colors.transparent),
        overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    );
  }
}
