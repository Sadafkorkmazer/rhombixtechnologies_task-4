import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VotingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> castVote({
    required String candidateId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please login before voting.');
    }

    final voteRef = _db.collection('votes').doc(user.uid);
    final candidateRef = _db.collection('candidates').doc(candidateId);

    await _db.runTransaction((transaction) async {
      final vote = await transaction.get(voteRef);
      final candidate = await transaction.get(candidateRef);

      if (vote.exists) {
        throw Exception('You have already voted.');
      }

      if (!candidate.exists) {
        throw Exception('Candidate not found.');
      }

      final data = candidate.data()!;
      final votes = data['votes'] ?? 0;

      transaction.set(voteRef, {
        'userId': user.uid,
        'candidateId': candidateId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(candidateRef, {
        'votes': (votes as num).toInt() + 1,
      });
    });
  }
}