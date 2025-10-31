import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mytravaly_assignment/core/network/api_client.dart';
import '../../data/models/get_property_list_req_model.dart';
import '../../data/models/get_search_results_req_model.dart';
import '../../domain/usecases/get_property_list_use_case.dart';
import '../../domain/usecases/get_search_result_use_case.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetPropertyListUseCase getPropertyListUseCase;
  final GetSearchResultUseCase getSearchResultUseCase;

  HomeBloc(
      this.getPropertyListUseCase,
      this.getSearchResultUseCase,
      ) : super(const HomeInitial()) {
    on<LoadPopularStays>(_onLoadPopularStays);
    on<SearchProperties>(_onSearchProperties);
    on<ClearSearch>(_onClearSearch);
    on<RefreshProperties>(_onRefreshProperties);
    on<CheckInChanged>(_onCheckInChanged);
    on<CheckOutChanged>(_onCheckOutChanged);
    on<GuestsChanged>(_onGuestsChanged);
    on<PerformSearch>(_onPerformSearch);
    on<SearchSelected>(_onSearchSelected);
  }

  Future<void> _onLoadPopularStays(
      LoadPopularStays event,
      Emitter<HomeState> emit,
      ) async {
    emit(const HomeLoading());

    try {
      final requestModel = GetPropertyListReqModel(
        popularStay: PopularStay(
          limit: event.limit > 10 ? 10 : event.limit, // Ensure max 10
          entityType: event.entityType,
          filter: PropertyFilter(
            searchType: event.searchType,
            searchTypeInfo: SearchTypeInfo(
              country: event.country,
              state: event.state,
              city: event.city,
            ),
          ),
        ),
      );

      final result = await getPropertyListUseCase(requestModel);

      result.fold(
            (failure) {
          emit(HomeError(failure.userFriendlyMessage));
        },
            (response) {
          if (response.data != null && response.data!.isNotEmpty) {
            emit(HomeLoaded(
              properties: response.data!,
              filteredProperties: response.data!,
            ));
          } else {
            emit(const HomeEmpty('No properties found in this location'));
          }
        },
      );
    } catch (e) {
      emit(HomeError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshProperties(
      RefreshProperties event,
      Emitter<HomeState> emit,
      ) async {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(HomeRefreshing(currentState.properties));
      add(const LoadPopularStays());
    } else {
      add(const LoadPopularStays());
    }
  }

  void _onSearchProperties(
      SearchProperties event,
      Emitter<HomeState> emit,
      ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      final query = event.query.toLowerCase().trim();

      if (query.isEmpty) {
        emit(currentState.copyWith(
          filteredProperties: currentState.properties,
          isSearching: false,
        ));
        return;
      }

      final filteredProperties = currentState.properties.where((property) {
        final propertyName = property.propertyName.toLowerCase();
        final city = property.propertyAddress.city.toLowerCase();
        final state = property.propertyAddress.state.toLowerCase();
        final country = property.propertyAddress.country.toLowerCase();
        final propertyType = property.propertyType.toLowerCase();

        return propertyName.contains(query) ||
            city.contains(query) ||
            state.contains(query) ||
            country.contains(query) ||
            propertyType.contains(query);
      }).toList();

      emit(currentState.copyWith(
        filteredProperties: filteredProperties,
        isSearching: true,
      ));
    }
  }

  void _onClearSearch(
      ClearSearch event,
      Emitter<HomeState> emit,
      ) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(
        filteredProperties: currentState.properties,
        isSearching: false,
      ));
    }
  }

  void _onCheckInChanged(CheckInChanged event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final cur = state as HomeLoaded;
      final newCheckOut = cur.checkOut;

      // If new check-in is after current check-out, adjust check-out
      if (newCheckOut != null && event.date.isAfter(newCheckOut)) {
        emit(cur.copyWith(
          checkIn: event.date,
          checkOut: event.date.add(const Duration(days: 1)),
        ));
      } else {
        emit(cur.copyWith(checkIn: event.date));
      }
    }
  }

  void _onCheckOutChanged(CheckOutChanged event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final cur = state as HomeLoaded;
      final newCheckIn = cur.checkIn ?? DateTime.now();

      // If new check-out is before check-in, adjust it
      if (event.date.isBefore(newCheckIn)) {
        emit(cur.copyWith(
          checkOut: newCheckIn.add(const Duration(days: 1)),
        ));
      } else {
        emit(cur.copyWith(checkOut: event.date));
      }
    }
  }

  void _onGuestsChanged(GuestsChanged event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      emit((state as HomeLoaded).copyWith(
        adults: event.adults,
        children: event.children,
      ));
    }
  }

  Future<void> _onPerformSearch(
      PerformSearch event,
      Emitter<HomeState> emit,
      ) async {
    emit(const HomeLoading());

    try {
      final req = GetSearchResultReqModel(
        getSearchResultListOfHotels: GetSearchResultListOfHotels(
          searchCriteria: SearchCriteria(
            checkIn: _formatDate(event.checkIn),
            checkOut: _formatDate(event.checkOut),
            rooms: 1,
            adults: event.adults,
            children: event.children,
            searchType: _mapToSearchType(event.location.searchArray.type),
            searchQuery: [event.location.valueToDisplay],
            limit: 10, // FIXED: Changed from 20 to 10
          ),
        ),
      );

      final result = await getSearchResultUseCase(req);

      result.fold(
            (failure) => emit(SearchError(failure.userFriendlyMessage)),
            (response) {
          if (response.data != null &&
              response.data!.arrayOfHotelList.isNotEmpty) {
            emit(SearchLoaded(
              hotels: response.data!.arrayOfHotelList,
              excludedHotels: response.data!.arrayOfExcludedHotels,
            ));
          } else {
            emit(const SearchEmpty('No hotels found for your search'));
          }
        },
      );
    } catch (e) {
      emit(SearchError('An unexpected error occurred: ${e.toString()}'));
    }
  }

  // Helper methods
  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  String _mapToSearchType(String type) {
    final lower = type.toLowerCase();
    if (lower.contains('city')) return 'citySearch';
    if (lower.contains('state')) return 'stateSearch';
    if (lower.contains('country')) return 'countrySearch';
    if (lower.contains('hotel') || lower.contains('property')) {
      return 'hotelIdSearch';
    }
    return 'citySearch'; // Default fallback
  }

  void _onSearchSelected(SearchSelected event, Emitter<HomeState> emit) {
    if (state is HomeLoaded) {
      final currentState = state as HomeLoaded;
      emit(currentState.copyWith(
        selectedLocation: event.result,
        isSearching: false, // Optional: reset search state
      ));
    }
  }
}