class PortModel {
  int id;
  String name;
  String location;

  PortModel({required this.id, required this.name, required this.location});

  factory PortModel.fromJson(Map<String, dynamic> json) {
    return PortModel(
      id: json['id'],
      name: json['name'],
      location: json['location'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'id': id.toString(), 'name': name, 'location': location};
}
