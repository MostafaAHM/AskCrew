import 'dart:io';
import 'package:aflam/core/helpers/messages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../../../core/app_config/app_strings.dart';
import '../../../../../../core/app_config/app_urls.dart';
import '../../../../../core/widgets/appbar/logo_skip_appbar.dart';
import '../../../../../core/widgets/buttons/custom_button.dart';
import '../../../../../core/widgets/fields/custom_text_field.dart';
import '../../../../../core/di/service_locator.dart';
import '../../data/models/request/create_movie_request_model.dart';
import '../cubit/create_movie_cubit.dart';
import '../cubit/create_movie_state.dart';
import '../../data/models/response/movie_model.dart';
import '../../data/models/request/update_movie_request_model.dart';
import '../cubit/update_movie_cubit.dart';
import '../cubit/update_movie_state.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../../core/widgets/animations/animated_slide_in.dart';

class AddActorsPriceScreen extends StatefulWidget {
  final Map<String, dynamic> movieData;
  
  const AddActorsPriceScreen({
    super.key,
    required this.movieData,
  });

  @override
  State<AddActorsPriceScreen> createState() => _AddActorsPriceScreenState();
}

class _AddActorsPriceScreenState extends State<AddActorsPriceScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _aboutController = TextEditingController();
  final _priceController = TextEditingController();
  late AnimationController _animationController;
  
  late final CreateMovieCubit _createMovieCubit;
  late final UpdateMovieCubit _updateMovieCubit;
  
  final List<ActorData> _actors = [ActorData()];
  bool _isPaidContent = false;
  File? _coverImage;
  String? _coverImageUrl;
  bool _isUpdate = false;
  MovieModel? _movieToUpdate;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
       vsync: this,
       duration: const Duration(milliseconds: 1200),
    );
    _animationController.forward();

    _createMovieCubit = getIt<CreateMovieCubit>();
    _updateMovieCubit = getIt<UpdateMovieCubit>();
    
    if (widget.movieData['movieToUpdate'] != null) {
      _isUpdate = true;
      _movieToUpdate = widget.movieData['movieToUpdate'] as MovieModel;
      _populateData();
    }
  }
  
  void _populateData() {
     _aboutController.text = _movieToUpdate!.about;
     _priceController.text = _movieToUpdate!.price;
     _isPaidContent = (double.tryParse(_movieToUpdate!.price) ?? 0) > 0;
     _coverImageUrl = _movieToUpdate!.coverImage;
     
     if (_movieToUpdate!.actors.isNotEmpty) {
       _actors.clear();
       for (var actor in _movieToUpdate!.actors) {
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
    for (var actor in _actors) {
      actor.nameController.dispose();
    }
    _createMovieCubit.close();
    _updateMovieCubit.close();
    _animationController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<CreateMovieCubit, CreateMovieState>(
          bloc: _createMovieCubit,
          listener: (context, state) {
            if (state is CreateMovieLoading) {
              AppMessages.showLoading(context);
            } else if (state is CreateMovieSuccess) {
              context.pop(); 
              context.pop(true); 
              AppMessages.showSuccess(context, state.message);
            } else if (state is CreateMovieError) {
              context.pop();
              AppMessages.showError(context, state.message);
            }
          },
        ),
        BlocListener<UpdateMovieCubit, UpdateMovieState>(
          bloc: _updateMovieCubit,
          listener: (context, state) {
            if (state is UpdateMovieLoading) {
              AppMessages.showLoading(context);
            } else if (state is UpdateMovieSuccess) {
              context.pop(); 
              context.pop(true); 
              AppMessages.showSuccess(context, state.message);
            } else if (state is UpdateMovieError) {
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
                child: CustomTextField(
                  controller: _aboutController,
                  label: AppStrings.aboutThisArtwork.tr(),
                  hint: AppStrings.someInfoAboutIt.tr(),
                  borderRadius: 8.r,
                  maxLines: 6,
                  height: 150,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppStrings.pleaseProvideInfoAboutArtwork.tr();
                    }
                    return null;
                  },
                ),
              ),
              
              SizedBox(height: 30.h),
              
              AnimatedSlideIn(
                index: 2,
                controller: _animationController,
                child: Text(
                  AppStrings.coverImage.tr(),
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ),
              
              SizedBox(height: 12.h),
              
              AnimatedSlideIn(
                index: 3,
                controller: _animationController,
                child: GestureDetector(
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
                                        fontSize: 21.sp,
                                        color: const Color(0xFFFF5722),
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    TextSpan(
                                      text: AppStrings.toUploadCoverImage.tr(),
                                      style: TextStyle(
                                        fontSize: 21.sp,
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
                                  fontSize: 19.sp,
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
                                    fontSize: 21.sp,
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
              ),
              
              SizedBox(height: 30.h),
              
              AnimatedSlideIn(
                index: 4,
                controller: _animationController,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      AppStrings.actors.tr(),
                      style: TextStyle(
                        fontSize: 25.sp,
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
                index: 5,
                controller: _animationController,
                child: Text(
                  AppStrings.includeCastMembers.tr(),
                  style: TextStyle(
                    fontSize: 21.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
              
              ..._actors.asMap().entries.map((entry) {
                return AnimatedSlideIn(
                  index: 6 + entry.key,
                  controller: _animationController,
                  child: _buildActorCard(entry.value),
                );
              }),
              
              SizedBox(height: 30.h),
              
              AnimatedSlideIn(
                index: 7 + _actors.length,
                controller: _animationController,
                child: Text(
                  AppStrings.priceYourProduction.tr(),
                  style: TextStyle(
                    fontSize: 25.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
              
              SizedBox(height: 8.h),
              
              AnimatedSlideIn(
                index: 8 + _actors.length,
                controller: _animationController,
                child: Text(
                  AppStrings.setViewingPrice.tr(),
                  style: TextStyle(
                    fontSize: 21.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              
              SizedBox(height: 20.h),
              
              AnimatedSlideIn(
                index: 9 + _actors.length,
                controller: _animationController,
                child: Text(
                  AppStrings.moviePrice.tr(),
                  style: TextStyle(
                    fontSize: 21.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              AnimatedSlideIn(
                index: 10 + _actors.length,
                controller: _animationController,
                child: CustomTextField(
                  controller: _priceController,
                  hint: AppStrings.enterThePrice.tr(),
                  keyboardType: TextInputType.number,
                  enabled: _isPaidContent,
                  validator: (value) {
                    if (_isPaidContent && (value == null || value.isEmpty)) {
                      return AppStrings.pleaseEnterPrice.tr();
                    }
                    return null;
                  },
                ),
              ),
              
              SizedBox(height: 16.h),
              
              AnimatedSlideIn(
                index: 11 + _actors.length,
                controller: _animationController,
                child: Row(
                  children: [
                    Checkbox(
                      value: _isPaidContent,
                      onChanged: (value) {
                        setState(() {
                          _isPaidContent = value ?? false;
                          if (!_isPaidContent) {
                            _priceController.clear();
                          }
                        });
                      },
                      activeColor: const Color(0xFFFF5722),
                    ),
                    Text(
                      'Paid Content ( need subscribe )',
                      style: TextStyle(
                        fontSize: 21.sp,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              
              SizedBox(height: 40.h),
              
              AnimatedSlideIn(
                index: 12 + _actors.length,
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
                  fontSize: 21.sp,
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
                                  fontSize: 21.sp,
                                  color: const Color(0xFFFF5722),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: AppStrings.toUploadPicture.tr(),
                                style: TextStyle(
                                  fontSize: 21.sp,
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
                            fontSize: 19.sp,
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
                              fontSize: 21.sp,
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
      final sourceFile = File(result.files.single.path!);
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      final savedFile = await sourceFile.copy(newPath);

      setState(() {
        actor.photo = savedFile;
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
      final sourceFile = File(result.files.single.path!);
      final directory = await getApplicationDocumentsDirectory();
      final newPath = '${directory.path}/${DateTime.now().millisecondsSinceEpoch}_${result.files.single.name}';
      final savedFile = await sourceFile.copy(newPath);

      setState(() {
        _coverImage = savedFile;
        _coverImageUrl = null;
      });
    }
  }

  void _onConfirm() {
    if (!_formKey.currentState!.validate()) return;
    
    if (_coverImage == null && _coverImageUrl == null) {
      AppMessages.showError(context, AppStrings.pleaseUploadCoverImage.tr());
      return;
    }
    
    final actorsData = _actors
        .where((a) => a.nameController.text.trim().isNotEmpty)
        .toList();
    
    if (actorsData.isEmpty) {
      AppMessages.showError(context, AppStrings.pleaseAddAtLeastOneActor.tr());
      return;
    }

    if (_isUpdate) {
        final updateActors = actorsData.map((a) => ActorUpdateData(
            name: a.nameController.text.trim(),
            imageFile: a.photo,
            imageUrl: a.photoUrl,
        )).toList();
        
        String? newVideoId = widget.movieData['videoId'];
        if (newVideoId == _movieToUpdate?.video) newVideoId = null;

        String? newTrailerId = widget.movieData['trailerId'];
        if (newTrailerId == _movieToUpdate?.trailer) newTrailerId = null;

        final requestModel = UpdateMovieRequestModel(
            movieId: _movieToUpdate!.id,
            name: widget.movieData['movieName'],
            price: _isPaidContent ? (double.tryParse(_priceController.text) ?? 0.0) : 0.0,
            coverImage: _coverImage, 
            actors: updateActors,
            trailerId: newTrailerId,
            categoryId: widget.movieData['categoryId'],
            isReady: true,
            videoId: newVideoId,
            about: _aboutController.text,
            isPaid: _isPaidContent, 
        );
        _updateMovieCubit.updateMovie(requestModel);
    } else {
        // Create
        final createActors = actorsData.map((a) => ActorRequestData(
              name: a.nameController.text.trim(),
              image: a.photo,
            )).toList();
        
        final requestModel = CreateMovieRequestModel(
          name: widget.movieData['movieName'] ?? '',
          price: _isPaidContent ? (double.tryParse(_priceController.text) ?? 0.0) : 0.0,
          coverImage: _coverImage!,
          actors: createActors,
          trailerId: widget.movieData['trailerId'] ?? '',
          categoryId: widget.movieData['categoryId'] ?? 0,
          isReady: true,
          videoId: widget.movieData['videoId'] ?? '',
          about: _aboutController.text,
          isPaid: _isPaidContent,
        );
        _createMovieCubit.createMovie(requestModel);
    }
  }
}


class ActorData {
  final TextEditingController nameController = TextEditingController();
  File? photo;
  String? photoUrl;
}
