import 'package:flutter/material.dart';

class RoomListView extends StatelessWidget {
  const RoomListView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Rooms')),
      body: const Center(child: Text('Room List View')),
    );
  }
}
