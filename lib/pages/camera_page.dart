import 'dart:io';

import 'package:camera/camera.dart';
import 'package:cloud_recognition/pages/inference_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'crop_page.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late CameraDescription _currentCamera;

  final ImagePicker _picker = ImagePicker();

  bool _isInitialized = false;
  bool _isTakingPicture = false;

  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.cameras.first;
    _initCamera();
  }

  Future<void> _initCamera() async {
    _controller = CameraController(
      _currentCamera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await _controller.initialize();

    _minZoom = await _controller.getMinZoomLevel();
    _maxZoom = await _controller.getMaxZoomLevel();

    if (!mounted) return;
    setState(() => _isInitialized = true);
  }

  Future<void> _switchCamera() async {
    await _controller.dispose();

    _currentCamera = _currentCamera == widget.cameras.first
        ? widget.cameras.last
        : widget.cameras.first;

    _isInitialized = false;
    setState(() {});
    await _initCamera();
  }
  void _onScaleStart(ScaleStartDetails details) {
    _baseZoom = _currentZoom;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) async {
    final zoom =
    (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);

    _currentZoom = zoom;
    await _controller.setZoomLevel(zoom);
  }


  Future<File> _cropCenterSquare(File file) async {
    final bytes = await file.readAsBytes();
    final image = img.decodeImage(bytes)!;

    final size =
    image.width < image.height ? image.width : image.height;

    final x = (image.width - size) ~/ 2;
    final y = (image.height - size) ~/ 2;

    final square = img.copyCrop(
      image,
      x: x,
      y: y,
      width: size,
      height: size,
    );

    final croppedFile = File(
      file.path.replaceFirst('.jpg', '_square.jpg'),
    );

    await croppedFile.writeAsBytes(
      img.encodeJpg(square, quality: 95),
    );

    return croppedFile;
  }

  Future<void> _takePicture() async {
    if (_isTakingPicture || !_controller.value.isInitialized) return;
    _isTakingPicture = true;

    try {
      await _controller.pausePreview();

      final XFile raw = await _controller.takePicture();
      final File cropped = await _cropCenterSquare(File(raw.path));

      if (!mounted) return;
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              InferencePage(tempImagePath: cropped.path),
        ),
      );

      await _controller.resumePreview();
    } catch (e) {
      debugPrint('Take picture error: $e');
    } finally {
      _isTakingPicture = false;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final XFile? image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );

    if (image == null) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Picture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(image.path),
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 12),
              const Text('Do you want to use this picture?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CropPage(imagePath: image.path),
      ),
    );
  }

  void showCaptureTipsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const Center(
                    child: Text(
                      'Capture Tips',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    '1. Make sure the cloud is inside the square and fills most of the frame.\n\n'
                        '2. Avoid taking photos in low-light or night conditions.\n\n'
                        '3. If no cloud is visible in the image, the result may not be accurate.',
                    style: TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 50),

                  const Center(
                    child: Text(
                      'Correct Capture Example',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                  ),

                  const SizedBox(height: 30),

                  ClipRRect(
                    child: Image.asset(
                      'assets/Ac-N004.jpg',
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? SafeArea(
        child: Stack(
          children: [
            Center(
              child: GestureDetector(
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                child: AspectRatio(
                  aspectRatio: 1,
                  child: ClipRect(
                    child: OverflowBox(
                      alignment: Alignment.center,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
              ),
            ),

            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 60,
                color: Colors.black54,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white),
                      onPressed: () =>
                          Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.info_outline,
                          color: Colors.white),
                      onPressed: () {
                        showCaptureTipsBottomSheet(context);
                      },
                    ),
                  ],
                ),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding:
                const EdgeInsets.symmetric(vertical: 20),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image,
                          color: Colors.white, size: 28),
                      onPressed: _pickFromGallery,
                    ),
                    GestureDetector(
                      onTap: _takePicture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: Colors.white,
                              width: 10),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.cameraswitch,
                          color: Colors.white, size: 28),
                      onPressed: _switchCamera,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      )
          : const Center(
        child: CircularProgressIndicator(
            color: Colors.white),
      ),
    );

  }
}

