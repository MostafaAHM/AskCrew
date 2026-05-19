import 'dart:io';
import 'package:aflam/core/helpers/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../../../core/app_config/app_strings.dart';
import '../../../../../../core/app_config/app_urls.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../../../../core/di/service_locator.dart';
import '../../data/models/request/create_advertise_request_model.dart';
import '../cubit/create_advertise_cubit.dart';
import '../cubit/create_advertise_state.dart';
import '../../data/models/response/create_advertise_response_model.dart';
import '../../data/models/request/update_advertise_request_model.dart';
import '../cubit/update_advertise_cubit.dart';
import '../cubit/update_advertise_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/widgets/animations/animated_slide_in.dart';


class AddAdvertiseDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> advertiseData;
  
  const AddAdvertiseDetailsScreen({
    super.key,
    required this.advertiseData,
  });

  @override
  State<AddAdvertiseDetailsScreen> createState() => _AddAdvertiseDetailsScreenState();
}

class _AddAdvertiseDetailsScreenState extends State<AddAdvertiseDetailsScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  
  final _aboutController = TextEditingController();
  final _priceController = TextEditingController();
  
  late final CreateAdvertiseCubit _createAdvertiseCubit;
  late final UpdateAdvertiseCubit _updateAdvertiseCubit;
  late AnimationController _animationController;
  
  final List<ActorData> _actors = [ActorData()];
  File? _coverImage;
  String? _coverImageUrl;
  bool _isUpdate = false;
  CreateAdvertiseResponseModel? _advertiseToUpdate;

  @override
  void initState() {
    super.initState();
    _createAdvertiseCubit = getIt<CreateAdvertiseCubit>();
    _updateAdvertiseCubit = getIt<UpdateAdvertiseCubit>();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();
    
    if (widget.advertiseData['advertiseToUpdate'] != null) {
      _isUpdate = true;
      _advertiseToUpdate = widget.advertiseData['advertiseToUpdate'] as CreateAdvertiseResponseModel;
      _populateData();
    }
  }
  
  void _populateData() {
     _priceController.text = _advertiseToUpdate!.price;
     _coverImageUrl = _advertiseToUpdate!.coverImage;
     
     if (_advertiseToUpdate!.actors.isNotEmpty) {
       _actors.clear();
       for (var actor in _advertiseToUpdate!.actors) {
          var a = ActorData();
          a.nameController.text = actor.name;
          a.photoUrl = actor.image;
          _actors.add(a);
       }
     }
  }

  @override
  void dispose() {
    _aboutController.dispose();
    _priceController.dispose();
    _animationController.dispose();
    for (var actor in _actors) {
      actor.nameController.dispose();
    }
    _createAdvertiseCubit.close();
    _updateAdvertiseCubit.close();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateAdvertiseCubit, CreateAdvertiseState>(
          bloc: _createAdvertiseCubit,
          listener: (context, state) {
            if (state is CreateAdvertiseLoading) {
              AppMessages.showLoading(context);
            } else if (state is CreateAdvertiseSuccess) {
              context.pop(); 
              context.pop(true); 
              AppMessages.showSuccess(context, state.message);
            } else if (state is CreateAdvertiseError) {
              context.pop();
              AppMessages.showError(context, state.message);
            }
          },
        ),
        BlocListener<UpdateAdvertiseCubit, UpdateAdvertiseState>(
          bloc: _updateAdvertiseCubit,
          listener: (context, state) {
            if (state is UpdateAdvertiseLoading) {
              AppMessages.showLoading(context);
            } else if (state is UpdateAdvertiseSuccess) {
              context.pop(); 
              context.pop(true); 
              AppMessages.showSuccess(context, state.message);
            } else if (state is UpdateAdvertiseError) {
               context.pop();
              AppMessages.showError(context, state.message);
            }
          },
        ),
      ],
      child: Scaffold(
      appBar: CustomAppBar.backAppBar(
        showLogoInBackAppBar: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedSlideIn(
                index: 0,
                controller: _animationController,
                child: _buildProgressIndicator(currentStep: 3, totalSteps: 3),
              ),
              
              SizedBox(height: 30.h),
              
              AnimatedSlideIn(
                index: 1,
                controller: _animationController,
                child: Text(
                  AppStrings.aboutTheAdvertise.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              
              SizedBox(height: 12.h),
              
              AnimatedSlideIn(
                index: 2,
                controller: _animationController,
                child: CustomTextField(
                  controller: _aboutController,
                  hint: AppStrings.enterAdvertiseDescription.tr(),
                  maxLines: 4,
                  borderRadius: 8,
                  height: 100,
                  enabled: !_isUpdate,
                  validator: (value) {
                    if (!_isUpdate && (value == null || value.isEmpty)) {
                      return AppStrings.pleaseEnterAbout.tr();
                    }
                    return null;
                  },
                ),
              ),
              
              SizedBox(height: 30.h),
              
              AnimatedSlideIn(
                index: 3,
                controller: _animationController,
                child: Text(
                  AppStrings.coverImage.tr(),
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              
              SizedBox(height: 12.h),
              
              GestureDetector(
                onTap: _pickCoverImage,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade300,
                      style: BorderStyle.solid,
                    ),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: (_coverImage == null && _coverImageUrl == null)
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: AppStrings.chooseVideoOrFile.tr(),
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: const Color(0xFFFF5722),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  TextSpan(
                                    text: AppStrings.toUploadCoverImage.tr(),
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
                              AppStrings.supportedFormatsJpegPng.tr(),
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade500,
                                ),
                            ),
                            SizedBox(height: 16.h),
                            Icon(
                              Icons.image_outlined,
                              size: 40.sp,
                              color: Colors.grey.shade400,
                            ),
                          ],
                        )
                      : Row(
                          children: [
                            if (_coverImage == null && _coverImageUrl != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: CachedNetworkImage(
                                  imageUrl: AppUrls.storageImageLink(_coverImageUrl!),
                                  width: 40.w,
                                  height: 40.h,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(color: Colors.grey.shade200),
                                  errorWidget: (context, url, error) => const Icon(Icons.error),
                                ),
                              )
                            else
                              Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 24.sp,
                              ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                _coverImage != null ? _coverImage!.path.split('/').last : 'Existing Cover',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () {
                                setState(() {
                                  _coverImage = null;
                                  _coverImageUrl = null;
                                });
                              },
                            ),
                          ],
                        ),
                ),
              ),
              
              SizedBox(height: 30.h),
              
              AnimatedSlideIn(
                index: 5,
                controller: _animationController,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.actors.tr(),
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    IconButton(
                    onPressed: _addActor,
                    icon: Icon(
                      Icons.add_circle_outline,
                      color: const Color(0xFFFF5722),
                      size: 28.sp,
                    ),
                  ),
                ],
              ),
              ),
              
              SizedBox(height: 8.h),
              
              AnimatedSlideIn(
                index: 6,
                controller: _animationController,
                child: Text(
                  AppStrings.includeCastMembers.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
              
              for (int i = 0; i < _actors.length; i++)
                 AnimatedSlideIn(
                  index: 7 + i,
                  controller: _animationController,
                  child: _buildActorCard(_actors[i]),
                ),
              
              SizedBox(height: 30.h),
              
              AnimatedSlideIn(
                index: 8,
                controller: _animationController,
                child: Text(
                  "Price your advertise",
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              
              SizedBox(height: 8.h),
              
              AnimatedSlideIn(
                index: 9,
                controller: _animationController,
                child: Text(
                  AppStrings.setViewingPrice.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
              
              AnimatedSlideIn(
                index: 10,
                controller: _animationController,
                child: Text(
                  AppStrings.advertisePrice.tr(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              AnimatedSlideIn(
                index: 11,
                controller: _animationController,
                child: CustomTextField(
                  controller: _priceController,
                  hint: AppStrings.enterThePrice.tr(),
                  keyboardType: TextInputType.number,
                  enabled: true, 
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.pleaseEnterPrice.tr();
                    }
                    return null;
                  },
                ),
              ),
              
              SizedBox(height: 40.h),
              
              AnimatedSlideIn(
                index: 12,
                controller: _animationController,
                child: CustomButton(
                  text: AppStrings.confirm.tr(),
                  isBackgroundGradient: true,
                  onTap: _onConfirm,
                ),
              ),
              
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildProgressIndicator({required int currentStep, required int totalSteps}) {
    return Row(
      children: List.generate(
        totalSteps,
        (index) => Expanded(
          child: Container(
            height: 4.h,
            margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8.w : 0),
            decoration: BoxDecoration(
              color: index < currentStep
                  ? const Color(0xFFFF5722)
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActorCard(ActorData actor) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                AppStrings.actorName.tr(),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              IconButton(
                onPressed: () => _removeActor(actor),
                icon: Icon(
                  Icons.delete_outline,
                  color: Colors.red,
                  size: 20.sp,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          CustomTextField(
            controller: actor.nameController,
            hint: AppStrings.enterActorName.tr(),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return AppStrings.pleaseEnterActorName.tr();
              }
              return null;
            },
          ),
          
          SizedBox(height: 16.h),
          
          GestureDetector(
            onTap: () => _pickActorPhoto(actor),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey.shade300,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: (actor.photo == null && actor.photoUrl == null)
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: AppStrings.chooseVideoOrFile.tr(),
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: const Color(0xFFFF5722),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: AppStrings.toUploadPicture.tr(),
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
                          AppStrings.supportedFormatsJpegPng.tr(),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.grey.shade500,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        Icon(
                          Icons.cloud_upload_outlined,
                          size: 40.sp,
                          color: Colors.grey.shade400,
                          ),
                      ],
                    )
                  : Row(
                      children: [
                        if (actor.photo == null && actor.photoUrl != null)
                           ClipRRect(
                             borderRadius: BorderRadius.circular(4.r),
                             child: CachedNetworkImage(
                               imageUrl: AppUrls.storageImageLink(actor.photoUrl!),
                               width: 40.w,
                               height: 40.h,
                               fit: BoxFit.cover,
                               placeholder: (context, url) => Container(color: Colors.grey.shade200),
                               errorWidget: (context, url, error) => const Icon(Icons.error),
                             ),
                           )
                        else
                          Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 24.sp,
                          ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            actor.photo != null ? actor.photo!.path.split('/').last : 'Existing Image',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() {
                              actor.photo = null;
                              actor.photoUrl = null;
                            });
                          },
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _addActor() {
    setState(() {
      _actors.add(ActorData());
    });
  }

  void _removeActor(ActorData actor) {
    setState(() {
      _actors.remove(actor);
      actor.nameController.dispose();
    });
  }

  Future<void> _pickActorPhoto(ActorData actor) async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      // Copy file to permanent location to avoid cache deletion
      final pickedFile = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      final permanentFile = File('${appDir.path}/$fileName');
      
      await pickedFile.copy(permanentFile.path);
      
      setState(() {
        actor.photo = permanentFile;
        actor.photoUrl = null;
      });
    }
  }

  Future<void> _pickCoverImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );

    if (result != null && result.files.single.path != null) {
      // Copy file to permanent location to avoid cache deletion
      final pickedFile = File(result.files.single.path!);
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      final permanentFile = File('${appDir.path}/$fileName');
      
      await pickedFile.copy(permanentFile.path);
      
      setState(() {
        _coverImage = permanentFile;
        _coverImageUrl = null;
      });
    }
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_coverImage == null && _coverImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${AppStrings.pleaseUploadCoverImage.tr()}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    final actorsData = _actors
        .where((a) => a.nameController.text.trim().isNotEmpty)
        .toList();
    
    // User requested actors, assume at least one required? Not strictly required by API usually but good for UX. AddActorsPriceScreen enforces it. I will enforce it.
    if (actorsData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${AppStrings.pleaseAddAtLeastOneActor.tr()}'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_isUpdate) {
        final updateActors = actorsData.map((a) => ActorUpdateData(
            name: a.nameController.text.trim(),
            imageFile: a.photo,
            imageUrl: a.photoUrl,
        )).toList();
        
        String? newVideoId = widget.advertiseData['videoId'];
        if (newVideoId == null && _advertiseToUpdate?.trailer != null) { // Note: Response model doesn't have videoId field explicitly for validation logic here, but usually video is immutable or handled via separate update if needed. But here we assume we passed new ID if uploaded.
           // Logic: If widget.advertiseData has videoId, it's a new upload.
           // However, UpdateAdvertiseRequestModel checks non-empty string.
        }

        // Logic from Upload Screen: if new video uploaded, it passes non-null ID.
        
        final requestModel = UpdateAdvertiseRequestModel(
            advertiseId: _advertiseToUpdate!.id,
            name: widget.advertiseData['movieName'], // Consistently using 'movieName' key from map
            price: double.tryParse(_priceController.text) ?? 0.0,
            coverImage: _coverImage, 
            actors: updateActors,
            trailerId: widget.advertiseData['trailerId'],
            categoryId: widget.advertiseData['categoryId'],
            isReady: true,
            videoId: widget.advertiseData['videoId'],
        );
        _updateAdvertiseCubit.updateAdvertise(requestModel);
    } else {
        // Create
        final createActors = actorsData.map((a) => ActorRequestData(
              name: a.nameController.text.trim(),
              image: a.photo,
            )).toList();
        
        final requestModel = CreateAdvertiseRequestModel(
          name: widget.advertiseData['movieName'] ?? '',
          about: _aboutController.text.trim(),
          price: double.tryParse(_priceController.text) ?? 0.0,
          coverImage: _coverImage!,
          actors: createActors,
          trailerId: widget.advertiseData['trailerId'] ?? '',
          categoryId: widget.advertiseData['categoryId'] ?? 0,
          isReady: true,
          videoId: widget.advertiseData['videoId'] ?? '',
        );
        _createAdvertiseCubit.createAdvertise(requestModel);
    }
  }
}



class ActorData {
  final TextEditingController nameController = TextEditingController();
  File? photo;
  String? photoUrl;
}

