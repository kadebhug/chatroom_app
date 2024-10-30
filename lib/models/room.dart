import 'package:cloud_firestore/cloud_firestore.dart';

enum RoomType {
  private,
  public;

  @override
  String toString() {
    return 'RoomType.$name';
  }
}

class Room {
  final String id;
  final String name;
  final String createdBy;
  final RoomType type;
  final List<String> members;
  final DateTime createdAt;

  Room({
    required this.id,
    required this.name,
    required this.createdBy,
    required this.type,
    required this.members,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'createdBy': createdBy,
      'type': type.toString(),
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Room.fromMap(String id, Map<String, dynamic> map) {
    print('Converting room data: $map');
    return Room(
      id: id,
      name: map['name'] as String,
      createdBy: map['createdBy'] as String,
      type: RoomType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => RoomType.public,
      ),
      members: List<String>.from(map['members'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}
