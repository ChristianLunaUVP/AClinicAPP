import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// Importa tus modelos actualizados
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/appointment.dart';

class DatabaseService {
  static Database? _db;
  static final DatabaseService instance = DatabaseService._constructor();

  // Nombres de Tablas (sin cambios)
  static const String _doctorsTableName = "doctors";
  static const String _patientsTableName = "patients";
  static const String _appointmentsTableName = "appointments";

  // Columnas Comunes (sin cambios)
  static const String _columnId = "id";

  // --- Columnas de Doctores ---
  static const String _columnDoctorName = "name";
  static const String _columnDoctorSpecialty = "specialty";
  // Nuevas columnas para Doctores
  static const String _columnDoctorPhoneNumber = "phoneNumber";
  static const String _columnDoctorEmail = "email";
  static const String _columnDoctorOfficeHours = "officeHours";

  // --- Columnas de Pacientes ---
  static const String _columnPatientName = "name";
  static const String _columnPatientDOB = "dateOfBirth";
  static const String _columnPatientContact = "contactInfo";
  // Nuevas columnas para Pacientes
  static const String _columnPatientAddress = "address";
  static const String _columnPatientGender = "gender";
  static const String _columnPatientEmergencyContactName = "emergencyContactName";
  static const String _columnPatientEmergencyContactPhone = "emergencyContactPhone";
  static const String _columnPatientBloodType = "bloodType";
  static const String _columnPatientAllergies = "allergies";

  // --- Columnas de Citas ---
  static const String _columnAppointmentPatientId = "patientId";
  static const String _columnAppointmentDoctorId = "doctorId";
  static const String _columnAppointmentDate = "appointmentDate";
  static const String _columnAppointmentReason = "reason";
  static const String _columnAppointmentStatus = "status";
  // Nuevas columnas para Citas
  static const String _columnAppointmentType = "appointmentType";
  static const String _columnAppointmentNotes = "notes";
  static const String _columnAppointmentDurationMinutes = "durationMinutes";
  static const String _columnAppointmentIsConfirmed = "isConfirmed";


  DatabaseService._constructor();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final databaseDirPath = await getDatabasesPath();
    final databasePath = join(databaseDirPath, "clinic_master_v2_db.db"); // Cambia el nombre o maneja la versión
    
    // --- IMPORTANTE: Incrementar la versión de la base de datos ---
    const int newVersion = 2; // La versión anterior era 1

    final database = await openDatabase(
      databasePath,
      version: newVersion, // Nueva versión
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        // Lógica de migración si la versión antigua es menor que la nueva
        if (oldVersion < newVersion) {
          // Ejemplo de migración para la versión 1 a 2
          if (oldVersion == 1) {
            // Añadir columnas a la tabla de doctores
            await db.execute('ALTER TABLE $_doctorsTableName ADD COLUMN $_columnDoctorPhoneNumber TEXT');
            await db.execute('ALTER TABLE $_doctorsTableName ADD COLUMN $_columnDoctorEmail TEXT');
            await db.execute('ALTER TABLE $_doctorsTableName ADD COLUMN $_columnDoctorOfficeHours TEXT');

            // Añadir columnas a la tabla de pacientes
            await db.execute('ALTER TABLE $_patientsTableName ADD COLUMN $_columnPatientAddress TEXT');
            await db.execute('ALTER TABLE $_patientsTableName ADD COLUMN $_columnPatientGender TEXT');
            await db.execute('ALTER TABLE $_patientsTableName ADD COLUMN $_columnPatientEmergencyContactName TEXT');
            await db.execute('ALTER TABLE $_patientsTableName ADD COLUMN $_columnPatientEmergencyContactPhone TEXT');
            await db.execute('ALTER TABLE $_patientsTableName ADD COLUMN $_columnPatientBloodType TEXT');
            await db.execute('ALTER TABLE $_patientsTableName ADD COLUMN $_columnPatientAllergies TEXT');

            // Añadir columnas a la tabla de citas
            await db.execute('ALTER TABLE $_appointmentsTableName ADD COLUMN $_columnAppointmentType TEXT');
            await db.execute('ALTER TABLE $_appointmentsTableName ADD COLUMN $_columnAppointmentNotes TEXT');
            await db.execute('ALTER TABLE $_appointmentsTableName ADD COLUMN $_columnAppointmentDurationMinutes INTEGER');
            await db.execute('ALTER TABLE $_appointmentsTableName ADD COLUMN $_columnAppointmentIsConfirmed INTEGER DEFAULT 0');
            
            // Nota: Cambiar restricciones ON DELETE CASCADE a ON DELETE RESTRICT en una migración
            // es complejo y generalmente requiere recrear la tabla y copiar los datos.
            // Para simplificar, esta migración solo añade columnas. La nueva restricción
            // se aplicará si la base de datos se crea desde cero con la nueva versión.
            // Si necesitas que la restricción cambie para bases de datos existentes,
            // deberías investigar cómo recrear la tabla 'appointments' con los nuevos constraints
            // y copiar los datos antiguos.
          }
          // Puedes añadir más bloques "if (oldVersion == X)" para futuras migraciones
        }
      },
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
    return database;
  }

  Future<void> _createTables(Database db) async {
      // Crear tabla de Doctores
      await db.execute('''
        CREATE TABLE $_doctorsTableName (
          $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_columnDoctorName TEXT NOT NULL,
          $_columnDoctorSpecialty TEXT NOT NULL,
          $_columnDoctorPhoneNumber TEXT,
          $_columnDoctorEmail TEXT UNIQUE,
          $_columnDoctorOfficeHours TEXT
        )
      ''');
      // Crear tabla de Pacientes
      await db.execute('''
        CREATE TABLE $_patientsTableName (
          $_columnId INTEGER PRIMARY KEY AUTOINCREMENT,
          $_columnPatientName TEXT NOT NULL,
          $_columnPatientDOB TEXT NOT NULL,
          $_columnPatientContact TEXT NOT NULL,
          $_columnPatientAddress TEXT,
          $_columnPatientGender TEXT,
          $_columnPatientEmergencyContactName TEXT,
          $_columnPatientEmergencyContactPhone TEXT,
          $_columnPatientBloodType TEXT,
          $_columnPatientAllergies TEXT
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
          $_columnAppointmentType TEXT,
          $_columnAppointmentNotes TEXT,
          $_columnAppointmentDurationMinutes INTEGER,
          $_columnAppointmentIsConfirmed INTEGER DEFAULT 0,
          FOREIGN KEY ($_columnAppointmentPatientId) REFERENCES $_patientsTableName ($_columnId) ON DELETE RESTRICT, -- CAMBIADO
          FOREIGN KEY ($_columnAppointmentDoctorId) REFERENCES $_doctorsTableName ($_columnId) ON DELETE RESTRICT  -- CAMBIADO
        )
      ''');
  }


  // --- Métodos CRUD para Doctores ---
  Future<int> addDoctor(Doctor doctor) async {
    final db = await database;
    return await db.insert(
      _doctorsTableName,
      doctor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace, // O .ignore si el email debe ser único y quieres evitar errores si ya existe
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

  /// Elimina un doctor.
  /// Puede lanzar una [SqfliteDatabaseException] si el doctor tiene citas asociadas
  /// debido a la restricción ON DELETE RESTRICT.
  /// Debes manejar esta excepción en la UI.
  Future<int> deleteDoctor(int id) async {
    final db = await database;
    try {
      return await db.delete(
        _doctorsTableName,
        where: '$_columnId = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (e) {
      // Puedes loggear el error o simplemente relanzarlo para que la UI lo maneje.
      // Un código común para violación de FK en SQLite es 19 (SQLITE_CONSTRAINT)
      // y el mensaje suele incluir "FOREIGN KEY constraint failed".
      print("Error al eliminar doctor: $e"); // Opcional: para debugging
      rethrow; // Relanza la excepción para que sea manejada por el llamador
    }
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

  /// Elimina un paciente.
  /// Puede lanzar una [SqfliteDatabaseException] si el paciente tiene citas asociadas
  /// debido a la restricción ON DELETE RESTRICT.
  /// Debes manejar esta excepción en la UI.
  Future<int> deletePatient(int id) async {
    final db = await database;
     try {
      return await db.delete(
        _patientsTableName,
        where: '$_columnId = ?',
        whereArgs: [id],
      );
    } on DatabaseException catch (e) {
      print("Error al eliminar paciente: $e");
      rethrow;
    }
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
  
  Future<void> close() async {
    final db = await database;
    _db = null; // Para que la próxima vez se reinicialice
    await db.close();
  }
}