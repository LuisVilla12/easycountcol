class Records {
  final int id;
  final int followID;
  final String imagePath;
  final int colonyCount;
  final int dayNumber;
  final double creationTime;
  final String creationDate;
  final int state;  

  Records({
      required this.id,
      required this.followID,
      required this.imagePath,
      required this.colonyCount,
      required this.dayNumber,
      required this.creationTime,
      required this.creationDate,
      required this.state
      });

  factory Records.fromJsonList(List<dynamic> json) {
    return Records(
      id: json[0],
      followID: json[1],
      imagePath: json[2],
      colonyCount: json[3],
      dayNumber: json[4],
      creationTime: json[5],
      creationDate: json[6],
      state: json[7],
    );
  }
}