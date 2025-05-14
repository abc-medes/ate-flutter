import 'package:flutter/material.dart';

class AllergiesSelector extends StatefulWidget {
  final List<String> selectedAllergies;
  final Function(List<String>) onAllergiesChanged;

  const AllergiesSelector({
    super.key,
    required this.selectedAllergies,
    required this.onAllergiesChanged,
  });

  @override
  State<AllergiesSelector> createState() => _AllergiesSelectorState();
}

class _AllergiesSelectorState extends State<AllergiesSelector> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customAllergyController =
      TextEditingController();
  String _searchQuery = '';
  bool _showCustomInput = false;

  // Category mapping
  final Map<String, List<String>> _allergiesByCategory = {
    'Food': [
      'Peanuts',
      'Tree Nuts',
      'Milk',
      'Eggs',
      'Fish',
      'Shellfish',
      'Soy',
      'Wheat',
      'Gluten',
    ],
    'Medications': [
      'Penicillin',
      'Sulfa Drugs',
      'NSAIDs (Aspirin, Ibuprofen)',
      'Codeine',
      'Tetracycline',
      'Morphine',
      'Local Anesthetics',
    ],
    'Environmental': [
      'Pollen',
      'Dust Mites',
      'Pet Dander',
      'Mold',
      'Grass',
      'Ragweed',
    ],
    'Insects': [
      'Bee Stings',
      'Wasp Stings',
      'Mosquito Bites',
      'Fire Ants',
    ],
    'Other': [
      'Latex',
      'Fragrances',
      'Dyes',
      'Nickel',
      'Adhesives',
      'Sunscreen',
    ],
  };

  @override
  void dispose() {
    _searchController.dispose();
    _customAllergyController.dispose();
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
              hintText: 'Search allergies...',
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

        // Add custom allergy button
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
                          'Add custom allergy',
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
                          controller: _customAllergyController,
                          decoration: const InputDecoration(
                            hintText: 'Enter allergy',
                            isDense: true,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check),
                        onPressed: () {
                          final allergy = _customAllergyController.text.trim();
                          if (allergy.isNotEmpty) {
                            final updatedAllergies =
                                List<String>.from(widget.selectedAllergies)
                                  ..add(allergy);
                            widget.onAllergiesChanged(updatedAllergies);
                            _customAllergyController.clear();
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

        // Add "No Known Allergies" option
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: InkWell(
            onTap: () {
              if (widget.selectedAllergies.contains('No Known Allergies')) {
                widget.onAllergiesChanged([]);
              } else {
                widget.onAllergiesChanged(['No Known Allergies']);
              }
            },
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                Icon(
                  widget.selectedAllergies.contains('No Known Allergies')
                      ? Icons.check_box
                      : Icons.check_box_outline_blank,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'No Known Allergies',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color:
                        widget.selectedAllergies.contains('No Known Allergies')
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Selected allergies chips (only if not "No Known Allergies")
        if (widget.selectedAllergies.isNotEmpty &&
            !widget.selectedAllergies.contains('No Known Allergies'))
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            alignment: Alignment.centerLeft,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.selectedAllergies.map((allergy) {
                return Chip(
                  label: Text(allergy),
                  deleteIcon: const Icon(Icons.close, size: 18),
                  onDeleted: () {
                    final updatedAllergies =
                        List<String>.from(widget.selectedAllergies)
                          ..remove(allergy);
                    widget.onAllergiesChanged(updatedAllergies);
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

        // Only show list if "No Known Allergies" is not selected
        if (!widget.selectedAllergies.contains('No Known Allergies'))
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
      itemCount: _allergiesByCategory.length,
      itemBuilder: (context, index) {
        final category = _allergiesByCategory.keys.elementAt(index);
        final allergies = _allergiesByCategory[category]!;

        return ExpansionTile(
          title: Text(
            category,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          children:
              allergies.map((allergy) => _buildAllergyTile(allergy)).toList(),
        );
      },
    );
  }

  Widget _buildSearchResults() {
    final matchingAllergies = <String>[];

    _allergiesByCategory.forEach((category, allergies) {
      for (final allergy in allergies) {
        if (allergy.toLowerCase().contains(_searchQuery)) {
          matchingAllergies.add(allergy);
        }
      }
    });

    if (matchingAllergies.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No allergies match your search',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add as custom allergy'),
              onPressed: () {
                if (_searchQuery.isNotEmpty) {
                  setState(() {
                    _customAllergyController.text = _searchQuery;
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
      itemCount: matchingAllergies.length,
      itemBuilder: (context, index) {
        return _buildAllergyTile(matchingAllergies[index]);
      },
    );
  }

  Widget _buildAllergyTile(String allergy) {
    final isSelected = widget.selectedAllergies.contains(allergy);

    return ListTile(
      title: Text(allergy),
      trailing: isSelected
          ? Icon(Icons.check_circle,
              color: Theme.of(context).colorScheme.primary)
          : Icon(Icons.add_circle_outline,
              color: Theme.of(context).colorScheme.outline),
      onTap: () {
        List<String> updatedAllergies;
        if (isSelected) {
          updatedAllergies = List<String>.from(widget.selectedAllergies)
            ..remove(allergy);
        } else {
          // If "No Known Allergies" is selected, clear it first
          updatedAllergies = List<String>.from(widget.selectedAllergies);
          updatedAllergies.remove('No Known Allergies');
          updatedAllergies.add(allergy);
        }
        widget.onAllergiesChanged(updatedAllergies);
      },
    );
  }
}
