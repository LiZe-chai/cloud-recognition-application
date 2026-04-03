import 'dart:io';

import 'package:cloud_recognition/services/inference.dart';
import 'package:cloud_recognition/widgets/contour_painter.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../generated/l10n.dart';
import '../models/prediction_model.dart';

class PreviewPage extends StatefulWidget {
  final List<List<Map<String, int>>> contours;
  final List<double> results;
  final String tempImagePath;
  final int imageWidth;
  final int imageHeight;

  const PreviewPage({
    super.key,
    required this.tempImagePath,
    required this.imageWidth,
    required this.imageHeight,
    required this.contours,
    required this.results,
  });

  @override
  State<PreviewPage> createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  bool _showAllResults = false;

  Future<bool?> showSaveAsDialog(BuildContext context) async {
    final controller = TextEditingController();
    final box = Hive.box<PredictionModel>('predictions');

    return await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      S.of(dialogContext)!.saveAs,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyLarge?.fontSize,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(dialogContext, false),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  S.of(dialogContext)!.fileName,
                  style: TextStyle(
                      fontSize:
                          Theme.of(context).textTheme.bodyMedium?.fontSize),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: S.of(dialogContext)!.enterFileName,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = controller.text.trim();
                      if (name.isEmpty) return;

                      final savedImagePath =
                          await saveImageToAppDir(File(widget.tempImagePath));

                      final prediction = PredictionModel(
                        imagePath: savedImagePath,
                        name: name,
                        date: DateTime.now(),
                        imageWidth: widget.imageWidth,
                        imageHeight: widget.imageHeight,
                        contours: widget.contours,
                        probabilities: widget.results,
                      );

                      box.add(prediction);

                      Navigator.pop(dialogContext, true);
                    },
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.black,
                    ),
                    child: Text(S.of(dialogContext)!.saveAction,
                        style: TextStyle(
                            fontSize:
                                Theme.of(context).textTheme.bodyLarge?.fontSize,
                            color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showCloudInfo(BuildContext context, CloudType type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type.label(context),
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.titleLarge?.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        type.imageAsset,
                        height: 180,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Example Image",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodySmall?.fontSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white54,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      type.description(context),
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize:
                            Theme.of(context).textTheme.bodyMedium?.fontSize,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                  right: 10,
                  top: 10,
                  child: InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Icon(Icons.close, size: 30, color: Colors.white),
                  )),
            ],
          ),
        );
      },
    );
  }

  Future<String> saveImageToAppDir(File tempImage) async {
    final dir = await getApplicationDocumentsDirectory();

    final predictionDir = Directory('${dir.path}/predictions');
    if (!await predictionDir.exists()) {
      await predictionDir.create(recursive: true);
    }

    final fileName =
        'cloud_${DateTime.now().millisecondsSinceEpoch}${p.extension(tempImage.path)}';

    final savedImage = await tempImage.copy('${predictionDir.path}/$fileName');

    return savedImage.path;
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final sorted_results = sortResults(widget.results);
    final displayedResults =
        _showAllResults ? sorted_results : sorted_results.take(3).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                      color: Colors.white,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Container(
                        color: Colors.grey[900],
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                Image.file(
                                  File(widget.tempImagePath),
                                  width: constraints.maxWidth,
                                  height: constraints.maxHeight,
                                  fit: BoxFit.cover,
                                ),
                                CustomPaint(
                                  size: Size(
                                    constraints.maxWidth,
                                    constraints.maxHeight,
                                  ),
                                  painter: ContourPainter(
                                    widget.contours,
                                    widget.imageWidth,
                                    widget.imageHeight,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 24),
                          Text(
                            S.of(context)!.predictionResult,
                            style: TextStyle(
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyLarge
                                  ?.fontSize,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                ...displayedResults
                                    .asMap()
                                    .entries
                                    .map<Widget>((entry) {
                                  int index = entry.key;
                                  final detection = entry.value as Map<String, dynamic>;
                                  final CloudType type = detection['type'] as CloudType;
                                  final cloudColor = type.color;
                                  bool isLast = index == displayedResults.length - 1;

                                  return Column(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: 26,
                                                  height: 26,
                                                  decoration: BoxDecoration(
                                                    color: cloudColor.withOpacity(0.2),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  alignment: Alignment.center,
                                                  child: Text(
                                                    '${index + 1}',
                                                    style: TextStyle(
                                                      color: cloudColor,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium
                                                          ?.fontSize,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      type.label(context),
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: Theme.of(context)
                                                            .textTheme
                                                            .bodyMedium
                                                            ?.fontSize,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    GestureDetector(
                                                      onTap: () {
                                                        _showCloudInfo(context, type);
                                                      },
                                                      child: const Icon(
                                                        Icons.info_outline,
                                                        size: 20,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const Spacer(),
                                                Text(
                                                  '${(detection['confidence'] * 100).toStringAsFixed(0)}%',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium
                                                        ?.fontSize,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Stack(
                                              children: [
                                                Container(
                                                  height: 6,
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black26,
                                                    borderRadius: BorderRadius.circular(3),
                                                  ),
                                                ),
                                                FractionallySizedBox(
                                                  widthFactor:
                                                  (detection['confidence'] as double).clamp(0.0, 1.0),
                                                  child: Container(
                                                    height: 6,
                                                    decoration: BoxDecoration(
                                                      color: cloudColor,
                                                      borderRadius: BorderRadius.circular(3),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isLast)
                                        Divider(
                                          height: 1,
                                          thickness: 1,
                                          color: Colors.white.withOpacity(0.05),
                                          indent: 16,
                                          endIndent: 16,
                                        ),
                                    ],
                                  );
                                }).toList(),

                                if (sorted_results.length > 3)
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        _showAllResults = !_showAllResults;
                                      });
                                    },
                                    child: Text(
                                      _showAllResults
                                          ? S.of(context)!.showLess
                                          : S.of(context)!.showMore,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: h * 0.09,
                color: const Color(0xFF2E2E2E),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          color: Colors.white,
                          onPressed: () {
                            Navigator.pop(context, false);
                          },
                        ),
                        Text(
                          S.of(context)!.newAction,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.save),
                          color: Colors.white,
                          onPressed: () async {
                            final bool? saved = await showSaveAsDialog(context);
                            if (saved != true) return;
                            Navigator.pop(context);
                            Navigator.pop(context);
                          },
                        ),
                        Text(
                          S.of(context)!.saveAction,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
