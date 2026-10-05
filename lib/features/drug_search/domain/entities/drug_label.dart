import 'package:equatable/equatable.dart';

/// A drug label from the US FDA database. Texts are in English and can be
/// several thousand characters long.
class DrugLabel extends Equatable {
  const DrugLabel({
    required this.id,
    this.brandName,
    this.genericName,
    this.manufacturer,
    this.purpose,
    this.dosage,
    this.warnings,
    this.sideEffects,
  });

  final String id;
  final String? brandName;
  final String? genericName;
  final String? manufacturer;

  /// Indications and usage (prescription) or purpose (OTC).
  final String? purpose;
  final String? dosage;
  final String? warnings;

  /// Adverse reactions; usually missing on OTC labels.
  final String? sideEffects;

  /// Best available name to show or to prefill a new medication with.
  String? get name => brandName ?? genericName;

  @override
  List<Object?> get props => [
    id,
    brandName,
    genericName,
    manufacturer,
    purpose,
    dosage,
    warnings,
    sideEffects,
  ];
}
