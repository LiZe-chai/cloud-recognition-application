import 'package:cloud_recognition/pages/setting_page.dart';
import 'package:cloud_recognition/services/inference.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
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
      filtered = filtered
          .where((e) => selectedCloudTypes.contains(e.cloudType))
          .toList();
    }
    if (searchQuery.isNotEmpty) {
      filtered = filtered.where((e) {
        return e.cloudType.name.toLowerCase().contains(searchQuery)
            || e.name.toLowerCase().contains(searchQuery);
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
          child: Icon(Icons.center_focus_strong,
              size: w * 0.15, color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
          ),
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
