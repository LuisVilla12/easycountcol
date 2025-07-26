import 'dart:typed_data';

import 'package:intl/intl.dart';

class ResultadoMuestra {
  final Uint8List originalImage;
  final Uint8List processedImage;
  final String name;
  final String typeSample;
  final String volumenSample;
  final String factorSample;
  final String dateSample;
  final double processingTime;
  final int count;
  final String medioSample;
  final String formattedTime;

  ResultadoMuestra({
    required this.originalImage,
    required this.processedImage,
    required this.name,
    required this.typeSample,
    required this.volumenSample,
    required this.factorSample,
    required this.dateSample,
    required this.processingTime,
    required this.count,
    required this.medioSample,
    required this.formattedTime,
  });

  factory ResultadoMuestra.fromMap(Map<String, dynamic> data) {
    final sample = data['sample'];
    final timeSample = sample[10];
    final DateTime now = DateTime.now();
    final DateTime creationTime = DateTime(now.year, now.month, now.day)
        .add(Duration(seconds: timeSample.toInt()));
    final String formattedTime =
        DateFormat('HH:mm:ss').format(creationTime);

    return ResultadoMuestra(
      originalImage: data['originalImage'] as Uint8List,
      processedImage: data['processedImage']as Uint8List,
      name: sample[1],
      typeSample: sample[3],
      volumenSample: sample[4],
      factorSample: sample[5],
      dateSample: sample[7],
      processingTime: sample[8],
      count: sample[9],
      medioSample: sample[11],
      formattedTime: formattedTime,
    );
  }
}
