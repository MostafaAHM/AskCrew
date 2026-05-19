import 'package:dartz/dartz.dart';
import '../../../../../../core/error/exceptions.dart';
import '../models/talent_profile_model.dart';
import '../datasource/talent_profile_remote_ds.dart';

abstract class TalentProfileRepository {
  Future<Either<CustomException, TalentProfileModel>> getTalentProfile(
    String id,
  );
}

class TalentProfileRepositoryImpl implements TalentProfileRepository {
  final TalentProfileRemoteDataSource _remoteDataSource;

  TalentProfileRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<CustomException, TalentProfileModel>> getTalentProfile(
    String id,
  ) async {
    try {
      final result = await _remoteDataSource.getTalentProfile(id);
      return Right(result);
    } catch (e) {
      if (e is CustomException) {
        return Left(e);
      }
      return Left(CustomException(e.toString()));
    }
  }
}
