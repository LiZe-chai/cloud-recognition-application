import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';

class CropPage extends StatelessWidget {
  final String imagePath;

  const CropPage({super.key, required this.imagePath});

  Future<void> _crop(BuildContext context) async {
    final croppedFile = await ImageCropper().cropImage(
      sourcePath: imagePath,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          lockAspectRatio: true,
          hideBottomControls: true,
        ),
        IOSUiSettings(
          title: 'Crop Image',
          aspectRatioLockEnabled: true,
        ),
      ],
    );

    if (croppedFile == null) return;

    Navigator.pop(context, croppedFile.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Uploaded Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _crop(context),
          ),
        ],
      ),
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
