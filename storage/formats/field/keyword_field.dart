import 'field_format.dart';

class KeywordField implements FieldFormat {
  final String key;
   final String headerName;
  KeywordField(this.key, {this.headerName = 'FIELD'});

  @override
  String encode(String field) => "$key=$field;";

  @override
  String decode(String raw) {
    return raw.split("=").last.replaceAll(";", "");
  }
}
