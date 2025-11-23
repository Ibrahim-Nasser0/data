import 'storage/formats/field/fixed_length_field.dart';
import 'storage/formats/generic_record_format.dart';
import 'storage/formats/record_separator.dart';
import 'storage/formats/record/record_format.dart';

void main() {
  final fields = [
    FixedLengthField(2, headerName: 'id'),
    FixedLengthField(10, headerName: 'name'),
    FixedLengthField(4, headerName: 'gpa'),
    FixedLengthField(4, headerName: 'dept'),
  ];
  final sep = RecordSeparator('#', type: RecordSeparatorType.lengthIndicator);
  final fmt = GenericRecordFormat(fieldFormats: fields, recordSeparator: sep);
  final records = [
    Record(['1', 'Alice', '3.50', 'CS']),
    Record(['2', 'Bob', '2.75', 'IS']),
  ];
  final encoded = fmt.encode(records);
  print('ENCODED: $encoded');
  try {
    final decoded = fmt.decode(encoded);
    print('Decoded count: ${decoded.length}');
    for (var r in decoded) print(r.fields);
  } catch (e, st) {
    print('DECODE ERROR: $e');
    print(st);
  }
}
