enum RecordSeparatorType {
  fixedLength,
  delimited,
  lengthIndicator,
  numberOfFields,
}

class RecordSeparator {
  final RecordSeparatorType type;
  final String delimiter; // لو delimited
  final int? recordLength; // لو fixedLength
  final int? fieldCount; // لو numberOfFields

  RecordSeparator(String s, {
    required this.type,
    this.delimiter = '\n',
    this.recordLength,
    this.fieldCount,
  });
}
