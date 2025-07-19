class Sample {
  final int id;
  final String sampleName;
  final int idUser;
  final String typeSample;
  final String volumenSample;
  final String factorSample;
  final String sampleRoute;
  final String creationDate;
  final double processingTime;
  final int count;
  final double creationTime;

  Sample(
      {required this.id,
      required this.sampleName,
      required this.idUser,
      required this.typeSample,
      required this.volumenSample,
      required this.factorSample,
      required this.sampleRoute,
      required this.creationDate,
      required this.processingTime,
      required this.count,
      required this.creationTime});

  // Método para crear un Sample a partir de la sublista
  factory Sample.fromJsonList(List<dynamic> json) {
    return Sample(
      id: json[0],
      sampleName: json[1],
      idUser: json[2],
      typeSample: json[3],
      volumenSample: json[4],
      factorSample: json[5],
      sampleRoute: json[6],
      creationDate: json[7],
      processingTime: json[8],
      count: json[9],
      creationTime: json[10],
    );
  }
}
