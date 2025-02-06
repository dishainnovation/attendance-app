class Employeemodel {
  int id;
  String userId;
  String name;
  String password;
  String phone;
  String email;
  String role;
  String profileImage;
  Employeemodel(
      {required this.id,
      required this.userId,
      required this.name,
      required this.phone,
      required this.email,
      required this.password,
      required this.role,
      required this.profileImage});

  factory Employeemodel.fromJson(Map<String, dynamic> json) {
    return Employeemodel(
        id: json['id'],
        userId: json['user_id'],
        name: json['name'],
        phone: json['phone'],
        email: json['email'],
        password: json['password'],
        role: json['role'],
        profileImage: json['profile_image']);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'name': name,
        'phone': phone,
        'email': email,
        'password': password,
        'role': role,
        'profile_image': profileImage
      };
}
