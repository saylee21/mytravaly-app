// presentation/home/bloc/search/search_bloc.dart
import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mytravaly_assignment/core/network/api_client.dart';
import '../../data/models/search_auto_complete_req_model.dart';
import '../../data/models/search_auto_complete_resp_model.dart';
import '../../domain/usecases/search_auto_complete_use_case.dart';
import 'search_event.dart';
import 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchAutoCompleteUseCase _useCase;
  Timer? _debounce;

  SearchBloc(this._useCase) : super(const SearchIdle()) {
    on<SearchTextChanged>(_onTextChanged);
    on<SelectSuggestion>(_onSelect);
    on<ClearSuggestions>(_onClear);
    on<HideOverlay>(_onHideOverlay);
    on<UpdateControllerText>(_onUpdateControllerText);
  }

  Future<void> _onTextChanged(
      SearchTextChanged event,
      Emitter<SearchState> emit,
      ) async {
    // Skip if this is from a selection
    if (event.isFromSelection) {
      return;
    }

    final query = event.query.trim();

    // Cancel any pending debounce
    _debounce?.cancel();

    // Reset to idle if empty
    if (query.isEmpty) {
      emit(const SearchIdle());
      return;
    }

    // Validate: Must be between 3 and 10 characters
    if (query.length < 3) {
      emit(const SearchIdle());
      return;
    }

    if (query.length > 10) {
      emit(const SearchError('Search query must be less than 10 characters'));
      return;
    }

    // Show loading immediately
    emit(const SearchLoading());

    // Create a completer to wait for debounce
    final completer = Completer<void>();

    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (!completer.isCompleted) {
        completer.complete();
      }
    });

    // Wait for debounce to complete
    await completer.future;

    // Check if already closed or cancelled
    if (isClosed || emit.isDone) return;

    // Build request
    final req = SearchAutoCompleteReqModel(
      searchAutoComplete: SearchAutoComplete(
        inputText: query,
        searchType: [
          'byCity',
          'byState',
          'byCountry',
          'byRandom',
          'byPropertyName',
        ],
        limit: 10,
      ),
    );

    final result = await _useCase(req);

    // Check again before emitting
    if (isClosed || emit.isDone) return;

    result.fold(
          (failure) {
        emit(SearchError(failure.userFriendlyMessage));
      },
          (resp) {
        final List<SearchResult> suggestions = [];

        void addFrom(SearchCategory? cat) {
          if (cat?.present ?? false) {
            suggestions.addAll(cat!.listOfResult);
          }
        }

        final data = resp.data?.autoCompleteList;
        if (data != null) {
          addFrom(data.byPropertyName);
          addFrom(data.byCity);
          addFrom(data.byState);
          addFrom(data.byCountry);
        }

        if (suggestions.isEmpty) {
          emit(const SearchIdle());
        } else {
          emit(SearchLoaded(suggestions));
        }
      },
    );
  }

  void _onSelect(SelectSuggestion event, Emitter<SearchState> emit) {
    _debounce?.cancel();
    emit(const SearchHideOverlay());
  }

  void _onClear(ClearSuggestions event, Emitter<SearchState> emit) {
    _debounce?.cancel();
    emit(const SearchIdle());
  }

  void _onHideOverlay(HideOverlay event, Emitter<SearchState> emit) {
    _debounce?.cancel();
    emit(const SearchHideOverlay());
  }

  void _onUpdateControllerText(
      UpdateControllerText event,
      Emitter<SearchState> emit,
      ) {
    // This event doesn't change state, just signals controller update
    // The actual controller update happens in the widget
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
}