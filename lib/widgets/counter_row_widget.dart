import 'package:flutter/material.dart';

class CounterRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  const CounterRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        Row(
          children: [
            IconButton(
              onPressed: value > (label == 'Adults' ? 1 : 0) ? () => onChanged(value - 1) : null,
              icon: const Icon(Icons.remove_circle_outline),
              disabledColor: Colors.grey.shade300,
            ),
            SizedBox(width: 40, child: Center(child: Text('$value', style: const TextStyle(fontSize: 16)))),
            IconButton(
              onPressed: () => onChanged(value + 1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }
}