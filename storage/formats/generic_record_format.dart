import 'field/delimited_field.dart';
import 'field/fixed_length_field.dart';
import 'field/keyword_field.dart';
import 'field/length_indicator_field.dart';
import 'field/field_format.dart';
import 'record/record_format.dart';
import 'record_separator.dart';

class GenericRecordFormat implements RecordFormat {
  final List<FieldFormat> fieldFormats;
  final RecordSeparator recordSeparator;
  final String header; // نضيف Header هنا

  GenericRecordFormat({
    required this.fieldFormats,
    required this.recordSeparator,
    String? header,
  }) : header = header ?? _generateHeader(fieldFormats, recordSeparator);

  /// ======================================
  /// توليد Header تلقائي من FieldFormats و RecordSeparator
  /// ======================================

  String headerString() {
    return fieldFormats
        .map((f) => f.headerName)
        .join(recordSeparator.delimiter);
  }

  static String _generateHeader(
    List<FieldFormat> fieldFormats,
    RecordSeparator sep,
  ) {
    final type = sep.type.name;
    final fieldsCount = fieldFormats.length;
    final delimiter = sep.delimiter;
    return 'FIELDS=$fieldsCount;TYPE=$type;DELIMITER=$delimiter';
  }

  /// ======================================
  /// قراءة الـ Header
  /// ======================================
  static GenericRecordFormat fromHeader(String headerLine) {
    final parts = headerLine.split(',');
    int fieldCount = 0;
    RecordSeparatorType type = RecordSeparatorType.delimited;
    String delimiter = '|';

    for (var part in parts) {
      final kv = part.split('=');
      if (kv.length != 2) continue;
      final key = kv[0].trim();
      final value = kv[1].trim();
      switch (key) {
        case 'FIELDS':
          fieldCount = int.parse(value);
          break;
        case 'TYPE':
          type = RecordSeparatorType.values.firstWhere(
            (e) => e.name.toLowerCase() == value.toLowerCase(),
            orElse: () => RecordSeparatorType.delimited,
          );
          break;
        case 'DELIMITER':
          delimiter = value;
          break;
      }
    }

    // نفترض كل الحقول LengthIndicatorField كبداية
    final fields = List<FieldFormat>.generate(
      fieldCount,
      (_) => LengthIndicatorField(),
    );

    return GenericRecordFormat(
      fieldFormats: fields,
      recordSeparator: RecordSeparator(delimiter, type: type),
      header: headerLine,
    );
  }

  @override
  List<Record> decode(String raw) {
    final records = <Record>[];

    switch (recordSeparator.type) {
      case RecordSeparatorType.delimited:
        final lines = raw
            .split(recordSeparator.delimiter)
            .where((l) => l.trim().isNotEmpty);
        for (var line in lines) {
          records.add(_decodeFields(line));
        }
        break;

      case RecordSeparatorType.fixedLength:
        final recLen = recordSeparator.recordLength!;
        for (int i = 0; i < raw.length; i += recLen) {
          final line = raw.substring(i, (i + recLen).clamp(0, raw.length));
          records.add(_decodeFields(line));
        }
        break;

      case RecordSeparatorType.lengthIndicator:
        int index = 0;
        while (index < raw.length) {
          final hashPos = raw.indexOf('#', index);
          if (hashPos == -1) break;
          final len = int.parse(raw.substring(index, hashPos));
          final start = hashPos + 1;
          final end = (start + len).clamp(0, raw.length);
          final recordStr = raw.substring(start, end);
          records.add(_decodeFields(recordStr));
          if (end <= hashPos) break;
          index = hashPos + 1 + len;
        }
        break;

      case RecordSeparatorType.numberOfFields:
        // Decode sequential records where each record contains a known number of fields.
        // We decode each record by parsing fields according to the configured FieldFormat
        // starting at the current index and advancing the index as we consume characters.
        int idx = 0;
        while (idx < raw.length) {
          final result = _decodeRecordFrom(raw, idx);
          records.add(result.record);
          idx = result.nextIndex;
        }
        break;
    }

    return records;
  }

  Record _decodeFields(String raw) {
    final fieldValues = <String>[];
    int index = 0;

    for (var f in fieldFormats) {
      if (f is FixedLengthField) {
        final part = raw.substring(
          index,
          (index + f.length).clamp(0, raw.length),
        );
        fieldValues.add(f.decode(part));
        index += f.length;
      } else if (f is DelimitedField) {
        final delimIndex = raw.indexOf(f.delimiter, index);
        if (delimIndex == -1) {
          fieldValues.add(raw.substring(index));
          index = raw.length;
        } else {
          fieldValues.add(raw.substring(index, delimIndex));
          index = delimIndex + f.delimiter.length;
        }
      } else if (f is LengthIndicatorField) {
        final hashPos = raw.indexOf('#', index);
        final len = int.parse(raw.substring(index, hashPos));
        fieldValues.add(raw.substring(hashPos + 1, hashPos + 1 + len));
        index = hashPos + 1 + len;
      } else if (f is KeywordField) {
        final end = raw.indexOf(';', index);

        if (end == -1) {
          final part = raw.substring(index);
          fieldValues.add(f.decode(part));
          index = raw.length;
        } else {
          final part = raw.substring(index, end + 1);
          fieldValues.add(f.decode(part));
          index = end + 1;
        }
      }
    }

    return Record(fieldValues);
  }

  // Helper to decode a single record starting at `startIndex` and returning
  // both the decoded Record and the index after the record (nextIndex).
  _RecordDecodeResult _decodeRecordFrom(String raw, int startIndex) {
    final fieldValues = <String>[];
    int index = startIndex;

    for (var f in fieldFormats) {
      if (f is FixedLengthField) {
        final part = raw.substring(
          index,
          (index + f.length).clamp(0, raw.length),
        );
        fieldValues.add(f.decode(part));
        index += f.length;
      } else if (f is DelimitedField) {
        final delimIndex = raw.indexOf(f.delimiter, index);
        if (delimIndex == -1) {
          fieldValues.add(raw.substring(index));
          index = raw.length;
        } else {
          fieldValues.add(raw.substring(index, delimIndex));
          index = delimIndex + f.delimiter.length;
        }
      } else if (f is LengthIndicatorField) {
        final hashPos = raw.indexOf('#', index);
        if (hashPos == -1) {
          // malformed - consume rest
          final rest = raw.substring(index);
          fieldValues.add(f.decode(rest));
          index = raw.length;
        } else {
          final len = int.parse(raw.substring(index, hashPos));
          fieldValues.add(
            raw.substring(
              hashPos + 1,
              (hashPos + 1 + len).clamp(0, raw.length),
            ),
          );
          index = hashPos + 1 + len;
        }
      } else if (f is KeywordField) {
        final end = raw.indexOf(';', index);

        if (end == -1) {
          final part = raw.substring(index);
          fieldValues.add(f.decode(part));
          index = raw.length;
        } else {
          final part = raw.substring(index, end + 1);
          fieldValues.add(f.decode(part));
          index = end + 1;
        }
      } else {
        // Unknown FieldFormat - try to consume until next separator or end
        final nextSep = raw.indexOf(';', index);
        if (nextSep == -1) {
          fieldValues.add(raw.substring(index));
          index = raw.length;
        } else {
          fieldValues.add(raw.substring(index, nextSep));
          index = nextSep + 1;
        }
      }
    }

    return _RecordDecodeResult(Record(fieldValues), index);
  }

  @override
  String encode(List<Record> records) {
    final buffer = StringBuffer();

    for (var record in records) {
      final recordStr = _encodeFields(record);
      switch (recordSeparator.type) {
        case RecordSeparatorType.delimited:
          buffer.write(recordStr + recordSeparator.delimiter);
          break;
        case RecordSeparatorType.fixedLength:
          buffer.write(recordStr);
          break;
        case RecordSeparatorType.lengthIndicator:
          buffer.write('${recordStr.length}#$recordStr');
          break;
        case RecordSeparatorType.numberOfFields:
          buffer.write(recordStr);
          break;
      }
    }

    return buffer.toString().trim();
  }

  /// Convenience: encode from raw rows (list of field string lists)
  String encodeFromRows(List<List<String>> rows) {
    final records = rows.map((r) => Record(r)).toList();
    return encode(records);
  }

  String _encodeFields(Record record) {
    final buffer = StringBuffer();
    for (int i = 0; i < fieldFormats.length; i++) {
      buffer.write(fieldFormats[i].encode(record.fields[i]));
    }
    return buffer.toString();
  }
}

class _RecordDecodeResult {
  final Record record;
  final int nextIndex;
  _RecordDecodeResult(this.record, this.nextIndex);
}
