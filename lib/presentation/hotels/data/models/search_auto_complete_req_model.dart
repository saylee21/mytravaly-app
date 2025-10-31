class SearchAutoCompleteReqModel {
  final String action;
  final SearchAutoComplete searchAutoComplete;

  SearchAutoCompleteReqModel({
    this.action = 'searchAutoComplete',
    required this.searchAutoComplete,
  });

  Map<String, dynamic> toJson() {
    return {
      'action': action,
      'searchAutoComplete': searchAutoComplete.toJson(),
    };
  }
}

class SearchAutoComplete {
  final String inputText;
  final List<String> searchType;
  final int limit;

  SearchAutoComplete({
    required this.inputText,
    required this.searchType,
    this.limit = 10,
  });

  Map<String, dynamic> toJson() {
    return {
      'inputText': inputText,
      'searchType': searchType,
      'limit': limit,
    };
  }
}