class UserModel {
  final String id;
  final String firstName;
  final String middleName;
  final String surname;
  final String idNumber;
  final String phoneNumber;
  final String email;
  final String department;
  final String county;
  final String subCounty;
  final String ward;
  final String workstation;
  final bool isAdmin;

  UserModel({
    required this.id,
    required this.firstName,
    required this.middleName,
    required this.surname,
    required this.idNumber,
    required this.phoneNumber,
    required this.email,
    required this.department,
    required this.county,
    required this.subCounty,
    required this.ward,
    required this.workstation,
    this.isAdmin = false,
  });

  factory UserModel.fromMap(Map<String, dynamic> data, String id) {
    return UserModel(
      id: id,
      firstName: data['firstName'] ?? '',
      middleName: data['middleName'] ?? '',
      surname: data['surname'] ?? '',
      idNumber: data['idNumber'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      department: data['department'] ?? '',
      county: data['county'] ?? '',
      subCounty: data['subCounty'] ?? '',
      ward: data['ward'] ?? '',
      workstation: data['workstation'] ?? '',
      isAdmin: data['isAdmin'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'surname': surname,
      'idNumber': idNumber,
      'phoneNumber': phoneNumber,
      'email': email,
      'department': department,
      'county': county,
      'subCounty': subCounty,
      'ward': ward,
      'workstation': workstation,
      'isAdmin': isAdmin,
    };
  }

  UserModel copyWith({
    String? id,
    String? firstName,
    String? middleName,
    String? surname,
    String? idNumber,
    String? phoneNumber,
    String? email,
    String? department,
    String? county,
    String? subCounty,
    String? ward,
    String? workstation,
    bool? isAdmin,
  }) {
    return UserModel(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      surname: surname ?? this.surname,
      idNumber: idNumber ?? this.idNumber,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      department: department ?? this.department,
      county: county ?? this.county,
      subCounty: subCounty ?? this.subCounty,
      ward: ward ?? this.ward,
      workstation: workstation ?? this.workstation,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}
