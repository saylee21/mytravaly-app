// presentation/hotels/presentation/pages/search_results_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/services/injection_container.dart';
import '../../../widgets/property_search_card_widget.dart';
import '../data/models/search_auto_complete_resp_model.dart';
import 'bloc/search_result_bloc.dart';
import 'bloc/search_result_event.dart';
import 'bloc/search_result_state.dart';

class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final location = args['location'] as SearchResult;
    final checkIn = args['checkIn'] as DateTime;
    final checkOut = args['checkOut'] as DateTime;
    final adults = args['adults'] as int;
    final children = args['children'] as int;

    return BlocProvider(
      create: (_) => sl<HotelSearchBloc>()
        ..add(LoadSearchResults(
          location: location,
          checkIn: checkIn,
          checkOut: checkOut,
          adults: adults,
          children: children,
        )),
      child: SearchResultsView(
        location: location,
        checkIn: checkIn,
        checkOut: checkOut,
        adults: adults,
        children: children,
      ),
    );
  }
}

class SearchResultsView extends StatefulWidget {
  final SearchResult location;
  final DateTime checkIn;
  final DateTime checkOut;
  final int adults;
  final int children;

  const SearchResultsView({
    super.key,
    required this.location,
    required this.checkIn,
    required this.checkOut,
    required this.adults,
    required this.children,
  });

  @override
  State<SearchResultsView> createState() => _SearchResultsViewState();
}

class _SearchResultsViewState extends State<SearchResultsView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more when user scrolls to 90% of the list
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      context.read<HotelSearchBloc>().add(LoadMoreResults());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: BlocConsumer<HotelSearchBloc, HotelSearchState>(
        listener: (context, state) {
          // Show snackbar for errors during pagination
          if (state is HotelSearchError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: const Color(0xFFFF7B6D),
                behavior: SnackBarBehavior.floating,
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: () {
                    context.read<HotelSearchBloc>().add(RetrySearch());
                  },
                ),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is HotelSearchLoading) {
            return _buildLoadingState();
          }

          if (state is HotelSearchLoaded || state is HotelSearchLoadingMore) {
            final hotels = state is HotelSearchLoaded
                ? state.hotels
                : (state as HotelSearchLoadingMore).hotels;
            final hasMore = state is HotelSearchLoaded ? state.hasMore : true;

            return _buildLoadedState(hotels, hasMore);
          }

          if (state is HotelSearchEmpty) {
            return _buildEmptyState(state.message);
          }

          if (state is HotelSearchError) {
            return _buildErrorState(state.message);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  // ── APP BAR ──
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFFF7B6D),
      foregroundColor: Colors.white,
      elevation: 2,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BlocBuilder<HotelSearchBloc, HotelSearchState>(
            builder: (context, state) {
              final count = state is HotelSearchLoaded ? state.hotels.length : 0;
              return Text(
                '$count Hotels Found',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          Text(
            widget.location.valueToDisplay,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              color: Colors.white70,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.filter_list),
          onPressed: () {
            // TODO: Implement filter bottom sheet (optional)
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Filters coming soon!')),
            );
          },
        ),
      ],
    );
  }

  // ── LOADING STATE ──
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Color(0xFFFF7B6D)),
          SizedBox(height: 16),
          Text(
            'Searching for hotels...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ── LOADED STATE ──
  Widget _buildLoadedState(List hotels, bool hasMore) {
    return RefreshIndicator(
      color: const Color(0xFFFF7B6D),
      onRefresh: () async {
        context.read<HotelSearchBloc>().add(LoadSearchResults(
          location: widget.location,
          checkIn: widget.checkIn,
          checkOut: widget.checkOut,
          adults: widget.adults,
          children: widget.children,
        ));
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: hotels.length + (hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Show loading indicator at the bottom while loading more
          if (index >= hotels.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFFF7B6D),
                  strokeWidth: 2,
                ),
              ),
            );
          }

          return PropertySearchCardWidget(hotel: hotels[index]);
        },
      ),
    );
  }

  // ── EMPTY STATE ──
  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.hotel_outlined,
              size: 100,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 24),
            Text(
              'No Hotels Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Try Different Search'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF7B6D),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── ERROR STATE ──
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 100,
              color: const Color(0xFFFF7B6D).withOpacity(0.7),
            ),
            const SizedBox(height: 24),
            const Text(
              'Oops! Something went wrong',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<HotelSearchBloc>().add(RetrySearch());
                  },
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF7B6D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Go Back'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF7B6D),
                    side: const BorderSide(color: Color(0xFFFF7B6D)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}