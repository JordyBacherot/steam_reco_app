import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'profile_picture_picker.dart';

/// Wrapper around ProfilePicturePicker to handle image picking internally.
class ProfilePicturePickerWrapper extends StatefulWidget {
  const ProfilePicturePickerWrapper({super.key});

  @override
  State<ProfilePicturePickerWrapper> createState() => _ProfilePicturePickerWrapperState();
}

class _ProfilePicturePickerWrapperState extends State<ProfilePicturePickerWrapper> {
  File? _image;
  final ImagePicker _picker = ImagePicker();

  File? get selectedImage => _image;

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfilePicturePicker(
      imageUrl: _image?.path,
      onTap: _pickImage,
    );
  }
}