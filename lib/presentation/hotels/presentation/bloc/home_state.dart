import 'package:equatable/equatable.dart';
import '../../data/models/get_property_list_resp_model.dart';
import '../../data/models/get_search_results_resp_model.dart';
import '../../data/models/search_auto_complete_resp_model.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeRefreshing extends HomeState {
  final List<Property> currentProperties;

  const HomeRefreshing(this.currentProperties);

  @override
  List<Object?> get props => [currentProperties];
}

class HomeLoaded extends HomeState {
  final List<Property> properties;
  final List<Property> filteredProperties;
  final bool isSearching;

  final DateTime? checkIn;
  final DateTime? checkOut;
  final int adults;
  final int children;
  final SearchResult? selectedLocation;

  const HomeLoaded({
    required this.properties,
    required this.filteredProperties,
    this.isSearching = false,
    this.checkIn,
    this.checkOut,
    this.adults = 2,
    this.children = 0,
    this.selectedLocation,
  });

  HomeLoaded copyWith({
    List<Property>? properties,
    List<Property>? filteredProperties,
    bool? isSearching,
    DateTime? checkIn,
    DateTime? checkOut,
    int? adults,
    int? children,
    SearchResult? selectedLocation,
  }) {
    return HomeLoaded(
      properties: properties ?? this.properties,
      filteredProperties: filteredProperties ?? this.filteredProperties,
      isSearching: isSearching ?? this.isSearching,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      adults: adults ?? this.adults,
      children: children ?? this.children,
      selectedLocation: selectedLocation ?? this.selectedLocation,
    );
  }

  @override
  List<Object?> get props => [
    properties,
    filteredProperties,
    isSearching,
    checkIn,
    checkOut,
    adults,
    children,
    selectedLocation,
  ];
}

class HomeError extends HomeState {
  final String message;
  final List<Property>? previousProperties;

  const HomeError(this.message, {this.previousProperties});

  @override
  List<Object?> get props => [message, previousProperties];
}

class HomeEmpty extends HomeState {
  final String message;

  const HomeEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

class SearchLoading extends HomeState {}

class SearchLoaded extends HomeState {
  final List<HotelSearchResult> hotels;
  final List<String> excludedHotels;
  const SearchLoaded({required this.hotels, required this.excludedHotels});
  @override
  List<Object?> get props => [hotels, excludedHotels];
}

class SearchEmpty extends HomeState {
  final String message;
  const SearchEmpty(this.message);
  @override
  List<Object?> get props => [message];
}

class SearchError extends HomeState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object?> get props => [message];
}