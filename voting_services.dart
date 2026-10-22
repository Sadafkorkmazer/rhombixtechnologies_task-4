import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VotingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> castVote({
    required String candidateId,
  }) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw Exception('Please login before voting.');
    }

    final voteRef = _firestore.collection('votes').doc(user.uid);
    final candidateRef =
        _firestore.collection('candidates').doc(candidateId);

    await _firestore.runTransaction((transaction) async {
      final voteSnapshot = await transaction.get(voteRef);
      final candidateSnapshot = await transaction.get(candidateRef);

      if (voteSnapshot.exists) {
        throw Exception('You have already voted.');
      }

      if (!candidateSnapshot.exists) {
        throw Exception('Candidate not found.');
      }

      final data = candidateSnapshot.data();
      final currentVotes = data?['votes'] ?? 0;

      transaction.set(voteRef, {
        'userId': user.uid,
        'candidateId': candidateId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      transaction.update(candidateRef, {
        'votes': (currentVotes as num).toInt() + 1,
      });
    });
  }
}ss