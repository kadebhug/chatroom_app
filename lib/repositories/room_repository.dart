import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:chatroom_app/models/room.dart';
import 'package:chatroom_app/models/user.dart' as app_user;
import 'package:chatroom_app/models/message.dart';

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

  Stream<List<Room>> getRooms() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('rooms')
        .where('members', arrayContains: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Room.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Stream<List<Message>> getMessages(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Message.fromMap(doc.id, doc.data()))
          .toList();
    });
  }

  Future<void> sendMessage(String roomId, String content) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final message = Message(
      id: '',
      roomId: roomId,
      senderId: user.uid,
      content: content,
      timestamp: DateTime.now(),
      senderName: user.displayName,
    );

    await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .add(message.toMap());
  }

  Stream<List<Room>> getPublicRooms() {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('rooms')
        .where('type', isEqualTo: 'RoomType.public')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
        print('Public rooms snapshot: ${snapshot.docs.length} rooms');
        return snapshot.docs
            .map((doc) {
              final room = Room.fromMap(doc.id, doc.data());
              print('Room ${room.name} type: ${room.type}');
              return room;
            })
            .where((room) => !room.members.contains(user.uid))
            .toList();
      });
  }

  Future<void> joinRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('rooms').doc(roomId).update({
      'members': FieldValue.arrayUnion([user.uid])
    });
  }
}
