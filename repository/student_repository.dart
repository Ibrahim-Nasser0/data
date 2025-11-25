import 'package:student_info_system/data/storage/formats/field/keyword_field.dart';
import 'package:student_info_system/data/storage/formats/record_separator.dart';

import '../storage/file_manager.dart';
import '../models/search_student_model.dart';
import '../models/student_model.dart';
import '../storage/formats/generic_record_format.dart';
import '../storage/formats/record/record_format.dart';

class StudentRepository {
  final FileManager fileManager = FileManager(basePath: 'lib/data/files');
  final GenericRecordFormat recordFormat = GenericRecordFormat(
    fieldFormats: [
      KeywordField('ID', headerName: 'id'),
      KeywordField('Name', headerName: 'name'),
      KeywordField('GPA', headerName: 'gpa'),
      KeywordField('Department', headerName: 'department'),
      KeywordField('Email', headerName: 'email'),
      KeywordField('PhoneNumber', headerName: 'phoneNumber'),
      KeywordField('Level', headerName: 'level'),
    ],
    recordSeparator: RecordSeparator('|', type: RecordSeparatorType.delimited),
  );
  final String fileName = 'students.txt';

  // ======================= HELPER METHOD =======================

  Future<void> _saveStudentsToFile(List<StudentModel> students) async {
    final records = students
        .map(
          (s) => Record([
            s.id.toString(),
            s.name,
            s.gpa.toString(),
            s.department,
            s.email,
            s.phoneNumber,
            s.level,
          ]),
        )
        .toList();

    final dataBody = recordFormat.encode(records);
    final headerNames = recordFormat.headerString();
    final metaHeader = recordFormat.header;
    final fullContent = '$headerNames\n$metaHeader\n$dataBody';

    await fileManager.write(fileName, fullContent);
  }

  // ======================= CRUD OPERATIONS =======================

  Future<List<StudentModel>> getAll() async {
    if (!fileManager.exists(fileName)) return [];

    final raw = await fileManager.read(fileName);
    if (raw.trim().isEmpty) return [];

    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.isEmpty) return [];

    // We write two header lines: a human-friendly names line and a metadata
    // line (FIELDS=...,TYPE=...,DELIMITER=...). Detect the metadata line
    // and skip it when present to avoid attempting to parse it as data.
    String dataLines;
    if (lines.length >= 2 &&
        (lines[1].startsWith('FIELDS=') || lines[1].contains('TYPE='))) {
      dataLines = lines.skip(2).join('\n');
    } else {
      dataLines = lines.skip(1).join('\n');
    }
    if (dataLines.trim().isEmpty) return [];

    try {
      final records = recordFormat.decode(dataLines);

      final students = records
          .map((r) {
            final fields = r.fields;
            if (fields.isEmpty) return null;

            final id = int.tryParse(fields[0].trim());
            if (id == null || id == 0) return null;

            final name = fields.length > 1 ? fields[1].trim() : '';
            if (name.isEmpty) return null;

            return StudentModel(
              id: id,
              name: name,
              gpa: fields.length > 2
                  ? double.tryParse(fields[2].trim()) ?? 0.0
                  : 0.0,
              department: fields.length > 3 ? fields[3].trim() : '',
              email: fields.length > 4 ? fields[4].trim() : '',
              phoneNumber: fields.length > 5 ? fields[5].trim() : '',
              level: fields.length > 6 ? fields[6].trim() : 'one',
            );
          })
          .whereType<StudentModel>()
          .toList();

      return students;
    } catch (e) {
      print("Error parsing file: $e");
      return [];
    }
  }

  Future<void> add(StudentModel student) async {
    List<StudentModel> students = await getAll();
    students.add(student);

    await _saveStudentsToFile(students);
  }

  Future<bool> update(StudentModel updated) async {
    final existing = await getAll();
    final index = existing.indexWhere((s) => s.id == updated.id);

    if (index == -1) return false; // الطالب غير موجود

    existing[index] = updated;

    // ✅ إصلاح: الكتابة مرة واحدة فقط مع الهيدر
    await _saveStudentsToFile(existing);
    return true;
  }

  Future<bool> delete(int id) async {
    final existing = await getAll();
    final before = existing.length;

    existing.removeWhere((s) => s.id == id);

    if (existing.length == before) return false; // لم يتم حذف شيء

    // ✅ إصلاح: الكتابة الآن تشمل الهيدر بفضل الدالة المساعدة
    await _saveStudentsToFile(existing);
    return true;
  }

  Future<void> deleteAll() async {
    final headerNames = recordFormat.headerString();
    final metaHeader = recordFormat.header;
    await fileManager.write(fileName, '$headerNames\n$metaHeader');
  }

  // ======================= SEARCH METHODS =======================

  Future<SearchStudentModel?> searchByID(int id) async {
    final sw = Stopwatch()..start();
    final existing = await getAll();

    try {
      // ✅ إصلاح: استخدام firstWhere يسبب كراش إذا لم يجد العنصر
      final student = existing.firstWhere((s) => s.id == id);
      sw.stop();
      return SearchStudentModel(
        student: student,
        timeInMicroseconds: sw.elapsedMicroseconds,
      );
    } catch (e) {
      sw.stop();
      return null; // لم يتم العثور عليه
    }
  }

  Future<SearchStudentModel?> searchByName(String name) async {
    final sw = Stopwatch()..start();
    final existing = await getAll();

    try {
      final student = existing.firstWhere(
        (s) => s.name.toLowerCase() == name.toLowerCase(),
      );
      sw.stop();
      return SearchStudentModel(
        student: student,
        timeInMicroseconds: sw.elapsedMicroseconds,
      );
    } catch (e) {
      sw.stop();
      return null;
    }
  }

  Future<List<SearchStudentModel>> searchByDepartment(String department) async {
    final sw = Stopwatch()..start();
    final existing = await getAll();

    final results = existing
        .where((s) => s.department.toLowerCase() == department.toLowerCase())
        .map(
          (s) => SearchStudentModel(
            student: s,
            timeInMicroseconds: sw.elapsedMicroseconds,
          ),
        )
        .toList();

    sw.stop();
    return results;
  }

  Future<List<SearchStudentModel>> searchByGPARange(
    double minGPA,
    double maxGPA,
  ) async {
    final sw = Stopwatch()..start();
    final existing = await getAll();

    final results = existing
        .where((s) => s.gpa >= minGPA && s.gpa <= maxGPA)
        .map(
          (s) => SearchStudentModel(
            student: s,
            timeInMicroseconds: sw.elapsedMicroseconds,
          ),
        )
        .toList();

    sw.stop();
    return results;
  }
}
