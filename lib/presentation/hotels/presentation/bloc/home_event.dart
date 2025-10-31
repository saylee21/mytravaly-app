import 'package:equatable/equatable.dart';

import '../../data/models/search_auto_complete_resp_model.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object?> get props => [];
}

class LoadPopularStays extends HomeEvent {
  final String searchType; // byCity, byState, byCountry, byRandom
  final String? country;
  final String? state;
  final String? city;
  final String entityType; // hotel, resort, Home Stay, Camp_sites/tent, Any
  final int limit;

  const LoadPopularStays({
    this.searchType = 'byRandom',
    this.country = '',
    this.state = '',
    this.city = '',
    this.entityType = 'Any',
    this.limit = 10,
  });

  @override
  List<Object?> get props => [searchType, country, state, city, entityType, limit];
}

class SearchProperties extends HomeEvent {
  final String query;

  const SearchProperties(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends HomeEvent {
  const ClearSearch();
}

class RefreshProperties extends HomeEvent {
  const RefreshProperties();
}

// presentation/home/bloc/home/home_event.dart  (add at bottom)
class SearchSelected extends HomeEvent {
  final SearchResult result;
  const SearchSelected(this.result);
  @override
  List<Object?> get props => [result];
}

class CheckInChanged extends HomeEvent {
  final DateTime date;
  const CheckInChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class CheckOutChanged extends HomeEvent {
  final DateTime date;
  const CheckOutChanged(this.date);
  @override
  List<Object?> get props => [date];
}

class GuestsChanged extends HomeEvent {
  final int adults;
  final int children;
  const GuestsChanged(this.adults, this.children);
  @override
  List<Object?> get props => [adults, children];
}

// Add to home_event.dart
class PerformSearch extends HomeEvent {
  final SearchResult location;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;

  const PerformSearch({
    required this.location,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
  });

  @override
  List<Object?> get props => [location, checkIn, checkOut, adults, children];
}