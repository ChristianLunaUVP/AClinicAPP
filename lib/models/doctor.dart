class Doctor {
  final int? id;
  final String name;
  final String specialty;
  final String? phoneNumber; // Nuevo
  final String? email;       // Nuevo
  final String? officeHours; // Nuevo

  Doctor({
    this.id,
    required this.name,
    required this.specialty,
    this.phoneNumber,
    this.email,
    this.officeHours,
  });

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] as int?,
      name: map['name'] as String,
      specialty: map['specialty'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      email: map['email'] as String?,
      officeHours: map['officeHours'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'phoneNumber': phoneNumber,
      'email': email,
      'officeHours': officeHours,
    };
  }
}