
import '../../../../core/network/api_client.dart';
import '../../../../core/utils/typedef.dart';
import '../../../../core/utils/urls.dart';
import '../models/get_property_list_req_model.dart';
import '../models/get_property_list_resp_model.dart';
import '../models/get_search_results_req_model.dart';
import '../models/get_search_results_resp_model.dart';
import '../models/search_auto_complete_req_model.dart';
import '../models/search_auto_complete_resp_model.dart';


abstract class HotelDatasource {

  ResultFutureV2<SearchAutoCompleteRespModel> autoComplete(
      SearchAutoCompleteReqModel requestModel);

  ResultFutureV2<GetPropertyListRespModel> getPropertyList(
      GetPropertyListReqModel requestModel);

  ResultFutureV2<GetSearchResultRespModel> getSearchResults(
      GetSearchResultReqModel requestModel);

}

class HotelDatasourceImpl implements HotelDatasource {

  HotelDatasourceImpl();

  @override
  ResultFutureV2<SearchAutoCompleteRespModel> autoComplete(
      SearchAutoCompleteReqModel requestModel) async {
    try {
      return await ApiClientV2().post<SearchAutoCompleteRespModel>(
        url: URLManager.baseUrl,
        body: requestModel.toJson(),
        converter: (json) => SearchAutoCompleteRespModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }


  @override
  ResultFutureV2<GetPropertyListRespModel> getPropertyList(
      GetPropertyListReqModel requestModel) async {
    try {
      return await ApiClientV2().post<GetPropertyListRespModel>(
        url: URLManager.baseUrl,
        body: requestModel.toJson(),
        converter: (json) => GetPropertyListRespModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  ResultFutureV2<GetSearchResultRespModel> getSearchResults(
      GetSearchResultReqModel requestModel) async {
    try {
      return await ApiClientV2().post<GetSearchResultRespModel>(
        url: URLManager.baseUrl,
        body: requestModel.toJson(),
        converter: (json) => GetSearchResultRespModel.fromJson(json),
      );
    } catch (e) {
      rethrow;
    }
  }

}
