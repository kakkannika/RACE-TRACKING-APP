import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/screens/2step/widget/TwoStep_list_tile.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/headerRow.dart';

class TwoStepView extends StatefulWidget {
  const TwoStepView({Key? key}) : super(key: key);

  @override
  State<TwoStepView> createState() => _TwoStepViewState();
}

class _TwoStepViewState extends State<TwoStepView> {
  int? selectedIndex;
  int _currentPage = 0;
  final int _itemsPerPage = 10;

  final List<Map<String, String>> finishTimes = [
    {"number": "01", "time": "02:30.88"},
    {"number": "02", "time": "01:59.88"},
    {"number": "03", "time": "01:58.88"},
    {"number": "04", "time": "02:30.88"},
    {"number": "05", "time": "01:59.88"},
    {"number": "06", "time": "01:58.88"},
    {"number": "07", "time": "02:30.88"},
    {"number": "08", "time": "01:59.88"},
    {"number": "09", "time": "01:58.88"},
    {"number": "10", "time": "01:59.88"},
    {"number": "11", "time": "02:30.88"},
    {"number": "12", "time": "01:59.88"},
    {"number": "13", "time": "01:58.88"},
    {"number": "14", "time": "02:30.88"},
    {"number": "15", "time": "01:59.88"},
    {"number": "16", "time": "01:58.88"},
    {"number": "17", "time": "02:30.88"},
    {"number": "18", "time": "01:59.88"},
    {"number": "19", "time": "01:58.88"},
    {"number": "20", "time": "01:59.88"},

  ];

  final Map<int, String> selectedBibs = {};
  // Calculate total pages
  int get _totalPages => (finishTimes.length / _itemsPerPage).ceil();
  
  // Get current page items
  List<Map<String, String>> get _currentPageItems {
    final startIndex = _currentPage * _itemsPerPage;
    final endIndex = startIndex + _itemsPerPage;
    return finishTimes.sublist(
      startIndex,
      endIndex > finishTimes.length ? finishTimes.length : endIndex
    );
  }

   String _getPageRange() {
    final start = (_currentPage * _itemsPerPage) + 1;
    final end = (_currentPage + 1) * _itemsPerPage;
    return '$start-${end > finishTimes.length ? finishTimes.length : end}';
  }

  Future<void> _showBibSelectionDialog(int index) async {
    final usedBibs = selectedBibs.entries
        .where((entry) => entry.key != index)
        .map((entry) => entry.value)
        .toSet();

    final selectedBib = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Select BIB number'),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Icon(Icons.close, size: 32, color: RaceColors.black),
            ),
          ],
        ),
        backgroundColor: RaceColors.white,
        content: SizedBox(
          width: 300,
          height: 250,
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              childAspectRatio: 1.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: 9,
            itemBuilder: (context, gridIndex) {
              final bibNumber = (gridIndex + 1).toString().padLeft(3, '0');
              final isUsed = usedBibs.contains(bibNumber);

              return ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isUsed ? RaceColors.disabled : RaceColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(RaceSpacings.radius),
                  ),
                ),
                onPressed: isUsed ? null : () => Navigator.pop(context, bibNumber),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      bibNumber,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: RaceColors.white,
                      ),
                    ),
                    Text(
                      'Finish',
                      style: TextStyle(
                        fontSize: RaceTextStyles.label.fontSize,
                        color: RaceColors.white
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    if (selectedBib != null) {
      setState(() {
        selectedIndex = index;
        selectedBibs[index] = selectedBib;
      });
    }
  }

  void _resetSelections() {
    setState(() {
      selectedIndex = null;
      selectedBibs.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mark Time button
        SizedBox(height: RaceSpacings.xs,),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: RaceColors.primary,
            foregroundColor: RaceColors.white,
            padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(RaceSpacings.radius),
            ),
          ),
          child: Text('Mark Time',
              style: TextStyle(fontSize: RaceTextStyles.subtitle.fontSize)),
        ),
       // const SizedBox(height: RaceSpacings.xs),

        // Pagination Controls
        Padding(
          padding: const EdgeInsets.symmetric(vertical:RaceSpacings.xs),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: _currentPage > 0
                    ? () {
                        setState(() {
                          _currentPage--;
                          selectedIndex = null;
                        });
                      }
                    : null,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: RaceColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(RaceSpacings.radiusLarge),
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
                          selectedIndex = null;
                        });
                      }
                    : null,
              ),
            ],
          ),
        ),

        // Header
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: RaceSpacings.xs),
          child: Row(
            children: [
              HeaderRow(title: 'No.', flex: 1),
              HeaderRow(title: 'Finish Time', flex: 2),
              HeaderRow(title: 'BIB', flex: 2),
              SizedBox(width: 50),
            ],
          ),
        ),
        const Divider(),

        // Updated List with pagination
        Expanded(
          child: ListView.builder(
            itemCount: _currentPageItems.length,
            itemBuilder: (context, index) {
              final globalIndex = _currentPage * _itemsPerPage + index;
              return TwoStepListTile(
                number: _currentPageItems[index]["number"]!,
                finishTime: _currentPageItems[index]["time"]!,
                isSelected: globalIndex == selectedIndex,
                selectedBib: selectedBibs[globalIndex],
                onSelectBib: () => _showBibSelectionDialog(globalIndex),
                onReset: () {
                  setState(() {
                    selectedBibs.remove(globalIndex);
                    if (globalIndex == selectedIndex) {
                      selectedIndex = null;
                    }
                  });
                },
              );
            },
          ),
        ),
      ],
    );
  }
}