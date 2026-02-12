import 'package:cloud_recognition/pages/home_page.dart';
import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../widgets/clause.dart';

class WelcomePage extends StatefulWidget {
  final void Function(Locale)? setLocale;
  const WelcomePage ({super.key,this.setLocale});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}
class _WelcomePageState extends State<WelcomePage> {
  bool _isChecked= false;

  final List<Clause> clauses = [
    Clause(
      title: 'Clause 1',
      body:
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
          'Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
    ),
    Clause(
      title: 'Clause 2',
      body:
      'Ut enim ad minim veniam, quis nostrud exercitation ullamco '
          'laboris nisi ut aliquip ex ea commodo consequat.',
    ),
    Clause(
      title: 'Clause 3',
      body:
      'Duis aute irure dolor in reprehenderit in voluptate velit '
          'esse cillum dolore eu fugiat nulla pariatur.',
    ),
  ];


  void showTermsModal(BuildContext context, double height,double width) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child:Container(
          height: height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          S.of(context)!.agreement,
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.titleMedium?.fontSize,
                            color: Colors.grey[800],
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          S.of(context)!.termOfService,
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          S.of(context)!.lastUpdatedDate("20/11/2025"),
                          style: TextStyle(
                            fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),

                    // Close Button
                    InkWell(
                      onTap: () => Navigator.pop(context),
                      child: Icon(Icons.close, size: 28),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Content Scroll Area
              Expanded(
                child:ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  itemCount: clauses.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) {
                    return ClauseItem(clause: clauses[index]);
                  },
                ),
              ),

              // Bottom Button
              Padding(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  width: width*0.7,
                  height: height*0.05,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      setState(() {
                        _isChecked = true;
                      });
                    },
                    child: Text(
                      S.of(context)!.acceptAndContinue,
                      style: TextStyle(
                          fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          PopupMenuButton<Locale>(
            icon: const Icon(Icons.language, color: Colors.white),
            onSelected: (Locale locale) {
              widget.setLocale?.call(locale);
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: Locale('en'),
                child: Text('English'),
              ),
              PopupMenuItem(
                value: Locale('zh'),
                child: Text('中文'),
              ),
              PopupMenuItem(
                value: Locale('my'),
                child: Text('Bahasa Melayu'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
          child:
            Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: h*0.3),
                  Image.asset("assets/google.png", height: 50),
                  SizedBox(height: h*0.3),
                  SizedBox(
                    width: w * 0.7,
                    height: h * 0.06,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage(setLocale:widget.setLocale,)),
                        );
                      },
                      child: Text(
                        S.of(context)!.getStarted,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: h*0.01),
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: w * 0.95,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Checkbox(
                            value: _isChecked,
                            onChanged: (value) {
                              setState(() {
                                _isChecked = value!;
                              });
                            },
                          ),
                          Flexible(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '${S.of(context)!.readAndAgree} ',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    showTermsModal(context, h, w);
                                  },
                                  child: Text(
                                    S.of(context)!.tAndC,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
        ],
            )
      ),

    );
  }
}
class ClauseItem extends StatelessWidget {
  final Clause clause;

  const ClauseItem({super.key, required this.clause});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          clause.title,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          clause.body,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
