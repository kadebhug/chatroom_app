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
      readBy: [user.uid],
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

  Future<void> markMessagesAsRead(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get all messages in the room
    final querySnapshot = await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .get();

    // Mark unread messages as read
    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      final readBy = List<String>.from(doc.data()['readBy'] ?? []);
      if (!readBy.contains(user.uid)) {
        batch.update(doc.reference, {
          'readBy': FieldValue.arrayUnion([user.uid])
        });
      }
    }
    await batch.commit();
  }

  Stream<int> getUnreadMessageCount(String roomId) {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    return _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .where((doc) => !(doc.data()['readBy'] as List<dynamic>)
                  .contains(user.uid))
              .length;
        });
  }

  Stream<Room> getRoomDetails(String roomId) {
    return _firestore
        .collection('rooms')
        .doc(roomId)
        .snapshots()
        .map((doc) => Room.fromMap(doc.id, doc.data()!));
  }

  Future<void> updateRoomName(String roomId, String newName) async {
    await _firestore.collection('rooms').doc(roomId).update({
      'name': newName,
    });
  }

  Future<void> leaveRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore.collection('rooms').doc(roomId).update({
      'members': FieldValue.arrayRemove([user.uid])
    });
  }

  Future<void> deleteRoom(String roomId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    // Get room data to verify creator
    final roomDoc = await _firestore.collection('rooms').doc(roomId).get();
    final room = Room.fromMap(roomDoc.id, roomDoc.data()!);

    if (room.createdBy != user.uid) {
      throw Exception('Only the room creator can delete the room');
    }

    // Delete all messages in the room
    final messages = await _firestore
        .collection('rooms')
        .doc(roomId)
        .collection('messages')
        .get();
    
    final batch = _firestore.batch();
    for (var message in messages.docs) {
      batch.delete(message.reference);
    }
    
    // Delete the room document
    batch.delete(_firestore.collection('rooms').doc(roomId));
    
    await batch.commit();
  }
}
