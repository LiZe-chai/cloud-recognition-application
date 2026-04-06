import 'package:cloud_recognition/pages/privacy_policy_page.dart';
import 'package:cloud_recognition/pages/term_of_service_page.dart';
import 'package:cloud_recognition/pages/welcome_page.dart';
import 'package:flutter/material.dart';

import '../generated/l10n.dart';
import '../widgets/clause.dart';

class SettingsPage extends StatefulWidget {
  final void Function(Locale)? setLocale;

  const SettingsPage({super.key, this.setLocale});

  @override
  State<StatefulWidget> createState() => _SettingPageState();
}
class _SettingPageState extends State<SettingsPage>{

  late final List<Clause> clauses = [
    Clause(
      title: S.of(context)!.terms_clause1_title,
      body:S.of(context)!.terms_clause1_body,
    ),
    Clause(
      title: S.of(context)!.terms_clause2_title,
      body:S.of(context)!.terms_clause2_body,
    ),
    Clause(
      title: S.of(context)!.terms_clause3_title,
      body:S.of(context)!.terms_clause3_body,
    ),
    Clause(
      title: S.of(context)!.terms_clause4_title,
      body:S.of(context)!.terms_clause4_body,
    ),
    Clause(
      title: S.of(context)!.terms_clause5_title,
      body:S.of(context)!.terms_clause5_body,
    ),
  ];

  Widget _langItem(
      BuildContext context,
      String text,
      String code,
      void Function(Locale)? setLocale,
      String currentLang,
      ) {
    final isSelected = code == currentLang;

    return ListTile(
      title: Text(
        text,
        style: TextStyle(
          color: Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.black)
          : null,
      onTap: () {
        setLocale?.call(Locale(code));
        Navigator.pop(context);
      },
    );
  }
  void _showAppInfoModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFF1E1E1E),
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.asset("assets/logo.png", height: 180),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    S.of(context)!.appName,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    S.of(context)!.appVersion,
                    style: TextStyle(color: Colors.grey[400], fontSize: Theme.of(context).textTheme.bodySmall?.fontSize),
                  ),

                  const SizedBox(height: 24),
                  const Divider(color: Colors.white10),
                  const SizedBox(height: 20),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blueAccent.withOpacity(0.3)),
                    ),
                    child:  Text(
                      S.of(context)!.appDescription,
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                        color: Colors.white,
                        height: 1.5,
                      ),
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
                child: Icon(Icons.close, size:30,color: Colors.white),
              )
            ),
          ],
        ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final h = MediaQuery.of(context).size.height;
    final w = MediaQuery.of(context).size.width;
    final currentLang = Localizations.localeOf(context).languageCode;


    return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: w * 0.1,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            S.of(context)!.settings,
            style: const TextStyle(color: Colors.black),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.all(w * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                S.of(context)!.generalSettings,
                style: TextStyle(
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              SizedBox(height: h * 0.02),
              _SettingsTile(
                icon: Icons.language,
                title: '${S.of(context)!.language} (${currentLang.toUpperCase()})',
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    backgroundColor: Colors.white,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      side: BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    builder: (context) {
                      return SafeArea(
                          child:Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _langItem(context, 'English', 'en',widget.setLocale,currentLang),
                          _langItem(context, '中文', 'zh',widget.setLocale,currentLang),
                          _langItem(context, 'Bahasa Melayu', 'my',widget.setLocale,currentLang),
                        ],
                      ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: h * 0.02),
              Text(
                S.of(context)!.legal,
                style: TextStyle(
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              SizedBox(height: h * 0.02),
              _SettingsTile(
                icon: Icons.gavel,
                title: S.of(context)!.termOfService,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const TermsOfServicePage(),
                    ),
                  );
                },
              ),
              SizedBox(height: h * 0.01),
              _SettingsTile(
                icon: Icons.policy,
                title: S.of(context)!.privacyPolicy,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyPage(),
                    ),
                  );
                },
              ),
              SizedBox(height: h * 0.02),
              Text(
                S.of(context)!.aboutThisApp,
                style: TextStyle(
                    fontSize: w * 0.06,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
              SizedBox(height: h * 0.02),
              _SettingsTile(
                icon: Icons.info,
                title: S.of(context)!.appInfo,
                onTap: () => _showAppInfoModal(context),
              ),
            ],
          ),
        ));
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: w * 0.06, color: Colors.white),
            SizedBox(width: w * 0.05),
            Text(
              title,
              style: TextStyle(fontSize: w * 0.05, color: Colors.white),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
