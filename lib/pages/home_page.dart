import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../generated/l10n.dart';
import '../models/prediction_model.dart';
import '../widgets/cloud_card.dart';

class HomePage extends StatefulWidget {
  final void Function(Locale)? setLocale;

  const HomePage({super.key, this.setLocale});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    final box = Hive.box<PredictionModel>('predictions');

    if (box.isEmpty) {
      box.add(
        PredictionModel(
          imagePath: 'assets/Ac-N004.jpg',
          name: 'Cloud 1',
          date: DateTime.now(),
          cloudType: 'Cumulus',
          confidence: 0.92,
        ),
      );
    }
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
          Text(
            S.of(context)!.recentActivities,
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
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
                ),
              ),
              SizedBox(width: w * 0.02),
              IconButton(
                onPressed: () {},
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
                  return const Center(
                    child: Text(
                      'No cloud predictions yet ☁️',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: box.length,
                  itemBuilder: (context, index) {
                    final prediction = box.getAt(index)!;

                    return CloudCard(
                      imagePath: prediction.imagePath,
                      name: prediction.name,
                      date: prediction.date,
                      cloudType: prediction.cloudType,
                      confidence: prediction.confidence,
                    );
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
          onPressed: () {},
          backgroundColor: Colors.white,
          child: Icon(Icons.center_focus_strong,
              size: w * 0.2, color: Colors.black),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        height: h * 0.1,
        color: Colors.white24,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.home,
                  color: Colors.white,
                  size: w * 0.08,
                ),
                Text(
                  S.of(context)!.home,
                  style: TextStyle(color: Colors.white, fontSize: w * 0.04),
                ),
              ],
            ),
            SizedBox(width: w * 0.1),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.settings, color: Colors.white, size: w * 0.08),
                Text(
                  S.of(context)!.settings,
                  style: TextStyle(color: Colors.white, fontSize: w * 0.04),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
