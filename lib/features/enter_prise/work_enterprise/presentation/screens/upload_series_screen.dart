import 'dart:io';
import 'package:aflam/core/helpers/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../core/app_config/app_strings.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../../../../core/app_config/app_colors.dart';
import '../../../../../core/di/service_locator.dart';
import '../cubit/categories_cubit.dart';
import '../cubit/create_series_cubit.dart';
import '../cubit/create_series_state.dart';
import '../../data/models/request/create_series_request_model.dart';
import '../cubit/categories_state.dart';
import 'add_series_details_screen.dart';
import '../../data/models/response/series_response_model.dart';
import '../cubit/update_series_cubit.dart';
import '../cubit/update_series_state.dart';
import '../../data/models/request/update_series_request_model.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../../core/widgets/animations/animated_slide_in.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/app_config/app_urls.dart';

class UploadSeriesScreen extends StatefulWidget {
  final SeriesModel? seriesToEdit;
  const UploadSeriesScreen({super.key, this.seriesToEdit});

  @override
  State<UploadSeriesScreen> createState() => _UploadSeriesScreenState();
}


class _UploadSeriesScreenState extends State<UploadSeriesScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _seriesTitleController = TextEditingController();
  final _aboutController = TextEditingController();
  
  late AnimationController _animationController;

  late final CreateSeriesCubit _createSeriesCubit;
  late final UpdateSeriesCubit _updateSeriesCubit;
  
  File? _coverImage;
  int? _selectedCategoryId;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();

    _createSeriesCubit = getIt<CreateSeriesCubit>();
    _updateSeriesCubit = getIt<UpdateSeriesCubit>();
    if (widget.seriesToEdit != null) {
      _seriesTitleController.text = widget.seriesToEdit!.title;
      _aboutController.text = widget.seriesToEdit!.about;
      _selectedCategoryId = widget.seriesToEdit!.category?.id;
    }
  }

  @override
  void dispose() {
    _seriesTitleController.dispose();
    _aboutController.dispose();
    _createSeriesCubit.close();
    _updateSeriesCubit.close();
    _animationController.dispose();
    super.dispose();
  }

  @override

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => getIt<CategoriesCubit>()..fetchCategories()),
        BlocProvider.value(value: _createSeriesCubit),
        BlocProvider.value(value: _updateSeriesCubit),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFFDFDFD),
        appBar: CustomAppBar.backAppBar(
          showLogoInBackAppBar: true,
        ),
        body: Builder(
          builder: (context) {
            return MultiBlocListener(
              listeners: [
                BlocListener<CreateSeriesCubit, CreateSeriesState>(
                  listener: (context, state) {
                    if (state is CreateSeriesLoading) {
                      AppMessages.showLoading(context);
                    } else if (state is CreateSeriesSuccess) {
                      AppMessages.hideLoading(context);
                      AppMessages.showSuccess(context, state.message);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddSeriesDetailsScreen(
                            seriesId: state.seriesId,
                            title: _seriesTitleController.text,
                            about: _aboutController.text,
                            categoryId: _selectedCategoryId!,
                            coverImage: _coverImage!,
                          ),
                        ),
                      );
                    } else if (state is CreateSeriesError) {
                      AppMessages.hideLoading(context);
                      setState(() => _isCreating = false);
                      AppMessages.showError(context, state.message);
                    }
                  },
                ),
                BlocListener<UpdateSeriesCubit, UpdateSeriesState>(
                  listener: (context, state) {
                    if (state is UpdateSeriesLoading) {
                       AppMessages.showLoading(context);
                    } else if (state is UpdateSeriesSuccess) {
                       AppMessages.hideLoading(context);
                       AppMessages.showSuccess(context, "Series Updated");
                        Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddSeriesDetailsScreen(
                            seriesId: widget.seriesToEdit!.id,
                            title: _seriesTitleController.text,
                            about: _aboutController.text,
                            categoryId: _selectedCategoryId!,
                            coverImage: _coverImage,
                            seriesToEdit: widget.seriesToEdit,
                          ),
                        ),
                      );
                    } else if (state is UpdateSeriesError) {
                       AppMessages.hideLoading(context);
                       AppMessages.showError(context, state.message);
                    }
                  }
                ),
              ],
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  left: 20.w,
                  right: 20.w,
                  top: 10.h,
                  bottom: 100.h,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedSlideIn(
                        index: 0,
                        controller: _animationController,
                        child: _buildProgressIndicator(currentStep: 1, totalSteps: 3),
                      ),
                      
                      SizedBox(height: 30.h),
                      
                      AnimatedSlideIn(
                        index: 1,
                        controller: _animationController,
                        child: Text(
                          AppStrings.fillYourSeriesData.tr(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      AnimatedSlideIn(
                        index: 2,
                        controller: _animationController,
                        child: Text(
                          AppStrings.fillSeriesDataDescription.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 30.h),
                      
                      AnimatedSlideIn(
                        index: 3,
                        controller: _animationController,
                        child: _buildFloatingLabelInput(
                          controller: _seriesTitleController,
                          label: AppStrings.seriesTitle.tr(),
                          hint: AppStrings.enterYourSeriesName.tr(),
                        ),
                      ),
                      
                      SizedBox(height: 30.h),
                      
                      AnimatedSlideIn(
                        index: 4,
                        controller: _animationController,
                        child: _buildFloatingLabelTextArea(
                          controller: _aboutController,
                          label: AppStrings.aboutThisArtwork.tr(),
                          hint: AppStrings.someInfoAboutIt.tr(),
                        ),
                      ),
                      
                      SizedBox(height: 30.h),
                      AnimatedSlideIn(
                        index: 5,
                        controller: _animationController,
                        child: BlocBuilder<CategoriesCubit, CategoriesState>(
                          builder: (context, state) {
                            if (state is CategoriesLoading) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                child: Container(
                                  height: 60.h,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(30.r),
                                  ),
                                ),
                              );
                            }
                            
                            List<DropdownMenuItem<int>> items = [];
                            
                           if (state is CategoriesLoaded) {
                              items = state.categories.map((category) {
                                return DropdownMenuItem<int>(
                                  value: category.id,
                                  child: Text(category.name),
                                );
                              }).toList();
                            } else if (state is CategoriesError) {
                              items = [
                                DropdownMenuItem(value: null, child: Text(AppStrings.errorLoadingCategories.tr())),
                              ];
                            }
                        
                            return _buildFloatingLabelDropdown(
                              label: AppStrings.seriesGenre.tr(),
                              hint: AppStrings.selectYourSeriesCategory.tr(),
                              value: _selectedCategoryId,
                              items: items,
                              onChanged: (int? value) {
                                setState(() {
                                  _selectedCategoryId = value;
                                });
                              },
                            );
                          },
                        ),
                      ),
                      
                      SizedBox(height: 30.h),
                      
                      AnimatedSlideIn(
                        index: 6,
                        controller: _animationController,
                        child: Text(
                          AppStrings.uploadSeriesCover.tr(),
                          style: TextStyle(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 8.h),
                      
                      AnimatedSlideIn(
                        index: 7,
                        controller: _animationController,
                        child: Text(
                          AppStrings.chooseSeriesCover.tr(),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 16.h),
                      
                      AnimatedSlideIn(
                        index: 8,
                        controller: _animationController,
                        child: _buildDottedUploadBox(
                          titlePart1: AppStrings.chooseVideoOrFile.tr(),
                          titlePart2: AppStrings.toUploadCoverImage.tr(),
                          subtitle: AppStrings.supportedFormatsJpegPdf.tr(),
                          file: _coverImage,
                          existingUrl: widget.seriesToEdit?.coverPhoto,
                          onTap: _pickCoverImage,
                        ),
                      ),
                      
                      SizedBox(height: 40.h),
                      
                     AnimatedSlideIn(
                       index: 9,
                       controller: _animationController,
                       child: Container(
                         width: double.infinity,
                         height: 56.h,
                         decoration: BoxDecoration(
                           gradient: const LinearGradient(
                             colors: [
                               AppColors.primaryColor,
                               AppColors.secondaryColor,
                             ],
                             begin: Alignment.centerLeft,
                             end: Alignment.centerRight,
                           ),
                           borderRadius: BorderRadius.circular(12.r),
                         ),
                         child: ElevatedButton(
                           onPressed: _canProceed() ? () => _onNext(context) : null,
                           style: ElevatedButton.styleFrom(
                             backgroundColor: Colors.transparent,
                             shadowColor: Colors.transparent,
                             shape: RoundedRectangleBorder(
                               borderRadius: BorderRadius.circular(12.r),
                             ),
                           ),
                           child: Text(
                             AppStrings.next.tr(),
                             style: TextStyle(
                               fontSize: 18.sp,
                               fontWeight: FontWeight.w600,
                               color: Colors.white,
                             ),
                           ),
                         ),
                       ),
                     ),
                      
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            );
          }
        ),
      ),
    );
  }

  Widget _buildProgressIndicator({required int currentStep, required int totalSteps}) {
    return Row(
      children: List.generate(
        totalSteps,
        (index) => Expanded(
          child: Container(
            height: 6.h,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8.w : 0),
            decoration: BoxDecoration(
              color: index < currentStep
                  ? const Color(0xFFFF5722)
                  : const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(3.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFloatingLabelInput({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 8.h),
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: const BorderSide(color: Color(0xFFFF5722)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.requiredField.tr();
              }
              return null;
            },
          ),
        ),
        Positioned(
          left: 24.w,
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            color: const Color(0xFFFDFDFD),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingLabelTextArea({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 8.h),
          child: TextFormField(
            controller: controller,
            maxLines: 5,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16.r),
                borderSide: const BorderSide(color: Color(0xFFFF5722)),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.requiredField.tr();
              }
              return null;
            },
          ),
        ),
        Positioned(
          left: 24.w,
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            color: const Color(0xFFFDFDFD),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFloatingLabelDropdown({
    required String label,
    required String hint,
    required int? value,
    required List<DropdownMenuItem<int>> items,
    required Function(int?)? onChanged,
  }) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(top: 8.h),
          child: DropdownButtonFormField<int>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFFF5722)),
            dropdownColor: Colors.white,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
              contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30.r),
                borderSide: const BorderSide(color: Color(0xFFFF5722)),
              ),
            ),
          ),
        ),
        Positioned(
          left: 24.w,
          top: 0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            color: const Color(0xFFFDFDFD),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDottedUploadBox({
    required String titlePart1,
    required String titlePart2,
    required String subtitle,
    required File? file,
    String? existingUrl,
    required VoidCallback onTap,
  }) {
    if (file != null || existingUrl != null) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Row(
          children: [
            if (file == null && existingUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: CachedNetworkImage(
                  imageUrl: AppUrls.storageImageLink(existingUrl),
                  width: 40.w,
                  height: 40.h,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 40.w,
                    height: 40.h,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.image, size: 20.sp),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 40.w,
                    height: 40.h,
                    color: Colors.grey.shade200,
                    child: Icon(Icons.error, size: 20.sp),
                  ),
                ),
              )
            else
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Icon(Icons.check, color: Colors.green, size: 20.sp),
              ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    file != null ? 'File Selected' : 'Existing Image',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    file != null ? file.path.split('/').last : (existingUrl != null ? 'Cover Image Loaded' : 'Image Loaded'),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.green.shade700),
              onPressed: () {
                setState(() {
                  _coverImage = null;
                   // Note: existingUrl is prop, can't clear it from here unless we update state.
                   // But for now, user can click to pick another.
                });
                _pickCoverImage();
              },
            ),
          ],
        ),
      ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: DottedBorder(
        color: Colors.grey.shade300,
        strokeWidth: 1.5,
        dashPattern: const [6, 4],
        borderType: BorderType.RRect,
        radius: Radius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Column(
            children: [
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: titlePart1,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFFFF5722),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: titlePart2,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade400,
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.file_upload_outlined,
                  size: 24.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        _coverImage = File(result.files.single.path!);
      });
    }
  }

  bool _canProceed() {
    if (widget.seriesToEdit != null) {
       return _seriesTitleController.text.isNotEmpty &&
              _aboutController.text.isNotEmpty &&
              _selectedCategoryId != null;
              // Cover Image optional if existing
    }
    return _seriesTitleController.text.isNotEmpty &&
           _aboutController.text.isNotEmpty &&
           _selectedCategoryId != null &&
           _coverImage != null;
  }

  void _onNext(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    if (!_canProceed()) return;

    if (widget.seriesToEdit != null) {
       // Edit Logic
       final request = UpdateSeriesRequestModel(
          seriesId: widget.seriesToEdit!.id,
          title: _seriesTitleController.text,
          about: _aboutController.text,
          categoryId: _selectedCategoryId,
          coverPhoto: _coverImage, // Optional
       );
       _updateSeriesCubit.updateSeries(request);
       return;
    }

    if (_isCreating) return;

    // Create series request
    final request = CreateSeriesRequestModel(
      title: _seriesTitleController.text,
      about: _aboutController.text,
      coverPhoto: _coverImage!,
      categoryId: _selectedCategoryId!,
    );

    // Call API
    _createSeriesCubit.createSeries(request);
  }
}
