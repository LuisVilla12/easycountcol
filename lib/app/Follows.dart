class Follows {
  final int id;
  final String nameFollow;
  final int idUser;
  final String description;
  final String creationDate;
  final int state;  
  final double creationTime;

  Follows(
      {required this.id,
      required this.nameFollow,
      required this.idUser,
      required this.description,
      required this.creationDate,
      required this.state,
      required this.creationTime});

  factory Follows.fromJsonList(List<dynamic> json) {
    return Follows(
      id: json[0],
      nameFollow: json[1],
      idUser: json[2],
      description: json[3],
      creationDate: json[4],
      state: json[5],
      creationTime: json[6],
    );
  }
}