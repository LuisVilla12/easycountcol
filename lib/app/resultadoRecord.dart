import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'dart:convert';

class ResultadoRecord {
  final int id;
  final Uint8List originalImage;
  final Uint8List processedImage;
  final String dateSample;
  final double processingTime;
  final int count;
  final int dayNumber;
  final String formattedTime;
  final int optimalClusters;
  final Map<String, dynamic> clustersDetail;


  ResultadoRecord({
    required this.id,
    required this.originalImage,
    required this.processedImage,
    required this.dateSample,
    required this.processingTime,
    required this.count,
    required this.dayNumber,
    required this.formattedTime,
    required this.optimalClusters,
    required this.clustersDetail,
  });

  factory ResultadoRecord.fromMap(Map<String, dynamic> data) {
    final record = data['record'];
    final timeSample = record[5];
    final DateTime now = DateTime.now();
    final DateTime creationTime = DateTime(now.year, now.month, now.day)
        .add(Duration(seconds: timeSample.toInt()));
    final String formattedTime = DateFormat('HH:mm:ss').format(creationTime);

    return ResultadoRecord(
      id: record[0],
      originalImage: data['originalImage'] as Uint8List,
      processedImage: data['processedImage']as Uint8List,
      count: record[3],
      dayNumber: record[4],
      dateSample: record[6],
      processingTime: record[8],
      formattedTime: formattedTime,
      optimalClusters: record[10],
      clustersDetail: record[9] != null
          ? jsonDecode(record[9])
          : {},
    );
  }
}
