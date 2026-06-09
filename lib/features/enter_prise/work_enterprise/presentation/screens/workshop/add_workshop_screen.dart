import 'dart:io';

import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/animations/animated_slide_in.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:aflam/core/widgets/fields/custom_drop_down_field.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/presentation/widgets/dashed_border_container.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/request/create_workshop_request_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/data/models/response/workshop_response_model.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_cubit.dart';
import 'package:aflam/features/enter_prise/work_enterprise/presentation/cubit/workshop/workshop_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddWorkshopScreen extends StatefulWidget {
  final WorkshopResponseModel? workshopToUpdate;
  final VoidCallback? onBack;

  const AddWorkshopScreen({super.key, this.workshopToUpdate, this.onBack});

  @override
  State<AddWorkshopScreen> createState() => _AddWorkshopScreenState();
}

class _AddWorkshopScreenState extends State<AddWorkshopScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late WorkshopCubit _workshopCubit;
  final _formKey = GlobalKey<FormState>();
  final _workshopNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _numberOfParticipantsController = TextEditingController();

  String? _selectedSpecialization;

  File? _selectedPicture;
  String? _coverImageUrl;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isUpdate = false;

  Color get _orange => const Color(0xFFFF7A3C);

  // Specialization options from the image
  static const List<String> _specializations = [
    'Director',
    'Copywriter',
    'Assistant Director',
    'Camera Operator',
    'Film Distributor',
    'Mentor',
    'Makeup Artist',
    'Sound Engineer',
    'Producer',
    'Photography',
    'Art Director',
    'Video Editor',
    'VFX Artist',
    'Stylist',
    'Casting Director',
    'Studio Owner',
  ];

  @override
  void initState() {
    super.initState();
    _workshopCubit = getIt<WorkshopCubit>();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    if (widget.workshopToUpdate != null) {
      _isUpdate = true;
      _populateData();
    }
  }

  void _populateData() {
    final workshop = widget.workshopToUpdate!;
    _workshopNameController.text = workshop.name;
    _descriptionController.text = workshop.description;
    _locationController.text = workshop.location;
    _selectedSpecialization = workshop.specialization;
    _numberOfParticipantsController.text = workshop.numberOfParticipants
        .toString();
    _startDate = workshop.startDate;
    _endDate = workshop.endDate;
    _coverImageUrl = workshop.coverImage;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _workshopNameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _numberOfParticipantsController.dispose();
    _workshopCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _workshopCubit,
      child: BlocListener<WorkshopCubit, WorkshopState>(
        listener: (context, state) {
          if (state is WorkshopSuccess) {
            AppMessages.hideLoading(context);
            AppMessages.showSuccess(context, state.message);
            widget.onBack?.call();
          } else if (state is WorkshopDeleteSuccess) {
            AppMessages.hideLoading(context);
            AppMessages.showSuccess(context, state.message);
            widget.onBack?.call();
          } else if (state is WorkshopError) {
            AppMessages.hideLoading(context);
            AppMessages.showError(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.lightBGColor,
          body: SafeArea(
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.only(
                left: 16.w,
                right: 16.w,
                top: 0,
                bottom: 100.h,
              ),
              child: AnimatedSlideIn(
                index: 0,
                controller: _animationController,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title with back button
                      Row(
                        children: [
                          IconButton(
                            onPressed:
                                widget.onBack ?? () => Navigator.pop(context),
                            icon: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 20,
                            ),
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          8.width,
                          Expanded(
                            child: Text(
                              _isUpdate
                                  ? 'Update Workshop'
                                  : 'Add all info about your Workshop',
                              style: TextStyle(
                                fontSize: 22.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      8.height,
                      // Description
                      Padding(
                        padding: EdgeInsets.only(left: 28.w),
                        child: Text(
                          'Upload all data about your workshop to help other to know more about it.',
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                      ),
                      24.height,
                      // Workshop Name Field
                      CustomTextField(
                        label: 'workshopName'.tr(),
                        hint: 'enterWorkshopName'.tr(),
                        controller: _workshopNameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'workshopNameRequired'.tr();
                          }
                          return null;
                        },
                      ),
                      24.height,
                      // Location Field
                      CustomTextField(
                        label: 'common_location'.tr(),
                        hint: 'enterLocation'.tr(),
                        controller: _locationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'locationRequired'.tr();
                          }
                          return null;
                        },
                      ),
                      24.height,
                      // Specialization Dropdown Field
                      CustomDropDownField<String>(
                        label: 'specification'.tr(),
                        hint: 'common_choose_specialization'.tr(),
                        value: _selectedSpecialization,
                        items: _specializations.map((spec) {
                          return DropdownMenuItem<String>(
                            value: spec,
                            child: Text(
                              spec,
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: const Color(0xFF101828),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedSpecialization = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.toString().isEmpty) {
                            return 'specializationRequired'.tr();
                          }
                          return null;
                        },
                        borderRadius: 30.r,
                        dropdownColor: Colors.white,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      24.height,
                      // Number of Participants Field
                      CustomTextField(
                        label: 'numberOfParticipants'.tr(),
                        hint: 'enterNumberOfParticipants'.tr(),
                        controller: _numberOfParticipantsController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'numberOfParticipantsRequired'.tr();
                          }
                          final num = int.tryParse(value);
                          if (num == null || num <= 0) {
                            return 'enterValidNumber'.tr();
                          }
                          const maxInt32 = 2147483647;
                          if (num > maxInt32) {
                            return '${'numberMustBeLessThan'.tr()} $maxInt32';
                          }
                          return null;
                        },
                      ),
                      24.height,
                      // Start Date Field
                      _buildDateField(
                        label: 'startDate'.tr(),
                        date: _startDate,
                        onTap: () => _selectDate(true),
                      ),
                      24.height,
                      // End Date Field
                      _buildDateField(
                        label: 'endDate'.tr(),
                        date: _endDate,
                        onTap: () => _selectDate(false),
                      ),
                      24.height,
                      // Picture Upload Section
                      _buildPictureUploadSection(),
                      24.height,
                      // About Workshop Text Area
                      Text(
                        'About workshop',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      8.height,
                      CustomTextField(
                        hint: 'some info about workshop...',
                        controller: _descriptionController,
                        minLines: 4,
                        maxLines: 6,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'About workshop is required';
                          }
                          return null;
                        },
                      ),
                      32.height,
                      // Confirm Button
                      BlocBuilder<WorkshopCubit, WorkshopState>(
                        builder: (context, state) {
                          final isLoading = state is WorkshopLoading;
                          return CustomButton(
                            text: _isUpdate ? 'Update' : 'Confirm',
                            isBackgroundGradient: true,
                            onTap: isLoading ? null : _onConfirm,
                          );
                        },
                      ),
                      if (_isUpdate) ...[
                        16.height,
                        // Delete Button
                        BlocBuilder<WorkshopCubit, WorkshopState>(
                          builder: (context, state) {
                            final isLoading = state is WorkshopLoading;
                            return CustomButton.outlined(
                              text: 'deleteWorkshop'.tr(),
                              textColor: Colors.red,
                              borderColor: Colors.red,
                              onTap: isLoading
                                  ? null
                                  : () => _onDelete(context),
                            );
                          },
                        ),
                      ],
                      20.height,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        8.height,
        InkWell(
          onTap: onTap,
          child: Container(
            height: 52.h,
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: const Color(0xFFD0D5DD), width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    date != null
                        ? DateFormat('yyyy-MM-dd').format(date)
                        : '${'select'.tr()} $label',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: date != null
                          ? const Color(0xFF101828)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                Icon(
                  Icons.calendar_today,
                  size: 20.w,
                  color: Colors.grey.shade600,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(bool isStartDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? (_startDate ?? DateTime.now())),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate != null && _endDate!.isBefore(_startDate!)) {
            _endDate = null;
          }
        } else {
          if (_startDate == null || picked.isAfter(_startDate!)) {
            _endDate = picked;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('endDateMustBeAfterStart'.tr())),
            );
          }
        }
      });
    }
  }

  Widget _buildPictureUploadSection() {
    final hasPicture = _selectedPicture != null || _coverImageUrl != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: InkWell(
            onTap: _pickPicture,
            child: DashedBorderContainer(
              borderColor: hasPicture
                  ? Colors.transparent
                  : Colors.grey.shade300,
              borderWidth: hasPicture ? 0 : 1.5,
              borderRadius: 12.r,
              padding: hasPicture
                  ? EdgeInsets.zero
                  : const EdgeInsets.all(16.0),
              backgroundColor: Colors.white,
              child: Column(
                children: [
                  if (hasPicture) ...[
                    // Show selected image/file
                    Container(
                      width: double.infinity,
                      height: 200.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12.r),
                        image: _selectedPicture != null
                            ? DecorationImage(
                                image: FileImage(_selectedPicture!),
                                fit: BoxFit.cover,
                              )
                            : _coverImageUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(
                                  _coverImageUrl!,
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _selectedPicture == null && _coverImageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: _coverImageUrl!,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                  ] else ...[
                    // Upload prompt
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.grey.shade600,
                        ),
                        children: [
                          TextSpan(
                            text: 'choosePhotoToUpload'.tr(),
                            style: TextStyle(
                              color: _orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextSpan(
                            text: '*',
                            style: TextStyle(
                              color: _orange,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    8.height,
                    Text(
                      'supportedFormatsJpegPng'.tr(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    16.height,
                    // Upload Icon
                    Container(
                      width: 56.w,
                      height: 56.h,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _orange.withOpacity(0.1),
                      ),
                      child: Icon(
                        Icons.arrow_upward,
                        size: 28.w,
                        color: _orange,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickPicture() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedPicture = File(result.files.single.path!);
          _coverImageUrl = null; // Clear URL when new file is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${'errorPickingFile'.tr()}: $e')),
        );
      }
    }
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPicture == null && _coverImageUrl == null && !_isUpdate) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('pleaseUploadPicture'.tr())));
      return;
    }

    if (_startDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('pleaseSelectStartDate'.tr())));
      return;
    }

    if (_endDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('pleaseSelectEndDate'.tr())));
      return;
    }

    // Parse and validate number of participants
    final participantsText = _numberOfParticipantsController.text.trim();
    final numberOfParticipants = int.tryParse(participantsText);
    if (numberOfParticipants == null || numberOfParticipants <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('pleaseEnterValidParticipants'.tr())),
      );
      return;
    }
    const maxInt32 = 2147483647;
    if (numberOfParticipants > maxInt32) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${'participantsMustBeLessThan'.tr()} $maxInt32'),
        ),
      );
      return;
    }

    final model = CreateWorkshopRequestModel(
      name: _workshopNameController.text.trim(),
      description: _descriptionController.text.trim(),
      coverImage: _selectedPicture,
      coverImageUrl: _coverImageUrl,
      location: _locationController.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      specialization: _selectedSpecialization ?? '',
      numberOfParticipants: numberOfParticipants,
    );

    AppMessages.showLoading(context);
    if (_isUpdate) {
      _workshopCubit.updateWorkshop(
        id: widget.workshopToUpdate!.id,
        model: model,
      );
    } else {
      _workshopCubit.createWorkshop(model);
    }
  }

  void _onDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('deleteWorkshop'.tr()),
        content: Text('deleteWorkshopConfirm'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              AppMessages.showLoading(context);
              _workshopCubit.deleteWorkshop(widget.workshopToUpdate!.id);
            },
            child: Text(
              'delete'.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
