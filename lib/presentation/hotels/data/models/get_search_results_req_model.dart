class GetSearchResultReqModel {
  final String action;
  final GetSearchResultListOfHotels getSearchResultListOfHotels;

  GetSearchResultReqModel({
    this.action = 'getSearchResultListOfHotels',
    required this.getSearchResultListOfHotels,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'getSearchResultListOfHotels': getSearchResultListOfHotels.toJson(),
    };
  }
}

class GetSearchResultListOfHotels {
  final SearchCriteria searchCriteria;

  GetSearchResultListOfHotels({
    required this.searchCriteria,
  });

  Map<String, dynamic> toJson() {
    return {
      'searchCriteria': searchCriteria.toJson(),
    };
  }
}

class SearchCriteria {
  final String checkIn;
  final String checkOut;
  final int rooms;
  final int adults;
  final int children;
  final String searchType;
  final List<String> searchQuery;
  final List<String> accommodation;
  final List<String> arrayOfExcludedSearchType;
  final String highPrice;
  final String lowPrice;
  final int limit;
  final List<String> preloaderList;
  final String currency;
  final int rid;

  SearchCriteria({
    required this.checkIn,
    required this.checkOut,
    required this.rooms,
    required this.adults,
    this.children = 0,
    required this.searchType,
    required this.searchQuery,
    this.accommodation = const ['all'],
    this.arrayOfExcludedSearchType = const [],
    this.highPrice = '3000000',
    this.lowPrice = '0',
    this.limit = 5,
    this.preloaderList = const [],
    this.currency = 'INR',
    this.rid = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'checkIn': checkIn,
      'checkOut': checkOut,
      'rooms': rooms,
      'adults': adults,
      'children': children,
      'searchType': searchType,
      'searchQuery': searchQuery,
      'accommodation': accommodation,
      'arrayOfExcludedSearchType': arrayOfExcludedSearchType,
      'highPrice': highPrice,
      'lowPrice': lowPrice,
      'limit': limit,
      'preloaderList': preloaderList,
      'currency': currency,
      'rid': rid,
    };
  }
}