class UserEntity {
  UserEntity({
    required this.uuid,
    required this.name,
    required this.phoneNumber,
    required this.description,
    required this.crp,
    required this.pixKey,
    required this.paymentDetails,
    required this.role,
  });

  final String uuid;
  final String name;
  final String phoneNumber;
  final String description;
  final String crp;
  final String pixKey;
  final String paymentDetails;
  final int role;

  static const String tableName = "doctors";
  static const String uuidColumn = "_uuid";
  static const String nameColumn = "name";
  static const String phoneNumberColumn = "phone_number";
  static const String descriptionColumn = "description";
  static const String crpColumn = "crp";
  static const String pixKeyColumn = "pix_key";
  static const String paymentDetailsColumn = "payment_details";
  static const String roleColumn = "role";

  static const creationStatement = """
    CREATE TABLE $tableName (
     $uuidColumn UUID PRIMARY KEY, 
     $nameColumn TEXT, 
     $phoneNumberColumn TEXT,
     $descriptionColumn TEXT,
     $crpColumn TEXT,
     $pixKeyColumn TEXT,
     $paymentDetailsColumn TEXT,
     $roleColumn INTEGER)
""";

  UserEntity copyWith({
    String? uuid,
    String? name,
    String? phoneNumber,
    String? description,
    String? crp,
    String? pixKey,
    String? paymentDetails,
    int? role,
  }) {
    return UserEntity(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      description: description ?? this.description,
      crp: crp ?? this.crp,
      pixKey: pixKey ?? this.pixKey,
      paymentDetails: paymentDetails ?? this.paymentDetails,
      role: role ?? this.role,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      uuidColumn: uuid,
      nameColumn: name,
      phoneNumberColumn: phoneNumber,
      descriptionColumn: description,
      crpColumn: crp,
      pixKeyColumn: pixKey,
      paymentDetailsColumn: paymentDetails,
      roleColumn: role,
    };
  }

  factory UserEntity.fromMap(Map<String, dynamic> map) {
    return UserEntity(
      uuid: map[uuidColumn] as String,
      name: map[nameColumn] as String,
      phoneNumber: map[phoneNumberColumn] as String,
      description: map[descriptionColumn] as String,
      crp: map[crpColumn] as String,
      pixKey: map[pixKeyColumn] as String,
      paymentDetails: map[paymentDetailsColumn] as String,
      role: map[roleColumn] as int,
    );
  }

  @override
  String toString() {
    return 'UserEntity(uuid: $uuid, name: $name, phoneNumber: $phoneNumber, description: $description, crp: $crp, pixKey: $pixKey, paymentDetails: $paymentDetails, role: $role)';
  }

  @override
  bool operator ==(covariant UserEntity other) {
    if (identical(this, other)) return true;

    return other.uuid == uuid &&
        other.name == name &&
        other.phoneNumber == phoneNumber &&
        other.description == description &&
        other.crp == crp &&
        other.pixKey == pixKey &&
        other.paymentDetails == paymentDetails &&
        other.role == role;
  }

  @override
  int get hashCode {
    return uuid.hashCode ^
        name.hashCode ^
        phoneNumber.hashCode ^
        description.hashCode ^
        crp.hashCode ^
        pixKey.hashCode ^
        paymentDetails.hashCode ^
        role.hashCode;
  }
}
