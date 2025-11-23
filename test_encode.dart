import 'storage/formats/field/length_indicator_field.dart';
import 'storage/formats/generic_record_format.dart';
import 'storage/formats/record_separator.dart';
import 'storage/formats/record/record_format.dart';

void main() {
  final fields = [
    LengthIndicatorField(headerName: 'id'),
    LengthIndicatorField(headerName: 'name'),
    LengthIndicatorField(headerName: 'gpa'),
  ];

  final fmt = GenericRecordFormat(
    fieldFormats: fields,
    recordSeparator: RecordSeparator(
      '#',
      type: RecordSeparatorType.lengthIndicator,
    ),
  );

  final records = [
    Record(['1', 'John', '3.5']),
  ];
  final encoded = fmt.encode(records);
  print('Encoded:\n$encoded');
  print('\n---\n');

  final decoded = fmt.decode(encoded);
  print('Decoded ${decoded.length} records:');
  for (var r in decoded) {
    print('  Fields: ${r.fields}');
  }
}
