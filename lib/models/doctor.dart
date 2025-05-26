class Doctor {
  final int? id;
  final String name;
  final String specialty;

  Doctor({
    this.id,
    required this.name,
    required this.specialty,
  });

  factory Doctor.fromMap(Map<String, dynamic> map) {
    return Doctor(
      id: map['id'] as int?,
      name: map['name'] as String,
      specialty: map['specialty'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
    };
  }
}