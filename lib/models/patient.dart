class Patient {
  final int? id;
  final String name;
  final String dateOfBirth;
  final String contactInfo;
  final String? address;               // Nuevo
  final String? gender;                // Nuevo
  final String? emergencyContactName;  // Nuevo
  final String? emergencyContactPhone; // Nuevo
  final String? bloodType;             // Nuevo
  final String? allergies;             // Nuevo

  Patient({
    this.id,
    required this.name,
    required this.dateOfBirth,
    required this.contactInfo,
    this.address,
    this.gender,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.bloodType,
    this.allergies,
  });

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as int?,
      name: map['name'] as String,
      dateOfBirth: map['dateOfBirth'] as String,
      contactInfo: map['contactInfo'] as String,
      address: map['address'] as String?,
      gender: map['gender'] as String?,
      emergencyContactName: map['emergencyContactName'] as String?,
      emergencyContactPhone: map['emergencyContactPhone'] as String?,
      bloodType: map['bloodType'] as String?,
      allergies: map['allergies'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'contactInfo': contactInfo,
      'address': address,
      'gender': gender,
      'emergencyContactName': emergencyContactName,
      'emergencyContactPhone': emergencyContactPhone,
      'bloodType': bloodType,
      'allergies': allergies,
    };
  }
}