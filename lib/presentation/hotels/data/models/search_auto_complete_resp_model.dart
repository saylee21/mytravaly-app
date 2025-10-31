class SearchAutoCompleteRespModel {
  final bool status;
  final String message;
  final int responseCode;
  final SearchAutoCompleteData? data;

  SearchAutoCompleteRespModel({
    required this.status,
    required this.message,
    required this.responseCode,
    this.data,
  });

  factory SearchAutoCompleteRespModel.fromJson(Map<String, dynamic> json) {
    return SearchAutoCompleteRespModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      responseCode: json['responseCode'] ?? 0,
      data: json['data'] != null
          ? SearchAutoCompleteData.fromJson(json['data'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'responseCode': responseCode,
      'data': data?.toJson(),
    };
  }
}

class SearchAutoCompleteData {
  final bool present;
  final int totalNumberOfResult;
  final AutoCompleteList autoCompleteList;

  SearchAutoCompleteData({
    required this.present,
    required this.totalNumberOfResult,
    required this.autoCompleteList,
  });

  factory SearchAutoCompleteData.fromJson(Map<String, dynamic> json) {
    return SearchAutoCompleteData(
      present: json['present'] ?? false,
      totalNumberOfResult: json['totalNumberOfResult'] ?? 0,
      autoCompleteList: AutoCompleteList.fromJson(json['autoCompleteList']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'present': present,
      'totalNumberOfResult': totalNumberOfResult,
      'autoCompleteList': autoCompleteList.toJson(),
    };
  }
}

class AutoCompleteList {
  final SearchCategory byPropertyName;
  final SearchCategory byStreet;
  final SearchCategory byCity;
  final SearchCategory byState;
  final SearchCategory byCountry;

  AutoCompleteList({
    required this.byPropertyName,
    required this.byStreet,
    required this.byCity,
    required this.byState,
    required this.byCountry,
  });

  factory AutoCompleteList.fromJson(Map<String, dynamic> json) {
    return AutoCompleteList(
      byPropertyName: SearchCategory.fromJson(json['byPropertyName'] ?? {}),
      byStreet: SearchCategory.fromJson(json['byStreet'] ?? {}),
      byCity: SearchCategory.fromJson(json['byCity'] ?? {}),
      byState: SearchCategory.fromJson(json['byState'] ?? {}),
      byCountry: SearchCategory.fromJson(json['byCountry'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'byPropertyName': byPropertyName.toJson(),
      'byStreet': byStreet.toJson(),
      'byCity': byCity.toJson(),
      'byState': byState.toJson(),
      'byCountry': byCountry.toJson(),
    };
  }
}

class SearchCategory {
  final bool present;
  final List<SearchResult> listOfResult;
  final int numberOfResult;

  SearchCategory({
    required this.present,
    required this.listOfResult,
    required this.numberOfResult,
  });

  factory SearchCategory.fromJson(Map<String, dynamic> json) {
    return SearchCategory(
      present: json['present'] ?? false,
      listOfResult: json['listOfResult'] != null
          ? (json['listOfResult'] as List)
          .map((item) => SearchResult.fromJson(item))
          .toList()
          : [],
      numberOfResult: json['numberOfResult'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'present': present,
      'listOfResult': listOfResult.map((item) => item.toJson()).toList(),
      'numberOfResult': numberOfResult,
    };
  }
}

class SearchResult {
  final String valueToDisplay;
  final String? propertyName;
  final Address address;
  final SearchArray searchArray;

  SearchResult({
    required this.valueToDisplay,
    this.propertyName,
    required this.address,
    required this.searchArray,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    return SearchResult(
      valueToDisplay: json['valueToDisplay'] ?? '',
      propertyName: json['propertyName'],
      address: Address.fromJson(json['address'] ?? {}),
      searchArray: SearchArray.fromJson(json['searchArray'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'valueToDisplay': valueToDisplay,
      if (propertyName != null) 'propertyName': propertyName,
      'address': address.toJson(),
      'searchArray': searchArray.toJson(),
    };
  }
}

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? country;

  Address({
    this.street,
    this.city,
    this.state,
    this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (street != null) 'street': street,
      if (city != null) 'city': city,
      if (state != null) 'state': state,
      if (country != null) 'country': country,
    };
  }
}

class SearchArray {
  final String type;
  final List<String> query;

  SearchArray({
    required this.type,
    required this.query,
  });

  factory SearchArray.fromJson(Map<String, dynamic> json) {
    return SearchArray(
      type: json['type'] ?? '',
      query: json['query'] != null
          ? List<String>.from(json['query'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'query': query,
    };
  }
}