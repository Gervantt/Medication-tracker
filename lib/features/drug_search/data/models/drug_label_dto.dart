import 'package:freezed_annotation/freezed_annotation.dart';

part 'drug_label_dto.freezed.dart';
part 'drug_label_dto.g.dart';

/// `GET /drug/label.json` response. Every label field in openFDA is an
/// array of strings and any of them may be missing.
@freezed
abstract class DrugLabelsResponseDto with _$DrugLabelsResponseDto {
  const factory DrugLabelsResponseDto({
    @Default(<DrugLabelDto>[]) List<DrugLabelDto> results,
  }) = _DrugLabelsResponseDto;

  factory DrugLabelsResponseDto.fromJson(Map<String, dynamic> json) =>
      _$DrugLabelsResponseDtoFromJson(json);
}

@freezed
abstract class DrugLabelDto with _$DrugLabelDto {
  const factory DrugLabelDto({
    required String id,
    @Default(OpenFdaDto()) OpenFdaDto openfda,
    @JsonKey(name: 'indications_and_usage') List<String>? indicationsAndUsage,
    List<String>? purpose,
    @JsonKey(name: 'dosage_and_administration')
    List<String>? dosageAndAdministration,
    @JsonKey(name: 'boxed_warning') List<String>? boxedWarning,
    List<String>? warnings,
    @JsonKey(name: 'warnings_and_cautions') List<String>? warningsAndCautions,
    @JsonKey(name: 'adverse_reactions') List<String>? adverseReactions,
  }) = _DrugLabelDto;

  factory DrugLabelDto.fromJson(Map<String, dynamic> json) =>
      _$DrugLabelDtoFromJson(json);
}

@freezed
abstract class OpenFdaDto with _$OpenFdaDto {
  const factory OpenFdaDto({
    @JsonKey(name: 'brand_name') List<String>? brandName,
    @JsonKey(name: 'generic_name') List<String>? genericName,
    @JsonKey(name: 'manufacturer_name') List<String>? manufacturerName,
  }) = _OpenFdaDto;

  factory OpenFdaDto.fromJson(Map<String, dynamic> json) =>
      _$OpenFdaDtoFromJson(json);
}
