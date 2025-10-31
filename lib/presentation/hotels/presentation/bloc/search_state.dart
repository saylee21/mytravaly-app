// presentation/home/bloc/search/search_state.dart
import 'package:equatable/equatable.dart';
import '../../data/models/search_auto_complete_resp_model.dart';

abstract class SearchState extends Equatable {
  const SearchState();
  @override
  List<Object?> get props => [];
}

class SearchIdle extends SearchState {
  const SearchIdle();
}

class SearchLoading extends SearchState {
  const SearchLoading();
}

class SearchLoaded extends SearchState {
  final List<SearchResult> suggestions;
  final bool showOverlay;

  const SearchLoaded(
      this.suggestions, {
        this.showOverlay = true,
      });

  SearchLoaded copyWith({
    List<SearchResult>? suggestions,
    bool? showOverlay,
  }) {
    return SearchLoaded(
      suggestions ?? this.suggestions,
      showOverlay: showOverlay ?? this.showOverlay,
    );
  }

  @override
  List<Object?> get props => [suggestions, showOverlay];
}

class SearchError extends SearchState {
  final String message;
  const SearchError(this.message);
  @override
  List<Object?> get props => [message];
}

class SearchHideOverlay extends SearchState {
  const SearchHideOverlay();
}