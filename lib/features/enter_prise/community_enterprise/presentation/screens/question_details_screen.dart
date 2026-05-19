import 'package:aflam/config/routes/routes.dart';
import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_icons.dart';
import 'package:aflam/core/app_config/font_styles.dart';
import 'package:aflam/core/widgets/svg_image/svg_image_widget.dart';
import 'package:aflam/features/enter_prise/profile_enterprise/presentation/utils/user_model_helper.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../../core/helpers/messages.dart';
import '../cubit/questions/cubit/questions_cubit.dart';
import '../../data/model/questions/request/create_answer_request_model.dart';
import '../../data/model/questions/response/question_answer_model.dart';
import '../../data/model/questions/response/question_response_model.dart';
import '../widgets/edit_question_sheet.dart';

class QuestionDetailsSection extends StatefulWidget {
  final QuestionResponseModel question;
  final int? currentUserId;
  final VoidCallback onBack;

  const QuestionDetailsSection({
    super.key,
    required this.question,
    this.currentUserId,
    required this.onBack,
  });

  @override
  State<QuestionDetailsSection> createState() => _QuestionDetailsSectionState();
}

class _QuestionDetailsSectionState extends State<QuestionDetailsSection> {
  late final TextEditingController _replyController;

  List<QuestionAnswerModel> _answers = [];
  int? _editingAnswerId;

  @override
  void initState() {
    super.initState();
    _replyController = TextEditingController();
    context.read<QuestionsCubit>().getAnswers(widget.question.id);
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  void _startEditing(QuestionAnswerModel answer) {
    setState(() {
      _editingAnswerId = answer.id;
      _replyController.text = answer.body;
    });
  }

  void _clearEditing() {
    setState(() {
      _editingAnswerId = null;
      _replyController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF7A3C);

    return BlocListener<QuestionsCubit, QuestionsState>(
      listener: (context, state) {
        if (state is AnswersSuccess) {
          setState(() {
            _answers = state.answers;
          });
        } else if (state is CreateAnswerSuccess) {
          AppMessages.showSuccess(context, 'answer_added_successfully'.tr());
          setState(() {
            _answers.add(state.answer);
          });
          _replyController.clear();
        } else if (state is CreateAnswerFailure) {
          AppMessages.showError(context, state.exception.message);
        } else if (state is UpdateAnswerSuccess) {
          AppMessages.showSuccess(context, 'answer_updated_successfully'.tr());
          final updated = state.answer;
          setState(() {
            final index = _answers.indexWhere(
              (element) => element.id == updated.id,
            );
            if (index != -1) {
              _answers[index] = updated;
            }
          });
          _clearEditing();
        } else if (state is UpdateAnswerFailure) {
          AppMessages.showError(context, state.exception.message);
        } else if (state is DeleteAnswerFailure) {
          AppMessages.showError(context, state.exception.message);
        }
      },
      child: BlocBuilder<QuestionsCubit, QuestionsState>(
        builder: (context, state) {
          final bool isSending =
              state is CreateAnswerLoading || state is UpdateAnswerLoading;

          final bool isAnswersLoading =
              state is AnswersLoading && _answers.isEmpty;

          final answersToShow = _answers.isNotEmpty
              ? _answers
              : (widget.question.answers);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back_ios_new, size: 18),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  8.horizontalSpace,
                  Text(
                    'Questions'.tr(),
                    style: FontStyles.body14W700.copyWith(
                      fontSize: 18.sp,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              14.verticalSpace,
              _QuestionHeaderCard(
                question: widget.question,
                currentUserId: widget.currentUserId,
                repliesCount: answersToShow.length,
              ),
              20.verticalSpace,
              Text(
                'community_replies_label'.tr(),
                style: FontStyles.body14W700.copyWith(
                  color: AppColors.lightMainText,
                  fontSize: 15.sp,
                ),
              ),
              10.verticalSpace,
              Expanded(
                child: isAnswersLoading
                    ? ListView.separated(
                        padding: EdgeInsets.only(bottom: 20.h),
                        itemCount: 3,
                        separatorBuilder: (_, __) => 12.verticalSpace,
                        itemBuilder: (_, __) => const _ReplyCardShimmer(),
                      )
                    : answersToShow.isEmpty
                    ? Center(
                        child: Text(
                          'community_replies_empty'.tr(),
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      )
                    : ListView.separated(
                        padding: EdgeInsets.only(bottom: 20.h),
                        itemCount: answersToShow.length,
                        separatorBuilder: (_, __) => 12.verticalSpace,
                        itemBuilder: (context, index) {
                          final reply = answersToShow[index];
                          final bool canManage =
                              widget.currentUserId != null &&
                              reply.author == widget.currentUserId;

                          return _ReplyCard(
                            authorId: reply.author,
                            name: reply.authorName,
                            body: reply.body,
                            canManage: canManage,
                            onEdit: canManage
                                ? () => _startEditing(reply)
                                : null,
                            onDelete: canManage
                                ? () {
                                    AppMessages.showSuccess(
                                      context,
                                      'answer_deleted_successfully'.tr(),
                                    );
                                    setState(() {
                                      _answers.removeWhere(
                                        (element) => element.id == reply.id,
                                      );
                                    });
                                    context.read<QuestionsCubit>().deleteAnswer(
                                      answerId: reply.id,
                                    );
                                  }
                                : null,
                          );
                        },
                      ),
              ),
              SafeArea(
                top: false,
                child: Column(
                  children: [
                    _ReplyInputBar(
                      orange: orange,
                      controller: _replyController,
                      isSending: isSending,
                      isEditing: _editingAnswerId != null,
                      onSend: () {
                        final text = _replyController.text.trim();
                        if (text.isEmpty) return;

                        if (_editingAnswerId != null) {
                          context.read<QuestionsCubit>().updateAnswer(
                            answerId: _editingAnswerId!,
                            body: text,
                          );
                        } else {
                          context.read<QuestionsCubit>().createAnswer(
                            model: CreateAnswerRequestModel(
                              question: widget.question.id,
                              body: text,
                            ),
                          );
                        }
                      },
                      onCancelEdit: _editingAnswerId != null
                          ? _clearEditing
                          : null,
                    ),
                    12.verticalSpace,
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuestionHeaderCard extends StatelessWidget {
  final QuestionResponseModel question;
  final int? currentUserId;
  final int repliesCount;

  const _QuestionHeaderCard({
    required this.question,
    this.currentUserId,
    required this.repliesCount,
  });

  @override
  Widget build(BuildContext context) {
    final bool canManage =
        currentUserId != null && currentUserId == question.author;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F0FF),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final userModel = UserModelHelper.createFromPartialData(
                      id: question.author,
                      fullname: question.authorName,
                      email: null,
                      profilePhoto:
                          'https://images.pexels.com/photos/6898859/pexels-photo-6898859.jpeg?auto=compress&cs=tinysrgb&w=200',
                      specification: question.authorSpecification,
                    );
                    context.pushNamed(Routes.userProfile, extra: userModel);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Image.network(
                      'https://images.pexels.com/photos/6898859/pexels-photo-6898859.jpeg?auto=compress&cs=tinysrgb&w=200',
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: Text(
                    question.authorName,
                    style: FontStyles.body14W700.copyWith(
                      fontSize: 18.sp,
                      color: const Color(0xFF3A3A3A),
                    ),
                  ),
                ),
                if (canManage) ...[
                  8.horizontalSpace,
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F0),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18.sp,
                      onPressed: () {
                        // Open edit sheet
                        final questionsCubit = context.read<QuestionsCubit>();
                        showModalBottomSheet(
                          context: context,
                          useRootNavigator: true,
                          isScrollControlled: true,
                          backgroundColor: Colors.transparent,
                          builder: (sheetContext) {
                            return BlocProvider.value(
                              value: questionsCubit,
                              child: EditQuestionBottomSheet(
                                question: question,
                              ),
                            );
                          },
                        );
                      },
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFFFF7A3C),
                      ),
                    ),
                  ),
                  8.horizontalSpace,
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18.sp,
                      onPressed: () {
                        // Delete question
                        context.read<QuestionsCubit>().deleteQuestion(
                          questionId: question.id,
                        );
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
                8.horizontalSpace,
                SvgImageWidget(
                  image: AppIcons.commentMessage,
                  width: 18.w,
                  height: 18.h,
                ),
                4.horizontalSpace,
                Text(
                  repliesCount.toString(),
                  style: FontStyles.body12W400.copyWith(
                    fontSize: 13.sp,
                    color: const Color(0xFF8C8C8C),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFE0D9F5)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Text(
              question.body,
              style: FontStyles.body14W500.copyWith(
                fontSize: 17.sp,
                color: const Color(0xFF727272),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyCard extends StatelessWidget {
  final int authorId;
  final String name;
  final String body;
  final bool canManage;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const _ReplyCard({
    required this.authorId,
    required this.name,
    required this.body,
    required this.canManage,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightBGColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE8E5DE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    final userModel = UserModelHelper.createFromPartialData(
                      id: authorId,
                      fullname: name,
                      email: null,
                      profilePhoto:
                          'https://images.pexels.com/photos/6898859/pexels-photo-6898859.jpeg?auto=compress&cs=tinysrgb&w=200',
                      specification: null,
                    );
                    context.pushNamed(Routes.userProfile, extra: userModel);
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6.r),
                    child: Image.network(
                      'https://images.pexels.com/photos/6898859/pexels-photo-6898859.jpeg?auto=compress&cs=tinysrgb&w=200',
                      width: 50.w,
                      height: 50.w,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                8.horizontalSpace,
                Expanded(
                  child: Text(
                    name,
                    style: FontStyles.body14W700.copyWith(
                      fontSize: 18.sp,
                      color: const Color(0xFF3A3A3A),
                    ),
                  ),
                ),
                if (canManage) ...[
                  8.horizontalSpace,
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF5F0),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18.sp,
                      onPressed: onEdit,
                      icon: const Icon(
                        Icons.edit_outlined,
                        color: Color(0xFFFF7A3C),
                      ),
                    ),
                  ),
                  8.horizontalSpace,
                  Container(
                    width: 32.w,
                    height: 32.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF0F0),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      iconSize: 18.sp,
                      onPressed: onDelete,
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, thickness: 0.8, color: Color(0xFFEAEAEA)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            child: Text(
              body,
              style: FontStyles.body14W500.copyWith(
                fontSize: 17.sp,
                color: const Color(0xFF727272),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReplyCardShimmer extends StatelessWidget {
  const _ReplyCardShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightBGColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: const Color(0xFFE8E5DE)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Row(
                children: [
                  Container(
                    width: 50.w,
                    height: 50.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6.r),
                      color: Colors.grey.shade300,
                    ),
                  ),
                  8.horizontalSpace,
                  Container(
                    height: 14.h,
                    width: 120.w,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, thickness: 0.8, color: Color(0xFFEAEAEA)),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 12.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.grey.shade300,
                    ),
                  ),
                  6.verticalSpace,
                  Container(
                    height: 12.h,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.r),
                      color: Colors.grey.shade300,
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

class _ReplyInputBar extends StatelessWidget {
  final Color orange;
  final TextEditingController controller;
  final bool isSending;
  final bool isEditing;
  final VoidCallback onSend;
  final VoidCallback? onCancelEdit;

  const _ReplyInputBar({
    required this.orange,
    required this.controller,
    required this.isSending,
    required this.isEditing,
    required this.onSend,
    this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72.h,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 72.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.borderColor),
            ),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            child: Row(
              children: [
                if (isEditing && onCancelEdit != null) ...[
                  InkWell(
                    onTap: onCancelEdit,
                    child: Padding(
                      padding: EdgeInsets.only(right: 8.w),
                      child: Text(
                        'Cancel'.tr(),
                        style: FontStyles.body12W400.copyWith(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
                Expanded(
                  child: TextField(
                    controller: controller,
                    maxLines: null,
                    textAlignVertical: TextAlignVertical.top,
                    decoration: InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      hintText: isEditing
                          ? 'community_reply_edit_placeholder'.tr()
                          : 'community_reply_share_placeholder'.tr(),
                      hintStyle: FontStyles.body14W500.copyWith(
                        fontSize: 14.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    style: FontStyles.body14W500.copyWith(
                      fontSize: 14.sp,
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 10.w,
            bottom: 8.h,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(24.r),
                onTap: isSending ? null : onSend,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  transitionBuilder: (child, animation) =>
                      ScaleTransition(scale: animation, child: child),
                  child: isSending
                      ? Shimmer.fromColors(
                          key: const ValueKey('sending'),
                          baseColor: orange.withOpacity(0.6),
                          highlightColor: Colors.white,
                          child: Container(
                            width: 28.w,
                            height: 28.w,
                            decoration: BoxDecoration(
                              color: orange,
                              shape: BoxShape.circle,
                            ),
                          ),
                        )
                      : SvgImageWidget(
                          key: const ValueKey('send'),
                          image: AppIcons.sendMessage,
                          width: 24.w,
                          height: 24.h,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
