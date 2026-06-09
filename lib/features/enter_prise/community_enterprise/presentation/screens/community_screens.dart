import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/features/viewer/home_viewer/presentation/widgets/home_top_bar.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/enums/jobs_filter.dart';
import '../../data/model/questions/response/question_response_model.dart';
import '../../data/model/jops/response/jop_item_model.dart';
import '../cubit/jops/cubit/get_all_jops_cubit.dart';
import '../cubit/questions/cubit/questions_cubit.dart';
import '../widgets/community_top_tabs.dart';
import '../widgets/community_widgets.dart';
import '../widgets/edit_question_sheet.dart';
import 'community_jobs_tab.dart';
import 'question_details_screen.dart';
import 'dart:convert';
import '../../../../../core/helpers/secure_local_storage.dart';
import '../../../../../core/app_config/prefs_keys.dart';

class CommunityScreens extends StatefulWidget {
  final int initialTabIndex;
  const CommunityScreens({super.key, this.initialTabIndex = 0});

  @override
  State<CommunityScreens> createState() => _CommunityScreensState();
}

class _CommunityScreensState extends State<CommunityScreens> {
  bool isAddingJob = false;
  bool isStudent = false;
  JobsFilter _selectedFilter = JobsFilter.yourOwn;

  dynamic _selectedJob;
  JobItemModel? _jobToEdit;
  QuestionResponseModel? _selectedQuestion;
  bool _tabListenerAttached = false;
  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final userStr = await SecureLocalStorage.read(PrefsKeys.user);
    if (userStr != null) {
      try {
        final userMap = jsonDecode(userStr);
        final type = userMap['type'];
        final userId = userMap['id'];
        // Assuming 'student' is the key for students.
        // Adjust if the backend uses a different string or int.
        if (type == 'student' || type == 'Student') {
          setState(() {
            isStudent = true;
            _selectedFilter = JobsFilter.suggested;
            _currentUserId = userId;
          });
        } else {
          setState(() {
            _currentUserId = userId;
          });
        }
      } catch (e) {
        debugPrint('Error parsing user role: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final orange = const Color(0xFFFF7A3C);
    final lightPill = const Color(0xFFFFF0E3);

    final borderRadius = BorderRadius.only(
      bottomLeft: Radius.circular(25.r),
      topRight: Radius.circular(25.r),
    );

    return MultiBlocProvider(
      providers: [
        BlocProvider<GetAllJopsCubit>(
          create: (_) =>
              getIt<GetAllJopsCubit>()
                ..getAllJops(filter: jobsFilterApiValue(_selectedFilter)),
        ),
        BlocProvider<QuestionsCubit>(
          create: (_) => getIt<QuestionsCubit>()..getQuestions(),
        ),
      ],
      child: isStudent
          ? BlocListener<QuestionsCubit, QuestionsState>(
              listener: (context, state) {
                if (state is DeleteQuestionSuccess) {
                  context.read<QuestionsCubit>().getQuestions();
                  AppMessages.showSuccess(
                    context,
                    "question_deleted_successfully".tr(),
                  );
                } else if (state is DeleteQuestionFailure) {
                  // Handle failure if needed
                }
              },
              child: WillPopScope(
                onWillPop: () async {
                  if (_selectedQuestion != null) {
                    setState(() => _selectedQuestion = null);
                    context.read<QuestionsCubit>().getQuestions();
                    return false;
                  }
                  return true;
                },
                child: Scaffold(
                  backgroundColor: AppColors.lightBGColor,
                  body: Stack(
                    children: [
                      Padding(
                        padding: REdgeInsets.symmetric(horizontal: 16.w),
                        child: Column(
                          children: [
                            30.verticalSpace,
                            HomeTopBar(showChat: true),
                            10.verticalSpace,
                            8.verticalSpace,
                            Expanded(
                              child: BlocBuilder<QuestionsCubit, QuestionsState>(
                                buildWhen: (prev, curr) =>
                                    curr is QuestionsLoading ||
                                    curr is QuestionsSuccess ||
                                    curr is QuestionsFailure ||
                                    curr is AnswersLoading ||
                                    curr is AnswersSuccess ||
                                    curr is AnswersFailure ||
                                    curr is DeleteQuestionSuccess ||
                                    curr is DeleteQuestionFailure ||
                                    curr is UpdateQuestionsSuccess ||
                                    curr is UpdateQuestionsFailure ||
                                    curr is CreateAnswerSuccess ||
                                    curr is CreateAnswerFailure ||
                                    curr is UpdateAnswerSuccess ||
                                    curr is UpdateAnswerFailure,
                                builder: (context, state) {
                                  if (_selectedQuestion == null) {
                                    if (state is QuestionsLoading) {
                                      return ListView.separated(
                                        padding: EdgeInsets.only(bottom: 90.h),
                                        itemCount: 4,
                                        separatorBuilder: (_, __) =>
                                            12.verticalSpace,
                                        itemBuilder: (_, __) =>
                                            const CommunityQuestionCardShimmer(),
                                      );
                                    } else if (state is QuestionsFailure) {
                                      return Center(
                                        child: Text(state.exception.message),
                                      );
                                    } else if (state is QuestionsSuccess) {
                                      final questions = state.questions;

                                      if (questions.isEmpty) {
                                        return Padding(
                                          padding: EdgeInsets.only(
                                            bottom: 80.h,
                                          ),
                                          child: Center(
                                            child: Text(
                                              'community_questions_empty'.tr(),
                                              style: TextStyle(
                                                fontSize: 15.sp,
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ),
                                        );
                                      }

                                      return ListView.separated(
                                        padding: EdgeInsets.only(bottom: 90.h),
                                        itemCount: questions.length,
                                        separatorBuilder: (_, __) =>
                                            12.verticalSpace,
                                        itemBuilder: (context, index) {
                                          final q = questions[index];

                                          final item = QuestionItemData(
                                            id: q.id,
                                            userName: q.authorName,
                                            avatarUrl:
                                                'https://images.pexels.com/photos/6898859/pexels-photo-6898859.jpeg?auto=compress&cs=tinysrgb&w=200',
                                            repliesCount: q.answers.length,
                                            text: q.body,
                                          );

                                          return CommunityQuestionCard(
                                            data: item,
                                            currentUserId: _currentUserId,
                                            questionAuthorId: q.author,
                                            onDelete: (id) {
                                              context
                                                  .read<QuestionsCubit>()
                                                  .deleteQuestion(
                                                    questionId: id,
                                                  );
                                            },
                                            onEdit: (question) {
                                              _openEditQuestionSheet(
                                                context,
                                                questions[index],
                                              );
                                            },
                                            onTapReplies: (id) {
                                              setState(() {
                                                _selectedQuestion = q;
                                              });
                                              context
                                                  .read<QuestionsCubit>()
                                                  .getAnswers(q.id);
                                            },
                                          );
                                        },
                                      );
                                    }

                                    return const SizedBox.shrink();
                                  }

                                  return QuestionDetailsSection(
                                    question: _selectedQuestion!,
                                    currentUserId: _currentUserId,
                                    onBack: () {
                                      setState(() {
                                        _selectedQuestion = null;
                                      });
                                      context
                                          .read<QuestionsCubit>()
                                          .getQuestions();
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_selectedQuestion == null)
                        Positioned(
                          right: 12.w,
                          bottom: 120.h,
                          child: AskQuestionFab(
                            key: const ValueKey('fab_questions'),
                            borderRadius: borderRadius,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          : DefaultTabController(
              length: 2,
              initialIndex: widget.initialTabIndex,
              child: Builder(
                builder: (context) {
                  final tabController = DefaultTabController.of(context);

                  if (!_tabListenerAttached) {
                    _tabListenerAttached = true;
                    tabController.addListener(() {
                      if (tabController.index != 0 &&
                          _selectedQuestion != null) {
                        setState(() {
                          _selectedQuestion = null;
                        });
                        context.read<QuestionsCubit>().getQuestions();
                      }
                      if (tabController.index != 1 && _selectedJob != null) {
                        setState(() {
                          _selectedJob = null;
                        });
                        // Refresh jobs list when returning to Jobs tab
                        context.read<GetAllJopsCubit>().getAllJops(
                          filter: jobsFilterApiValue(
                            isStudent ? JobsFilter.suggested : _selectedFilter,
                          ),
                        );
                      }
                    });
                  }

                  return BlocListener<QuestionsCubit, QuestionsState>(
                    listener: (context, state) {
                      if (state is DeleteQuestionSuccess) {
                        context.read<QuestionsCubit>().getQuestions();
                        AppMessages.showSuccess(
                          context,
                          "question_deleted_successfully".tr(),
                        );
                      } else if (state is DeleteQuestionFailure) {
                        // Handle failure
                      }
                    },
                    child: WillPopScope(
                      onWillPop: () async {
                        if (isStudent) {
                          if (_selectedQuestion != null) {
                            setState(() => _selectedQuestion = null);
                            context.read<QuestionsCubit>().getQuestions();
                            return false;
                          }
                          if (_selectedJob != null) {
                            setState(() => _selectedJob = null);
                            // Refresh jobs list
                            context.read<GetAllJopsCubit>().getAllJops(
                              filter: jobsFilterApiValue(JobsFilter.suggested),
                            );
                            return false;
                          }
                          return true;
                        }

                        if (tabController.index == 0 &&
                            _selectedQuestion != null) {
                          setState(() => _selectedQuestion = null);
                          context.read<QuestionsCubit>().getQuestions();
                          return false;
                        }

                        if (tabController.index == 1 && _selectedJob != null) {
                          setState(() => _selectedJob = null);
                          return false;
                        }

                        if (tabController.index == 1 && isAddingJob) {
                          setState(() => isAddingJob = false);
                          return false;
                        }
                        return true;
                      },
                      child: Scaffold(
                        backgroundColor: AppColors.lightBGColor,
                        body: Stack(
                          children: [
                            Padding(
                              padding: REdgeInsets.symmetric(horizontal: 16.w),
                              child: Column(
                                children: [
                                  30.verticalSpace,
                                  HomeTopBar(showChat: true),
                                  10.verticalSpace,
                                  if (!isStudent) CommunityTopTabs(),
                                  8.verticalSpace,
                                  Expanded(
                                    child: isStudent
                                        ? // For students, show only Questions
                                          BlocBuilder<
                                            QuestionsCubit,
                                            QuestionsState
                                          >(
                                            builder: (context, state) {
                                              if (_selectedQuestion == null) {
                                                if (state is QuestionsLoading) {
                                                  return ListView.separated(
                                                    padding: EdgeInsets.only(
                                                      bottom: 90.h,
                                                    ),
                                                    itemCount: 4,
                                                    separatorBuilder: (_, __) =>
                                                        12.verticalSpace,
                                                    itemBuilder: (_, __) =>
                                                        const CommunityQuestionCardShimmer(),
                                                  );
                                                } else if (state
                                                    is QuestionsFailure) {
                                                  return Center(
                                                    child: Text(
                                                      state.exception.message,
                                                    ),
                                                  );
                                                } else if (state
                                                    is QuestionsSuccess) {
                                                  final questions =
                                                      state.questions;

                                                  if (questions.isEmpty) {
                                                    return Padding(
                                                      padding: EdgeInsets.only(
                                                        bottom: 80.h,
                                                      ),
                                                      child: Center(
                                                        child: Text(
                                                          'community_questions_empty'
                                                              .tr(),
                                                          style: TextStyle(
                                                            fontSize: 15.sp,
                                                            color: Colors
                                                                .grey
                                                                .shade500,
                                                          ),
                                                        ),
                                                      ),
                                                    );
                                                  }

                                                  return ListView.separated(
                                                    padding: EdgeInsets.only(
                                                      bottom: 90.h,
                                                    ),
                                                    itemCount: questions.length,
                                                    separatorBuilder: (_, __) =>
                                                        12.verticalSpace,
                                                    itemBuilder: (context, index) {
                                                      final q =
                                                          questions[index];

                                                      final item = QuestionItemData(
                                                        id: q.id,
                                                        userName: q.authorName,
                                                        avatarUrl:
                                                            'https://images.pexels.com/photos/6898859/pexels-photo-6898859.jpeg?auto=compress&cs=tinysrgb&w=200',
                                                        repliesCount:
                                                            q.answers.length,
                                                        text: q.body,
                                                      );

                                                      return CommunityQuestionCard(
                                                        data: item,
                                                        currentUserId:
                                                            _currentUserId,
                                                        questionAuthorId:
                                                            q.author,
                                                        onDelete: (id) {
                                                          context
                                                              .read<
                                                                QuestionsCubit
                                                              >()
                                                              .deleteQuestion(
                                                                questionId: id,
                                                              );
                                                        },
                                                        onEdit: (question) {
                                                          _openEditQuestionSheet(
                                                            context,
                                                            questions[index],
                                                          );
                                                        },
                                                        onTapReplies: (id) {
                                                          setState(() {
                                                            _selectedQuestion =
                                                                q;
                                                          });
                                                          context
                                                              .read<
                                                                QuestionsCubit
                                                              >()
                                                              .getAnswers(q.id);
                                                        },
                                                      );
                                                    },
                                                  );
                                                }

                                                return const SizedBox.shrink();
                                              }

                                              return QuestionDetailsSection(
                                                question: _selectedQuestion!,
                                                currentUserId: _currentUserId,
                                                onBack: () {
                                                  setState(() {
                                                    _selectedQuestion = null;
                                                  });
                                                  context
                                                      .read<QuestionsCubit>()
                                                      .getQuestions();
                                                },
                                              );
                                            },
                                          )
                                        : TabBarView(
                                            children: [
                                              // ===== Questions tab
                                              BlocBuilder<
                                                QuestionsCubit,
                                                QuestionsState
                                              >(
                                                buildWhen: (prev, curr) =>
                                                    curr is QuestionsLoading ||
                                                    curr is QuestionsSuccess ||
                                                    curr is QuestionsFailure ||
                                                    curr is AnswersLoading ||
                                                    curr is AnswersSuccess ||
                                                    curr is AnswersFailure ||
                                                    curr
                                                        is DeleteQuestionSuccess ||
                                                    curr
                                                        is DeleteQuestionFailure ||
                                                    curr
                                                        is UpdateQuestionsSuccess ||
                                                    curr
                                                        is UpdateQuestionsFailure ||
                                                    curr
                                                        is CreateAnswerSuccess ||
                                                    curr
                                                        is CreateAnswerFailure ||
                                                    curr
                                                        is UpdateAnswerSuccess ||
                                                    curr is UpdateAnswerFailure,
                                                builder: (context, state) {
                                                  if (_selectedQuestion ==
                                                      null) {
                                                    if (state
                                                        is QuestionsLoading) {
                                                      return ListView.separated(
                                                        padding:
                                                            EdgeInsets.only(
                                                              bottom: 90.h,
                                                            ),
                                                        itemCount: 4,
                                                        separatorBuilder:
                                                            (_, __) => 12
                                                                .verticalSpace,
                                                        itemBuilder: (_, __) =>
                                                            const CommunityQuestionCardShimmer(),
                                                      );
                                                    } else if (state
                                                        is QuestionsFailure) {
                                                      return Center(
                                                        child: Text(
                                                          state
                                                              .exception
                                                              .message,
                                                        ),
                                                      );
                                                    } else if (state
                                                        is QuestionsSuccess) {
                                                      final questions =
                                                          state.questions;

                                                      if (questions.isEmpty) {
                                                        return Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                bottom: 80.h,
                                                              ),
                                                          child: Center(
                                                            child: Text(
                                                              'community_questions_empty'
                                                                  .tr(),
                                                              style: TextStyle(
                                                                fontSize: 15.sp,
                                                                color: Colors
                                                                    .grey
                                                                    .shade500,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      }

                                                      return ListView.separated(
                                                        padding:
                                                            EdgeInsets.only(
                                                              bottom: 90.h,
                                                            ),
                                                        itemCount:
                                                            questions.length,
                                                        separatorBuilder:
                                                            (_, __) => 12
                                                                .verticalSpace,
                                                        itemBuilder: (context, index) {
                                                          final q =
                                                              questions[index];

                                                          final item =
                                                              QuestionItemData(
                                                                id: q.id,
                                                                userName: q
                                                                    .authorName,
                                                                avatarUrl:
                                                                    'https://images.pexels.com/photos/6898859/pexels-photo-6898859.jpeg?auto=compress&cs=tinysrgb&w=200',
                                                                repliesCount: q
                                                                    .answers
                                                                    .length,
                                                                text: q.body,
                                                              );

                                                          return CommunityQuestionCard(
                                                            data: item,
                                                            currentUserId:
                                                                _currentUserId,
                                                            questionAuthorId:
                                                                q.author,
                                                            onDelete: (id) {
                                                              context
                                                                  .read<
                                                                    QuestionsCubit
                                                                  >()
                                                                  .deleteQuestion(
                                                                    questionId:
                                                                        id,
                                                                  );
                                                            },
                                                            onEdit: (question) {
                                                              _openEditQuestionSheet(
                                                                context,
                                                                questions[index],
                                                              );
                                                            },
                                                            onTapReplies: (id) {
                                                              setState(() {
                                                                _selectedQuestion =
                                                                    q;
                                                              });
                                                              context
                                                                  .read<
                                                                    QuestionsCubit
                                                                  >()
                                                                  .getAnswers(
                                                                    q.id,
                                                                  );
                                                            },
                                                          );
                                                        },
                                                      );
                                                    }

                                                    return const SizedBox.shrink();
                                                  }

                                                  return QuestionDetailsSection(
                                                    question:
                                                        _selectedQuestion!,
                                                    currentUserId:
                                                        _currentUserId,
                                                    onBack: () {
                                                      setState(() {
                                                        _selectedQuestion =
                                                            null;
                                                      });
                                                      context
                                                          .read<
                                                            QuestionsCubit
                                                          >()
                                                          .getQuestions();
                                                    },
                                                  );
                                                },
                                              ),

                                              // ===== Jobs tab
                                              CommunityJobsTab(
                                                lightPill: lightPill,
                                                isAddingJob: isAddingJob,
                                                isStudent: isStudent,
                                                selectedFilter: isStudent
                                                    ? JobsFilter.suggested
                                                    : _selectedFilter,
                                                selectedJob: _selectedJob,
                                                jobToEdit: _jobToEdit,
                                                onJobSelected: (job) {
                                                  setState(() {
                                                    _selectedJob = job;
                                                  });
                                                },
                                                onFilterChanged: (value) {
                                                  setState(() {
                                                    _selectedFilter = value;
                                                  });
                                                  context
                                                      .read<GetAllJopsCubit>()
                                                      .getAllJops(
                                                        filter:
                                                            jobsFilterApiValue(
                                                              value,
                                                            ),
                                                      );
                                                },
                                                onEditJob: (job) {
                                                  setState(() {
                                                    _jobToEdit = job;
                                                    isAddingJob = true;
                                                    _selectedJob =
                                                        null; // Close details screen
                                                  });
                                                },
                                                onJobCreated: () {
                                                  setState(() {
                                                    isAddingJob = false;
                                                    _jobToEdit = null;
                                                  });
                                                  context
                                                      .read<GetAllJopsCubit>()
                                                      .getAllJops(
                                                        filter:
                                                            jobsFilterApiValue(
                                                              _selectedFilter,
                                                            ),
                                                      );
                                                },
                                              ),
                                            ],
                                          ),
                                  ),
                                ],
                              ),
                            ),

                            Positioned(
                              right: 12.w,
                              bottom: 120.h,
                              child: AnimatedBuilder(
                                animation: tabController,
                                builder: (context, _) {
                                  if (tabController.index != 1 && isAddingJob) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (mounted) {
                                            setState(() => isAddingJob = false);
                                          }
                                        });
                                  }

                                  Widget fab = const SizedBox.shrink(
                                    key: ValueKey('fab_none'),
                                  );

                                  if (tabController.index == 0 &&
                                      _selectedQuestion == null) {
                                    fab = AskQuestionFab(
                                      key: const ValueKey('fab_questions'),
                                      borderRadius: borderRadius,
                                    );
                                  } else if (tabController.index == 1 &&
                                      !isAddingJob &&
                                      !isStudent &&
                                      _selectedJob == null &&
                                      _selectedFilter == JobsFilter.yourOwn) {
                                    fab = PostJobFab(
                                      key: const ValueKey('fab_jobs'),
                                      borderRadius: borderRadius,
                                      onTap: () {
                                        setState(() {
                                          isAddingJob = true;
                                          _jobToEdit = null;
                                        });
                                      },
                                    );
                                  }

                                  return AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 250),
                                    transitionBuilder: (child, animation) {
                                      return ScaleTransition(
                                        scale: animation,
                                        child: FadeTransition(
                                          opacity: animation,
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: fab,
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

void _openEditQuestionSheet(
  BuildContext context,
  QuestionResponseModel question,
) {
  final questionsCubit = context.read<QuestionsCubit>();
  showModalBottomSheet(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      return BlocProvider.value(
        value: questionsCubit,
        child: EditQuestionBottomSheet(question: question),
      );
    },
  );
}
