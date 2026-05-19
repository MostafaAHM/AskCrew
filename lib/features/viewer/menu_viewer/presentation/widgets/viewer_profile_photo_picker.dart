import 'dart:io';

import 'package:aflam/core/app_config/app_strings.dart';
import 'package:easy_localization/easy_localization.dart';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../../core/app_config/app_colors.dart';
import '../../../../../../core/widgets/avatars/user_avatar.dart';

class ViewerProfilePhotoPicker extends StatelessWidget {
  final String? currentPhotoUrl;
  final File? selectedFile;
  final ValueChanged<File> onPhotoSelected;

  const ViewerProfilePhotoPicker({
    super.key,
    this.currentPhotoUrl,
    this.selectedFile,
    required this.onPhotoSelected,
  });

  Future<void> _pickImage(BuildContext context) async {
    final picker = ImagePicker();

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppStrings.gallery.tr()),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.gallery,
                );
                if (image != null) {
                  onPhotoSelected(File(image.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_camera),
              title: Text(AppStrings.camera.tr()),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(
                  source: ImageSource.camera,
                );
                if (image != null) {
                  onPhotoSelected(File(image.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          UserAvatar(
            url: currentPhotoUrl ?? '',
            fileImage: selectedFile,
            radius: 60,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _pickImage(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
