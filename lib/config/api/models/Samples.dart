class Sample {
  final int id;
  final String name;
  final int category;
  final String type;
  final String volume;
  final String sampleVolume;
  final String image;
  final String date;
  final double result;

  Sample({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.volume,
    required this.sampleVolume,
    required this.image,
    required this.date,
    required this.result,
  });

  // Método para crear un Sample a partir de la sublista
  factory Sample.fromJsonList(List<dynamic> json) {
    return Sample(
      id: json[0],
      name: json[1],
      category: json[2],
      type: json[3],
      volume: json[4],
      sampleVolume: json[5],
      image: json[6],
      date: json[7],
      result: json[8],
    );
  }
}
