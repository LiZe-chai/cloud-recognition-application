import 'package:flutter/material.dart';
import '../generated/l10n.dart';
import '../widgets/clause.dart';
import 'welcome_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final clauses = [
      Clause(
        title: S.of(context)!.privacy_clause1_title,
        body: S.of(context)!.privacy_clause1_body,
      ),
      Clause(
        title: S.of(context)!.privacy_clause2_title,
        body: S.of(context)!.privacy_clause2_body,
      ),
      Clause(
        title: S.of(context)!.privacy_clause3_title,
        body: S.of(context)!.privacy_clause3_body,
      ),
      Clause(
        title: S.of(context)!.privacy_clause4_title,
        body: S.of(context)!.privacy_clause4_body,
      ),
      Clause(
        title: S.of(context)!.privacy_clause5_title,
        body: S.of(context)!.privacy_clause5_body,
      ),
      Clause(
        title: S.of(context)!.privacy_clause6_title,
        body: S.of(context)!.privacy_clause6_body,
      ),
      Clause(
        title: S.of(context)!.privacy_clause7_title,
        body: S.of(context)!.privacy_clause7_body,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        width: double.infinity,
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    S.of(context)!.privacyPolicy,
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.titleLarge?.fontSize,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    S.of(context)!.effectiveDate("Apr 3, 2026"),
                    style: TextStyle(
                      fontSize: Theme.of(context).textTheme.bodyMedium?.fontSize,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: clauses.length,
                separatorBuilder: (_, __) => const SizedBox(height: 24),
                itemBuilder: (context, index) {
                  return ClauseItem(clause: clauses[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}