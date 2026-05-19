import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../cubit/student_onboarding_cubit.dart';
import '../cubit/student_onboarding_state.dart';

class SocialMediaStep extends StatefulWidget {
  const SocialMediaStep({super.key});

  @override
  State<SocialMediaStep> createState() => _SocialMediaStepState();
}

class _SocialMediaStepState extends State<SocialMediaStep> {
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();
  final _youtubeController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _isVisible = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _facebookController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    _youtubeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StudentOnboardingCubit, StudentOnboardingState>(
      builder: (context, state) {
        if (state is! StudentOnboardingInProgress) {
          return const SizedBox.shrink();
        }

        final cubit = context.read<StudentOnboardingCubit>();
        final facebookLink = state.data.facebookLink;
        final instagramLink = state.data.instagramLink;
        final linkedinLink = state.data.linkedinLink;
        final youtubeLink = state.data.youtubeLink;
        final emailAddress = state.data.emailAddress;

        if (facebookLink != null && _facebookController.text.isEmpty) {
          _facebookController.text = facebookLink;
        }
        if (instagramLink != null && _instagramController.text.isEmpty) {
          _instagramController.text = instagramLink;
        }
        if (linkedinLink != null && _linkedinController.text.isEmpty) {
          _linkedinController.text = linkedinLink;
        }
        if (youtubeLink != null && _youtubeController.text.isEmpty) {
          _youtubeController.text = youtubeLink;
        }
        if (emailAddress != null && _emailController.text.isEmpty) {
          _emailController.text = emailAddress;
        }

        final fields = <Widget>[
          CustomTextField(
            label: 'facebook'.tr(),
            hint: 'facebookLink'.tr(),
            controller: _facebookController,
            keyboardType: TextInputType.url,
            onChanged: (value) {
              cubit.updateFacebookLink(value);
            },
          ),
          CustomTextField(
            label: 'instagram'.tr(),
            hint: 'instagramLink'.tr(),
            controller: _instagramController,
            keyboardType: TextInputType.url,
            onChanged: (value) {
              cubit.updateInstagramLink(value);
            },
          ),
          CustomTextField(
            label: 'linkedin'.tr(),
            hint: 'linkedinLink'.tr(),
            controller: _linkedinController,
            keyboardType: TextInputType.url,
            onChanged: (value) {
              cubit.updateLinkedinLink(value);
            },
          ),
          CustomTextField(
            label: 'youtube'.tr(),
            hint: 'youtubeLink'.tr(),
            controller: _youtubeController,
            keyboardType: TextInputType.url,
            onChanged: (value) {
              cubit.updateYoutubeLink(value);
            },
          ),
          CustomTextField(
            label: 'emailAddress'.tr(),
            hint: 'emailLink'.tr(),
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            onChanged: (value) {
              cubit.updateEmailAddress(value);
            },
          ),
        ];

        return AnimatedOpacity(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOut,
          opacity: _isVisible ? 1 : 0,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOut,
            offset: _isVisible ? Offset.zero : const Offset(0, 0.04),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  24.height,
                  Text(
                    'shareYourSocialMedia'.tr(),
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.lightTText,
                    ),
                  ),
                  8.height,
                  Text(
                    'shareSocialMediaDescription'.tr(),
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                  32.height,
                  ...fields.asMap().entries.map((entry) {
                    final index = entry.key;
                    final field = entry.value;
                    return TweenAnimationBuilder<double>(
                      tween: Tween(begin: 18, end: 0),
                      duration: Duration(milliseconds: 200 + index * 70),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index == fields.length - 1 ? 24.h : 20.h,
                          ),
                          child: Transform.translate(
                            offset: Offset(0, value),
                            child: Opacity(
                              opacity: 1 - (value / 18).clamp(0, 1),
                              child: child,
                            ),
                          ),
                        );
                      },
                      child: field,
                    );
                  }),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
