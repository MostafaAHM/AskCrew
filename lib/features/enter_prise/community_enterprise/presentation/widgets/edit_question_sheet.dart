import 'package:aflam/core/widgets/animated_loading/animated_loading.dart';
import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/font_styles.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../data/model/questions/response/question_response_model.dart';
import '../../data/model/questions/request/create_question_request_model.dart';
import '../cubit/questions/cubit/questions_cubit.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ask_question_bottom_sheet.dart';

class EditQuestionBottomSheet extends StatefulWidget {
  final QuestionResponseModel question;

  const EditQuestionBottomSheet({super.key, required this.question});

  @override
  State<EditQuestionBottomSheet> createState() =>
      _EditQuestionBottomSheetState();
}

class _EditQuestionBottomSheetState extends State<EditQuestionBottomSheet> {
  late TextEditingController _titleController;
  late TextEditingController _bodyController;

  String? _specification;

  String? _titleError;
  String? _bodyError;
  String? _specError;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.question.title);
    _bodyController = TextEditingController(text: widget.question.body);
    _specification = widget.question.specification;
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

    context.read<QuestionsCubit>().updateQuestion(
      questionId: widget.question.id,
      model: model,
    );
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF7A3C);

    return BlocConsumer<QuestionsCubit, QuestionsState>(
      listener: (context, state) {
        if (state is UpdateQuestionsSuccess) {
          context.read<QuestionsCubit>().getQuestions();
          Navigator.pop(context);
        }
        if (state is UpdateQuestionsFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.exception.message)));
        }
      },
      builder: (context, state) {
        final bool isLoading = state is UpdateQuestionsLoading;

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
                      'community_question_edit_title'.tr(),
                      style: FontStyles.body12W400.copyWith(
                        color: orange,
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    8.verticalSpace,
                    Text(
                      'community_question_edit_description'.tr(),
                      style: FontStyles.body14W500.copyWith(
                        fontSize: 16.sp,
                        color: AppColors.descriptionColor,
                      ),
                    ),
                    22.verticalSpace,
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
                    SpecificationDropdown(
                      value: _specification,
                      onChanged: (val) {
                        setState(() {
                          _specification = val;
                          _specError = null;
                        });
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
                      'Enter your question'.tr(),
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
                                  child: const AnimatedLoading(color: Colors.white),
                                )
                              : Text(
                                  'saveChanges'.tr(),
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
