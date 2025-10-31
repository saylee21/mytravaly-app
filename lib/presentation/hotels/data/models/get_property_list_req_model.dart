class GetPropertyListReqModel {
  final String action;
  final PopularStay popularStay;

  GetPropertyListReqModel({
    this.action = 'popularStay',
    required this.popularStay,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'popularStay': popularStay.toJson(),
    };
  }
}

class PopularStay {
  final int limit;
  final String entityType;
  final PropertyFilter filter;
  final String currency;

  PopularStay({
    this.limit = 10,
    this.entityType = 'Any',
    required this.filter,
    this.currency = 'INR',
  });

  Map<String, dynamic> toJson() {
    return {
      'limit': limit,
      'entityType': entityType,
      'filter': filter.toJson(),
      'currency': currency,
    };
  }
}

class PropertyFilter {
  final String searchType;
  final SearchTypeInfo searchTypeInfo;

  PropertyFilter({
    required this.searchType,
    required this.searchTypeInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'searchType': searchType,
      'searchTypeInfo': searchTypeInfo.toJson(),
    };
  }
}

class SearchTypeInfo {
  final String? country;
  final String? state;
  final String? city;

  SearchTypeInfo({
    this.country,
    this.state,
    this.city,
  });

  Map<String, dynamic> toJson() {
    return {
      if (country != null) 'country': country,
      if (state != null) 'state': state,
      if (city != null) 'city': city,
    };
  }
}