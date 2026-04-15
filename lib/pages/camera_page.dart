import 'dart:io';
import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:cloud_recognition/pages/inference_page.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../generated/l10n.dart';
import 'crop_page.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({super.key, required this.cameras});

  @override
  State<CameraPage> createState() => _CameraPageState();
}

Future<File> _isolateCropTask(Map<String, dynamic> params) async {
  final String path = params['path'];
  final double previewLeft = params['previewLeft'];
  final double previewTop = params['previewTop'];
  final double previewWidthOnScreen = params['previewWidthOnScreen'];
  final double previewHeightOnScreen = params['previewHeightOnScreen'];
  final double cropLeft = params['cropLeft'];
  final double cropTop = params['cropTop'];
  final double cropWidth = params['cropWidth'];
  final double cropHeight = params['cropHeight'];
  final double zoom = params['zoom'];

  final bytes = File(path).readAsBytesSync();
  img.Image? image = img.decodeImage(bytes);
  if (image == null) {
    throw Exception("Could not decode image");
  }

  image = img.bakeOrientation(image);

  double imageWidth = image.width.toDouble();
  double imageHeight = image.height.toDouble();

  if (zoom > 1.0) {
    final double zoomedWidth = imageWidth / zoom;
    final double zoomedHeight = imageHeight / zoom;

    final int zoomX = ((imageWidth - zoomedWidth) / 2).round();
    final int zoomY = ((imageHeight - zoomedHeight) / 2).round();

    image = img.copyCrop(
      image,
      x: zoomX,
      y: zoomY,
      width: zoomedWidth.round(),
      height: zoomedHeight.round(),
    );

    imageWidth = image.width.toDouble();
    imageHeight = image.height.toDouble();
  }

  final double previewAspect = previewWidthOnScreen / previewHeightOnScreen;
  final double imageAspect = imageWidth / imageHeight;

  double displayedWidth;
  double displayedHeight;

  if (imageAspect > previewAspect) {
    displayedHeight = previewHeightOnScreen;
    displayedWidth = displayedHeight * imageAspect;
  } else {
    displayedWidth = previewWidthOnScreen;
    displayedHeight = displayedWidth / imageAspect;
  }

  final double overflowX = (displayedWidth - previewWidthOnScreen) / 2;
  final double overflowY = (displayedHeight - previewHeightOnScreen) / 2;

  final double cropXInPreview = cropLeft - previewLeft;
  final double cropYInPreview = cropTop - previewTop;

  final double cropXInDisplayed = cropXInPreview + overflowX;
  final double cropYInDisplayed = cropYInPreview + overflowY;

  final double scaleX = imageWidth / displayedWidth;
  final double scaleY = imageHeight / displayedHeight;

  int cropX = (cropXInDisplayed * scaleX).round();
  int cropY = (cropYInDisplayed * scaleY).round();
  int cropW = (cropWidth * scaleX).round();
  int cropH = (cropHeight * scaleY).round();

  if (cropX < 0) cropX = 0;
  if (cropY < 0) cropY = 0;
  if (cropX + cropW > image.width) cropW = image.width - cropX;
  if (cropY + cropH > image.height) cropH = image.height - cropY;

  final cropped = img.copyCrop(
    image,
    x: cropX,
    y: cropY,
    width: cropW,
    height: cropH,
  );

  final String croppedPath = path.replaceFirst('.jpg', '_cropped.jpg');
  final File croppedFile = File(croppedPath);
  croppedFile.writeAsBytesSync(img.encodeJpg(cropped, quality: 95));

  return croppedFile;
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late CameraDescription _currentCamera;
  late TutorialCoachMark tutorialCoachMark;
  GlobalKey captureTipsButton = GlobalKey();
  GlobalKey galleryButton = GlobalKey();
  GlobalKey captureButton = GlobalKey();
  GlobalKey _cropOverlayKey = GlobalKey();

  final ImagePicker _picker = ImagePicker();

  bool _isInitialized = false;
  bool _isTakingPicture = false;

  double _minZoom = 1.0;
  double _maxZoom = 1.0;
  double _currentZoom = 1.0;
  double _baseZoom = 1.0;

  bool _hasCameraPermission = false;
  bool _permissionChecked = false;

  @override
  void initState() {
    super.initState();
    _currentCamera = widget.cameras.first;
    _initPage();
  }
  Future<void> _initPage() async {
    await _initCameraWithPermission();

    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      createTutorial();
      await _checkCameraTutorial();
    });
  }
  Future<void> _checkCameraTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('camera_tutorial_first_time') ?? true;

    if (isFirstTime) {
      Future.delayed(Duration.zero, showTutorial);
      await prefs.setBool('camera_tutorial_first_time', false);
    }
  }
  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: Colors.indigo,
      textSkip: S.of(context)!.tutorialSkip,
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        print("Tutorial Finished");
      },
      onSkip: () {
        print("Tutorial Skipped");
        return true;
      },
    );
  }

  Widget _buildContent({
    required String title,
    required String description,
  }) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];
    targets.add(
      TargetFocus(
        identify: "capture",
        keyTarget: captureButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildContent(
                title: S.of(context)!.tutorialCaptureButtonTitle,
                description: S.of(context)!.tutorialCaptureButtonDesc,
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "gallery",
        keyTarget: galleryButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildContent(
                title: S.of(context)!.tutorialGalleryTitle,
                description: S.of(context)!.tutorialGalleryDesc,
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "capture_tips",
        keyTarget: captureTipsButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildContent(
                title: S.of(context)!.tutorialCaptureTipsTitle,
                description: S.of(context)!.tutorialCaptureTipsDesc,
              );
            },
          ),
        ],
      ),
    );



    return targets;
  }
  Future<void> _initCameraWithPermission() async {
    final status = await Permission.camera.request();

    if (!status.isGranted) {
      setState(() {
        _hasCameraPermission = false;
        _permissionChecked = true;
      });
      return;
    }

    _hasCameraPermission = true;
    _permissionChecked = true;

    await _initCamera();
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
    if (!_hasCameraPermission) return;

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
    final zoom = (_baseZoom * details.scale).clamp(_minZoom, _maxZoom);

    _currentZoom = zoom;
    await _controller.setZoomLevel(zoom);
  }



  Future<void> _takePicture() async {
    if (_isTakingPicture || !_controller.value.isInitialized) return;
    _isTakingPicture = true;

    try {
      final XFile raw = await _controller.takePicture();

      final previewSize = _controller.value.previewSize!;
      final screenSize = MediaQuery.of(context).size;

      final double screenAspect = screenSize.width / screenSize.height;
      final double previewAspect = previewSize.height / previewSize.width;

      double previewWidthOnScreen;
      double previewHeightOnScreen;

      if (previewAspect > screenAspect) {
        previewHeightOnScreen = screenSize.height;
        previewWidthOnScreen = previewHeightOnScreen * previewAspect;
      } else {
        previewWidthOnScreen = screenSize.width;
        previewHeightOnScreen = previewWidthOnScreen / previewAspect;
      }

      final double previewLeft = (screenSize.width - previewWidthOnScreen) / 2;
      final double previewTop = (screenSize.height - previewHeightOnScreen) / 2;

      final renderBox =
      _cropOverlayKey.currentContext!.findRenderObject() as RenderBox;
      final overlayOffset = renderBox.localToGlobal(Offset.zero);
      final overlaySize = renderBox.size;

      final File cropped = await compute(_isolateCropTask, {
        'path': raw.path,
        'previewLeft': previewLeft,
        'previewTop': previewTop,
        'previewWidthOnScreen': previewWidthOnScreen,
        'previewHeightOnScreen': previewHeightOnScreen,
        'cropLeft': overlayOffset.dx,
        'cropTop': overlayOffset.dy,
        'cropWidth': overlaySize.width,
        'cropHeight': overlaySize.height,
        'zoom': _currentZoom,
      });

      if (!mounted) return;

      await _controller.dispose();
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => InferencePage(tempImagePath: cropped.path),
        ),
      );

      await _initCamera();
    } catch (e) {
      debugPrint('Take picture error: $e');
    } finally {
      _isTakingPicture = false;
    }
  }

  @override
  void dispose() {
    tutorialCoachMark.finish();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickFromGallery() async {
    final status = await Permission.photos.request();

    if (!status.isGranted) {
      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return;
    }

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
          title: Text(S.of(context)!.confirmPictureTitle),
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
              Text(S.of(context)!.confirmPictureMessage),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(S.of(context)!.cancel),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(S.of(context)!.confirm),
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
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
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
                  Center(
                    child: Text(
                      S.of(context)!.captureTipsTitle,
                      style: TextStyle(
                        fontSize:
                        Theme
                            .of(context)
                            .textTheme
                            .titleLarge
                            ?.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    '1. ${S.of(context)!.captureTip1}\n\n'
                        '2. ${S.of(context)!.captureTip2}\n\n'
                        '3. ${S.of(context)!.captureTip3}\n\n',
                    style: TextStyle(
                        fontSize:
                        Theme
                            .of(context)
                            .textTheme
                            .bodyMedium
                            ?.fontSize),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Text(
                      S.of(context)!.correctCaptureExample,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: Theme
                              .of(context)
                              .textTheme
                              .titleMedium
                              ?.fontSize),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    child: Image.asset(
                      'assets/captureExample.jpg',
                      height: 300,
                      width: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(height: 50),
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
      body: _permissionChecked
          ? SafeArea(
        child: Stack(
          children: [
            Center(
              child: _hasCameraPermission
                  ? (_isInitialized
                  ? GestureDetector(
                onScaleStart: _onScaleStart,
                onScaleUpdate: _onScaleUpdate,
                child: SizedBox.expand(
                  child: FittedBox(
                    fit: BoxFit.cover,
                    child: SizedBox(
                      width:
                      _controller.value.previewSize!.height,
                      height:
                      _controller.value.previewSize!.width,
                      child: CameraPreview(_controller),
                    ),
                  ),
                ),
              )
                  : const CircularProgressIndicator()) // Initializing hardware
                  : Column(
                // Permission denied UI
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.no_photography,
                      color: Colors.white54, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    S.of(context)!.cameraPermissionRequired,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _initCameraWithPermission,
                    // Reuse your init method
                    child: Text(S.of(context)!.grantPermission),
                  ),
                ],
              ),
            ),
            if (_hasCameraPermission && _isInitialized)
              Center(
                child: IgnorePointer(
                  child: Container(
                    key: _cropOverlayKey,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.white, width: 3),
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
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Spacer(),
                    IconButton(
                      key: captureTipsButton,
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
                padding: const EdgeInsets.symmetric(vertical: 20),
                color: Colors.black54,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      key: galleryButton,
                      icon: const Icon(Icons.image,
                          color: Colors.white, size: 28),
                      onPressed: _pickFromGallery,
                    ),
                    GestureDetector(
                      key: captureButton,
                      onTap: _takePicture,
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border:
                          Border.all(color: Colors.white, width: 10),
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
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}
