import 'storage/formats/field/length_indicator_field.dart';
import 'storage/formats/field/keyword_field.dart';
import 'storage/formats/field/fixed_length_field.dart';
import 'storage/formats/field/delimited_field.dart';
import 'storage/formats/field/field_format.dart';
import 'storage/formats/generic_record_format.dart';
import 'storage/formats/record_separator.dart';
import 'storage/formats/record/record_format.dart';

void main() {
  final samples = [
    ['1', 'Alice', '3.50', 'CS'],
    ['2', 'Bob', '2.75', 'IS'],
  ];

  final fieldTypes = <String, List<FieldFormat>>{
    'lengthIndicator': [
      LengthIndicatorField(headerName: 'id'),
      LengthIndicatorField(headerName: 'name'),
      LengthIndicatorField(headerName: 'gpa'),
      LengthIndicatorField(headerName: 'dept'),
    ],
    'keyword': [
      KeywordField('ID', headerName: 'id;'),
      KeywordField('Name', headerName: 'name;'),
      KeywordField('GPA', headerName: 'gpa;'),
      KeywordField('Department', headerName: 'department;'),
    ],
    'fixedLength': [
      FixedLengthField(2, headerName: 'id'),
      FixedLengthField(10, headerName: 'name'),
      FixedLengthField(4, headerName: 'gpa'),
      FixedLengthField(4, headerName: 'dept'),
    ],
    'delimitedField': [
      DelimitedField(delimiter: '|', headerName: 'id'),
      DelimitedField(delimiter: '|', headerName: 'name'),
      DelimitedField(delimiter: '|', headerName: 'gpa'),
      DelimitedField(delimiter: '|', headerName: 'dept'),
    ],
  };

  final separators = {
    'lengthIndicator': RecordSeparator(
      '#',
      type: RecordSeparatorType.lengthIndicator,
    ),
    'delimited': RecordSeparator('|', type: RecordSeparatorType.delimited),
    'fixedLength': RecordSeparator(
      '|',
      type: RecordSeparatorType.fixedLength,
      recordLength: 20,
    ),
    'numberOfFields': RecordSeparator(
      '|',
      type: RecordSeparatorType.numberOfFields,
      fieldCount: 4,
    ),
  };

  print('Running encode/decode matrix...');

  for (var fEntry in fieldTypes.entries) {
    for (var sEntry in separators.entries) {
      final fieldKey = fEntry.key;
      final sepKey = sEntry.key;
      final fieldList = fEntry.value;
      final sep = sEntry.value;

      // Skip incompatible combos:
      // - FixedLengthField requires RecordSeparator.fixedLength or fixed-size encoding;
      // - LengthIndicator fields work best with lengthIndicator separator.
      try {
        final fmt = GenericRecordFormat(
          fieldFormats: fieldList,
          recordSeparator: sep,
        );
        final records = samples.map((s) => Record(s)).toList();
        final encoded = fmt.encode(records);
        final decoded = fmt.decode(encoded);

        final ok =
            decoded.length == records.length && _recordsEqual(records, decoded);

        print(
          '[$fieldKey x $sepKey] => Encoded length ${encoded.length} | RoundTrip: ${ok ? 'OK' : 'FAIL'}',
        );
        if (!ok) {
          print('  Encoded: $encoded');
          for (var i = 0; i < decoded.length; i++) {
            print('  Decoded[$i]: ${decoded[i].fields}');
          }
        }
      } catch (e) {
        print('[$fieldKey x $sepKey] => ERROR: $e');
      }
    }
  }
}

bool _recordsEqual(List<Record> a, List<Record> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    final af = a[i].fields;
    final bf = b[i].fields;
    if (af.length != bf.length) return false;
    for (int j = 0; j < af.length; j++) {
      if (af[j] != bf[j]) return false;
    }
  }
  return true;
}
