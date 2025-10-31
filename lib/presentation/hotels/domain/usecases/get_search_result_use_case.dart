
import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/usecase.dart';
import '../../data/models/get_search_results_req_model.dart';
import '../../data/models/get_search_results_resp_model.dart';
import '../repo/hotel_repo.dart';

class GetSearchResultUseCase
    implements UseCaseWithParamsV2<GetSearchResultRespModel, GetSearchResultReqModel> {
  final HotelRepo repository;

  GetSearchResultUseCase(this.repository);

  @override
  ResultFutureV2<GetSearchResultRespModel> call(params) async {
    return await repository.getSearchResults(params);
  }
}