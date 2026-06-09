import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/font_styles.dart';
import '../../../../../core/helpers/messages.dart';
import '../../../../../core/widgets/animated_loading/animated_loading.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../data/model/questions/request/create_question_request_model.dart';
import '../cubit/questions/cubit/questions_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AskQuestionBottomSheet extends StatefulWidget {
  const AskQuestionBottomSheet({super.key});

  @override
  State<AskQuestionBottomSheet> createState() => _AskQuestionBottomSheetState();
}

class _AskQuestionBottomSheetState extends State<AskQuestionBottomSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _bodyController = TextEditingController();
  String? _specification;

  String? _titleError;
  String? _bodyError;
  String? _specError;

  @override
  void initState() {
    super.initState();
    context.read<QuestionsCubit>().getSpecifications();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _validateAndSubmit(BuildContext context, bool isLoading) {
    if (isLoading) return;

    setState(() {
      _titleError = null;
      _bodyError = null;
      _specError = null;
    });

    final title = _titleController.text.trim();
    final body = _bodyController.text.trim();

    bool hasError = false;

    if (title.isEmpty) {
      _titleError = 'community_question_title_required'.tr();
      hasError = true;
    } else if (title.length < 8) {
      _titleError = 'community_question_title_min_length'.tr();
      hasError = true;
    }

    if (body.isEmpty) {
      _bodyError = 'community_question_body_required'.tr();
      hasError = true;
    } else if (body.length < 20) {
      _bodyError = 'community_question_body_min_length'.tr();
      hasError = true;
    }

    if (_specification == null) {
      _specError = 'pleaseSelectAtLeastOneSpecification'.tr();
      hasError = true;
    }

    if (hasError) {
      setState(() {});
      return;
    }

    final model = CreateQuestionRequestModel(
      title: title,
      body: body,
      specification: _specification!,
    );

    context.read<QuestionsCubit>().createQuestion(model: model);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<QuestionsCubit, QuestionsState>(
      listener: (context, state) {
        if (state is CreateQuestionSuccess) {
          AppMessages.showSuccess(
            context,
            'question_created_successfully'.tr(),
          );
          context.read<QuestionsCubit>().getQuestions();
          Navigator.of(context).pop();
        }
        if (state is CreateQuestionFailure) {
          AppMessages.showError(context, 'question_creation_failed'.tr());
        }
      },
      builder: (context, state) {
        final bool isLoading = state is CreateQuestionLoading;

        return Container(
          margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 20,
                spreadRadius: 0,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: DraggableScrollableSheet(
            initialChildSize: 0.85,
            maxChildSize: 0.95,
            minChildSize: 0.5,
            expand: false,
            builder: (context, scrollController) {
              return Column(
                children: [
                  // Header with drag indicator and close button
                  Padding(
                    padding: EdgeInsets.only(
                      top: 12.h,
                      bottom: 8.h,
                      left: 16.w,
                      right: 16.w,
                    ),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: 48.w,
                            height: 5.h,
                            decoration: BoxDecoration(
                              color: Color(0xFFE0E0E0),
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                          ),
                        ),
                        10.verticalSpace,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ask_new_question'.tr(),
                              style: FontStyles.body12W400.copyWith(
                                color: Colors.black87,
                                fontSize: 20.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: BoxDecoration(
                                  color: AppColors.lightBGColor,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.close,
                                  size: 20.sp,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: AppColors.lightBGColor,
                    thickness: 1.5,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(
                        horizontal: 20.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'ask_question_description'.tr(),
                            style: FontStyles.body14W500.copyWith(
                              fontSize: 15.sp,
                              color: Colors.grey.shade600,
                              height: 1.4,
                            ),
                          ),
                          24.verticalSpace,

                          // Title
                          Text(
                            'question_title'.tr(),
                            style: FontStyles.body14W700.copyWith(
                              color: Colors.black87,
                              fontSize: 15.sp,
                            ),
                          ),
                          10.verticalSpace,
                          CustomTextField(
                            controller: _titleController,
                            hint: 'community_question_title_placeholder'.tr(),
                          ),
                          if (_titleError != null) ...[
                            8.verticalSpace,
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 16.sp,
                                ),
                                4.horizontalSpace,
                                Text(
                                  _titleError!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          22.verticalSpace,

                          // Specification
                          Text(
                            'Specification'.tr(),
                            style: FontStyles.body14W700.copyWith(
                              color: Colors.black87,
                              fontSize: 15.sp,
                            ),
                          ),
                          10.verticalSpace,
                          BlocBuilder<QuestionsCubit, QuestionsState>(
                            buildWhen: (prev, curr) =>
                                curr is SpecificationsLoading ||
                                curr is SpecificationsSuccess ||
                                curr is SpecificationsFailure,
                            builder: (context, specState) {
                              return SpecificationDropdown(
                                value: _specification,
                                isLoadingSpecs:
                                    specState is SpecificationsLoading,
                                specifications:
                                    specState is SpecificationsSuccess
                                    ? specState.specifications
                                    : {},
                                onChanged: (val) {
                                  setState(() {
                                    _specification = val;
                                    _specError = null;
                                  });
                                },
                              );
                            },
                          ),
                          if (_specError != null) ...[
                            8.verticalSpace,
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 16.sp,
                                ),
                                4.horizontalSpace,
                                Text(
                                  _specError!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          22.verticalSpace,

                          // Question body
                          Text(
                            'enter_your_question'.tr(),
                            style: FontStyles.body14W700.copyWith(
                              color: Colors.black87,
                              fontSize: 15.sp,
                            ),
                          ),
                          10.verticalSpace,
                          Container(
                            height: 150.h,
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 14.h,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFF9F9F9),
                              borderRadius: BorderRadius.circular(20.r),
                              border: Border.all(
                                color: _bodyError != null
                                    ? Colors.red
                                    : Color(0xFFE0E0E0),
                                width: 1.2,
                              ),
                            ),
                            child: TextField(
                              controller: _bodyController,
                              maxLines: null,
                              expands: true,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: Colors.black87,
                              ),
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: 'community_question_title_placeholder'
                                    .tr(),
                                hintStyle: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                              onChanged: (_) {
                                if (_bodyError != null) {
                                  setState(() {
                                    _bodyError = null;
                                  });
                                }
                              },
                            ),
                          ),
                          if (_bodyError != null) ...[
                            8.verticalSpace,
                            Row(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  color: Colors.red,
                                  size: 16.sp,
                                ),
                                4.horizontalSpace,
                                Text(
                                  _bodyError!,
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                          30.verticalSpace,

                          // Submit button
                          Center(
                            child: GestureDetector(
                              onTap: () =>
                                  _validateAndSubmit(context, isLoading),
                              child: Container(
                                width: double.infinity,
                                height: 56.h,
                                decoration: BoxDecoration(
                                  gradient: AppColors.primaryGradient,
                                  borderRadius: BorderRadius.circular(30.r),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primaryColor.withOpacity(
                                        0.35,
                                      ),
                                      blurRadius: 12,
                                      offset: Offset(0, 4),
                                    ),
                                  ],
                                ),
                                alignment: Alignment.center,
                                child: isLoading
                                    ? SizedBox(
                                        width: 24.w,
                                        height: 24.w,
                                        child: const AnimatedLoading(
                                          color: Colors.white,
                                          size: 24,
                                        ),
                                      )
                                    : Text(
                                        'Submit your question'.tr(),
                                        style: FontStyles.headline16.copyWith(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          20.verticalSpace,
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class SpecificationDropdown extends StatelessWidget {
  final String? value;
  final ValueChanged<String?> onChanged;
  final bool isLoadingSpecs;
  final Map<String, List<String>> specifications;

  const SpecificationDropdown({
    super.key,
    required this.value,
    required this.onChanged,
    this.isLoadingSpecs = false,
    this.specifications = const {},
  });

  @override
  Widget build(BuildContext context) {
    final List<String> categories = specifications.keys.toList();

    return Container(
      height: 58.h,
      padding: EdgeInsets.symmetric(horizontal: 18.w),
      decoration: BoxDecoration(
        color: Color(0xFFF9F9F9),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: Color(0xFFE0E0E0), width: 1.2),
      ),
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: categories.contains(value) ? value : null,
              dropdownColor: Colors.white,
              hint: Text(
                isLoadingSpecs
                    ? 'loading_specifications'.tr()
                    : 'select specification for asking'.tr(),
                style: TextStyle(fontSize: 15.sp, color: Colors.grey.shade500),
              ),
              icon: Icon(
                Icons.keyboard_arrow_down_outlined,
                size: 26.sp,
                color: Colors.black54,
              ),
              items: categories
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e.tr(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: isLoadingSpecs ? null : onChanged,
            ),
          ),
          if (isLoadingSpecs)
            Positioned(
              right: 40.w,
              child: SizedBox(
                width: 18.w,
                height: 18.w,
                child: AnimatedLoading(size: 18, color: AppColors.primaryColor),
              ),
            ),
        ],
      ),
    );
  }
}
