import '../../../../../../core/network/dio_service.dart';
import '../../../../../../core/network/network_request.dart';
import '../../../../../../core/app_config/app_urls.dart';
import '../models/talent_profile_model.dart';

abstract class TalentProfileRemoteDataSource {
  Future<TalentProfileModel> getTalentProfile(String id);
}

class TalentProfileRemoteDataSourceImpl
    implements TalentProfileRemoteDataSource {
  final DioService _dioService;

  TalentProfileRemoteDataSourceImpl(this._dioService);

  @override
  Future<TalentProfileModel> getTalentProfile(String id) async {
    try {
      final response = await _dioService.callApi(
        NetworkRequest(
          AppUrls.getUserProfile(int.parse(id)),
          method: RequestMethod.get,
        ),
      );

      return TalentProfileModel.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}
