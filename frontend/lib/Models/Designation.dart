class DesignationModel {
  int id;
  String name;
  String user_type;
  bool remote_checkin;
  DesignationModel(
      {required this.id,
      required this.name,
      this.user_type = 'USER',
      this.remote_checkin = false});

  factory DesignationModel.fromJson(Map<String, dynamic> json) {
    return DesignationModel(
        id: int.parse(json['id'].toString()),
        name: json['name'],
        user_type: json['user_type'],
        remote_checkin: bool.parse(json['remote_checkin'].toString()));
  }

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'name': name,
        'user_type': user_type,
        'remote_checkin': remote_checkin.toString()
      };
}
