import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class SocialService extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  /// Search users by name OR email (prefix match), annotated with the current
  /// user's relation to each result: 'friend' | 'pending' | 'none'.
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    final uid = _uid;
    if (query.trim().isEmpty || uid == null) return [];
    final q = query.toLowerCase().trim();

    final found = <String, Map<String, dynamic>>{};

    Future<void> runPrefix(String field) async {
      try {
        final snap = await _db
            .collection('users')
            .where(field, isGreaterThanOrEqualTo: q)
            .where(field, isLessThan: '$q')
            .limit(20)
            .get();
        for (final d in snap.docs) {
          if (d.id != uid) found[d.id] = {'uid': d.id, ...d.data()};
        }
      } catch (_) {
        // field may be missing / unindexed — ignore and continue
      }
    }

    await runPrefix('searchKey'); // by name
    await runPrefix('emailKey');  // by email

    if (found.isEmpty) return [];

    final friends = await _friendUids(uid);
    final pending = await _outgoingPendingUids(uid);

    return found.values.map((u) {
      final fid = u['uid'] as String;
      final relation = friends.contains(fid)
          ? 'friend'
          : pending.contains(fid)
              ? 'pending'
              : 'none';
      return {...u, '_relation': relation};
    }).toList();
  }

  Future<Set<String>> _friendUids(String uid) async {
    final snap = await _db.collection('users').doc(uid).collection('friends').get();
    return snap.docs.map((d) => d.id).toSet();
  }

  Future<Set<String>> _outgoingPendingUids(String uid) async {
    final snap = await _db
        .collection('friend_requests')
        .where('from', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .get();
    return snap.docs.map((d) => d.data()['to'] as String).toSet();
  }

  Future<String?> sendFriendRequest(String targetUid) async {
    final uid = _uid;
    if (uid == null) return 'Not authenticated';
    try {
      final reqId = '${uid}_$targetUid';
      final existing = await _db.collection('friend_requests').doc(reqId).get();
      if (existing.exists) return 'Permintaan sudah dikirim';
      await _db.collection('friend_requests').doc(reqId).set({
        'from': uid,
        'to': targetUid,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> acceptFriendRequest(String requestId, String fromUid) async {
    final uid = _uid;
    if (uid == null) return 'Not authenticated';
    try {
      final batch = _db.batch();
      batch.update(_db.collection('friend_requests').doc(requestId), {'status': 'accepted'});
      batch.set(_db.collection('users').doc(uid).collection('friends').doc(fromUid), {
        'uid': fromUid,
        'since': FieldValue.serverTimestamp(),
      });
      batch.set(_db.collection('users').doc(fromUid).collection('friends').doc(uid), {
        'uid': uid,
        'since': FieldValue.serverTimestamp(),
      });
      await batch.commit();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<void> declineFriendRequest(String requestId) async {
    await _db.collection('friend_requests').doc(requestId).delete();
  }

  Future<void> removeFriend(String friendUid) async {
    final uid = _uid;
    if (uid == null) return;
    final batch = _db.batch();
    batch.delete(_db.collection('users').doc(uid).collection('friends').doc(friendUid));
    batch.delete(_db.collection('users').doc(friendUid).collection('friends').doc(uid));
    await batch.commit();
  }

  Stream<List<Map<String, dynamic>>> friendsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('users')
        .doc(uid)
        .collection('friends')
        .snapshots()
        .asyncMap((snap) async {
      final friends = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final friendUid = doc.id;
        final userDoc = await _db.collection('users').doc(friendUid).get();
        if (userDoc.exists) {
          friends.add({'uid': friendUid, ...userDoc.data()!});
        }
      }
      return friends;
    });
  }

  Stream<List<Map<String, dynamic>>> incomingRequestsStream() {
    final uid = _uid;
    if (uid == null) return const Stream.empty();
    return _db
        .collection('friend_requests')
        .where('to', isEqualTo: uid)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .asyncMap((snap) async {
      final requests = <Map<String, dynamic>>[];
      for (final doc in snap.docs) {
        final fromUid = doc.data()['from'] as String;
        final userDoc = await _db.collection('users').doc(fromUid).get();
        if (userDoc.exists) {
          requests.add({'requestId': doc.id, 'uid': fromUid, ...userDoc.data()!});
        }
      }
      return requests;
    });
  }

  Future<List<Map<String, dynamic>>> friendWorkouts(String friendUid) async {
    final snap = await _db
        .collection('users')
        .doc(friendUid)
        .collection('workouts')
        .orderBy('date', descending: true)
        .limit(10)
        .get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }
}
