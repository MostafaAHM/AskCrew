import 'dart:io';

import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/app_config/font_styles.dart';
import '../cubit/jops/cubit/get_all_jops_cubit.dart';
import '../../data/model/jops/request/create_job_request_model.dart';

import 'package:aflam/features/enter_prise/community_enterprise/data/model/jops/response/jop_item_model.dart';

class PostJobScreen extends StatefulWidget {
  final VoidCallback? onJobCreated;
  final JobItemModel? jobToEdit;

  const PostJobScreen({super.key, this.onJobCreated, this.jobToEdit});

  @override
  State<PostJobScreen> createState() => _PostJobScreenState();
}

class _PostJobScreenState extends State<PostJobScreen> {
  final _companyNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _aboutWorkshopController = TextEditingController();

  File? _logoFile;
  String? _existingLogoUrl;

  @override
  void initState() {
    super.initState();
    if (widget.jobToEdit != null) {
      _companyNameController.text = widget.jobToEdit!.companyName;
      _jobTitleController.text = widget.jobToEdit!.jobTitle;
      _aboutWorkshopController.text = widget.jobToEdit!.about;
      _existingLogoUrl = widget.jobToEdit!.image;
    }
  }

  @override
  void dispose() {
    _companyNameController.dispose();
    _jobTitleController.dispose();
    _aboutWorkshopController.dispose();
    super.dispose();
  }

  Future<void> _pickLogo() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _logoFile = File(result.files.single.path!);
      });
    }
  }

  void _submit() {
    final company = _companyNameController.text.trim();
    final title = _jobTitleController.text.trim();
    final about = _aboutWorkshopController.text.trim();

    if (company.isEmpty || title.isEmpty || about.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('please_fill_all_fields'.tr())));
      return;
    }

    final model = CreateJobRequestModel(
      companyName: company,
      jobTitle: title,
      about: about,
      isActive: true,
      image: _logoFile,
    );

    if (widget.jobToEdit != null) {
      context.read<GetAllJopsCubit>().updateJob(
        jobId: widget.jobToEdit!.id,
        model: model,
      );
    } else {
      context.read<GetAllJopsCubit>().createJob(model: model);
    }
  }

  @override
  Widget build(BuildContext context) {
    final titleStyle = FontStyles.headline16.copyWith(
      fontSize: 18.sp,
      fontWeight: FontWeight.w700,
      color: AppColors.lightMainText,
    );

    final subtitleStyle = FontStyles.body12W400.copyWith(
      color: AppColors.descriptionColor,
      height: 1.4,
    );

    final isEditing = widget.jobToEdit != null;

    return BlocListener<GetAllJopsCubit, GetAllJopsState>(
      listener: (context, state) async {
        if (state is CreateJobLoading || state is UpdateJobLoading) {
          AppMessages.showLoading(context);
        } else {
          AppMessages.hideLoading(context);
        }

        if (state is CreateJobSuccess) {
          AppMessages.showSuccess(context, 'job_created_successfully'.tr());
          _clearForm();
          context.read<GetAllJopsCubit>().getAllJops();
          widget.onJobCreated?.call();
        } else if (state is UpdateJobSuccess) {
          AppMessages.showSuccess(context, 'job_updated_successfully'.tr());
          context.read<GetAllJopsCubit>().getAllJops();
          widget.onJobCreated?.call(); // Go back or refresh
        }

        if (state is CreateJobFailure) {
          AppMessages.showError(context, state.exception.message);
        } else if (state is UpdateJobFailure) {
          AppMessages.showError(context, state.exception.message);
        }
      },
      child: BlocBuilder<GetAllJopsCubit, GetAllJopsState>(
        buildWhen: (prev, curr) =>
            curr is CreateJobLoading ||
            curr is CreateJobFailure ||
            curr is CreateJobInitial ||
            curr is UpdateJobLoading ||
            curr is UpdateJobFailure ||
            curr is UpdateJobInitial,
        builder: (context, state) {
          final isLoading =
              state is CreateJobLoading || state is UpdateJobLoading;

          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.only(
              left: 16.w,
              right: 16.w,
              top: 8.h,
              bottom:
                  100.h, // Extra padding at bottom for keyboard and scrolling
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isEditing ? 'Edit Job' : 'add_company_info_title'.tr(),
                  style: titleStyle,
                ),
                8.verticalSpace,
                Text(
                  isEditing
                      ? 'Update your job details'
                      : 'add_company_info_subtitle'.tr(),
                  style: subtitleStyle,
                ),
                24.verticalSpace,
                CustomTextField(
                  label: 'company_name'.tr(),
                  hint: 'enter_company_name'.tr(),
                  controller: _companyNameController,
                ),
                20.verticalSpace,
                CustomTextField(
                  label: 'job_title'.tr(),
                  hint: 'enter_job_title'.tr(),
                  controller: _jobTitleController,
                ),
                24.verticalSpace,
                Text(
                  'upload_logo_title'.tr(),
                  style: FontStyles.body14W500.copyWith(
                    color: AppColors.lightMainText,
                  ),
                ),
                12.verticalSpace,
                _UploadLogoBox(
                  onTap: isLoading ? () {} : _pickLogo,
                  logoFile: _logoFile,
                  existingUrl: _existingLogoUrl,
                ),
                24.verticalSpace,
                CustomTextField(
                  label: 'about_job'.tr(),
                  hint: 'enter_about_job'.tr(),
                  controller: _aboutWorkshopController,
                  keyboardType: TextInputType.multiline,
                  minLines: 4,
                  maxLines: 8,
                ),
                32.verticalSpace,
                CustomButton(
                  text: isLoading
                      ? 'loading'.tr()
                      : (isEditing ? 'Update' : 'confirm'.tr()),
                  onTap: isLoading ? () {} : _submit,
                  isBackgroundGradient: true,
                  height: 50.h,
                  style: FontStyles.body14W500.copyWith(
                    color: Colors.white,
                    fontSize: 18.sp,
                  ),
                ),
                40.verticalSpace,
              ],
            ),
          );
        },
      ),
    );
  }

  void _clearForm() {
    _companyNameController.clear();
    _jobTitleController.clear();
    _aboutWorkshopController.clear();
    setState(() {
      _logoFile = null;
      _existingLogoUrl = null;
    });
  }
}

class _UploadLogoBox extends StatelessWidget {
  final VoidCallback onTap;
  final File? logoFile;
  final String? existingUrl;

  const _UploadLogoBox({required this.onTap, this.logoFile, this.existingUrl});

  @override
  Widget build(BuildContext context) {
    final hasNewLogo = logoFile != null;
    final hasExistingLogo = existingUrl != null && existingUrl!.isNotEmpty;
    final hasLogo = hasNewLogo || hasExistingLogo;

    final path = logoFile?.path ?? '';
    final fileName = hasNewLogo
        ? path.split(Platform.pathSeparator).last
        : (hasExistingLogo ? 'Existing Logo' : '');

    final icon = Icon(
      hasLogo ? Icons.check_rounded : Icons.upload_rounded,
      size: 22,
      color: hasLogo ? Colors.green : AppColors.lightGreyText,
    );

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
        decoration: BoxDecoration(
          color: AppColors.lightBGColor,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: hasLogo ? Colors.green : AppColors.borderColor,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
              child: Center(child: icon),
            ),
            12.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'upload_logo_title'.tr(),
                    style: FontStyles.body14W500.copyWith(
                      color: AppColors.lightMainText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  4.verticalSpace,
                  Text(
                    'upload_logo_subtitle'.tr(),
                    style: FontStyles.body12W400.copyWith(
                      color: AppColors.lightGreyText,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (hasLogo) ...[
                    6.verticalSpace,
                    Text(
                      fileName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FontStyles.body12W400.copyWith(
                        color: AppColors.lightMainText,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
