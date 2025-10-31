import 'package:flutter/material.dart';

import 'counter_row_widget.dart';

class GuestTile extends StatelessWidget {
  final int adults;
  final int children;
  final Function(int adults, int children) onChanged;

  const GuestTile({required this.adults, required this.children, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showGuestPicker(context),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FA),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.people, size: 20, color: Colors.grey.shade600),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Guests', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text(
                  '$adults Adult${adults > 1 ? 's' : ''}${children > 0 ? ', $children Child${children > 1 ? 'ren' : ''}' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showGuestPicker(BuildContext context) {
    int tempAdults = adults;
    int tempChildren = children;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Select Guests', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              CounterRow(
                label: 'Adults',
                value: tempAdults,
                onChanged: (v) => setState(() => tempAdults = v),
              ),
              const SizedBox(height: 16),
              CounterRow(
                label: 'Children',
                value: tempChildren,
                onChanged: (v) => setState(() => tempChildren = v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  onChanged(tempAdults, tempChildren);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF7B6D),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('Done', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
