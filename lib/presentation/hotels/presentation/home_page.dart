// lib/presentation/hotels/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mytravaly_assignment/presentation/hotels/presentation/search_results_page.dart';
import '../../../core/services/injection_container.dart';
import '../../../widgets/date_tile_wdiget.dart';
import '../../../widgets/guest_tile_widget.dart';
import '../../../widgets/search_bar_widget.dart';
import '../data/models/get_property_list_resp_model.dart';
import '../data/models/search_auto_complete_resp_model.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HomeBloc(sl(), sl())..add(const LoadPopularStays()),
      child: const HomePageView(),
    );
  }
}

class HomePageView extends StatefulWidget {
  const HomePageView({super.key});
  @override State<HomePageView> createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      resizeToAvoidBottomInset: true, // ← KEY: Prevents overflow
      body: SafeArea(
        child: Column(
          children: [
            // ── STICKY HEADER (Never scrolls) ──
            _buildStickyHeader(),

            // ── SCROLLABLE CONTENT: Search + Date + Guests + Button + List ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  children: [
                    // Search Bar (now scrollable)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                      child: SearchBarWithDropdown(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        onSelected: (result) {
                          context.read<HomeBloc>().add(SearchSelected(result));
                          _searchController.text = result.valueToDisplay;
                          _searchFocusNode.unfocus();
                        },
                      ),
                    ),

                    // Date + Guests + Search Button (Compact Row)
                    _buildCompactSearchSection(),

                    // Property List
                    BlocConsumer<HomeBloc, HomeState>(
                      listener: (context, state) {
                        if (state is HomeError && state.previousProperties == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.message),
                              backgroundColor: const Color(0xFFFF7B6D),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      },
                      builder: (context, state) {
                        if (state is HomeLoading) return _buildLoadingState();
                        if (state is HomeLoaded) return _buildLoadedState(context, state);
                        if (state is HomeRefreshing) return _buildRefreshingState(state);
                        if (state is HomeEmpty) return _buildEmptyState(context, state.message);
                        if (state is HomeError) return _buildErrorState(context, state.message);
                        return const SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── STICKY HEADER ──
  Widget _buildStickyHeader() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFFF9A8B), Color(0xFFFF7B6D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.flight_takeoff, color: Colors.white, size: 28),
                ),
                const SizedBox(width: 12),
                const Text(
                  'MyTravaly',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                    child: const Icon(Icons.notifications_outlined, color: Colors.white, size: 22),
                  ),
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Find your perfect stay', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  // ── COMPACT: Date + (Guests + Search Button) in ROW ──
  Widget _buildCompactSearchSection() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (_, state) {
        if (state is! HomeLoaded) return const SizedBox.shrink();
        final s = state as HomeLoaded;

        final bool canSearch = s.selectedLocation != null && s.checkIn != null && s.checkOut != null;

        return Container(
          color: Colors.white,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Date Tile
              DateTile(
                label: 'Dates',
                date: s.checkIn,
                secondaryDate: s.checkOut,
                onTap: () => _pickDateRange(context, s),
              ),
              const SizedBox(height: 16),

              // Guests + Search Button in ONE ROW
              Row(
                children: [
                  // Guests
                  Expanded(
                    flex: 3,
                    child: GuestTile(
                      adults: s.adults,
                      children: s.children,
                      onChanged: (a, c) => context.read<HomeBloc>().add(GuestsChanged(a, c)),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Search Button
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 68,
                      child: ElevatedButton(
                        onPressed: canSearch ? () => _performSearch(context, s) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7B6D),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          elevation: 2,
                        ),
                        child: const Icon(Icons.search, size: 34),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ── DATE PICKER ──
  Future<void> _pickDateRange(BuildContext ctx, HomeLoaded current) async {
    final picked = await showDateRangePicker(
      context: ctx,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: current.checkIn != null && current.checkOut != null
          ? DateTimeRange(start: current.checkIn!, end: current.checkOut!)
          : null,
      builder: (_, child) => Theme(
        data: Theme.of(ctx).copyWith(colorScheme: const ColorScheme.light(primary: Color(0xFFFF7B6D))),
        child: child!,
      ),
    );
    if (picked != null) {
      ctx.read<HomeBloc>().add(CheckInChanged(picked.start));
      ctx.read<HomeBloc>().add(CheckOutChanged(picked.end));
    }
  }

  // ── NAVIGATE ──
  void _performSearch(BuildContext context, HomeLoaded state) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(),
        settings: RouteSettings(
          arguments: {
            'location': state.selectedLocation!,
            'checkIn': state.checkIn!,
            'checkOut': state.checkOut!,
            'adults': state.adults,
            'children': state.children,
          },
        ),
      ),
    );
  }

  // ── UI STATES ──
  Widget _buildLoadingState() => const Padding(
    padding: EdgeInsets.all(40),
    child: Center(child: CircularProgressIndicator(color: Color(0xFFFF7B6D))),
  );

  Widget _buildRefreshingState(HomeRefreshing state) {
    return Stack(
      children: [
        _buildPropertyList(state.currentProperties),
        Container(color: Colors.black38, child: const Center(child: CircularProgressIndicator(color: Color(0xFFFF7B6D)))),
      ],
    );
  }

  Widget _buildLoadedState(BuildContext context, HomeLoaded state) {
    if (state.filteredProperties.isEmpty) {
      return _buildEmptyState(context, state.isSearching ? 'No properties found' : 'No properties available');
    }

    return RefreshIndicator(
      color: const Color(0xFFFF7B6D),
      onRefresh: () async {
        context.read<HomeBloc>().add(const RefreshProperties());
        await Future.delayed(const Duration(seconds: 2));
      },
      child: Column(
        children: [
          if (state.isSearching)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              color: const Color(0xFFFF7B6D).withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 18, color: Color(0xFFFF7B6D)),
                  const SizedBox(width: 10),
                  Text('${state.filteredProperties.length} result(s)', style: const TextStyle(color: Color(0xFFFF7B6D), fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          _buildPropertyList(state.filteredProperties),
        ],
      ),
    );
  }

  Widget _buildPropertyList(List<Property> properties) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      itemCount: properties.length,
      itemBuilder: (context, index) => _buildPropertyCard(properties[index]),
    );
  }

  // ── PROPERTY CARD (unchanged) ──
  Widget _buildPropertyCard(Property property) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Stack(
              children: [
                Image.network(
                  property.propertyImage,
                  height: 220,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(height: 220, color: Colors.grey[200], child: const Icon(Icons.image_not_supported)),
                ),
                Positioned(
                  top: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)]),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Color(0xFFFBBC05), size: 18),
                        const SizedBox(width: 4),
                        Text(
                          property.googleReview.reviewPresent ? property.googleReview.data!.overallRating.toStringAsFixed(1) : 'N/A',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(property.propertyName, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                    ),
                    const SizedBox(width: 12),
                    Row(children: List.generate(property.propertyStar, (_) => const Icon(Icons.star, color: Color(0xFFFBBC05), size: 18))),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 18, color: Colors.grey[600]),
                    const SizedBox(width: 6),
                    Expanded(child: Text('${property.propertyAddress.city}, ${property.propertyAddress.state}', style: TextStyle(color: Colors.grey[700], fontSize: 14))),
                  ],
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    if (property.propertyPoliciesAndAmmenities.present && property.propertyPoliciesAndAmmenities.data!.freeWifi)
                      _buildAmenityChip(Icons.wifi, 'Free WiFi'),
                    if (property.propertyPoliciesAndAmmenities.present && property.propertyPoliciesAndAmmenities.data!.freeCancellation)
                      _buildAmenityChip(Icons.cancel_outlined, 'Free Cancellation'),
                    if (property.propertyPoliciesAndAmmenities.present && property.propertyPoliciesAndAmmenities.data!.coupleFriendly)
                      _buildAmenityChip(Icons.favorite_border, 'Couple Friendly'),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(property.staticPrice.displayAmount, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFFFF7B6D))),
                        Text('per night', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
                      ],
                    ),
                    if (property.googleReview.reviewPresent)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('${property.googleReview.data!.totalUserRating} reviews', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                          const SizedBox(height: 8),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7B6D), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            child: const Text('View Details', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFFF7B6D).withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: const Color(0xFFFF7B6D).withOpacity(0.3))),
      child: Row(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 16, color: const Color(0xFFFF7B6D)), const SizedBox(width: 6), Text(label, style: const TextStyle(color: Color(0xFFFF7B6D), fontSize: 12, fontWeight: FontWeight.w600))]),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.search_off_rounded, size: 100, color: Colors.grey[300]),
          const SizedBox(height: 24),
          Text(message, style: TextStyle(color: Colors.grey[700], fontSize: 17, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<HomeBloc>().add(const LoadPopularStays()),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Reload'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7B6D), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.error_outline_rounded, size: 100, color: const Color(0xFFFF7B6D).withOpacity(0.7)),
          const SizedBox(height: 24),
          const Text('Oops! Something went wrong', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(message, style: TextStyle(color: Colors.grey[600], fontSize: 15), textAlign: TextAlign.center),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.read<HomeBloc>().add(const LoadPopularStays()),
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF7B6D), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          ),
        ],
      ),
    );
  }
}