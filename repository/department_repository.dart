import '../models/student_model.dart';
import '../models/course_model.dart';
import 'student_repository.dart';
import 'course_repository.dart';
import '../storage/file_manager.dart';
import '../storage/formats/generic_record_format.dart';
import '../storage/formats/field/keyword_field.dart';
import '../storage/formats/record_separator.dart';
import '../storage/formats/record/record_format.dart';

class DepartmentRepository {
  final StudentRepository studentRepository;
  final CourseRepository courseRepository;
  final FileManager fileManager = FileManager();

  late final GenericRecordFormat recordFormat;

  DepartmentRepository({
    required this.studentRepository,
    required this.courseRepository,
  }) {
    recordFormat = GenericRecordFormat(
      fieldFormats: [
        KeywordField('Name', headerName: 'Name;'),
        KeywordField('Students', headerName: 'Students;'),
        KeywordField('Courses', headerName: 'Courses;'),
      ],
      recordSeparator: RecordSeparator(
        '|',
        type: RecordSeparatorType.delimited,
      ),
    );
  }

  Future<List<StudentModel>> getStudentsByDepartment(
    String departmentName,
  ) async {
    final allStudents = await studentRepository.getAll();

    return allStudents
        .where(
          (s) => s.department.toLowerCase() == departmentName.toLowerCase(),
        )
        .toList();
  }

  Future<List<CourseModel>> getCoursesByDepartment(
    String departmentName,
  ) async {
    final allCourses = await courseRepository.getAll();

    return allCourses
        .where(
          (c) => c.department.toLowerCase() == departmentName.toLowerCase(),
        )
        .toList();
  }

  Future<Set<String>> getAllDepartmentNames() async {
    final students = await studentRepository.getAll();
    final courses = await courseRepository.getAll();

    final departmentNames = <String>{};

   
    for (var s in students) {
      if (s.department.isNotEmpty) departmentNames.add(s.department);
    }

    // إضافة أقسام الكورسات
    for (var c in courses) {
      if (c.department.isNotEmpty) departmentNames.add(c.department);
    }

    // إزالة أي فراغات وإرجاع مجموعة فريدة
    return departmentNames.where((d) => d.trim().isNotEmpty).toSet();
  }

  Future<void> createDepartmentFile(String departmentName) async {
    final students = await getStudentsByDepartment(departmentName);
    final courses = await getCoursesByDepartment(departmentName);

    final studentsIds = students.map((s) => s.id.toString()).join(',');
    final coursesCodes = courses.map((c) => c.code).join(',');

    final dataBody = recordFormat.encode([
      Record([departmentName, studentsIds, coursesCodes]),
    ]);

    final header = recordFormat.headerString();
    final fullContent = '$header\n$dataBody';

    final fileName = 'departments/$departmentName.txt';
    await fileManager.write(fileName, fullContent);
  }
}
