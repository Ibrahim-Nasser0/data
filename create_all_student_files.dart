import 'dart:async';
import 'models/student_model.dart';
import 'storage/file_manager.dart';
import 'storage/formats/field/keyword_field.dart';
import 'storage/formats/field/length_indicator_field.dart';
import 'storage/formats/field/fixed_length_field.dart';
import 'storage/formats/field/delimited_field.dart';
import 'storage/formats/generic_record_format.dart';
import 'storage/formats/record_separator.dart';

Future<void> main() async {
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

  final fm = FileManager();
  for (var entry in formats.entries) {
    final fileName = entry.key;
    final fmt = entry.value;

    // Build records in memory and write directly to file to avoid parsing while bootstrapping
    final rows = <List<String>>[];
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
      rows.add([
        s.id.toString(),
        s.name,
        s.gpa.toStringAsFixed(2),
        s.department,
        s.email,
        s.phoneNumber,
        s.level,
      ]);
    }

    final dataBody = fmt.encodeFromRows(rows);
    final header = fmt.headerString();
    final full = '$header\n$dataBody';
    await fm.write(fileName, full);
    print('Created $fileName with 20 students');
  }
}
