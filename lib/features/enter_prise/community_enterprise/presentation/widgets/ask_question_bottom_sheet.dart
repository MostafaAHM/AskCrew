import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/font_styles.dart';
import '../../../../../core/helpers/messages.dart';
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
    final orange = const Color(0xFFFF7A3C);

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

        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          maxChildSize: 0.85,
          minChildSize: 0.45,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: AppColors.lightBGColor,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              ),
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: SingleChildScrollView(
                controller: scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40.w,
                        height: 4.h,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade400,
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                      ),
                    ),
                    18.verticalSpace,
                    Text(
                      'ask_new_question'.tr(),
                      style: FontStyles.body12W400.copyWith(
                        color: orange,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    8.verticalSpace,
                    Text(
                      'ask_question_description'.tr(),
                      style: FontStyles.body14W500.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.descriptionColor,
                      ),
                    ),
                    22.verticalSpace,

                    // Title
                    CustomTextField(
                      controller: _titleController,
                      label: 'question_title'.tr(),
                      hint: 'community_question_title_placeholder'.tr(),
                    ),
                    if (_titleError != null) ...[
                      6.verticalSpace,
                      Text(
                        _titleError!,
                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
                      ),
                    ],
                    18.verticalSpace,

                    // Specification
                    BlocBuilder<QuestionsCubit, QuestionsState>(
                      buildWhen: (prev, curr) =>
                          curr is SpecificationsLoading ||
                          curr is SpecificationsSuccess ||
                          curr is SpecificationsFailure,
                      builder: (context, specState) {
                        return SpecificationDropdown(
                          value: _specification,
                          isLoadingSpecs: specState is SpecificationsLoading,
                          specifications: specState is SpecificationsSuccess
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
                      6.verticalSpace,
                      Text(
                        _specError!,
                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
                      ),
                    ],
                    18.verticalSpace,

                    Text(
                      'enter_your_question'.tr(),
                      style: FontStyles.body14W700.copyWith(
                        color: AppColors.lightMainText,
                      ),
                    ),
                    8.verticalSpace,
                    Container(
                      height: 120.h,
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14.r),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: TextField(
                        controller: _bodyController,
                        maxLines: null,
                        style: TextStyle(fontSize: 16.sp),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
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
                      6.verticalSpace,
                      Text(
                        _bodyError!,
                        style: TextStyle(color: Colors.red, fontSize: 12.sp),
                      ),
                    ],
                    26.verticalSpace,

                    Center(
                      child: GestureDetector(
                        onTap: () => _validateAndSubmit(context, isLoading),
                        child: Container(
                          width: 260.w,
                          height: 50.h,
                          decoration: BoxDecoration(
                            color: isLoading ? orange.withOpacity(0.6) : orange,
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(4.r),
                              bottomLeft: Radius.circular(26.r),
                              topRight: Radius.circular(26.r),
                              bottomRight: Radius.circular(4.r),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          alignment: Alignment.center,
                          child: isLoading
                              ? SizedBox(
                                  width: 22.w,
                                  height: 22.w,
                                  child: const CircularProgressIndicator(
                                    strokeWidth: 2.4,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  'Submit your question'.tr(),
                                  style: FontStyles.headline16.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    14.verticalSpace,
                  ],
                ),
              ),
            );
          },
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
    // Show only the main category keys
    final List<String> categories = specifications.keys.toList();

    return SizedBox(
      height: 58.h,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          InputDecorator(
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              labelText: 'Specification'.tr(),
              labelStyle: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              floatingLabelStyle:
                  TextStyle(fontSize: 22.sp, color: Colors.black87),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.w,
                vertical: 14.h,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: AppColors.borderColor),
              ),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                isExpanded: true,
                value: (categories.contains(value)) ? value : null,
                dropdownColor: Colors.white,
                hint: Text(
                  isLoadingSpecs
                      ? 'loading_specifications'.tr()
                      : 'select specification for asking'.tr(),
                  style: TextStyle(fontSize: 18.sp, color: Colors.grey.shade500),
                ),
                icon:
                    Icon(Icons.expand_more, size: 26.sp, color: Colors.black87),
                items: categories
                    .map(
                      (e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(
                          e.tr(), // Translate the category key
                          style:
                              TextStyle(fontSize: 16.sp, color: Colors.black87),
                        ),
                      ),
                    )
                    .toList(),
                onChanged: isLoadingSpecs ? null : onChanged,
              ),
            ),
          ),
          if (isLoadingSpecs)
            Positioned(
              right: 40.w,
              child: SizedBox(
                width: 16.w,
                height: 16.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFFF7A3C),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
