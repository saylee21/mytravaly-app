import 'package:equatable/equatable.dart';
import '../../data/models/search_auto_complete_resp_model.dart';

sealed class HotelSearchEvent extends Equatable {
  const HotelSearchEvent();
  @override
  List<Object?> get props => [];
}

class LoadSearchResults extends HotelSearchEvent {
  final SearchResult location;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;

  const LoadSearchResults({
    required this.location,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
  });

  @override
  List<Object?> get props => [location, checkIn, checkOut, adults, children];
}

class LoadMoreResults extends HotelSearchEvent {}

class RetrySearch extends HotelSearchEvent {}