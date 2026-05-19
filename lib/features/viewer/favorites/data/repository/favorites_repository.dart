import 'package:dartz/dartz.dart';
import '../../../../../core/error/exceptions.dart';
import '../../../../../core/repository/repository.dart';
import '../model/favorite_item_model.dart';

abstract class FavoritesRepository extends Repository {
  Future<Either<CustomException, FavoritesResponseModel>> getFavorites();
  Future<Either<CustomException, void>> addFavorite({
    required String contentType,
    required int objectId,
  });
  Future<Either<CustomException, void>> removeFavorite({
    required String contentType,
    required int objectId,
  });
}
