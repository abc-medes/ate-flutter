import 'package:flutter/material.dart';

class MedicationsSelector extends StatefulWidget {
  final List<String> selectedMedications;
  final Function(List<String>) onMedicationsChanged;

  const MedicationsSelector({
    Key? key,
    required this.selectedMedications,
    required this.onMedicationsChanged,
  }) : super(key: key);

  @override
  State<MedicationsSelector> createState() => _MedicationsSelectorState();
}

class _MedicationsSelectorState extends State<MedicationsSelector> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customMedicationController =
      TextEditingController();
  String _searchQuery = '';
  bool _showCustomInput = false;

  // Category mapping
  final Map<String, List<String>> _medicationsByCategory = {
    'Blood Pressure': [
      'Lisinopril',
      'Amlodipine',
      'Losartan',
      'Metoprolol',
    ],
    'Diabetes': [
      'Metformin',
      'Insulin',
      'Glipizide',
      'Januvia',
    ],
    'Pain & Inflammation': [
      'Ibuprofen',
      'Acetaminophen',
      'Naproxen',
      'Aspirin',
      'Celecoxib',
    ],
    'Cholesterol': [
      'Atorvastatin',
      'Simvastatin',
      'Rosuvastatin',
      'Pravastatin',
    ],
    'Mental Health': [
      'Sertraline',
      'Escitalopram',
      'Fluoxetine',
      'Bupropion',
      'Alprazolam',
    ],
    'Respiratory': [
      'Albuterol',
      'Fluticasone',
      'Montelukast',
      'Budesonide',
    ],
    'Thyroid': [
      'Levothyroxine',
    ],
    'Antibiotics': [
      'Amoxicillin',
      'Azithromycin',
      'Ciprofloxacin',
      'Doxycycline',
    ],
    'Supplements': [
      'Vitamin D',
      'Calcium',
      'Iron',
      'Magnesium',
      'Multivitamin',
      'Omega-3',
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    _customMedicationController.dispose();
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
              hintText: 'Search medications...',
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

        // Add custom medication button
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _showCustomInput ? 80 : 40,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    setState(() {
                      _showCustomInput = !_showCustomInput;
                    });
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _showCustomInput ? Icons.remove : Icons.add,
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Add custom medication',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_showCustomInput)
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customMedicationController,
                          decoration: const InputDecoration(
                            hintText: 'Enter medication name',
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          final medication =
                              _customMedicationController.text.trim();
                          if (medication.isNotEmpty) {
                            final updatedMedications =
                                List<String>.from(widget.selectedMedications)
                                  ..add(medication);
                            widget.onMedicationsChanged(updatedMedications);
                            _customMedicationController.clear();
                            setState(() {
                              _showCustomInput = false;
                            });
                          }
                        },
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),

        // Selected medications chips
        if (widget.selectedMedications.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedMedications.map((medication) {
                return Chip(
                  label: Text(medication),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    final updatedMedications =
                        List<String>.from(widget.selectedMedications)
                          ..remove(medication);
                    widget.onMedicationsChanged(updatedMedications);
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

        const SizedBox(height: 8),

        // Expandable categories or search results
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
      itemCount: _medicationsByCategory.length,
      itemBuilder: (context, index) {
        final category = _medicationsByCategory.keys.elementAt(index);
        final medications = _medicationsByCategory[category]!;

        return ExpansionTile(
          title: Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          children: medications
              .map((medication) => _buildMedicationTile(medication))
              .toList(),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final matchingMedications = <String>[];

    _medicationsByCategory.forEach((category, medications) {
      for (final medication in medications) {
        if (medication.toLowerCase().contains(_searchQuery)) {
          matchingMedications.add(medication);
        }
      }
    });

    if (matchingMedications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No medications match your search',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add as custom medication'),
              onPressed: () {
                if (_searchQuery.isNotEmpty) {
                  setState(() {
                    _customMedicationController.text = _searchQuery;
                    _showCustomInput = true;
                  });
                }
              },
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: matchingMedications.length,
      itemBuilder: (context, index) {
        return _buildMedicationTile(matchingMedications[index]);
      },
    );
  }

  Widget _buildMedicationTile(String medication) {
    final isSelected = widget.selectedMedications.contains(medication);

    return ListTile(
      title: Text(medication),
      trailing: isSelected
          ? Icon(Icons.check_circle,
              color: Theme.of(context).colorScheme.primary)
          : Icon(Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.outline),
      onTap: () {
        List<String> updatedMedications;
        if (isSelected) {
          updatedMedications = List<String>.from(widget.selectedMedications)
            ..remove(medication);
        } else {
          updatedMedications = List<String>.from(widget.selectedMedications)
            ..add(medication);
        }
        widget.onMedicationsChanged(updatedMedications);
      },
    );
  }
}
