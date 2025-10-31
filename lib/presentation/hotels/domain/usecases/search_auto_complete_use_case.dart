
import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/usecase.dart';
import '../../data/models/search_auto_complete_req_model.dart';
import '../../data/models/search_auto_complete_resp_model.dart';
import '../repo/hotel_repo.dart';

class SearchAutoCompleteUseCase
    implements UseCaseWithParamsV2<SearchAutoCompleteRespModel, SearchAutoCompleteReqModel> {
  final HotelRepo repository;

  SearchAutoCompleteUseCase(this.repository);

  @override
  ResultFutureV2<SearchAutoCompleteRespModel> call(params) async {
    return await repository.autoComplete(params);
  }
}