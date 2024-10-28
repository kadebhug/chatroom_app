import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:chatroom_app/models/room.dart';
import 'package:chatroom_app/models/user.dart' as app_user;

class RoomRepository {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _auth;

  RoomRepository({
    FirebaseFirestore? firestore,
    firebase_auth.FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? firebase_auth.FirebaseAuth.instance;

  Future<Room> createRoom({
    required String name,
    required RoomType type,
    required List<String> members,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Always include the creator in the members list
    if (!members.contains(user.uid)) {
      members.add(user.uid);
    }

    final roomData = Room(
      id: '',
      name: name,
      createdBy: user.uid,
      type: type,
      members: members,
      createdAt: DateTime.now(),
    ).toMap();

    final docRef = await _firestore.collection('rooms').add(roomData);
    return Room.fromMap(docRef.id, roomData);
  }

  Future<List<app_user.User>> getUsers() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) throw Exception('User not authenticated');

    final querySnapshot = await _firestore.collection('users').get();
    
    return querySnapshot.docs
        .where((doc) => doc.id != currentUser.uid) // Exclude current user
        .map((doc) => app_user.User(
              id: doc.id,
              email: doc.data()['email'] as String?,
              name: '${doc.data()['firstName']} ${doc.data()['lastName']}',
            ))
        .toList()
      ..sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
  }
}
