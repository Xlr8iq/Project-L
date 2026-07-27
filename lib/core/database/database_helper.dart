import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../models/tooth.dart';
import '../models/treatment_plan_item.dart';
import '../models/doctor.dart';
import '../models/secretary.dart';
import '../models/procedure_setting.dart';

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
      return await openDatabase(
        inMemoryDatabasePath,
        version: 7,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(
        path, 
        version: 7, 
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
      if (oldVersion < 7) {
        try {
          await db.execute("ALTER TABLE appointments ADD COLUMN appointment_type TEXT DEFAULT 'Consultation'");
          await db.execute("ALTER TABLE appointments ADD COLUMN doctor_name TEXT DEFAULT ''");
          await db.execute("ALTER TABLE appointments ADD COLUMN consultation_fee REAL DEFAULT 0");
          await db.execute("ALTER TABLE appointments ADD COLUMN paid_amount REAL DEFAULT 0");
        } catch (e) {
          debugPrint("Database Upgrade V7 Warning: $e");
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
  appointment_type TEXT DEFAULT 'Consultation',
  doctor_name TEXT DEFAULT '',
  consultation_fee REAL DEFAULT 0,
  paid_amount REAL DEFAULT 0,
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
        {'name': 'د. أبو الحسن', 'specialty': 'طب وجراحة الأسنان', 'phone': '+964 770 123 4567', 'email': 'abualhassan@lumina.clinic', 'color_hex': '#1565C0', 'created_at': now},
        {'name': 'د. أحمد الموسوي', 'specialty': 'حشوات وعلاج عصب', 'phone': '+964 780 987 6543', 'email': 'ahmed@lumina.clinic', 'color_hex': '#00897B', 'created_at': now},
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
        {'name': 'Implant', 'default_fee': 800.0, 'currency': 'USD', 'default_visits': 4, 'is_active': 1},
        {'name': 'Veneer', 'default_fee': 300.0, 'currency': 'USD', 'default_visits': 2, 'is_active': 1},
        {'name': 'Scaling & Polishing', 'default_fee': 40.0, 'currency': 'USD', 'default_visits': 1, 'is_active': 1},
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
        'name': 'الاستقبال',
        'phone': '+964 770 000 1111',
        'username': 'secretary',
        'password': '123',
        'is_active': 1,
        'created_at': now,
      });
    }
  }

  // --- Doctors CRUD ---
  Future<List<Doctor>> readAllDoctors() async {
    final db = await instance.database;
    final maps = await db.query('doctors', orderBy: 'id ASC');
    return maps.map((json) => Doctor.fromMap(json)).toList();
  }

  Future<Doctor> createDoctor(Doctor doctor) async {
    final db = await instance.database;
    final id = await db.insert('doctors', doctor.toMap());
    return doctor.copyWith(id: id);
  }

  Future<int> updateDoctor(Doctor doctor) async {
    final db = await instance.database;
    return await db.update('doctors', doctor.toMap(), where: 'id = ?', whereArgs: [doctor.id]);
  }

  Future<int> deleteDoctor(int id) async {
    final db = await instance.database;
    return await db.delete('doctors', where: 'id = ?', whereArgs: [id]);
  }

  // --- Procedures Settings CRUD ---
  Future<List<ProcedureSetting>> readAllProcedureSettings() async {
    final db = await instance.database;
    final maps = await db.query('procedure_settings', orderBy: 'id ASC');
    return maps.map((json) => ProcedureSetting.fromMap(json)).toList();
  }

  Future<ProcedureSetting> createProcedureSetting(ProcedureSetting proc) async {
    final db = await instance.database;
    final id = await db.insert('procedure_settings', proc.toMap());
    return proc.copyWith(id: id);
  }

  Future<int> updateProcedureSetting(ProcedureSetting proc) async {
    final db = await instance.database;
    return await db.update('procedure_settings', proc.toMap(), where: 'id = ?', whereArgs: [proc.id]);
  }

  Future<int> deleteProcedureSetting(int id) async {
    final db = await instance.database;
    return await db.delete('procedure_settings', where: 'id = ?', whereArgs: [id]);
  }

  // --- Secretaries CRUD ---
  Future<List<Secretary>> readAllSecretaries() async {
    final db = await instance.database;
    final maps = await db.query('secretaries', orderBy: 'id ASC');
    return maps.map((json) => Secretary.fromMap(json)).toList();
  }

  Future<Secretary> createSecretary(Secretary secretary) async {
    final db = await instance.database;
    final id = await db.insert('secretaries', secretary.toMap());
    return secretary.copyWith(id: id);
  }

  Future<int> updateSecretary(Secretary secretary) async {
    final db = await instance.database;
    return await db.update('secretaries', secretary.toMap(), where: 'id = ?', whereArgs: [secretary.id]);
  }

  Future<int> deleteSecretary(int id) async {
    final db = await instance.database;
    return await db.delete('secretaries', where: 'id = ?', whereArgs: [id]);
  }

  // --- Patients CRUD ---
  Future<Patient> createPatient(Patient patient) async {
    final db = await instance.database;
    final id = await db.insert('patients', patient.toMap());
    return patient.copyWith(id: id);
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
