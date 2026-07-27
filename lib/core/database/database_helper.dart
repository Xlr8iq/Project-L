import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/patient.dart';
import '../models/appointment.dart';
import '../models/tooth.dart';
import '../models/treatment_plan_item.dart';

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
        version: 4,
        onCreate: _createDB,
        onUpgrade: _upgradeDB,
      ));
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(
        path, 
        version: 4, 
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
