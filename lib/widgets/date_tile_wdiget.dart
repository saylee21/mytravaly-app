import 'package:flutter/material.dart';

class DateTile extends StatelessWidget {
  final String label;
  final DateTime? date;
  final DateTime? secondaryDate;
  final VoidCallback onTap;

  const DateTile({super.key, required this.label, this.date, this.secondaryDate, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[300]!)),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 20, color: const Color(0xFFFF7B6D)),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(
                  date == null ? 'Select date' : secondaryDate == null
                      ? '${_format(date!)}'
                      : '${_format(date!)} – ${_format(secondaryDate!)}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _format(DateTime d) => '${d.day} ${_month(d.month)}';
  String _month(int m) => ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][m-1];
}