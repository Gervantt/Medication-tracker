import 'package:medtrack/features/drug_search/data/models/drug_label_dto.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';

extension DrugLabelDtoMapper on DrugLabelDto {
  DrugLabel toEntity() => DrugLabel(
    id: id,
    brandName: _first(openfda.brandName),
    genericName: _first(openfda.genericName),
    manufacturer: _first(openfda.manufacturerName),
    purpose: _join(indicationsAndUsage ?? purpose),
    dosage: _join(dosageAndAdministration),
    // Prescription labels use `warnings_and_cautions`, OTC ones `warnings`.
    warnings: _join([...?boxedWarning, ...?(warnings ?? warningsAndCautions)]),
    sideEffects: _join(adverseReactions),
  );
}

String? _first(List<String>? values) {
  final value = values?.firstOrNull?.trim();
  return value == null || value.isEmpty ? null : value;
}

/// OTC labels often repeat the section heading: "Uses Uses temporarily…".
final _repeatedFirstWord = RegExp(r'^(\w+) \1\b');

/// Joins label paragraphs, collapsing the irregular whitespace of the
/// source documents. Returns `null` when there is no text.
String? _join(List<String>? paragraphs) {
  final text = [
    for (final paragraph in paragraphs ?? const <String>[])
      paragraph
          .replaceAll(RegExp(r'\s+'), ' ')
          .trim()
          .replaceFirstMapped(_repeatedFirstWord, (match) => match[1]!),
  ].where((p) => p.isNotEmpty).join('\n\n');
  return text.isEmpty ? null : text;
}
