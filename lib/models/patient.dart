class Patient {
  final int? id;
  final String name;
  final String dateOfBirth; // Consider using DateTime and formatting as TEXT "YYYY-MM-DD"
  final String contactInfo;

  Patient({
    this.id,
    required this.name,
    required this.dateOfBirth,
    required this.contactInfo,
  });

  factory Patient.fromMap(Map<String, dynamic> map) {
    return Patient(
      id: map['id'] as int?,
      name: map['name'] as String,
      dateOfBirth: map['dateOfBirth'] as String,
      contactInfo: map['contactInfo'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'dateOfBirth': dateOfBirth,
      'contactInfo': contactInfo,
    };
  }
}