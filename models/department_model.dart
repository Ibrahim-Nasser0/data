import 'course_model.dart';
import 'student_model.dart';

class DepartmentModel {
  final String name;
  List<StudentModel> students;
  List<CourseModel> courses;

  DepartmentModel({
    required this.name,
    required this.students,
    required this.courses,
  });
}
