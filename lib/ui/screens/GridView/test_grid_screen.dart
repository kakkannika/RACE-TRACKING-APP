import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/screens/GridView/widget/BIB_Button.dart';

class ParticipantGrid extends StatefulWidget {
  const ParticipantGrid({Key? key}) : super(key: key);

  @override
  State<ParticipantGrid> createState() => _ParticipantGridState();
}

class _ParticipantGridState extends State<ParticipantGrid> {
  int _currentPage = 0;
  final int _itemsPerPage = 10;
  final int _totalPages = 7;
  
  // Map to store active buttons and their timestamps
  // Key: button ID (as string), Value: timestamp string
  final Map<String, String> _activeButtons = {};

  void _handleButtonTap(String id) {
    setState(() {
      if (_activeButtons.containsKey(id)) {
        // If already active, deactivate it
        _activeButtons.remove(id);
      } else {
        // Activate and set timestamp
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: RaceColors.primary,
        title: const Text('Cycle Segment', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            // Handle back navigation
          },
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          // Timer display
          const Text(
            '11:11:11.00',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          // View toggle and pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.indigo),
                    ),
                  ),
                  child: const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Grid View'),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('2-Step View'),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Pagination controls
          Row(
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
              for (int i = 0; i < _totalPages; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: CircleAvatar(
                    backgroundColor: i == _currentPage ? RaceColors.primary : Colors.grey[300],
                    radius: 12,
                    child: Text(
                      '$i',
                      style: TextStyle(
                        color: i == _currentPage ? Colors.white : Colors.black,
                        fontSize: 12,
                      ),
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
          const SizedBox(height: 10),
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
                itemCount: _itemsPerPage,
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
      ),
    );
  }
}