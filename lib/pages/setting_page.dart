import 'package:flutter/material.dart';

import '../generated/l10n.dart';

class SettingsPage extends StatelessWidget {
  final void Function(Locale)? setLocale;
  const SettingsPage({super.key, this.setLocale});


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
          color: Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      trailing: isSelected
          ? const Icon(Icons.check, color: Colors.white)
          : null,
      onTap: () {
        setLocale?.call(Locale(code));
        Navigator.pop(context);
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
                    backgroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(16)),
                      side: const BorderSide(
                        color: Colors.white,
                        width: 1,
                      ),
                    ),
                    builder: (context) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _langItem(context, 'English', 'en',setLocale,currentLang),
                          _langItem(context, '中文', 'zh',setLocale,currentLang),
                          //_langItem(context, 'Bahasa Melayu', 'ms',setLocale),
                        ],
                      );
                    },
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
                onTap: () {},
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
