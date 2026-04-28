import 'package:intl/intl.dart';

class ShowRecord {
  final int id;
  final String dateSample;
  final int count;
  final int dayNumber;


  ShowRecord({
    required this.id,
    required this.dateSample,
    required this.count,
    required this.dayNumber,
  });

  factory ShowRecord.fromMap(Map<String, dynamic> data) {
    final record = data['record'];
    return ShowRecord(
      id: record[0],
      count: record[1],
      dayNumber: record[2],
      dateSample: record[3]
    );
  }
}
