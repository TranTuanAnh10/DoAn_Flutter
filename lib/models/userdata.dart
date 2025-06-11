class UserData {
  final int id;
  final String name;
  final DateTime dateOfBirth;
  final String gender;
  final String phoneNumber;
  final String email;
  final String userName;

  UserData({
    required this.id,
    required this.name,
    required this.dateOfBirth,
    required this.gender,
    required this.phoneNumber,
    required this.email,
    required this.userName,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'],
      name: json['name'],
      dateOfBirth: DateTime.parse(json['dateOfBirth']),
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
      userName: json['userName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'phoneNumber': phoneNumber,
      'email': email,
      'userName': userName,
    };
  }
}
