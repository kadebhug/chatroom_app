import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String roomId;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final String? senderName;

  Message({
    required this.id,
    required this.roomId,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.senderName,
  });

  Map<String, dynamic> toMap() {
    return {
      'roomId': roomId,
      'senderId': senderId,
      'content': content,
      'timestamp': Timestamp.fromDate(timestamp),
      'senderName': senderName,
    };
  }

  factory Message.fromMap(String id, Map<String, dynamic> map) {
    return Message(
      id: id,
      roomId: map['roomId'] as String,
      senderId: map['senderId'] as String,
      content: map['content'] as String,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      senderName: map['senderName'] as String?,
    );
  }
} 