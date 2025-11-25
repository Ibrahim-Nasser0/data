// import 'dart:io';

// import 'models/course_model.dart';
// import 'models/student_model.dart';
// import 'repository/course_repository.dart';
// import 'repository/department_repository.dart';
// import 'repository/student_repository.dart';
// import 'storage/formats/field/keyword_field.dart';
// import 'storage/formats/generic_record_format.dart';
// import 'storage/formats/record_separator.dart';

// // تأكد من ضبط المسارات حسب مشروعك


// // ------------------- 1. MOCK DATA & FORMATS (البيانات الوهمية والتنسيق) -------------------

// // تعريف تنسيق السجل للطلاب (بناءً على طلبك)
// final studentRecordFormat = GenericRecordFormat(
//   fieldFormats: [
//     KeywordField('ID', headerName: 'id'),
//     KeywordField('Name', headerName: 'name'),
//     KeywordField('GPA', headerName: 'gpa'),
//     KeywordField('Department', headerName: 'department'),
//     KeywordField('Email', headerName: 'email'),
//     KeywordField('PhoneNumber', headerName: 'phoneNumber'),
//     KeywordField('Level', headerName: 'level'),
//   ],
//   recordSeparator: RecordSeparator('|', type: RecordSeparatorType.delimited),
// );

// // يتم استخدام هذا التنسيق في Constructor لـ MockStudentRepository
// class MockStudentRepository extends StudentRepository {
//   MockStudentRepository()
//     // ✅ نمرر التنسيق المحدد الآن
//     : super(recordFormat: studentRecordFormat);

//   @override
//   Future<List<StudentModel>> getAll() async {
//     return [
//       StudentModel(
//         id: 1,
//         name: 'Ahmed Ali',
//         gpa: 3.5,
//         department: 'CS',
//         email: 'ahmed@test.com',
//         phoneNumber: '01010',
//         level: 'Four',
//       ),
//       StudentModel(
//         id: 2,
//         name: 'Sara Kamel',
//         gpa: 3.8,
//         department: 'IS',
//         email: 'sara@test.com',
//         phoneNumber: '01020',
//         level: 'Three',
//       ),
//       StudentModel(
//         id: 3,
//         name: 'Mona Sayed',
//         gpa: 2.9,
//         department: 'cs',
//         email: 'mona@test.com',
//         phoneNumber: '01030',
//         level: 'Two',
//       ),
//       StudentModel(
//         id: 4,
//         name: 'Kareem Nour',
//         gpa: 3.0,
//         department: 'IT',
//         email: 'kareem@test.com',
//         phoneNumber: '01040',
//         level: 'One',
//       ),
//       StudentModel(
//         id: 5,
//         name: 'Hassan Reda',
//         gpa: 2.5,
//         department: 'CS',
//         email: 'hassan@test.com',
//         phoneNumber: '01050',
//         level: 'Four',
//       ),
//     ];
//   }
// }

// // نفترض أن تنسيق الكورسات بسيط أيضاً، لكنه يحتاج إلى GenericRecordFormat كقيمة غير فارغة
// class MockCourseRepository extends CourseRepository {
//   MockCourseRepository()
//     // ✅ نمرر تنسيقاً وهمياً صحيحاً لتجنب خطأ null safety
//     : super(
//         recordFormat: GenericRecordFormat(
//           fieldFormats: [],
//           recordSeparator: RecordSeparator(
//             ';',
//             type: RecordSeparatorType.delimited,
//           ),
//         ),
//       );

//   @override
//   Future<List<CourseModel>> getAll() async {
//     return [
//       CourseModel(
//         code: 'CS101',
//         name: 'Intro to CS',
//         creditHours: 3,
//         enrolledStudents: 50,
//         instructor: 'Dr. A',
//         department: 'CS',
//       ),
//       CourseModel(
//         code: 'IS201',
//         name: 'Databases',
//         creditHours: 3,
//         enrolledStudents: 40,
//         instructor: 'Dr. B',
//         department: 'IS',
//       ),
//       CourseModel(
//         code: 'CS305',
//         name: 'Algorithms',
//         creditHours: 4,
//         enrolledStudents: 30,
//         instructor: 'Dr. C',
//         department: 'cs',
//       ),
//       CourseModel(
//         code: 'IT101',
//         name: 'Networking',
//         creditHours: 3,
//         enrolledStudents: 60,
//         instructor: 'Dr. D',
//         department: 'IT',
//       ),
//     ];
//   }
// }

// // ------------------- 2. MAIN TEST FUNCTION -------------------

// void main() async {
//   print('=============================================');
//   print('      STARTING DEPARTMENT REPOSITORY TEST    ');
//   print('=============================================\n');

//   // 1. تجهيز الـ Repositories الوهمية
//   final mockStudentRepo = MockStudentRepository();
//   final mockCourseRepo = MockCourseRepository();

//   // 2. حقن (Inject) البيانات الوهمية داخل DepartmentRepository
//   final deptRepo = DepartmentRepository(
//     studentRepository: mockStudentRepo,
//     courseRepository: mockCourseRepo,
//   );

//   // ---------------------------------------------------------
//   // Test 1: استخراج أسماء الأقسام (getAllDepartmentNames)
//   // ---------------------------------------------------------
//   print('🔹 Test 1: Getting All Unique Department Names...');

//   final deptNames = await deptRepo.getAllDepartmentNames();
//   print('   Result: $deptNames');

//   if (deptNames.length == 3 &&
//       deptNames.contains('CS') &&
//       deptNames.contains('IS') &&
//       deptNames.contains('IT')) {
//     print('   ✅ PASSED: Correctly identified CS, IS, IT (normalized case).');
//   } else {
//     print('   ❌ FAILED: Expected {CS, IS, IT}.');
//   }
//   print('---------------------------------------------------\n');

//   // ---------------------------------------------------------
//   // Test 4: إنشاء ملف القسم الفعلي (createDepartmentFile)
//   // ---------------------------------------------------------
//   print('🔹 Test 4: Creating Physical File for "CS"...');

//   // التأكد من وجود مجلد departments
//   final dir = Directory('departments');
//   if (!await dir.exists()) {
//     await dir.create();
//     print('   (Created "departments" directory)');
//   }

//   try {
//     // نستخدم اسم القسم الكبير 'CS'
//     await deptRepo.createDepartmentFile('CS');

//     final file = File('departments/CS.txt');
//     if (await file.exists()) {
//       print('   ✅ PASSED: File "departments/CS.txt" created successfully.');

//       print('\n   📄 File Content Preview (using | separator):');
//       print('   ---------------------------------------------');
//       print(await file.readAsString());
//       print('   ---------------------------------------------');
//     } else {
//       print('   ❌ FAILED: File was not created.');
//     }
//   } catch (e) {
//     print('   ❌ ERROR: Exception while creating file -> $e');
//   }

//   print('\n=============================================');
//   print('              TEST COMPLETED                 ');
//   print('=============================================');
// }
