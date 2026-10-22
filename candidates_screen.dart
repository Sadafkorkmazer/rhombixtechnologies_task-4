import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../services/voting_service.dart';

class CandidatesScreen extends StatelessWidget {
  const CandidatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Candidates'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('candidates')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Could not load candidates. Please check Firebase.'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final candidates = snapshot.data?.docs ?? [];

          if (candidates.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No candidates available yet.\n'
                  'Please add candidates to Firestore.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: candidates.length,
            itemBuilder: (context, index) {
              final doc = candidates[index];
              final data = doc.data();

              final name = data['name']?.toString() ?? 'Candidate';
              final party = data['party']?.toString() ?? 'Independent';
              final votes = data['votes'] is num
                  ? (data['votes'] as num).toInt()
                  : 0;

              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                elevation: 2,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    child: Icon(Icons.person),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      '$party\nVotes: $votes',
                    ),
                  ),
                  isThreeLine: true,
                  trailing: FilledButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) {
                          return AlertDialog(
                            title: const Text('Confirm Vote'),
                            content: Text(
                              'Do you want to vote for $name?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, false);
                                },
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                onPressed: () {
                                  Navigator.pop(dialogContext, true);
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                          );
                        },
                      );

                      if (confirm != true || !context.mounted) {
                        return;
                      }

                      try {
                        await VotingService().castVote(
                          candidateId: doc.id,
                        );

                        if (!context.mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Vote submitted successfully!',
                            ),
                          ),
                        );
                      } catch (e) {
                        if (!context.mounted) return;

                        final message = e.toString().replaceFirst(
                              'Exception: ',
                              '',
                            );

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(message),
                          ),
                        );
                      }
                    },
                    child: const Text('Vote'),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}