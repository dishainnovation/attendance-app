class DesignationModel {
  int id;
  String name;
  DesignationModel({required this.id, required this.name});

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name};
}
