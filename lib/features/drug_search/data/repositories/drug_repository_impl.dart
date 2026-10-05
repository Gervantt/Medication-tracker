import 'package:dio/dio.dart';
import 'package:medtrack/core/error/failure.dart';
import 'package:medtrack/core/error/result.dart';
import 'package:medtrack/core/network/dio_failure_mapper.dart';
import 'package:medtrack/features/drug_search/data/datasources/open_fda_remote_data_source.dart';
import 'package:medtrack/features/drug_search/data/mappers/drug_label_mapper.dart';
import 'package:medtrack/features/drug_search/domain/entities/drug_label.dart';
import 'package:medtrack/features/drug_search/domain/repositories/drug_repository.dart';

class DrugRepositoryImpl implements DrugRepository {
  const DrugRepositoryImpl(this._remote);

  final OpenFdaRemoteDataSource _remote;

  @override
  Future<Result<List<DrugLabel>>> searchByName(String query) async {
    final result = await _guard(() => _remote.searchByName(query));
    return switch (result) {
      Ok(:final value) => Ok([for (final dto in value.results) dto.toEntity()]),
      // For a search, "not found" simply means no results.
      Err(failure: NotFoundFailure()) => const Ok([]),
      Err(:final failure) => Err(failure),
    };
  }

  @override
  Future<Result<DrugLabel>> getById(String id) async {
    final result = await _guard(() => _remote.getById(id));
    return switch (result) {
      Ok(:final value) when value.results.isNotEmpty => Ok(
        value.results.first.toEntity(),
      ),
      Ok() => const Err(NotFoundFailure()),
      Err(:final failure) => Err(failure),
    };
  }

  Future<Result<T>> _guard<T>(Future<T> Function() request) async {
    try {
      return Ok(await request());
    } on DioException catch (error) {
      return Err(error.toFailure());
    } on Object catch (error) {
      // E.g. a response that does not match the expected JSON shape.
      return Err(UnexpectedFailure(error));
    }
  }
}
