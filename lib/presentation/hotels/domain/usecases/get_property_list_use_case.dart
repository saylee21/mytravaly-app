
import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/usecase.dart';
import '../../data/models/get_property_list_req_model.dart';
import '../../data/models/get_property_list_resp_model.dart';
import '../repo/hotel_repo.dart';

class GetPropertyListUseCase implements UseCaseWithParamsV2<GetPropertyListRespModel, GetPropertyListReqModel> {
  final HotelRepo repository;

  GetPropertyListUseCase(this.repository);

  @override
  ResultFutureV2<GetPropertyListRespModel> call(params) async {
    return await repository.getPropertyList(params);
  }
}