import 'dart:io';

import 'package:aflam/core/app_config/app_colors.dart';
import 'package:aflam/core/app_config/app_strings.dart';
import 'package:aflam/core/di/service_locator.dart';
import 'package:aflam/core/extensions/space_extension.dart';
import 'package:aflam/core/helpers/messages.dart';
import 'package:aflam/core/widgets/animations/animated_slide_in.dart';
import 'package:aflam/core/widgets/appbar/logo_skip_appbar.dart';
import 'package:aflam/core/widgets/buttons/custom_button.dart';
import 'package:aflam/core/widgets/fields/custom_drop_down_field.dart';
import 'package:aflam/core/widgets/fields/custom_text_field.dart';
import 'package:aflam/features/auth/enterprise/enterprise_auth_flow/presentation/widgets/dashed_border_container.dart';
import 'package:aflam/features/enter_prise/booking_enterprise/data/models/request/create_booking_item_request_model.dart';
import 'package:aflam/features/enter_prise/booking_enterprise/data/models/response/booking_item_response_model.dart';
import 'package:aflam/features/enter_prise/booking_enterprise/presentation/cubit/booking_cubit.dart';
import 'package:aflam/features/enter_prise/booking_enterprise/presentation/cubit/booking_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddBookingScreen extends StatefulWidget {
  final BookingItemResponseModel? itemToUpdate;

  const AddBookingScreen({super.key, this.itemToUpdate});

  @override
  State<AddBookingScreen> createState() => _AddBookingScreenState();
}

class _AddBookingScreenState extends State<AddBookingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _numberOfItemsController = TextEditingController();
  final _pricePerDayController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedItemType;
  File? _selectedPicture;
  String? _imageUrl;
  bool _isUpdate = false;
  DateTime? _startTime;
  DateTime? _endTime;
  bool _isActive = true;

  Color get _orange => const Color(0xFFFF7A3C);

  final List<String> _itemTypes = ['tool', 'studio'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();

    if (widget.itemToUpdate != null) {
      _isUpdate = true;
      _populateData();
    }
  }

  void _populateData() {
    final item = widget.itemToUpdate!;
    _nameController.text = item.name;
    _numberOfItemsController.text = item.quantity;
    _pricePerDayController.text = item.pricePerDay.toString();
    _locationController.text = item.location;
    _selectedItemType = item.type;
    _imageUrl = item.image;
    _startTime = item.startTime;
    _endTime = item.endTime;
    _isActive = item.isActive;
    if (item.description != null && item.description!.isNotEmpty) {
      _descriptionController.text = item.description!;
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _numberOfItemsController.dispose();
    _pricePerDayController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    // _bookingCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    BookingCubit bookingCubit;
    try {
      bookingCubit = context.read<BookingCubit>();
    } catch (e) {
      bookingCubit = getIt<BookingCubit>();
    }

    return BlocProvider.value(
      value: bookingCubit,
      child: BlocListener<BookingCubit, BookingState>(
        listener: (context, state) {
          if (state is BookingSuccess) {
            AppMessages.hideLoading(context);
            AppMessages.showSuccess(context, state.message);
            if (mounted) {
              Navigator.pop(context, true);
            }
          } else if (state is BookingDeleteSuccess) {
            AppMessages.hideLoading(context);
            AppMessages.showSuccess(context, state.message);
            final bookingCubit = context.read<BookingCubit>();
            bookingCubit.getBookingItems(refresh: true);
            if (mounted) {
              Navigator.pop(context, true);
            }
          } else if (state is BookingError) {
            AppMessages.hideLoading(context);
            AppMessages.showError(context, state.message);
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.lightBGColor,
          appBar: CustomAppBar.backAppBar(showLogoInBackAppBar: true),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: AnimatedSlideIn(
                index: 0,
                controller: _animationController,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      16.height,
                      // Subtitle
                      Text(
                        AppStrings.enterMoreSpecificInfoAboutThisItemOrPlace
                            .tr(),
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),

                      24.height,

                      CustomDropDownField<String>(
                        label: AppStrings.itemType.tr(),
                        hint: AppStrings.chooseTheItemType.tr(),
                        value: _selectedItemType,
                        items: _itemTypes.map((type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type.tr(),
                              style: TextStyle(
                                fontSize: 15.sp,
                                color: const Color(0xFF101828),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedItemType = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.toString().isEmpty) {
                            return AppStrings.itemTypeIsRequired.tr();
                          }
                          return null;
                        },
                        borderRadius: 30.r,
                        icon: Icon(
                          Icons.keyboard_arrow_down,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      24.height,

                      // Name Field
                      CustomTextField(
                        label: AppStrings.name.tr(),
                        hint: AppStrings.enterNameForIt.tr(),
                        controller: _nameController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.nameIsRequired.tr();
                          }
                          return null;
                        },
                      ),
                      24.height,

                      // No.of this item Field - accepts any text (numbers, letters, symbols)
                      CustomTextField(
                        label: AppStrings.noOfThisItem.tr(),
                        hint: AppStrings.enterNumberOfItems.tr(),
                        controller: _numberOfItemsController,
                        keyboardType: TextInputType.text,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.numberOfItemsIsRequired.tr();
                          }
                          return null;
                        },
                      ),
                      24.height,

                      // Description Field
                      CustomTextField(
                        label: AppStrings.productDescription.tr(),
                        hint: AppStrings.enterProductDescription.tr(),
                        controller: _descriptionController,
                        keyboardType: TextInputType.multiline,
                        minLines: 4,
                        maxLines: 8,
                        validator: (value) {
                          // Description is optional
                          return null;
                        },
                      ),
                      24.height,

                      // Price/day Field
                      CustomTextField(
                        label: AppStrings.pricePerDay.tr(),
                        hint: AppStrings.day.tr(),
                        controller: _pricePerDayController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.pricePerDayIsRequired.tr();
                          }
                          final num = double.tryParse(value);
                          if (num == null || num <= 0) {
                            return AppStrings.pleaseEnterValidPrice.tr();
                          }
                          return null;
                        },
                      ),
                      24.height,

                      // Location Field
                      CustomTextField(
                        label: AppStrings.location.tr(),
                        hint: AppStrings.enterYourLocation.tr(),
                        controller: _locationController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return AppStrings.locationIsRequired.tr();
                          }
                          return null;
                        },
                      ),
                      24.height,

                      // Active Switch
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          AppStrings.active.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        value: _isActive,
                        activeThumbColor: _orange,
                        onChanged: (val) {
                          setState(() {
                            _isActive = val;
                          });
                        },
                      ),
                      24.height,
                      // Start Time Field
                      _buildDateTimeField(
                        label: AppStrings.startBookingTime.tr(),
                        dateTime: _startTime,
                        onTap: () => _selectStartTime(context),
                      ),
                      24.height,

                      // End Time Field
                      _buildDateTimeField(
                        label: AppStrings.endBookingTime.tr(),
                        dateTime: _endTime,
                        onTap: () => _selectEndTime(context),
                      ),
                      24.height,

                      // Picture Upload Section
                      _buildPictureUploadSection(),
                      32.height,
                      // Submit Button
                      BlocBuilder<BookingCubit, BookingState>(
                        builder: (context, state) {
                          final isLoading = state is BookingLoading;
                          return CustomButton(
                            text: _isUpdate
                                ? AppStrings.update.tr()
                                : AppStrings.submit.tr(),
                            onTap: isLoading ? null : _onSubmit,
                            isBackgroundGradient: true,
                          );
                        },
                      ),
                      if (_isUpdate) ...[
                        16.height,
                        // Delete Button
                        BlocBuilder<BookingCubit, BookingState>(
                          builder: (context, state) {
                            final isLoading = state is BookingLoading;
                            return CustomButton.outlined(
                              text: AppStrings.delete.tr(),
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

  Widget _buildPictureUploadSection() {
    final hasPicture = _selectedPicture != null || _imageUrl != null;

    return Center(
      child: Column(
        children: [
          InkWell(
            onTap: _pickPicture,
            child: DashedBorderContainer(
              borderColor: hasPicture ? _orange : Colors.grey.shade300,
              borderWidth: 1.5,
              borderRadius: 12.r,
              backgroundColor: Colors.white,
              child: Column(
                children: [
                  if (hasPicture) ...[
                    // Show selected image
                    Container(
                      width: double.infinity,
                      height: 150.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                        image: _selectedPicture != null
                            ? DecorationImage(
                                image: FileImage(_selectedPicture!),
                                fit: BoxFit.cover,
                              )
                            : _imageUrl != null
                            ? DecorationImage(
                                image: CachedNetworkImageProvider(_imageUrl!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _selectedPicture == null && _imageUrl != null
                          ? CachedNetworkImage(
                              imageUrl: _imageUrl!,
                              fit: BoxFit.cover,
                            )
                          : null,
                    ),
                    16.height,
                    Text(
                      _selectedPicture != null
                          ? _selectedPicture!.path.split('/').last
                          : AppStrings.currentImage.tr(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                            text: AppStrings.choosePhotoOrFileToUploadPicture
                                .tr(),
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
                      AppStrings.supportedFormatsJpegPdf.tr(),
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
        ],
      ),
    );
  }

  Future<void> _pickPicture() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'pdf', 'png'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedPicture = File(result.files.single.path!);
          _imageUrl = null; // Clear URL when new file is selected
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppStrings.errorPickingFile.tr()}: $e')),
        );
      }
    }
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedPicture == null && _imageUrl == null && !_isUpdate) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseUploadAPicture.tr())),
      );
      return;
    }

    // Quantity is now a string, so no need to parse as int
    final quantity = _numberOfItemsController.text.trim();
    if (quantity.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseEnterNumberOfItems.tr())),
      );
      return;
    }

    final pricePerDay = double.tryParse(_pricePerDayController.text.trim());
    if (pricePerDay == null || pricePerDay <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppStrings.pleaseEnterValidPrice.tr())),
      );
      return;
    }

    final model = CreateBookingItemRequestModel(
      name: _nameController.text.trim(),
      quantity: quantity,
      pricePerDay: pricePerDay,
      location: _locationController.text.trim(),
      type: _selectedItemType!,
      description: _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      image: _selectedPicture,
      imageUrl: _imageUrl,
      isActive: _isActive,
      startTime: _startTime,
      endTime: _endTime,
    );

    // Show loading
    AppMessages.showLoading(context);

    final bookingCubit = context.read<BookingCubit>();
    if (_isUpdate) {
      bookingCubit.updateBookingItem(id: widget.itemToUpdate!.id, model: model);
    } else {
      bookingCubit.createBookingItem(model);
    }
  }

  void _onDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppStrings.deleteBookingItem.tr()),
        content: Text(AppStrings.areYouSureDeleteBookingItem.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final bookingCubit = context.read<BookingCubit>();
              bookingCubit.deleteBookingItem(widget.itemToUpdate!.id);
            },
            child: Text(
              AppStrings.delete.tr(),
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeField({
    required String label,
    required DateTime? dateTime,
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
                    dateTime != null
                        ? DateFormat('yyyy-MM-dd HH:mm').format(dateTime)
                        : '${AppStrings.select.tr()} $label',
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: dateTime != null
                          ? const Color(0xFF101828)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
                ),
                Icon(
                  Icons.access_time,
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

  Future<void> _selectStartTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _startTime != null
            ? TimeOfDay.fromDateTime(_startTime!)
            : TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _startTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  Future<void> _selectEndTime(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _endTime ?? (_startTime ?? DateTime.now()),
      firstDate: _startTime ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: _endTime != null
            ? TimeOfDay.fromDateTime(_endTime!)
            : TimeOfDay.now(),
      );
      if (pickedTime != null) {
        setState(() {
          _endTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }
}
