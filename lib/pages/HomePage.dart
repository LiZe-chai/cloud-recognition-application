import 'package:flutter/material.dart';
import '../generated/l10n.dart';


class HomePage extends StatefulWidget {
  final void Function(Locale)? setLocale;
  const HomePage  ({super.key,this.setLocale});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                Text(
                  S.of(context)!.recentActivities,
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: h*0.02),
                Row(
                  children: [
                    SizedBox(
                      width: w*0.71,
                      height: h*0.05,
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
                    SizedBox(width: w*0.02),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.filter_list),
                      iconSize: w*0.1,
                      color: Colors.white,
                    ),
                  ],
                ),
              ]
            ),
          )
      ),
    );
  }

}