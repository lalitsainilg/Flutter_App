// lib/widgets/filter_selector.dart
import 'package:flutter/material.dart';

class FilterSelector extends StatelessWidget {
  final int currentFilterIndex;
  final double filterStrength;
  final Function(int) onFilterChanged;
  final Function(double) onStrengthChanged;

  const FilterSelector({
    super.key,
    required this.currentFilterIndex,
    required this.filterStrength,
    required this.onFilterChanged,
    required this.onStrengthChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Filter strength slider
        Slider(
          value: filterStrength,
          min: 0.0,
          max: 1.0,
          onChanged: onStrengthChanged,
        ),

        // Filter options
        SizedBox(
          height: 80,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterOption('Original', 0),
              _buildFilterOption('Filter 1', 1),
              _buildFilterOption('Filter 2', 2),
              _buildFilterOption('Filter 3', 3),
              _buildFilterOption('Filter 4', 4),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFilterOption(String name, int index) {
    return GestureDetector(
      onTap: () => onFilterChanged(index),
      child: Container(
        margin: const EdgeInsets.all(8),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                border: Border.all(
                  color: currentFilterIndex == index
                      ? Colors.purple
                      : Colors.transparent,
                  width: 2,
                ),
              ),
            ),
            Text(name),
          ],
        ),
      ),
    );
  }
}