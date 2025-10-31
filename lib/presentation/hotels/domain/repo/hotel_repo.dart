import '../../../../core/utils/typedef.dart';
import '../../data/models/get_property_list_req_model.dart';
import '../../data/models/get_property_list_resp_model.dart';
import '../../data/models/get_search_results_req_model.dart';
import '../../data/models/get_search_results_resp_model.dart';
import '../../data/models/search_auto_complete_req_model.dart';
import '../../data/models/search_auto_complete_resp_model.dart';

abstract class HotelRepo {

  ResultFutureV2<SearchAutoCompleteRespModel> autoComplete(
      SearchAutoCompleteReqModel requestModel);

  ResultFutureV2<GetPropertyListRespModel> getPropertyList(
      GetPropertyListReqModel requestModel);

  ResultFutureV2<GetSearchResultRespModel> getSearchResults(
      GetSearchResultReqModel requestModel);

}