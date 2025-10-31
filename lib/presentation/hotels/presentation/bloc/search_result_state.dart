// presentation/hotels/presentation/bloc/search_result_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/get_search_results_resp_model.dart';

sealed class HotelSearchState extends Equatable {
  const HotelSearchState();

  @override
  List<Object?> get props => [];
}

class HotelSearchInitial extends HotelSearchState {}

class HotelSearchLoading extends HotelSearchState {}

class HotelSearchLoadingMore extends HotelSearchState {
  final List<HotelSearchResult> hotels;

  const HotelSearchLoadingMore({required this.hotels});

  @override
  List<Object?> get props => [hotels];
}

class HotelSearchLoaded extends HotelSearchState {
  final List<HotelSearchResult> hotels;
  final bool hasMore;

  const HotelSearchLoaded({
    required this.hotels,
    required this.hasMore,
  });

  @override
  List<Object?> get props => [hotels, hasMore];
}

class HotelSearchEmpty extends HotelSearchState {
  final String message;

  const HotelSearchEmpty(this.message);

  @override
  List<Object?> get props => [message];
}

class HotelSearchError extends HotelSearchState {
  final String message;

  const HotelSearchError(this.message);

  @override
  List<Object?> get props => [message];
}