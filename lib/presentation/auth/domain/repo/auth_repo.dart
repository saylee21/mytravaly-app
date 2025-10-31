import '../../../../core/utils/typedef.dart';
import '../../data/models/register_device_req_model.dart';
import '../../data/models/register_device_resp_model.dart';

abstract class AuthRepo {

  ResultFutureV2<RegisterDeviceRespModel> registerDevice(
      RegisterDeviceReqModel requestModel);

}