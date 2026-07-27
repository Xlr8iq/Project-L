import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../models/tooth.dart';
import '../models/treatment_plan_item.dart';
import '../models/doctor.dart';
import '../models/procedure_setting.dart';
import '../models/secretary.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('dental_clinic.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      var factory = databaseFactoryFfiWeb;
      return await factory.openDatabase(filePath, options: OpenDatabaseOptions(
        version: 6,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ));
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(
        path, 
        version: 6, 
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    }
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('DROP TABLE IF EXISTS appointments');
      await db.execute('DROP TABLE IF EXISTS teeth_chart');
      await db.execute('DROP TABLE IF EXISTS patients');
      await _createDB(db, newVersion);
    } else {
      if (oldVersion < 3) {
        try {
          await db.execute('ALTER TABLE patients ADD COLUMN phone TEXT');
          await db.execute('ALTER TABLE patients ADD COLUMN address TEXT');
          await db.execute('ALTER TABLE patients ADD COLUMN emergency_contact TEXT');
          await db.execute('ALTER TABLE patients ADD COLUMN emergency_phone TEXT');
          await db.execute('ALTER TABLE patients ADD COLUMN date_of_birth TEXT');
        } catch (e) {
          debugPrint("Database Upgrade V3 Warning: $e");
        }
      }
      if (oldVersion < 4) {
        try {
          await db.execute('''
CREATE TABLE IF NOT EXISTS treatment_plans (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  patient_id INTEGER NOT NULL,
  tooth_number INTEGER NOT NULL,
  procedure_type TEXT NOT NULL,
  status TEXT NOT NULL,
  current_visit INTEGER DEFAULT 1,
  total_visits INTEGER DEFAULT 1,
  next_visit_date TEXT,
  doctor_name TEXT,
  estimated_fee REAL DEFAULT 0,
  paid_amount REAL DEFAULT 0,
  notes TEXT,
  created_at TEXT NOT NULL,
  completed_at TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
)
''');
        } catch (e) {
          debugPrint("Database Upgrade V4 Warning: $e");
        }
      }
      if (oldVersion < 5) {
        try {
          await db.execute('''
CREATE TABLE IF NOT EXISTS doctors (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  specialty TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  color_hex TEXT,
  created_at TEXT NOT NULL
)
''');
          await _seedDefaultDoctors(db);
        } catch (e) {
          debugPrint("Database Upgrade V5 Warning: $e");
        }
      }
      if (oldVersion < 6) {
        try {
          await db.execute('''
CREATE TABLE IF NOT EXISTS procedure_settings (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  default_fee REAL NOT NULL,
  currency TEXT NOT NULL,
  default_visits INTEGER DEFAULT 1,
  is_active INTEGER DEFAULT 1
)
''');
          await db.execute('''
CREATE TABLE IF NOT EXISTS secretaries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  phone TEXT,
  username TEXT NOT NULL,
  password TEXT NOT NULL,
  is_active INTEGER DEFAULT 1,
  created_at TEXT NOT NULL
)
''');
          await _seedDefaultProcedures(db);
          await _seedDefaultSecretaries(db);
        } catch (e) {
          debugPrint("Database Upgrade V6 Warning: $e");
        }
      }
    }
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE patients (
  id $idType,
  name $textType,
  age $integerType,
  gender $textType,
  created_at $textType,
  phone TEXT,
  address TEXT,
  emergency_contact TEXT,
  emergency_phone TEXT,
  date_of_birth TEXT
)
''');

    await db.execute('''
CREATE TABLE appointments (
  id $idType,
  patient_id $integerType,
  date_time $textType,
  status $textType,
  notes TEXT,
  work_performed TEXT,
  outcomes TEXT,
  medications TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE teeth_chart (
  id $idType,
  patient_id $integerType,
  tooth_number $integerType,
  procedure_type $textType,
  FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE,
  UNIQUE(patient_id, tooth_number)
)
''');

    await db.execute('''
CREATE TABLE treatment_plans (
  id $idType,
  patient_id $integerType,
  tooth_number $integerType,
  procedure_type $textType,
  status $textType,
  current_visit INTEGER DEFAULT 1,
  total_visits INTEGER DEFAULT 1,
  next_visit_date TEXT,
  doctor_name TEXT,
  estimated_fee REAL DEFAULT 0,
  paid_amount REAL DEFAULT 0,
  notes TEXT,
  created_at $textType,
  completed_at TEXT,
  FOREIGN KEY (patient_id) REFERENCES patients (id) ON DELETE CASCADE
)
''');

    await db.execute('''
CREATE TABLE doctors (
  id $idType,
  name $textType,
  specialty $textType,
  phone TEXT,
  email TEXT,
  color_hex TEXT,
  created_at $textType
)
''');

    await db.execute('''
CREATE TABLE procedure_settings (
  id $idType,
  name $textType,
  default_fee REAL NOT NULL,
  currency $textType,
  default_visits INTEGER DEFAULT 1,
  is_active INTEGER DEFAULT 1
)
''');

    await db.execute('''
CREATE TABLE secretaries (
  id $idType,
  name $textType,
  phone TEXT,
  username $textType,
  password $textType,
  is_active INTEGER DEFAULT 1,
  created_at $textType
)
''');

    await _seedDefaultDoctors(db);
    await _seedDefaultProcedures(db);
    await _seedDefaultSecretaries(db);
  }

  Future<void> _seedDefaultDoctors(Database db) async {
    final countResult = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM doctors'));
    if (countResult == 0) {
      final now = DateTime.now().toIso8601String();
      final defaultDoctors = [
        {'name': 'Dr. Ahmed Al-Mousawi', 'specialty': 'Endodontics & Restorative', 'phone': '+964 770 123 4567', 'email': 'ahmed@lumina.clinic', 'color_hex': '#1565C0', 'created_at': now},
        {'name': 'Dr. Michael Chen', 'specialty': 'Orthodontics & General', 'phone': '+1 (555) 345-6789', 'email': 'michael.chen@lumina.clinic', 'color_hex': '#00897B', 'created_at': now},
        {'name': 'Dr. Emily Taylor', 'specialty': 'Prosthodontics & Cosmetic', 'phone': '+1 (555) 456-7890', 'email': 'emily.taylor@lumina.clinic', 'color_hex': '#7B1FA2', 'created_at': now},
        {'name': 'Dr. Alex Smith', 'specialty': 'Oral Surgery & Implants', 'phone': '+1 (555) 567-8901', 'email': 'alex.smith@lumina.clinic', 'color_hex': '#E65100', 'created_at': now},
      ];

      for (var d in defaultDoctors) {
        await db.insert('doctors', d);
      }
    }
  }

  Future<void> _seedDefaultProcedures(Database db) async {
    final countResult = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM procedure_settings'));
    if (countResult == 0) {
      final defaultProcedures = [
        {'name': 'Composite Restoration', 'default_fee': 50.0, 'currency': 'USD', 'default_visits': 1, 'is_active': 1},
        {'name': 'Root Canal (RCT)', 'default_fee': 180.0, 'currency': 'USD', 'default_visits': 3, 'is_active': 1},
        {'name': 'Extraction', 'default_fee': 70.0, 'currency': 'USD', 'default_visits': 1, 'is_active': 1},
        {'name': 'Crown', 'default_fee': 250.0, 'currency': 'USD', 'default_visits': 2, 'is_active': 1},
        {'name': 'Bridge', 'default_fee': 350.0, 'currency': 'USD', 'default_visits': 2, 'is_active': 1},
        {'name': 'Scaling & Polishing', 'default_fee': 40.0, 'currency': 'USD', 'default_visits': 1, 'is_active': 1},
        {'name': 'Implant', 'default_fee': 400.0, 'currency': 'USD', 'default_visits': 3, 'is_active': 1},
        {'name': 'Veneer', 'default_fee': 200.0, 'currency': 'USD', 'default_visits': 2, 'is_active': 1},
      ];

      for (var p in defaultProcedures) {
        await db.insert('procedure_settings', p);
      }
    }
  }

  Future<void> _seedDefaultSecretaries(Database db) async {
    final countResult = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM secretaries'));
    if (countResult == 0) {
      final now = DateTime.now().toIso8601String();
      await db.insert('secretaries', {
        'name': 'Hadeel Kareem',
        'phone': '+1 (555) 987-6543',
        'username': 'secretary1',
        'password': '123',
        'is_active': 1,
        'created_at': now,
      });
    }
  }

  // --- Doctors ---
  Future<Doctor> createDoctor(Doctor doctor) async {
    final db = await instance.database;
    final id = await db.insert('doctors', doctor.toMap());
    return doctor.copyWith(id: id);
  }

  Future<List<Doctor>> readAllDoctors() async {
    final db = await instance.database;
    const orderBy = 'name ASC';
    final result = await db.query('doctors', orderBy: orderBy);
    return result.map((json) => Doctor.fromMap(json)).toList();
  }

  Future<int> updateDoctor(Doctor doctor) async {
    final db = await instance.database;
    return db.update(
      'doctors',
      doctor.toMap(),
      where: 'id = ?',
      whereArgs: [doctor.id],
    );
  }

  Future<int> deleteDoctor(int id) async {
    final db = await instance.database;
    return db.delete('doctors', where: 'id = ?', whereArgs: [id]);
  }

  // --- Procedure Settings ---
  Future<ProcedureSetting> createProcedureSetting(ProcedureSetting proc) async {
    final db = await instance.database;
    final id = await db.insert('procedure_settings', proc.toMap());
    return proc.copyWith(id: id);
  }

  Future<List<ProcedureSetting>> readAllProcedureSettings() async {
    final db = await instance.database;
    const orderBy = 'name ASC';
    final result = await db.query('procedure_settings', orderBy: orderBy);
    return result.map((json) => ProcedureSetting.fromMap(json)).toList();
  }

  Future<int> updateProcedureSetting(ProcedureSetting proc) async {
    final db = await instance.database;
    return db.update(
      'procedure_settings',
      proc.toMap(),
      where: 'id = ?',
      whereArgs: [proc.id],
    );
  }

  Future<int> deleteProcedureSetting(int id) async {
    final db = await instance.database;
    return db.delete('procedure_settings', where: 'id = ?', whereArgs: [id]);
  }

  // --- Secretaries ---
  Future<Secretary> createSecretary(Secretary sec) async {
    final db = await instance.database;
    final id = await db.insert('secretaries', sec.toMap());
    return sec.copyWith(id: id);
  }

  Future<List<Secretary>> readAllSecretaries() async {
    final db = await instance.database;
    const orderBy = 'name ASC';
    final result = await db.query('secretaries', orderBy: orderBy);
    return result.map((json) => Secretary.fromMap(json)).toList();
  }

  Future<int> updateSecretary(Secretary sec) async {
    final db = await instance.database;
    return db.update(
      'secretaries',
      sec.toMap(),
      where: 'id = ?',
      whereArgs: [sec.id],
    );
  }

  Future<int> deleteSecretary(int id) async {
    final db = await instance.database;
    return db.delete('secretaries', where: 'id = ?', whereArgs: [id]);
  }

  // --- Patients ---
  Future<Patient> createPatient(Patient patient) async {
    final db = await instance.database;
    final id = await db.insert('patients', patient.toMap());
    return Patient(
      id: id,
      name: patient.name,
      age: patient.age,
      gender: patient.gender,
      createdAt: patient.createdAt,
      phone: patient.phone,
      address: patient.address,
      emergencyContact: patient.emergencyContact,
      emergencyPhone: patient.emergencyPhone,
      dateOfBirth: patient.dateOfBirth,
    );
  }

  Future<int> updatePatient(Patient patient) async {
    final db = await instance.database;
    return db.update(
      'patients',
      patient.toMap(),
      where: 'id = ?',
      whereArgs: [patient.id],
    );
  }

  Future<List<Patient>> readAllPatients() async {
    final db = await instance.database;
    const orderBy = 'name ASC';
    final result = await db.query('patients', orderBy: orderBy);
    return result.map((json) => Patient.fromMap(json)).toList();
  }

  Future<Patient?> getPatient(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'patients',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Patient.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // --- Treatment Plans ---
  Future<TreatmentPlanItem> createTreatmentPlanItem(TreatmentPlanItem item) async {
    final db = await instance.database;
    final id = await db.insert('treatment_plans', item.toMap());
    return item.copyWith(id: id);
  }

  Future<List<TreatmentPlanItem>> getTreatmentPlanForPatient(int patientId) async {
    final db = await instance.database;
    final maps = await db.query(
      'treatment_plans',
      where: 'patient_id = ?',
      whereArgs: [patientId],
      orderBy: 'created_at ASC',
    );
    return maps.map((json) => TreatmentPlanItem.fromMap(json)).toList();
  }

  Future<int> updateTreatmentPlanItem(TreatmentPlanItem item) async {
    final db = await instance.database;
    return db.update(
      'treatment_plans',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
  }

  Future<int> deleteTreatmentPlanItem(int id) async {
    final db = await instance.database;
    return db.delete(
      'treatment_plans',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // --- Appointments ---
  Future<Appointment> createAppointment(Appointment appointment) async {
    final db = await instance.database;
    final id = await db.insert('appointments', appointment.toMap());
    return appointment.copyWith(id: id);
  }

  Future<int> updateAppointment(Appointment appointment) async {
    final db = await instance.database;
    return db.update(
      'appointments',
      appointment.toMap(),
      where: 'id = ?',
      whereArgs: [appointment.id],
    );
  }

  Future<List<Appointment>> readAllAppointments() async {
    final db = await instance.database;
    const orderBy = 'date_time ASC';
    final result = await db.query('appointments', orderBy: orderBy);
    return result.map((json) => Appointment.fromMap(json)).toList();
  }

  // --- Teeth Charting ---
  Future<void> saveToothProcedure(int patientId, Tooth tooth) async {
    final db = await instance.database;
    await db.insert(
      'teeth_chart',
      {
        'patient_id': patientId,
        'tooth_number': tooth.number,
        'procedure_type': tooth.procedure.toString().split('.').last,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Tooth>> getTeethForPatient(int patientId) async {
    final db = await instance.database;
    final maps = await db.query(
      'teeth_chart',
      where: 'patient_id = ?',
      whereArgs: [patientId],
    );

    List<Tooth> teeth = [];
    for (var map in maps) {
      final procedureStr = map['procedure_type'] as String;
      ProcedureType type = ProcedureType.values.firstWhere(
        (e) => e.toString().split('.').last == procedureStr,
        orElse: () => ProcedureType.none,
      );
      teeth.add(Tooth(number: map['tooth_number'] as int, procedure: type));
    }
    return teeth;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
