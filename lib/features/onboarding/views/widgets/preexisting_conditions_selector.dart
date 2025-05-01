import 'package:flutter/material.dart';

class PreExistingConditionsSelector extends StatefulWidget {
  final List<String> selectedConditions;
  final Function(List<String>) onConditionsChanged;

  const PreExistingConditionsSelector({
    Key? key,
    required this.selectedConditions,
    required this.onConditionsChanged,
  }) : super(key: key);

  @override
  State<PreExistingConditionsSelector> createState() =>
      _PreExistingConditionsSelectorState();
}

class _PreExistingConditionsSelectorState
    extends State<PreExistingConditionsSelector> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Category mapping
  final Map<String, List<String>> _conditionsByCategory = {
    'Cardiovascular': [
      'Hypertension',
      'Heart Disease',
      'High Cholesterol',
      'Arrhythmia'
    ],
    'Respiratory': ['Asthma', 'COPD', 'Sleep Apnea'],
    'Metabolic': [
      'Diabetes Type 1',
      'Diabetes Type 2',
      'Thyroid Disorder',
      'Obesity'
    ],
    'Mental Health': ['Depression', 'Anxiety', 'ADHD', 'Bipolar Disorder'],
    'Autoimmune': [
      'Rheumatoid Arthritis',
      'Lupus',
      'Multiple Sclerosis',
      'Psoriasis'
    ],
    // Add more categories as needed
  };

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search conditions...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ),

        // Selected conditions chips
        if (widget.selectedConditions.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedConditions.map((condition) {
                return Chip(
                  label: Text(condition),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    final updatedConditions =
                        List<String>.from(widget.selectedConditions)
                          ..remove(condition);
                    widget.onConditionsChanged(updatedConditions);
                  },
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }).toList(),
            ),
          ),

        const SizedBox(height: 16),

        // Expandable categories
        Expanded(
          child: _searchQuery.isEmpty
              ? _buildCategorizedList()
              : _buildSearchResults(),
        ),
      ],
    );
  }

  Widget _buildCategorizedList() {
    return ListView.builder(
      itemCount: _conditionsByCategory.length,
      itemBuilder: (context, index) {
        final category = _conditionsByCategory.keys.elementAt(index);
        final conditions = _conditionsByCategory[category]!;

        return ExpansionTile(
          title: Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          children: conditions
              .map((condition) => _buildConditionTile(condition))
              .toList(),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final matchingConditions = <String>[];

    _conditionsByCategory.forEach((category, conditions) {
      for (final condition in conditions) {
        if (condition.toLowerCase().contains(_searchQuery)) {
          matchingConditions.add(condition);
        }
      }
    });

    if (matchingConditions.isEmpty) {
      return Center(
        child: Text(
          'No conditions match your search',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      );
    }

    return ListView.builder(
      itemCount: matchingConditions.length,
      itemBuilder: (context, index) {
        return _buildConditionTile(matchingConditions[index]);
      },
    );
  }

  Widget _buildConditionTile(String condition) {
    final isSelected = widget.selectedConditions.contains(condition);

    return ListTile(
      title: Text(condition),
      trailing: isSelected
          ? Icon(Icons.check_circle,
              color: Theme.of(context).colorScheme.primary)
          : Icon(Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.outline),
      onTap: () {
        List<String> updatedConditions;
        if (isSelected) {
          updatedConditions = List<String>.from(widget.selectedConditions)
            ..remove(condition);
        } else {
          updatedConditions = List<String>.from(widget.selectedConditions)
            ..add(condition);
        }
        widget.onConditionsChanged(updatedConditions);
      },
    );
  }
}
