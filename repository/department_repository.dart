import '../models/student_model.dart';
import '../models/course_model.dart';
import 'student_repository.dart';
import 'course_repository.dart';

class DepartmentRepository {
  final StudentRepository studentRepository;
  final CourseRepository courseRepository;

  DepartmentRepository({
    required this.studentRepository,
    required this.courseRepository,
  });


  Future<List<StudentModel>> getStudentsByDepartment(String departmentName,) async {
    final allStudents = await studentRepository.getAll();

    return allStudents
        .where(
          (s) => s.department.toLowerCase() == departmentName.toLowerCase(),
        )
        .toList();
  }

  
  Future<List<CourseModel>> getCoursesByDepartment(String departmentName,) async {
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

    // إضافة أقسام الطلاب
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

}
