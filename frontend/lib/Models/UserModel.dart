class UserModel {
  int id;
  String name;
  String password;
  // String phone;
  String email;
  String role;
  String profileImage;
  UserModel(
      {required this.id,
      required this.name,
      // required this.phone,
      required this.email,
      required this.password,
      required this.role,
      required this.profileImage});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
        id: json['user_id'],
        name: json['name'],
        // phone: json['phone'],
        email: json['email'],
        password: json['password'],
        role: json['role'],
        profileImage: json['profile_image']);
  }

  Map<String, dynamic> toJson() => {
        'user_id': id,
        'name': name,
        // 'phone': phone,
        'email': email,
        'password': password,
        'role': role,
        'profile_image': profileImage
      };
}
