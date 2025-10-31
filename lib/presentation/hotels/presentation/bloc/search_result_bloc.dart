import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mytravaly_assignment/core/network/api_client.dart';
import '../../../../core/network/network_info.dart';
import '../../data/models/get_search_results_req_model.dart';
import '../../data/models/get_search_results_resp_model.dart';
import '../../domain/entities/search_params.dart';
import '../../domain/usecases/get_search_result_use_case.dart';
import 'search_result_event.dart';
import 'search_result_state.dart';

class HotelSearchBloc extends Bloc<HotelSearchEvent, HotelSearchState> {
  final GetSearchResultUseCase _useCase;
  final int _pageSize = 5; // ✅ Changed from 10 to 5
  int _currentPage = 0;
  List<HotelSearchResult> _allHotels = [];
  List<String> _excludedHotels = [];
  bool _hasMore = true;
  late SearchParams _lastParams;

  HotelSearchBloc(this._useCase) : super(HotelSearchInitial()) {
    on<LoadSearchResults>(_onLoad);
    on<LoadMoreResults>(_onLoadMore);
    on<RetrySearch>(_onRetry);
  }

  Future<void> _onLoad(
      LoadSearchResults event,
      Emitter<HotelSearchState> emit,
      ) async {
    emit(HotelSearchLoading());

    // Reset pagination state
    _currentPage = 0;
    _allHotels.clear();
    _excludedHotels.clear();
    _hasMore = true;

    // Store search params for retry/pagination
    _lastParams = SearchParams(
      location: event.location,
      checkIn: event.checkIn,
      checkOut: event.checkOut,
      adults: event.adults,
      children: event.children,
    );

    final result = await _fetchPage(_currentPage);

    result.fold(
          (failure) => emit(HotelSearchError(failure.userFriendlyMessage)),
          (resp) {
        final hotels = resp.data?.arrayOfHotelList ?? [];
        final excluded = resp.data?.arrayOfExcludedHotels ?? [];

        _allHotels = hotels;
        _excludedHotels = excluded;
        _hasMore = hotels.length >= _pageSize;

        if (hotels.isEmpty) {
          emit(const HotelSearchEmpty('No hotels found for your search criteria'));
        } else {
          emit(HotelSearchLoaded(hotels: _allHotels, hasMore: _hasMore));
        }
      },
    );
  }

  Future<void> _onLoadMore(
      LoadMoreResults event,
      Emitter<HotelSearchState> emit,
      ) async {
    // Prevent duplicate calls
    if (!_hasMore || state is HotelSearchLoadingMore) return;

    emit(HotelSearchLoadingMore(hotels: _allHotels));

    _currentPage++;
    final result = await _fetchPage(_currentPage);

    result.fold(
          (failure) {
        // On error, stay on current page and show loaded data
        emit(HotelSearchLoaded(hotels: _allHotels, hasMore: false));
      },
          (resp) {
        final newHotels = resp.data?.arrayOfHotelList ?? [];
        final newExcluded = resp.data?.arrayOfExcludedHotels ?? [];

        _allHotels.addAll(newHotels);
        _excludedHotels.addAll(newExcluded);
        _hasMore = newHotels.length >= _pageSize;

        emit(HotelSearchLoaded(hotels: _allHotels, hasMore: _hasMore));
      },
    );
  }

  Future<void> _onRetry(RetrySearch event, Emitter<HotelSearchState> emit) async {
    add(LoadSearchResults(
      location: _lastParams.location,
      checkIn: _lastParams.checkIn,
      checkOut: _lastParams.checkOut,
      adults: _lastParams.adults,
      children: _lastParams.children,
    ));
  }

  // ✅ FIXED: Now uses dynamic values from selected location
  Future<Either<FailureV2, GetSearchResultRespModel>> _fetchPage(int page) async {
    final req = GetSearchResultReqModel(
      getSearchResultListOfHotels: GetSearchResultListOfHotels(
        searchCriteria: SearchCriteria(
          checkIn: _formatDate(_lastParams.checkIn),
          checkOut: _formatDate(_lastParams.checkOut),
          rooms: _calculateRooms(_lastParams.adults, _lastParams.children),
          adults: _lastParams.adults,
          children: _lastParams.children,

          // ✅ DYNAMIC: Use searchArray from selected location
          searchType: _lastParams.location.searchArray.type,
          searchQuery: _lastParams.location.searchArray.query,

          accommodation: ['all', 'hotel'],
          arrayOfExcludedSearchType: ['street'],
          highPrice: '3000000',
          lowPrice: '0',
          limit: 5, // ✅ Always 5
          preloaderList: _excludedHotels,
          currency: 'INR',
          rid: page * _pageSize, // ✅ Pagination offset: 0, 5, 10, 15...
        ),
      ),
    );

    return await _useCase(req);
  }

  // ── HELPER METHODS ──

  /// Format date to YYYY-MM-DD
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Calculate number of rooms needed (1 room per 2 people)
  int _calculateRooms(int adults, int children) {
    final totalGuests = adults + children;
    return (totalGuests / 2).ceil().clamp(1, 10); // Min 1, Max 10 rooms
  }

  @override
  Future<void> close() {
    _allHotels.clear();
    _excludedHotels.clear();
    return super.close();
  }
}