class Appointment {
  final int? id;
  final int patientId;
  final int doctorId;
  final String appointmentDate; // Consider using DateTime and formatting as TEXT "YYYY-MM-DD HH:MM:SS"
  final String reason;
  final String status; // e.g., "scheduled", "completed", "canceled"

  Appointment({
    this.id,
    required this.patientId,
    required this.doctorId,
    required this.appointmentDate,
    required this.reason,
    required this.status,
  });

  factory Appointment.fromMap(Map<String, dynamic> map) {
    return Appointment(
      id: map['id'] as int?,
      patientId: map['patientId'] as int,
      doctorId: map['doctorId'] as int,
      appointmentDate: map['appointmentDate'] as String,
      reason: map['reason'] as String,
      status: map['status'] as String,
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
    };
  }
}