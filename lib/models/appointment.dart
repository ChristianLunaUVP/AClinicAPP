class Appointment {
  final int? id;
  final int patientId;
  final int doctorId;
  final String appointmentDate;
  final String reason;
  final String status;
  final String? appointmentType; // Nuevo
  final String? notes;           // Nuevo
  final int? durationMinutes;   // Nuevo
  final bool? isConfirmed;       // Nuevo (se guardará como INTEGER 0 o 1)

  Appointment({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.reason,
    required this.status,
    this.appointmentType,
    this.notes,
    this.durationMinutes,
    this.isConfirmed,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      patientId: map['patientId'] as int,
      doctorId: map['doctorId'] as int,
      appointmentDate: map['appointmentDate'] as String,
      reason: map['reason'] as String,
      status: map['status'] as String,
      appointmentType: map['appointmentType'] as String?,
      notes: map['notes'] as String?,
      durationMinutes: map['durationMinutes'] as int?,
      isConfirmed: map['isConfirmed'] == null ? null : (map['isConfirmed'] as int == 1), // Convertir INTEGER a bool
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'patientId': patientId,
      'doctorId': doctorId,
      'appointmentDate': appointmentDate,
      'reason': reason,
      'status': status,
      'appointmentType': appointmentType,
      'notes': notes,
      'durationMinutes': durationMinutes,
      'isConfirmed': isConfirmed == null ? null : (isConfirmed! ? 1 : 0), // Convertir bool a INTEGER
    };
  }
}