import '../storage/file_manager.dart';
import '../models/course_model.dart';
import '../models/search_course_model.dart';
import '../storage/formats/generic_record_format.dart';
import '../storage/formats/record/record_format.dart';

class CourseRepository {
  final FileManager fileManager = FileManager();
  final GenericRecordFormat recordFormat;
  final String fileName;

  CourseRepository({
    required this.recordFormat,
    this.fileName = 'courses.txt',
  });

  // ======================= HELPER METHOD =======================

  Future<void> _saveCoursesToFile(List<CourseModel> courses) async {
    // 1. تشفير البيانات
    final dataBody = recordFormat.encode(
      courses
          .map(
            (c) => Record([
              c.code, // 👈 الحقل الأول: Code
              c.name,
              c.creditHours.toString(),
              c.enrolledStudents.toString(),
              c.instructor,
              c.department,
            ]),
          )
          .toList(),
    );

    // 2. تجميع المحتوى: الهيدر + فاصل سطر + البيانات
    final header = recordFormat.headerString();
    final fullContent = '$header\n$dataBody';

    await fileManager.write(fileName, fullContent);
  }

  // ======================= CRUD OPERATIONS =======================

  Future<List<CourseModel>> getAll() async {
    if (!fileManager.exists(fileName)) return [];

    final raw = await fileManager.read(fileName);
    if (raw.trim().isEmpty) return [];

    // فصل الهيدر عن البيانات باستخدام '\n'
    final lines = raw.split('\n').where((l) => l.trim().isNotEmpty).toList();
    if (lines.length < 2) return [];

    final dataLines = lines.skip(1).join('\n');
    if (dataLines.trim().isEmpty) return [];

    try {
      final records = recordFormat.decode(dataLines);

      final courses = records.map((r) {
        final fields = r.fields;
        // 👈 يجب أن يكون التحويل متطابقاً مع ترتيب الحقول في _saveCoursesToFile
        return CourseModel(
          code: fields.isNotEmpty ? fields[0].trim() : '',
          name: fields.length > 1 ? fields[1].trim() : '',
          creditHours: fields.length > 2
              ? int.tryParse(fields[2].trim()) ?? 0
              : 0,
          enrolledStudents: fields.length > 3
              ? int.tryParse(fields[3].trim()) ?? 0
              : 0,
          instructor: fields.length > 4 ? fields[4].trim() : '',
          department: fields.length > 5 ? fields[5].trim() : '',
        );
      });

      // تنظيف البيانات التالفة (الكود الفارغ)
      return courses
          .where((c) => c.code.isNotEmpty && c.name.isNotEmpty)
          .toList();
    } catch (e) {
      print("Error parsing course file: $e");
      return [];
    }
  }

  Future<void> add(CourseModel course) async {
    List<CourseModel> existing = await getAll();

   
    if (existing.any((c) => c.code == course.code)) {
      throw Exception("Course with code ${course.code} already exists.");
    }

    existing.add(course);
    await _saveCoursesToFile(existing);
  }

  Future<bool> update(CourseModel updated) async {
    final existing = await getAll();
    final index = existing.indexWhere(
      (c) => c.code == updated.code,
    ); // البحث بالكود

    if (index == -1) return false;

    existing[index] = updated;
    await _saveCoursesToFile(existing);
    return true;
  }

  Future<bool> delete(String code) async {
    final existing = await getAll();
    final before = existing.length;

    existing.removeWhere((c) => c.code == code);

    if (existing.length == before) return false;

    await _saveCoursesToFile(existing);
    return true;
  }

  Future<void> deleteAll() async {
    // ترك الهيدر فقط
    final header = recordFormat.headerString();
    await fileManager.write(
      fileName,
      '$header\n',
    ); // الأفضل ترك سطر جديد بعد الهيدر
  }

  // ======================= SEARCH METHODS =======================

  Future<SearchCourseModel?> searchByCode(String code) async {
    final sw = Stopwatch()..start();
    final existing = await getAll();

    try {
      final course = existing.firstWhere((c) => c.code == code);
      sw.stop();
      return SearchCourseModel(
        course: course,
        timeInMicroseconds: sw.elapsedMicroseconds,
      );
    } catch (e) {
      sw.stop();
      return null;
    }
  }


}
