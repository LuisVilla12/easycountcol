import 'dart:typed_data';

import 'package:intl/intl.dart';

class ResultadoFollow {
  final int id;
  final String name;
  final String description;
  final String dateFollow;
  final String formattedTime;

  ResultadoFollow({
    required this.id,
    required this.name,
    required this.description,
    required this.dateFollow,
    required this.formattedTime,
  });

  factory ResultadoFollow.fromMap(Map<String, dynamic> data) {
    final follow = data['follow'];
    final timeSample = follow[6];
    final DateTime now = DateTime.now();
    final DateTime creationTime = DateTime(now.year, now.month, now.day)
        .add(Duration(seconds: timeSample.toInt()));
    final String formattedTime =
        DateFormat('HH:mm:ss').format(creationTime);

    return ResultadoFollow(
      id: follow[0],
      name: follow[1],
      description: follow[3],
      dateFollow: follow[4],
      formattedTime: formattedTime,
    );
  }
}
