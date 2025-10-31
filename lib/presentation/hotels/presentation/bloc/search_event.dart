// presentation/home/bloc/search/search_event.dart
import 'package:equatable/equatable.dart';
import '../../data/models/search_auto_complete_resp_model.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();
  @override
  List<Object?> get props => [];
}

class SearchTextChanged extends SearchEvent {
  final String query;
  final bool isFromSelection;

  const SearchTextChanged(
      this.query, {
        this.isFromSelection = false,
      });

  @override
  List<Object?> get props => [query, isFromSelection];
}

class SelectSuggestion extends SearchEvent {
  final SearchResult result;
  const SelectSuggestion(this.result);
  @override
  List<Object?> get props => [result];
}

class ClearSuggestions extends SearchEvent {
  const ClearSuggestions();
}

class HideOverlay extends SearchEvent {
  const HideOverlay();
}

class UpdateControllerText extends SearchEvent {
  final String text;
  const UpdateControllerText(this.text);
  @override
  List<Object?> get props => [text];
}