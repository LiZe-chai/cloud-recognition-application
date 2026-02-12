import 'package:camera/camera.dart';
import 'package:cloud_recognition/pages/preview_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

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
    if (!mounted) return;

    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _switchCamera() async {
    final newCamera = _currentCamera == widget.cameras.first
        ? widget.cameras.last
        : widget.cameras.first;

    await _controller.dispose();
    _currentCamera = newCamera;
    _initCamera();
  }


  Future<void> _takePicture() async {
    if (_isTakingPicture) return;
    if (!_controller.value.isInitialized) return;

    _isTakingPicture = true;

    try {
      await _controller.pausePreview();

      final XFile image = await _controller.takePicture();

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PreviewPage(tempImagePath: image.path),
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

    debugPrint('Selected image path: ${image.path}');
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isInitialized
          ? Stack(
        children: [
          /// Camera Preview
          Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: CameraPreview(_controller),
            ),
          ),

          /// Top Bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              color: Colors.black54,
              child: SafeArea(
                bottom: false,
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close,
                          color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.info_outline, color: Colors.white),
                      onPressed: () {
                        // TODO: hint action
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          /// Bottom Controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              color: Colors.black54,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  /// Gallery
                  IconButton(
                    icon: const Icon(Icons.image,
                        color: Colors.white, size: 28),
                        onPressed: _pickFromGallery,
                  ),

                  /// Shutter
                  GestureDetector(
                    onTap: _takePicture,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white, width: 10),
                      ),
                    ),
                  ),

                  /// Switch Camera
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
      )
          : const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
