import '../../../../core/utils/typedef.dart';
import '../../domain/repo/auth_repo.dart';
import '../datasource/auth_datasource.dart';
import '../models/register_device_req_model.dart';
import '../models/register_device_resp_model.dart';

class AuthRepoImpl implements AuthRepo {
  final AuthDatasource _remoteDataSource;

  const AuthRepoImpl(this._remoteDataSource);

  @override
  ResultFutureV2<RegisterDeviceRespModel> registerDevice(
      RegisterDeviceReqModel request) async {
    try {
      final result = await _remoteDataSource.registerDevice(request);
      return result;
    } catch (e) {
      rethrow;
    }
  }

}
