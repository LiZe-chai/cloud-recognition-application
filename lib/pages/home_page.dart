import 'dart:ui';

import 'package:cloud_recognition/pages/setting_page.dart';
import 'package:cloud_recognition/services/inference.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import '../generated/l10n.dart';
import '../main.dart';
import '../models/prediction_model.dart';
import '../widgets/cloud_card.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'camera_page.dart';

class HomePage extends StatefulWidget {
  final void Function(Locale)? setLocale;
  const HomePage({super.key, this.setLocale});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Set<CloudType> selectedCloudTypes = {};
  bool sortLatest = true;
  String searchQuery = '';
  late TutorialCoachMark tutorialCoachMark;

  GlobalKey captureButton = GlobalKey();
  GlobalKey cardRegion = GlobalKey();
  GlobalKey searchQueryField = GlobalKey();
  GlobalKey filterButton = GlobalKey();
  GlobalKey settingsButton = GlobalKey();

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  Future<void> createTutorial() async {
    tutorialCoachMark = TutorialCoachMark(
      targets: await _createTargets(),
      colorShadow: Colors.indigo,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        print("target: $target");
        print(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
      onSkip: () {
        print("skip");
        return true;
      },
    );
  }

  Future<List<TargetFocus>> _createTargets() async {
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
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Infer your cloud image by access this",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "filtering",
        keyTarget: filterButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Filter your inference history by categorising cloud type and sort by time",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "searchQuery",
        keyTarget: searchQueryField,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "Search your inference history by query the name",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "settings",
        keyTarget: settingsButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "access settings for changing language or view app info",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    return targets;
  }

  void _filterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child:
          FilterBottomSheet(
          initialCloudTypes: selectedCloudTypes,
          initialSortLatest: sortLatest,
          onApply: (cloudType, latest) {
            setState(() {
              selectedCloudTypes = cloudType;
              sortLatest = latest;
            });
          },
        ),
        );
      },
    );
  }
  List<PredictionModel> _applyFilter(List<PredictionModel> list) {
    var filtered = [...list];

    if (selectedCloudTypes.isNotEmpty) {
      filtered = filtered.where((e) {
        return e.detections.any((d) => selectedCloudTypes.contains(d.cloudType));
      }).toList();
    }

    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      filtered = filtered.where((e) {
        bool nameMatch = e.name.toLowerCase().contains(query);
        bool typeMatch = e.detections.any((d) =>
            d.cloudType.name.toLowerCase().contains(query));

        return nameMatch || typeMatch;
      }).toList();
    }

    filtered.sort((a, b) {
      return sortLatest
          ? b.date.compareTo(a.date)
          : a.date.compareTo(b.date);
    });

    return filtered;
  }
  @override
  void initState(){
    createTutorial();
    Future.delayed(Duration.zero, showTutorial);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<PredictionModel>('predictions');
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            children: [
              Text(
                S.of(context)!.recentActivities,
                style: TextStyle(
                  fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                key: settingsButton,
                icon: Icon(
                  Icons.settings,
                  color: Colors.white,
                  size: w * 0.08,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => SettingsPage(setLocale: widget.setLocale),
                    ),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: h * 0.02),
          Row(
            children: [
              SizedBox(
                width: w * 0.71,
                height: h * 0.05,
                child: SearchBar(
                  key:searchQueryField,
                  hintText: S.of(context)!.search,
                  leading: Icon(Icons.search),
                  backgroundColor: WidgetStatePropertyAll(Colors.grey[200]),
                  shape: WidgetStatePropertyAll(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onChanged: (value) => {
                    setState(() {
                      searchQuery = value.trim().toLowerCase();
                    }),
                  },
                  trailing: searchQuery.isNotEmpty
                      ? [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        setState(() {
                          searchQuery = '';
                        });
                      },
                    )
                  ] : null,
                ),
              ),
              SizedBox(width: w * 0.02),
              IconButton(
                key: filterButton,
                onPressed: _filterModal,
                icon: Icon(Icons.filter_list),
                iconSize: w * 0.1,
                color: Colors.white,
              ),
            ],
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: box.listenable(),
              builder: (context, Box<PredictionModel> box, _) {
                if (box.isEmpty) {
                  return Center(
                    child: Text(
                      S.of(context)!.noCloudPredictions,
                      style: TextStyle(color: Colors.white,fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize),

                    ),
                  );
                }
                final filtered = _applyFilter(box.values.toList());
                if (filtered.isEmpty) {
                  return Center(
                    child: Text(
                      S.of(context)!.noResultMatchesFilter,
                      style: TextStyle(color: Colors.white70, fontSize: Theme.of(context).textTheme.bodyLarge?.fontSize),
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    return CloudCard(result: filtered[index]);
                  },
                );
              },
            ),
          ),
        ]),
      )),
      floatingActionButton: SizedBox(
        width: w * 0.2,
        height: w * 0.2,
        key: captureButton,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => CameraPage(cameras: cameras),
              ),
            );
          },
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
          child: Icon(Icons.center_focus_strong,
              size: w * 0.15, color: Colors.black),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: h * 0.05,
        color: Colors.white24,
      ),
    );
  }
}
