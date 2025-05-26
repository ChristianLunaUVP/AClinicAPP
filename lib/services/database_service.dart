import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Importa tus nuevos modelos
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/appointment.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  // Nombres de Tablas
  static const String _doctorsTableName = "doctors";
  static const String _patientsTableName = "patients";
  static const String _appointmentsTableName = "appointments";

  // Columnas Comunes
  static const String _columnId = "id";

  // Columnas de Doctores
  static const String _columnDoctorName = "name";
  static const String _columnDoctorSpecialty = "specialty";

  // Columnas de Pacientes
  static const String _columnPatientName = "name";
  static const String _columnPatientDOB = "dateOfBirth";
  static const String _columnPatientContact = "contactInfo";

  // Columnas de Citas
  static const String _columnAppointmentPatientId = "patientId";
  static const String _columnAppointmentDoctorId = "doctorId";
  static const String _columnAppointmentDate = "appointmentDate";
  static const String _columnAppointmentReason = "reason";
  static const String _columnAppointmentStatus = "status";

  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "clinic_master_db.db");
    final database = await openDatabase(
      databasePath,
      version: 1,
      onCreate: (db, version) async {
        // Crear tabla de Doctores
        await db.execute('''
          CREATE TABLE $_doctorsTableName (
            $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_columnDoctorName TEXT NOT NULL,
            $_columnDoctorSpecialty TEXT NOT NULL
          )
        ''');
        // Crear tabla de Pacientes
        await db.execute('''
          CREATE TABLE $_patientsTableName (
            $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_columnPatientName TEXT NOT NULL,
            $_columnPatientDOB TEXT NOT NULL,
            $_columnPatientContact TEXT NOT NULL
          )
        ''');
        // Crear tabla de Citas
        await db.execute('''
          CREATE TABLE $_appointmentsTableName (
            $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $_columnAppointmentPatientId INTEGER NOT NULL,
            $_columnAppointmentDoctorId INTEGER NOT NULL,
            $_columnAppointmentDate TEXT NOT NULL,
            $_columnAppointmentReason TEXT,
            $_columnAppointmentStatus TEXT NOT NULL,
            FOREIGN KEY ($_columnAppointmentPatientId) REFERENCES $_patientsTableName ($_columnId) ON DELETE CASCADE,
            FOREIGN KEY ($_columnAppointmentDoctorId) REFERENCES $_doctorsTableName ($_columnId) ON DELETE CASCADE
          )
        ''');
      },
      // Habilitar foreign keys
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
    return database;
  }

  // --- Métodos CRUD para Doctores ---
  Future<int> addDoctor(Doctor doctor) async {
    final db = await database;
    return await db.insert(
      _doctorsTableName,
      doctor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Doctor>> getDoctors() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_doctorsTableName);
    return List.generate(maps.length, (i) {
      return Doctor.fromMap(maps[i]);
    });
  }

  Future<int> updateDoctor(Doctor doctor) async {
    final db = await database;
    return await db.update(
      _doctorsTableName,
      doctor.toMap(),
      where: '$_columnId = ?',
      whereArgs: [doctor.id],
    );
  }

  Future<int> deleteDoctor(int id) async {
    final db = await database;
    return await db.delete(
      _doctorsTableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }

  // --- Métodos CRUD para Pacientes ---
  Future<int> addPatient(Patient patient) async {
    final db = await database;
    return await db.insert(
      _patientsTableName,
      patient.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Patient>> getPatients() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_patientsTableName);
    return List.generate(maps.length, (i) {
      return Patient.fromMap(maps[i]);
    });
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await database;
    return await db.update(
      _patientsTableName,
      patient.toMap(),
      where: '$_columnId = ?',
      whereArgs: [patient.id],
    );
  }

  Future<int> deletePatient(int id) async {
    final db = await database;
    return await db.delete(
      _patientsTableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }

  // --- Métodos CRUD para Citas ---
  Future<int> addAppointment(Appointment appointment) async {
    final db = await database;
    return await db.insert(
      _appointmentsTableName,
      appointment.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Appointment>> getAppointments() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(_appointmentsTableName);
    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }

  // Puedes añadir métodos más específicos, por ejemplo, obtener citas por doctor o paciente
  Future<List<Appointment>> getAppointmentsByPatient(int patientId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _appointmentsTableName,
      where: '$_columnAppointmentPatientId = ?',
      whereArgs: [patientId],
    );
    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }

  Future<List<Appointment>> getAppointmentsByDoctor(int doctorId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      _appointmentsTableName,
      where: '$_columnAppointmentDoctorId = ?',
      whereArgs: [doctorId],
    );
    return List.generate(maps.length, (i) {
      return Appointment.fromMap(maps[i]);
    });
  }


  Future<int> updateAppointment(Appointment appointment) async {
    final db = await database;
    return await db.update(
      _appointmentsTableName,
      appointment.toMap(),
      where: '$_columnId = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<int> deleteAppointment(int id) async {
    final db = await database;
    return await db.delete(
      _appointmentsTableName,
      where: '$_columnId = ?',
      whereArgs: [id],
    );
  }
  
  // Método para cerrar la base de datos si es necesario
  Future<void> close() async {
    final db = await database;
    _db = null;
    await db.close();
  }
}