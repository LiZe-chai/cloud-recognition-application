
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:crop_your_image/crop_your_image.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crop Image'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _crop,
          ),
        ],
      ),
      body: !_ready
          ? const Center(child: CircularProgressIndicator())
          : Crop(
        controller: _controller,
        image: _imageData,
        aspectRatio: 1,
        onCropped: (CropResult result) {
          Navigator.pop(context, result);
        },
      ),
    );
  }
}
