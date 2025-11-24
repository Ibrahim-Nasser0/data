import 'dart:async';
import 'models/student_model.dart';
import 'repository/student_repository.dart';
import 'storage/formats/field/keyword_field.dart';
import 'storage/formats/field/length_indicator_field.dart';
import 'storage/formats/field/fixed_length_field.dart';
import 'storage/formats/field/delimited_field.dart';
import 'storage/formats/generic_record_format.dart';
import 'storage/formats/record_separator.dart';

Future<void> main() async {
  final List hederName = [
    'id',
    'name',
    'gpa',
    'department',
    'email',
    'phoneNumber',
    'level',
  ];
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
        '\n',
        type: RecordSeparatorType.delimited,
      ),
    ),

    'students_length_indicator.txt': GenericRecordFormat(
      fieldFormats: List.generate(
        7,
        (int index) => LengthIndicatorField(headerName: hederName[index]),
      ),
      recordSeparator: RecordSeparator(
        '\n',
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
        '\n',
        type: RecordSeparatorType.fixedLength,
        recordLength: 86,
      ),
    ),

    'students_delimited_field.txt': GenericRecordFormat(
      fieldFormats: List.generate(
        7,
        (index) => DelimitedField(headerName: hederName[index], delimiter: '|'),
      ),
      recordSeparator: RecordSeparator(
        '\n',
        type: RecordSeparatorType.delimited,
      ),
    ),

    // numberOfFields: fields are encoded sequentially per record; use newline to separate records
    'students_number_of_fields.txt': GenericRecordFormat(
      fieldFormats: List.generate(
        7,
        (index) => LengthIndicatorField(headerName: hederName[index]),
      ),
      recordSeparator: RecordSeparator(
        '\n',
        type: RecordSeparatorType.numberOfFields,
        fieldCount: 7,
      ),
    ),
  };

  for (var entry in formats.entries) {
    final fileName = entry.key;
    final fmt = entry.value;

    // Use the repository API to create the file and add students.
    final repo = StudentRepository(recordFormat: fmt, fileName: fileName);

    // Start fresh
    await repo.deleteAll();

    for (int i = 1; i <= 20; i++) {
      final s = StudentModel(
        id: i,
        name: 'Student${i.toString().padLeft(2, '0')}',
        gpa: 2.5 + (i % 10) * 0.1,
        department: ['CS', 'IS', 'IT', 'SE', 'DS'][i % 5],
        email: 'stu${i}@example.com',
        phoneNumber: '010${1000 + i}',
        level: ['one', 'two', 'three', 'four'][i % 4],
      );

      await repo.add(s);
    }

    final students = await repo.getAll();
    print(
      'Created ${students.length} students in $fileName via StudentRepository',
    );
    if (students.isNotEmpty) {
      final first = students.first;
      print(
        ' First student: id=${first.id}, name=${first.name}, gpa=${first.gpa}',
      );
    }
  }
}
