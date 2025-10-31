class GetSearchResultRespModel {
  final bool status;
  final String message;
  final int responseCode;
  final SearchResultData? data;

  GetSearchResultRespModel({
    required this.status,
    required this.message,
    required this.responseCode,
    this.data,
  });

  factory GetSearchResultRespModel.fromJson(Map<String, dynamic> json) {
    return GetSearchResultRespModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      responseCode: json['responseCode'] ?? 0,
      data: json['data'] != null
          ? SearchResultData.fromJson(json['data'])
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

class SearchResultData {
  final List<HotelSearchResult> arrayOfHotelList;
  final List<String> arrayOfExcludedHotels;
  final List<String> arrayOfExcludedSearchType;

  SearchResultData({
    required this.arrayOfHotelList,
    required this.arrayOfExcludedHotels,
    required this.arrayOfExcludedSearchType,
  });

  factory SearchResultData.fromJson(Map<String, dynamic> json) {
    return SearchResultData(
      arrayOfHotelList: json['arrayOfHotelList'] != null
          ? (json['arrayOfHotelList'] as List)
          .map((item) => HotelSearchResult.fromJson(item))
          .toList()
          : [],
      arrayOfExcludedHotels: json['arrayOfExcludedHotels'] != null
          ? List<String>.from(json['arrayOfExcludedHotels'])
          : [],
      arrayOfExcludedSearchType: json['arrayOfExcludedSearchType'] != null
          ? List<String>.from(json['arrayOfExcludedSearchType'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'arrayOfHotelList':
      arrayOfHotelList.map((item) => item.toJson()).toList(),
      'arrayOfExcludedHotels': arrayOfExcludedHotels,
      'arrayOfExcludedSearchType': arrayOfExcludedSearchType,
    };
  }
}

class HotelSearchResult {
  final String propertyCode;
  final String propertyName;
  final PropertyImage propertyImage;
  final String propertytype;
  final int propertyStar;
  final PropertyPoliciesAndAmenities propertyPoliciesAndAmmenities;
  final PropertyAddress propertyAddress;
  final String propertyUrl;
  final String roomName;
  final int numberOfAdults;
  final PriceInfo markedPrice;
  final PriceInfo propertyMaxPrice;
  final PriceInfo propertyMinPrice;
  final List<AvailableDeal> availableDeals;
  final SubscriptionStatus subscriptionStatus;
  final int propertyView;
  final bool isFavorite;
  final SimplPriceList simplPriceList;
  final GoogleReview googleReview;

  HotelSearchResult({
    required this.propertyCode,
    required this.propertyName,
    required this.propertyImage,
    required this.propertytype,
    required this.propertyStar,
    required this.propertyPoliciesAndAmmenities,
    required this.propertyAddress,
    required this.propertyUrl,
    required this.roomName,
    required this.numberOfAdults,
    required this.markedPrice,
    required this.propertyMaxPrice,
    required this.propertyMinPrice,
    required this.availableDeals,
    required this.subscriptionStatus,
    required this.propertyView,
    required this.isFavorite,
    required this.simplPriceList,
    required this.googleReview,
  });

  factory HotelSearchResult.fromJson(Map<String, dynamic> json) {
    return HotelSearchResult(
      propertyCode: json['propertyCode'] ?? '',
      propertyName: json['propertyName'] ?? '',
      propertyImage: PropertyImage.fromJson(json['propertyImage'] ?? {}),
      propertytype: json['propertytype'] ?? '',
      propertyStar: json['propertyStar'] ?? 0,
      propertyPoliciesAndAmmenities: PropertyPoliciesAndAmenities.fromJson(
          json['propertyPoliciesAndAmmenities'] ?? {}),
      propertyAddress: PropertyAddress.fromJson(json['propertyAddress'] ?? {}),
      propertyUrl: json['propertyUrl'] ?? '',
      roomName: json['roomName'] ?? '',
      numberOfAdults: json['numberOfAdults'] ?? 0,
      markedPrice: PriceInfo.fromJson(json['markedPrice'] ?? {}),
      propertyMaxPrice: PriceInfo.fromJson(json['propertyMaxPrice'] ?? {}),
      propertyMinPrice: PriceInfo.fromJson(json['propertyMinPrice'] ?? {}),
      availableDeals: json['availableDeals'] != null
          ? (json['availableDeals'] as List)
          .map((item) => AvailableDeal.fromJson(item))
          .toList()
          : [],
      subscriptionStatus:
      SubscriptionStatus.fromJson(json['subscriptionStatus'] ?? {}),
      propertyView: json['propertyView'] ?? 0,
      isFavorite: json['isFavorite'] ?? false,
      simplPriceList: SimplPriceList.fromJson(json['simplPriceList'] ?? {}),
      googleReview: GoogleReview.fromJson(json['googleReview'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'propertyCode': propertyCode,
      'propertyName': propertyName,
      'propertyImage': propertyImage.toJson(),
      'propertytype': propertytype,
      'propertyStar': propertyStar,
      'propertyPoliciesAndAmmenities': propertyPoliciesAndAmmenities.toJson(),
      'propertyAddress': propertyAddress.toJson(),
      'propertyUrl': propertyUrl,
      'roomName': roomName,
      'numberOfAdults': numberOfAdults,
      'markedPrice': markedPrice.toJson(),
      'propertyMaxPrice': propertyMaxPrice.toJson(),
      'propertyMinPrice': propertyMinPrice.toJson(),
      'availableDeals': availableDeals.map((item) => item.toJson()).toList(),
      'subscriptionStatus': subscriptionStatus.toJson(),
      'propertyView': propertyView,
      'isFavorite': isFavorite,
      'simplPriceList': simplPriceList.toJson(),
      'googleReview': googleReview.toJson(),
    };
  }
}

class PropertyImage {
  final String fullUrl;
  final String location;
  final String imageName;

  PropertyImage({
    required this.fullUrl,
    required this.location,
    required this.imageName,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      fullUrl: json['fullUrl'] ?? '',
      location: json['location'] ?? '',
      imageName: json['imageName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullUrl': fullUrl,
      'location': location,
      'imageName': imageName,
    };
  }
}

class PropertyPoliciesAndAmenities {
  final bool present;
  final PolicyData? data;

  PropertyPoliciesAndAmenities({
    required this.present,
    this.data,
  });

  factory PropertyPoliciesAndAmenities.fromJson(Map<String, dynamic> json) {
    return PropertyPoliciesAndAmenities(
      present: json['present'] ?? false,
      data: json['data'] != null ? PolicyData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'present': present,
      'data': data?.toJson(),
    };
  }
}

class PolicyData {
  final String cancelPolicy;
  final String refundPolicy;
  final String childPolicy;
  final String damagePolicy;
  final String propertyRestriction;
  final bool petsAllowed;
  final bool coupleFriendly;
  final bool suitableForChildren;
  final bool bachularsAllowed;
  final bool freeWifi;
  final bool freeCancellation;
  final bool payAtHotel;
  final bool payNow;
  final String lastUpdatedOn;

  PolicyData({
    required this.cancelPolicy,
    required this.refundPolicy,
    required this.childPolicy,
    required this.damagePolicy,
    required this.propertyRestriction,
    required this.petsAllowed,
    required this.coupleFriendly,
    required this.suitableForChildren,
    required this.bachularsAllowed,
    required this.freeWifi,
    required this.freeCancellation,
    required this.payAtHotel,
    required this.payNow,
    required this.lastUpdatedOn,
  });

  factory PolicyData.fromJson(Map<String, dynamic> json) {
    return PolicyData(
      cancelPolicy: json['cancelPolicy'] ?? '',
      refundPolicy: json['refundPolicy'] ?? '',
      childPolicy: json['childPolicy'] ?? '',
      damagePolicy: json['damagePolicy'] ?? '',
      propertyRestriction: json['propertyRestriction'] ?? '',
      petsAllowed: json['petsAllowed'] ?? false,
      coupleFriendly: json['coupleFriendly'] ?? false,
      suitableForChildren: json['suitableForChildren'] ?? false,
      bachularsAllowed: json['bachularsAllowed'] ?? false,
      freeWifi: json['freeWifi'] ?? false,
      freeCancellation: json['freeCancellation'] ?? false,
      payAtHotel: json['payAtHotel'] ?? false,
      payNow: json['payNow'] ?? false,
      lastUpdatedOn: json['lastUpdatedOn'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cancelPolicy': cancelPolicy,
      'refundPolicy': refundPolicy,
      'childPolicy': childPolicy,
      'damagePolicy': damagePolicy,
      'propertyRestriction': propertyRestriction,
      'petsAllowed': petsAllowed,
      'coupleFriendly': coupleFriendly,
      'suitableForChildren': suitableForChildren,
      'bachularsAllowed': bachularsAllowed,
      'freeWifi': freeWifi,
      'freeCancellation': freeCancellation,
      'payAtHotel': payAtHotel,
      'payNow': payNow,
      'lastUpdatedOn': lastUpdatedOn,
    };
  }
}

class PropertyAddress {
  final String street;
  final String city;
  final String state;
  final String country;
  final String zipcode;
  final String mapAddress;
  final double latitude;
  final double longitude;

  PropertyAddress({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.zipcode,
    required this.mapAddress,
    required this.latitude,
    required this.longitude,
  });

  factory PropertyAddress.fromJson(Map<String, dynamic> json) {
    return PropertyAddress(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      zipcode: json['zipcode'] ?? '',
      mapAddress: json['mapAddress'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'zipcode': zipcode,
      'mapAddress': mapAddress,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

class PriceInfo {
  final double amount;
  final String displayAmount;
  final String currencyAmount;
  final String currencySymbol;

  PriceInfo({
    required this.amount,
    required this.displayAmount,
    required this.currencyAmount,
    required this.currencySymbol,
  });

  factory PriceInfo.fromJson(Map<String, dynamic> json) {
    return PriceInfo(
      amount: (json['amount'] ?? 0).toDouble(),
      displayAmount: json['displayAmount'] ?? '',
      currencyAmount: json['currencyAmount'] ?? '',
      currencySymbol: json['currencySymbol'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'amount': amount,
      'displayAmount': displayAmount,
      'currencyAmount': currencyAmount,
      'currencySymbol': currencySymbol,
    };
  }
}

class AvailableDeal {
  final String headerName;
  final String websiteUrl;
  final String dealType;
  final PriceInfo price;

  AvailableDeal({
    required this.headerName,
    required this.websiteUrl,
    required this.dealType,
    required this.price,
  });

  factory AvailableDeal.fromJson(Map<String, dynamic> json) {
    return AvailableDeal(
      headerName: json['headerName'] ?? '',
      websiteUrl: json['websiteUrl'] ?? '',
      dealType: json['dealType'] ?? '',
      price: PriceInfo.fromJson(json['price'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'headerName': headerName,
      'websiteUrl': websiteUrl,
      'dealType': dealType,
      'price': price.toJson(),
    };
  }
}

class SubscriptionStatus {
  final bool status;

  SubscriptionStatus({
    required this.status,
  });

  factory SubscriptionStatus.fromJson(Map<String, dynamic> json) {
    return SubscriptionStatus(
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
    };
  }
}

class SimplPriceList {
  final PriceInfo simplPrice;
  final double originalPrice;

  SimplPriceList({
    required this.simplPrice,
    required this.originalPrice,
  });

  factory SimplPriceList.fromJson(Map<String, dynamic> json) {
    return SimplPriceList(
      simplPrice: PriceInfo.fromJson(json['simplPrice'] ?? {}),
      originalPrice: (json['originalPrice'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'simplPrice': simplPrice.toJson(),
      'originalPrice': originalPrice,
    };
  }
}

class GoogleReview {
  final bool reviewPresent;
  final ReviewData? data;

  GoogleReview({
    required this.reviewPresent,
    this.data,
  });

  factory GoogleReview.fromJson(Map<String, dynamic> json) {
    return GoogleReview(
      reviewPresent: json['reviewPresent'] ?? false,
      data: json['data'] != null ? ReviewData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewPresent': reviewPresent,
      'data': data?.toJson(),
    };
  }
}

class ReviewData {
  final double overallRating;
  final int totalUserRating;
  final int withoutDecimal;

  ReviewData({
    required this.overallRating,
    required this.totalUserRating,
    required this.withoutDecimal,
  });

  factory ReviewData.fromJson(Map<String, dynamic> json) {
    return ReviewData(
      overallRating: (json['overallRating'] ?? 0).toDouble(),
      totalUserRating: json['totalUserRating'] ?? 0,
      withoutDecimal: json['withoutDecimal'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overallRating': overallRating,
      'totalUserRating': totalUserRating,
      'withoutDecimal': withoutDecimal,
    };
  }
}