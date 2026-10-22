import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Election Results')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('candidates')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('Unable to load results.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs.toList()
            ..sort((a, b) {
              final av = a.data()['votes'] as num? ?? 0;
              final bv = b.data()['votes'] as num? ?? 0;
              return bv.compareTo(av);
            });

          if (docs.isEmpty) {
            return const Center(child: Text('No results available.'));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Card(
                color: Color(0xFFEAF0FF),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Candidate vote totals. Results are not official '
                    'until authorized election administrators publish them.',
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ...docs.map((doc) {
                final data = doc.data();
                final votes = (data['votes'] as num? ?? 0).toInt();

                return Card(
                  color: Colors.white,
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(data['name']?.toString() ?? 'Candidate'),
                    subtitle: Text(
                      data['party']?.toString() ?? 'Independent',
                    ),
                    trailing: Text(
                      '$votes votes',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2457C5),
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}