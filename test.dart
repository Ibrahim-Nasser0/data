import 'dart:io';
import 'dart:math';
import 'models/course_model.dart';
import 'repository/course_repository.dart';
import 'repository/department_repository.dart';
import 'repository/student_repository.dart';
import 'models/student_model.dart';
import 'storage/formats/field/keyword_field.dart';
import 'storage/formats/field/length_indicator_field.dart';
import 'storage/formats/field/fixed_length_field.dart';
import 'storage/formats/field/delimited_field.dart';
import 'storage/formats/generic_record_format.dart';
import 'storage/formats/record_separator.dart';

void main() async {
  testStudent();
}

void testStudent() async {
  final fieldFormats = [
    KeywordField('ID', headerName: 'id'),
    KeywordField('Name', headerName: 'name'),
    KeywordField('GPA', headerName: 'gpa'),
    KeywordField('Department', headerName: 'department'),
    KeywordField('Email', headerName: 'email'),
    KeywordField('PhoneNumber', headerName: 'phoneNumber'),
    KeywordField('Level', headerName: 'level'),
  ];

  final recordFormat = GenericRecordFormat(
    fieldFormats: fieldFormats,
    recordSeparator: RecordSeparator('|', type: RecordSeparatorType.delimited),
  );

  final repository = StudentRepository(recordFormat: recordFormat);

  // helper tool: create student files for all supported structures
  Future<void> createAllStudentFiles() async {
    final formats = <String, GenericRecordFormat>{
      'students_keyword.txt': GenericRecordFormat(
        fieldFormats: [
          KeywordField('ID', headerName: 'id'),
          KeywordField('Name', headerName: 'name'),
          KeywordField('GPA', headerName: 'gpa'),
          KeywordField('Department', headerName: 'department'),
          KeywordField('Email', headerName: 'email'),
          KeywordField('PhoneNumber', headerName: 'phoneNumber'),
          KeywordField('Level', headerName: 'level'),
        ],
        recordSeparator: RecordSeparator(
          '|',
          type: RecordSeparatorType.delimited,
        ),
      ),

      'students_length_indicator.txt': GenericRecordFormat(
        fieldFormats: [
          LengthIndicatorField(headerName: 'id'),
          LengthIndicatorField(headerName: 'name'),
          LengthIndicatorField(headerName: 'gpa'),
          LengthIndicatorField(headerName: 'department'),
          LengthIndicatorField(headerName: 'email'),
          LengthIndicatorField(headerName: 'phoneNumber'),
          LengthIndicatorField(headerName: 'level'),
        ],
        recordSeparator: RecordSeparator(
          '#',
          type: RecordSeparatorType.lengthIndicator,
        ),
      ),

      'students_fixed.txt': GenericRecordFormat(
        fieldFormats: [
          FixedLengthField(4, headerName: 'id'),
          FixedLengthField(20, headerName: 'name'),
          FixedLengthField(6, headerName: 'gpa'),
          FixedLengthField(6, headerName: 'department'),
          FixedLengthField(30, headerName: 'email'),
          FixedLengthField(12, headerName: 'phoneNumber'),
          FixedLengthField(8, headerName: 'level'),
        ],
        recordSeparator: RecordSeparator(
          '|',
          type: RecordSeparatorType.fixedLength,
          recordLength: 86,
        ),
      ),

      'students_delimited_field.txt': GenericRecordFormat(
        fieldFormats: [
          DelimitedField(delimiter: '|', headerName: 'id'),
          DelimitedField(delimiter: '|', headerName: 'name'),
          DelimitedField(delimiter: '|', headerName: 'gpa'),
          DelimitedField(delimiter: '|', headerName: 'department'),
          DelimitedField(delimiter: '|', headerName: 'email'),
          DelimitedField(delimiter: '|', headerName: 'phoneNumber'),
          DelimitedField(delimiter: '|', headerName: 'level'),
        ],
        recordSeparator: RecordSeparator(
          '|',
          type: RecordSeparatorType.delimited,
        ),
      ),

      'students_number_of_fields.txt': GenericRecordFormat(
        fieldFormats: [
          LengthIndicatorField(headerName: 'id'),
          LengthIndicatorField(headerName: 'name'),
          LengthIndicatorField(headerName: 'gpa'),
          LengthIndicatorField(headerName: 'department'),
          LengthIndicatorField(headerName: 'email'),
          LengthIndicatorField(headerName: 'phoneNumber'),
          LengthIndicatorField(headerName: 'level'),
        ],
        recordSeparator: RecordSeparator(
          '|',
          type: RecordSeparatorType.numberOfFields,
          fieldCount: 7,
        ),
      ),
    };

  
    for (var entry in formats.entries) {
      final fileName = entry.key;
      final fmt = entry.value;
      final repo = StudentRepository(recordFormat: fmt, fileName: fileName);
      await repo.deleteAll();

      for (int i = 1; i <= 20; i++) {
        final s = StudentModel(
          id: i,
          name: 'S${i.toString().padLeft(2, '0')}',
          gpa: 2.5 + (i % 10) * 0.1,
          department: ['CS', 'IS', 'IT', 'SE', 'DS'][i % 5],
          email: 's${i}@example.com',
          phoneNumber: '010${1000 + i}',
          level: ['one', 'two', 'three', 'four'][i % 4],
        );
        await repo.add(s);
      }
      print('Created $fileName with 20 students');
    }
  }

  // -------------------- إضافة 100 طالب تلقائي --------------------
  final random = Random();
  final departments = ['CS', 'IS', 'IT', 'SE', 'DS'];
  final levels = ['one', 'two', 'three', 'four'];
  final studentsInFile = await repository.getAll();

  if (studentsInFile.isEmpty) {
    print("Adding 100 students...");
    for (int i = 1; i <= 100; i++) {
      await repository.add(
        StudentModel(
          id: i,
          name: 'Student$i',
          gpa: (2.0 + random.nextDouble() * 2.0),
          department: departments[random.nextInt(departments.length)],
          email: 'student$i@test.com',
          phoneNumber: '010${1000 + i}',
          level: levels[random.nextInt(levels.length)],
        ),
      );
    }
    print("✅ 100 students added successfully!\n");
  }

  // -------------------- حلقة do-while للتشغيل --------------------
  int choice;
  do {
    print('''
====== Student Management ======
1. View All Students
2. Add Student
3. Update Student
4. Delete Student
5. Search Student by ID
0. Exit
==============================
''');
    stdout.write("Enter your choice: ");
    choice = int.tryParse(stdin.readLineSync() ?? '') ?? -1;

    switch (choice) {
      case 6:
        print('\nCreating sample student files for all formats...');
        await createAllStudentFiles();
        print('Done.');
        break;
      case 1:
        final students = await repository.getAll();
        print("Total Students: ${students.length}");
        for (var s in students) {
          print(
            "${s.id} | ${s.name} | GPA: ${s.gpa.toStringAsFixed(2)} | ${s.department} | ${s.level}",
          );
        }
        break;

      case 2:
        stdout.write("Enter name: ");
        final name = stdin.readLineSync() ?? '';
        stdout.write("Enter GPA: ");
        final gpa = double.tryParse(stdin.readLineSync() ?? '') ?? 0.0;
        stdout.write("Enter department: ");
        final dept = stdin.readLineSync() ?? '';
        stdout.write("Enter email: ");
        final email = stdin.readLineSync() ?? '';
        stdout.write("Enter phone: ");
        final phone = stdin.readLineSync() ?? '';
        stdout.write("Enter level: ");
        final level = stdin.readLineSync() ?? 'one';
        final id = (await repository.getAll()).length + 1;

        await repository.add(
          StudentModel(
            id: id,
            name: name,
            gpa: gpa,
            department: dept,
            email: email,
            phoneNumber: phone,
            level: level,
          ),
        );
        print("✅ Student added successfully!");
        break;

      case 3:
        stdout.write("Enter Student ID to update: ");
        final idToUpdate = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
        final existing = (await repository.getAll()).firstWhere(
          (s) => s.id == idToUpdate,
          orElse: () => StudentModel(
            id: -1,
            name: '',
            gpa: 0.0,
            department: '',
            email: '',
            phoneNumber: '',
            level: '',
          ),
        );

        if (existing.id == -1) {
          print("❌ Student not found!");
          break;
        }

        stdout.write("Enter new name [${existing.name}]: ");
        final name = stdin.readLineSync();
        stdout.write("Enter new GPA [${existing.gpa}]: ");
        final gpa = double.tryParse(stdin.readLineSync() ?? '') ?? existing.gpa;
        stdout.write("Enter new department [${existing.department}]: ");
        final dept = stdin.readLineSync();
        stdout.write("Enter new email [${existing.email}]: ");
        final email = stdin.readLineSync();
        stdout.write("Enter new phone [${existing.phoneNumber}]: ");
        final phone = stdin.readLineSync();
        stdout.write("Enter new level [${existing.level}]: ");
        final level = stdin.readLineSync();

        await repository.update(
          StudentModel(
            id: existing.id,
            name: name?.isEmpty ?? true ? existing.name : name!,
            gpa: gpa,
            department: dept?.isEmpty ?? true ? existing.department : dept!,
            email: email?.isEmpty ?? true ? existing.email : email!,
            phoneNumber: phone?.isEmpty ?? true ? existing.phoneNumber : phone!,
            level: level?.isEmpty ?? true ? existing.level : level!,
          ),
        );
        print("✅ Student updated successfully!");
        break;

      case 4:
        stdout.write("Enter Student ID to delete: ");
        final idToDelete = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
        final deleted = await repository.delete(idToDelete);
        if (deleted) {
          print("✅ Student deleted successfully!");
        } else {
          print("❌ Student not found!");
        }
        break;

      case 5:
        stdout.write("Enter Student ID to search: ");
        final idToSearch = int.tryParse(stdin.readLineSync() ?? '') ?? -1;
        final result = await repository.searchByID(idToSearch);
        if (result != null) {
          final s = result.student;
          print(
            "Found: ${s.id} | ${s.name} | GPA: ${s.gpa} | ${s.department} | ${s.level} | Time: ${result.timeInMicroseconds} μs",
          );
        } else {
          print("❌ Student not found!");
        }
        break;

      case 0:
        print("Exiting...");
        break;

      default:
        print("Invalid choice, try again!");
    }

    print("\n");
  } while (choice != 0);
}

void testCourse() async {
  // ===================== استخدام FileManager الحقيقي =====================

  // إعداد Record Format للكورسات باستخدام KeywordField
  final fieldFormats = [
    KeywordField('Code', headerName: 'code;'),
    KeywordField('Name', headerName: 'name;'),
    KeywordField('CreditHours', headerName: 'creditHours;'),
    KeywordField('EnrolledStudents', headerName: 'enrolledStudents;'),
    KeywordField('Instructor', headerName: 'instructor;'),
    KeywordField('Department', headerName: 'department;'),
  ];

  final recordFormat = GenericRecordFormat(
    fieldFormats: fieldFormats,
    recordSeparator: RecordSeparator('|', type: RecordSeparatorType.delimited),
  );

  final repository = CourseRepository(
    recordFormat: recordFormat,
    fileName: 'courses.txt',
  );

  // -------------------- إضافة 10 كورسات تلقائي --------------------
  final random = Random();
  final departments = ['CS', 'IS', 'IT', 'SE', 'MATH'];
  final instructors = ['Dr. Ahmed', 'Dr. Sara', 'Eng. Omar', 'Prof. Layla'];
  final coursesInFile = await repository.getAll();

  if (coursesInFile.isEmpty) {
    print("Adding 10 sample courses...");
    for (int i = 1; i <= 10; i++) {
      await repository.add(
        CourseModel(
          code: 'CS${100 + i}',
          name: 'Course Name $i',
          creditHours: random.nextInt(3) + 2, // بين 2 و 4
          enrolledStudents: 10 + random.nextInt(90), // بين 10 و 100
          department: departments[random.nextInt(departments.length)],
          instructor: instructors[random.nextInt(instructors.length)],
        ),
      );
    }
    print("✅ 10 courses added successfully!\n");
  }

  // -------------------- حلقة do-while للتشغيل --------------------
  int choice;
  do {
    print('''
====== Course Management ======
1. View All Courses
2. Add New Course
3. Update Course
4. Delete Course
5. Search Course by Code
0. Exit
==============================
''');
    stdout.write("Enter your choice: ");
    final input = stdin.readLineSync();
    choice = int.tryParse(input ?? '') ?? -1;

    switch (choice) {
      case 1:
        final courses = await repository.getAll();
        print("Total Courses: ${courses.length}");
        for (var c in courses) {
          print(c);
        }
        break;

      case 2:
        stdout.write("Enter Course Code (e.g., CS101): ");
        final code = stdin.readLineSync() ?? '';
        stdout.write("Enter Course Name: ");
        final name = stdin.readLineSync() ?? '';
        stdout.write("Enter Credit Hours: ");
        final credits = int.tryParse(stdin.readLineSync() ?? '') ?? 3;
        stdout.write("Enter Enrolled Students: ");
        final enrolled = int.tryParse(stdin.readLineSync() ?? '') ?? 0;
        stdout.write("Enter Instructor: ");
        final instructor = stdin.readLineSync() ?? '';
        stdout.write("Enter Department: ");
        final dept = stdin.readLineSync() ?? '';

        try {
          await repository.add(
            CourseModel(
              code: code,
              name: name,
              creditHours: credits,
              enrolledStudents: enrolled,
              instructor: instructor,
              department: dept,
            ),
          );
          print("✅ Course added successfully!");
        } catch (e) {
          print("❌ Error adding course: ${e.toString()}");
        }
        break;

      case 3:
        stdout.write("Enter Course Code to update: ");
        final codeToUpdate = stdin.readLineSync() ?? '';
        final existingCourses = await repository.getAll();

        CourseModel? existing;
        try {
          existing = existingCourses.firstWhere((c) => c.code == codeToUpdate);
        } catch (e) {
          existing = null;
        }

        if (existing == null) {
          print("❌ Course not found!");
          break;
        }

        stdout.write("Enter new Name [${existing.name}]: ");
        final name = stdin.readLineSync();
        stdout.write("Enter new Credit Hours [${existing.creditHours}]: ");
        final credits = int.tryParse(stdin.readLineSync() ?? '');
        stdout.write(
          "Enter new Enrolled Students [${existing.enrolledStudents}]: ",
        );
        final enrolled = int.tryParse(stdin.readLineSync() ?? '');
        stdout.write("Enter new Instructor [${existing.instructor}]: ");
        final instructor = stdin.readLineSync();
        stdout.write("Enter new Department [${existing.department}]: ");
        final dept = stdin.readLineSync();

        final updatedCourse = CourseModel(
          code: existing.code,
          name: name?.isEmpty ?? true ? existing.name : name!,
          creditHours: credits ?? existing.creditHours,
          enrolledStudents: enrolled ?? existing.enrolledStudents,
          instructor: instructor?.isEmpty ?? true
              ? existing.instructor
              : instructor!,
          department: dept?.isEmpty ?? true ? existing.department : dept!,
        );

        final updated = await repository.update(updatedCourse);
        if (updated) {
          print("✅ Course updated successfully!");
        } else {
          print("❌ Failed to update course (should not happen if found).");
        }
        break;

      case 4:
        stdout.write("Enter Course Code to delete: ");
        final codeToDelete = stdin.readLineSync() ?? '';
        final deleted = await repository.delete(codeToDelete);
        if (deleted) {
          print("✅ Course deleted successfully!");
        } else {
          print("❌ Course not found!");
        }
        break;

      case 5:
        stdout.write("Enter Course Code to search: ");
        final codeToSearch = stdin.readLineSync() ?? '';
        final result = await repository.searchByCode(codeToSearch);
        if (result != null) {
          final c = result.course;
          print("Found: $c | Time: ${result.timeInMicroseconds} μs");
        } else {
          print("❌ Course not found!");
        }
        break;

      case 0:
        print("Exiting...");
        break;

      default:
        print("Invalid choice, try again!");
    }

    print("\n");
  } while (choice != 0);
}

void testDepartment() async {
  final studentRecordFormat = GenericRecordFormat(
    fieldFormats: [
      KeywordField('ID', headerName: 'id'),
      KeywordField('Name', headerName: 'name'),
      KeywordField('GPA', headerName: 'gpa'),
      KeywordField('Deparment', headerName: 'department'),
      KeywordField('Email', headerName: 'email'),
      KeywordField('PhoneNumber', headerName: 'phoneNumber'),
      KeywordField('Level', headerName: 'level'),
    ],
    recordSeparator: RecordSeparator('|', type: RecordSeparatorType.delimited),
  );

  final courseRecordFormat = GenericRecordFormat(
    fieldFormats: [
      KeywordField('Code', headerName: 'code;'),
      KeywordField('Name', headerName: 'name;'),
      KeywordField('CreditHours', headerName: 'creditHours;'),
      KeywordField('EnrolledStudents', headerName: 'enrolledStudents;'),
      KeywordField('Instructor', headerName: 'instructor;'),
      KeywordField('Department', headerName: 'department;'),
    ],
    recordSeparator: RecordSeparator('|', type: RecordSeparatorType.delimited),
  );

  final studentRepo = StudentRepository(recordFormat: studentRecordFormat);

  final courseRepo = CourseRepository(recordFormat: courseRecordFormat);

  final departmentRepo = DepartmentRepository(
    studentRepository: studentRepo,
    courseRepository: courseRepo,
  );

  final csStudents = await departmentRepo.getStudentsByDepartment('CS');
  print('CS Students: ${csStudents.map((s) => s.name).toList()}');

  final csCourses = await departmentRepo.getCoursesByDepartment('CS');
  print('CS Courses: ${csCourses.map((c) => c.name).toList()}');

  final allDepartments = await departmentRepo.getAllDepartmentNames();
  print('All Departments: $allDepartments');
}
