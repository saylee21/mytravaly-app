
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/urls.dart';
import '../models/register_device_req_model.dart';
import '../models/register_device_resp_model.dart';

abstract class AuthDatasource {

  ResultFutureV2<RegisterDeviceRespModel> registerDevice(
      RegisterDeviceReqModel requestModel);

}

class AuthDatasourceImpl implements AuthDatasource {

  AuthDatasourceImpl();

  @override
  ResultFutureV2<RegisterDeviceRespModel> registerDevice(
      RegisterDeviceReqModel requestModel) async {
    try {
      return await ApiClientV2().post<RegisterDeviceRespModel>(
        url: URLManager.baseUrl,
        body: requestModel.toJson(),
        converter: (json) => RegisterDeviceRespModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

}
