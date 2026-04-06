import 'dart:io';

import 'package:cloud_recognition/services/inference.dart';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../models/prediction_model.dart';
import '../widgets/contour_painter.dart';
import 'camera_page.dart';

class SavedResultPage extends StatefulWidget {
  final PredictionModel result;

  const SavedResultPage({
    super.key,
    required this.result,
  });

  @override
  State<SavedResultPage> createState() => _SavedResultPageState();
}

class _SavedResultPageState extends State<SavedResultPage> {
  bool _showAllResults = false;

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
                      S.of(context)!.exampleImage,
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
                            Theme.of(context).textTheme.bodyLarge?.fontSize,
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

  @override
  Widget build(BuildContext context) {
    final sorted_results = sortResults(widget.result.probabilities);
    final displayedResults =
    _showAllResults ? sorted_results : sorted_results.take(1).toList();
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
                                  File(widget.result.imagePath),
                                  fit: BoxFit.contain,
                                ),
                                CustomPaint(
                                  size: Size(
                                    constraints.maxWidth,
                                    constraints.maxHeight,
                                  ),
                                  painter: ContourPainter(
                                    widget.result.contours,
                                    widget.result.imageWidth,
                                    widget.result.imageHeight,
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
                              children:
                                  [...displayedResults.asMap().entries.map<Widget>((entry) {
                                int index = entry.key;
                                final detection = entry.value;
                                final CloudType type =
                                    detection['type'] as CloudType;
                                final cloudColor = type.color;
                                bool isLast =
                                    index == widget.result.probabilities.length - 1;

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
                                                  color: cloudColor
                                                      .withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                alignment: Alignment.center,
                                                child: Text(
                                                  '${index + 1}',
                                                  style: TextStyle(
                                                    color: Colors.white,
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
                                                      fontSize:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.fontSize,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 6),
                                                  GestureDetector(
                                                    onTap: () {
                                                      _showCloudInfo(
                                                          context, type);
                                                    },
                                                    child: Icon(
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
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                ),
                                              ),
                                              FractionallySizedBox(
                                                widthFactor:
                                                    detection['confidence']
                                                        .clamp(0.0, 1.0),
                                                child: Container(
                                                  height: 6,
                                                  decoration: BoxDecoration(
                                                    color: cloudColor,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            3),
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
                                    if (sorted_results.length > 1)
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
                          const SizedBox(height: 20),
                          _buildSimpleInfoTile(
                              S.of(context)!.name, widget.result.name, context),
                          _buildSimpleInfoTile(
                              S.of(context)!.date,
                              '${widget.result.date.year}-${widget.result.date.month}-${widget.result.date.day}',
                              context),
                          const SizedBox(height: 120),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                iconSize: 28,
                onPressed: () => Navigator.pop(context),
                color: Colors.white,
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF2E2E2E),
                  border: Border(
                      top: BorderSide(color: Colors.white10, width: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => CameraPage(cameras: cameras),
                          ),
                        );
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.camera_alt,
                              color: Colors.white, size: 28),
                          const SizedBox(height: 4),
                          Text(
                            S.of(context)!.newAction,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.fontSize,
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildSimpleInfoTile(
      String label, String value, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.white54,
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize)),
          const SizedBox(height: 4),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize,
                  fontWeight: FontWeight.bold)),
          const Divider(color: Colors.white12),
        ],
      ),
    );
  }
}
