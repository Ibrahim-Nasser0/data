import 'field_format.dart';

class LengthIndicatorField implements FieldFormat {
  final String headerName;

  LengthIndicatorField({this.headerName = 'FIELD'});
  @override
  String encode(String field) => "${field.length}#$field";

  @override
  String decode(String raw) {
    // Parse length digits, then extract that many characters
    int i = 0;
    while (i < raw.length && int.tryParse(raw[i]) != null) {
      i++;
    }
    if (i == 0) return raw; // No digits found
    final len = int.tryParse(raw.substring(0, i)) ?? 0;
    if (len <= 0 || i + len > raw.length) return raw;
    return raw.substring(i, i + len);
  }
}
