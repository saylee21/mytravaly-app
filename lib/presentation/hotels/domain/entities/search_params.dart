import '../../data/models/search_auto_complete_resp_model.dart';

class SearchParams {
  final SearchResult location;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;

  const SearchParams({
    required this.location,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
  });
}