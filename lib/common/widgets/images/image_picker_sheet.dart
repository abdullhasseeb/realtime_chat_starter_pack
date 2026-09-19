

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/helpers/snackbar_helpers.dart';

class ImagePickerSheet extends StatelessWidget {
  const ImagePickerSheet({super.key, required this.onImagePicked});

  final Function(XFile file) onImagePicked;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: const .all(16),
          child: Wrap(
            spacing: 8,
            children: [
              /// Camera
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Camera'),
                onTap: (){
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.camera);
                },
              ),

              /// Gallery
              ListTile(
                leading: const Icon(Icons.photo_camera_outlined),
                title: const Text('Gallery'),
                onTap: (){
                  Navigator.pop(context);
                  _pickImage(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        )
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async{
    try{
      final picker = ImagePicker();
      final file = await picker.pickImage(source: source, imageQuality: 80, maxWidth: 1080, maxHeight: 1080);

      if(file == null) return;

      onImagePicked(file);
    }catch(e){
      SnackBarHelper.error('Failed to pick image: $e');
    }
  }
}
