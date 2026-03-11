import 'dart:ui';

import 'package:cloud_recognition/pages/setting_page.dart';
import 'package:cloud_recognition/services/inference.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
  bool _tutorialInitialized = false;

  GlobalKey captureButton = GlobalKey();
  GlobalKey searchQueryField = GlobalKey();
  GlobalKey filterButton = GlobalKey();
  GlobalKey settingsButton = GlobalKey();
  GlobalKey inferenceHistoryRegion = GlobalKey();

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }
  Future<void> _checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstTime = prefs.getBool('is_first_time') ?? true;

    if (isFirstTime) {
      Future.delayed(Duration.zero, showTutorial);
      await prefs.setBool('is_first_time', false);
    }
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
    )
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
                title: S.of(context)!.tutorialCaptureTitle,
                description:
                S.of(context)!.tutorialCaptureDesc,
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "filter",
        keyTarget: filterButton,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.left,
            builder: (context, controller) {
              return _buildContent(
                title: S.of(context)!.tutorialFilterTitle,
                description:
                S.of(context)!.tutorialFilterDesc,
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "search",
        keyTarget: searchQueryField,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return _buildContent(
                title: S.of(context)!.tutorialSearchTitle,
                description:
                S.of(context)!.tutorialSearchDesc,
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
              return _buildContent(
                title: S.of(context)!.tutorialSettingsTitle,
                description:
                S.of(context)!.tutorialSettingsDesc,
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "history",
        keyTarget: inferenceHistoryRegion,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return _buildContent(
                title: S.of(context)!.tutorialHistoryTitle,
                description:
                S.of(context)!.tutorialHistoryDesc,
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

        final top3 = getTop3(e.probabilities);

        return top3.any(
              (t) => selectedCloudTypes.contains(t["type"]),
        );

      }).toList();
    }
    if (searchQuery.isNotEmpty) {

      final query = searchQuery.toLowerCase();

      filtered = filtered.where((e) {

        bool nameMatch =
        e.name.toLowerCase().contains(query);

        final top3 = getTop3(e.probabilities);

        bool typeMatch = top3.any(
              (t) => (t["type"] as CloudType)
              .label(context)
              .toLowerCase()
              .contains(query),
        );

        bool dateMatch =
        e.date.toString().toLowerCase().contains(query);

        return nameMatch || typeMatch || dateMatch;

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
  void initState() {
    super.initState();
    _checkFirstTime();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_tutorialInitialized) {
      _tutorialInitialized = true;
      createTutorial();
    }
  }
  @override
  Widget build(BuildContext context) {
    final box = Hive.box<PredictionModel>('predictions');
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomInset: false,
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
              key: inferenceHistoryRegion,
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
