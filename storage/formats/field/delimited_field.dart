import 'field_format.dart';

class DelimitedField implements FieldFormat {
  final String delimiter;
  @override
  final String headerName;

  DelimitedField({this.delimiter = ':', this.headerName = 'FIELD'});

  @override
  String encode(String field) => '$field$delimiter';

  @override
  String decode(String raw) {
    // نقطع الحقل عند delimiter
    final delimIndex = raw.indexOf(delimiter);
    if (delimIndex == -1) return raw; // آخر حقل
    return raw.substring(0, delimIndex);
  }
}
