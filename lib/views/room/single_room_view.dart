import 'package:flutter/material.dart';

class SingleRoomView extends StatelessWidget {
  final String roomId;

  const SingleRoomView({Key? key, required this.roomId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Room $roomId')),
      body: Center(child: Text('Single Room View for Room $roomId')),
    );
  }
}
