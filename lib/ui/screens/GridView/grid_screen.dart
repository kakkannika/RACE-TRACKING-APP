import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/screens/GridView/widget/BIB_Button.dart';
import 'package:race_traking_app/ui/theme/theme.dart';

class ParticipantGridView extends StatefulWidget {
  const ParticipantGridView({Key? key}) : super(key: key);

  @override
  State<ParticipantGridView> createState() => _ParticipantGridViewState();
}

class _ParticipantGridViewState extends State<ParticipantGridView> {
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  final int _totalItems = 70; // Total number of participants
  
  // Calculate total pages
  int get _totalPages => (_totalItems / _itemsPerPage).ceil();
  
  // Map to store active buttons and their timestamps
  final Map<String, String> _activeButtons = {};

  // Get current page range (e.g., "1-10")
  String _getPageRange() {
    final start = (_currentPage * _itemsPerPage) + 1;
    final end = (_currentPage + 1) * _itemsPerPage;
    return '$start-${end > _totalItems ? _totalItems : end}';
  }

  void _handleButtonTap(String id) {
    setState(() {
      if (_activeButtons.containsKey(id)) {
        _activeButtons.remove(id);
      } else {
        final now = DateTime.now();
        final timestamp = "${now.hour.toString().padLeft(2, '0')}:"
                         "${now.minute.toString().padLeft(2, '0')}:"
                         "${now.second.toString().padLeft(2, '0')}."
                         "${(now.millisecond ~/ 10).toString().padLeft(2, '0')}";
        _activeButtons[id] = timestamp;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Pagination controls
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0
                    ? () {
                        setState(() {
                          _currentPage--;
                        });
                      }
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: RaceColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  _getPageRange(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: RaceColors.primary,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: _currentPage < _totalPages - 1
                    ? () {
                        setState(() {
                          _currentPage++;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ),
        
        // Grid of participant buttons
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _getItemCount(),
              itemBuilder: (context, index) {
                final itemNumber = _currentPage * _itemsPerPage + index + 1;
                final itemId = itemNumber.toString();
                
                return ParticipantButton(
                  id: itemId,
                  isActive: _activeButtons.containsKey(itemId),
                  timestamp: _activeButtons[itemId],
                  onTap: () => _handleButtonTap(itemId),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to calculate items for current page
  int _getItemCount() {
    if (_currentPage == _totalPages - 1) {
      final remainingItems = _totalItems % _itemsPerPage;
      return remainingItems == 0 ? _itemsPerPage : remainingItems;
    }
    return _itemsPerPage;
  }
}