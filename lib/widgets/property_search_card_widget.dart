// lib/presentation/widgets/property_search_card_widget.dart
import 'package:flutter/material.dart';
import '../presentation/hotels/data/models/get_search_results_resp_model.dart';

class PropertySearchCardWidget extends StatelessWidget {
  final HotelSearchResult hotel;

  const PropertySearchCardWidget({
    super.key,
    required this.hotel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── IMAGE WITH RATING BADGE ──
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Stack(
              children: [
                Image.network(
                  hotel.propertyImage.fullUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                    ),
                  ),
                ),

                // Rating Badge (Top Right)
                if (hotel.googleReview.reviewPresent &&
                    hotel.googleReview.data != null &&
                    hotel.googleReview.data!.overallRating > 0)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getRatingColor(hotel.googleReview.data!.overallRating),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.white),
                          const SizedBox(width: 4),
                          Text(
                            hotel.googleReview.data!.overallRating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Property Type Badge (Bottom Left)
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      hotel.propertytype,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── CONTENT ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Stars
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        hotel.propertyName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D3748),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (hotel.propertyStar > 0)
                      Row(
                        children: List.generate(
                          hotel.propertyStar,
                              (_) => const Icon(
                            Icons.star,
                            size: 16,
                            color: Color(0xFFFBBC05),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${hotel.propertyAddress.city}, ${hotel.propertyAddress.state}',
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Amenities (FIXED: Uses propertyPoliciesAndAmmenities with double 'm')
                if (hotel.propertyPoliciesAndAmmenities.present &&
                    hotel.propertyPoliciesAndAmmenities.data != null)
                  _buildAmenities(hotel.propertyPoliciesAndAmmenities.data!),

                const SizedBox(height: 12),

                // Price + Reviews + Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Price Section
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            hotel.propertyMinPrice.displayAmount,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFFF7B6D),
                            ),
                          ),
                          const Text(
                            'per night',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          if (hotel.googleReview.reviewPresent &&
                              hotel.googleReview.data != null &&
                              hotel.googleReview.data!.totalUserRating > 0)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                '${hotel.googleReview.data!.totalUserRating} reviews',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // View Details Button
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navigate to hotel details page
                        debugPrint('View details: ${hotel.propertyCode}');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7B6D),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
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

  // ── AMENITIES CHIPS ──
  Widget _buildAmenities(PolicyData amenities) {
    final List<Widget> chips = [];

    if (amenities.freeWifi) {
      chips.add(_buildAmenityChip(Icons.wifi, 'Free WiFi'));
    }
    if (amenities.freeCancellation) {
      chips.add(_buildAmenityChip(Icons.cancel_outlined, 'Free Cancellation'));
    }
    if (amenities.coupleFriendly) {
      chips.add(_buildAmenityChip(Icons.favorite_border, 'Couple Friendly'));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: chips,
    );
  }

  Widget _buildAmenityChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFFF7B6D).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFFFF7B6D).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFFFF7B6D)),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFF7B6D),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ── HELPER: Rating Color ──
  Color _getRatingColor(double rating) {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }
}