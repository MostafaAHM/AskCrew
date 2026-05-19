import 'network_request.dart';

abstract class NetworkService {
  Future<Model> callApi<Model>(
    NetworkRequest networkRequest, {
    Model Function(dynamic json)? mapper,
  });
}
