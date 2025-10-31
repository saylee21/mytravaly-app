
import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/usecase.dart';
import '../../data/models/register_device_req_model.dart';
import '../../data/models/register_device_resp_model.dart';
import '../repo/auth_repo.dart';

class RegisterDeviceUseCase
    implements UseCaseWithParamsV2<RegisterDeviceRespModel, RegisterDeviceReqModel> {
  final AuthRepo repository;

  RegisterDeviceUseCase(this.repository);

  @override
  ResultFutureV2<RegisterDeviceRespModel> call(params) async {
    return await repository.registerDevice(params);
  }
}