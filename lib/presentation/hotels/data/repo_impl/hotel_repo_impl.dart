import 'package:mytravaly_assignment/presentation/hotels/data/datasources/hotel_datasource.dart';

import '../../../../core/utils/typedef.dart';
import '../../domain/repo/hotel_repo.dart';
import '../models/get_property_list_req_model.dart';
import '../models/get_property_list_resp_model.dart';
import '../models/get_search_results_req_model.dart';
import '../models/get_search_results_resp_model.dart';
import '../models/search_auto_complete_req_model.dart';
import '../models/search_auto_complete_resp_model.dart';


class HotelRepoImpl implements HotelRepo {
  final HotelDatasource _remoteDataSource;

  const HotelRepoImpl(this._remoteDataSource);

  @override
  ResultFutureV2<SearchAutoCompleteRespModel> autoComplete(
      SearchAutoCompleteReqModel request) async {
    try {
      final result = await _remoteDataSource.autoComplete(request);
      return result;
    } catch (e) {
      rethrow;
    }
  }


  @override
  ResultFutureV2<GetPropertyListRespModel> getPropertyList(
      GetPropertyListReqModel request) async {
    try {
      final result = await _remoteDataSource.getPropertyList(request);
      return result;
    } catch (e) {
      rethrow;
    }
  }



  @override
  ResultFutureV2<GetSearchResultRespModel> getSearchResults(
      GetSearchResultReqModel request) async {
    try {
      final result = await _remoteDataSource.getSearchResults(request);
      return result;
    } catch (e) {
      rethrow;
    }
  }


}
