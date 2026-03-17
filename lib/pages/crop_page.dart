import 'dart:io';
import 'dart:typed_data';
import 'package:cloud_recognition/pages/inference_page.dart';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import '../generated/l10n.dart';

class CropPage extends StatefulWidget {
  final String imagePath;

  const CropPage({super.key, required this.imagePath});

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  final CropController _controller = CropController();
  late Uint8List _imageData;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    _imageData = await File(widget.imagePath).readAsBytes();
    setState(() => _ready = true);
  }

  void _crop() {
    _controller.crop();
  }

  Future<File> _saveToCache(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final fileName = 'crop_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final file = File(p.join(dir.path, fileName));
    await file.writeAsBytes(bytes);

    return file;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white,
        ),
        backgroundColor: Colors.black,
        title: Text(
          S.of(context)!.cropImage,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _crop,
            color: Colors.white,
          ),
        ],
      ),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : Crop(
              controller: _controller,
              image: _imageData,
              aspectRatio: 1,
              onCropped: (CropResult result) async {
                if (result is CropSuccess) {
                  final Uint8List croppedData = result.croppedImage;
                  final File tempImage = await _saveToCache(croppedData);
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            InferencePage(tempImagePath: tempImage.path),
                      ),
                    );
                  }
                }else if(result is CropFailure){
                  debugPrint('CropFailed');
                }
              },
            ),
    );
  }
}
