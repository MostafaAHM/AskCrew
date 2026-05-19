import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';

import '../../app_config/app_icons.dart';
import '../../app_config/app_strings.dart';
import '../svg_image/svg_image_widget.dart';
import 'custom_text_field.dart';

class CustomSearchField extends StatelessWidget {
  const CustomSearchField({
    super.key,
    required this.controller,
    this.onChanged,
    this.radius,
    this.onTap,
    this.hint,
    this.readOnly,
    this.suffix,
  });
  final TextEditingController controller;
  final Function(String?)? onChanged;
  final double? radius;
  final Function()? onTap;
  final String? hint;
  final bool? readOnly;
  final Widget? suffix;
  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: '',
      readOnly: readOnly ?? false,
      borderRadius: radius,
      onTap: onTap,
      suffix: suffix,
      prefix: Padding(
        padding: const EdgeInsets.all(12),
        child: SvgImageWidget(image: AppIcons.search),
      ),
      hint: hint ?? AppStrings.search.tr(),
      onChanged: onChanged,
      controller: controller,
    );
  }
}
