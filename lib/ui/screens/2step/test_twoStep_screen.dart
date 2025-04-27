import 'package:flutter/material.dart';
import 'package:race_traking_app/ui/screens/2step/widget/TwoStep_list_tile.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/headerRow.dart';

class TwoStepScreen extends StatefulWidget {
  const TwoStepScreen({Key? key}) : super(key: key);

  @override
  State<TwoStepScreen> createState() => _TwoStepScreenState();
}

class _TwoStepScreenState extends State<TwoStepScreen> {
  int? selectedIndex;

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
  ];

  final Map<int, String> selectedBibs = {};
//dialog for bib selection
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
              child: Icon(
                Icons.close,  
                size: 32,     
                color: RaceColors.black
              ),
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
                  backgroundColor:
                      isUsed ? RaceColors.disabled : RaceColors.primary,
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
                      style: TextStyle(fontSize: RaceTextStyles.label.fontSize, color: RaceColors.white),
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: RaceColors.primary,
        title: const Text('Cycle Segment', style: TextStyle(color: Colors.white)),
        leading: BackButton(color: RaceColors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '11:11:11.00',
              style: TextStyle(fontSize: RaceTextStyles.heading.fontSize, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          // Tabs
          Row(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    'Grid View',
                    style: TextStyle(color: RaceColors.darkGrey),
                  ),
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    children: [
                      Text(
                        '2-Step View',
                        style: TextStyle(color: RaceColors.primary),
                      ),
                      Container(
                        height: 2,
                        color: RaceColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 16),
          // Pagination
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {},
              ),
              ...List.generate(
                7,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: index == 0 ? Colors.indigo.shade400 : Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      index.toString(),
                      style: TextStyle(
                        color: index == 0 ? Colors.white : Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {},
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Header
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  HeaderRow(
                    title: 'No.',
                    flex: 1,
                  ),
                  HeaderRow(
                    title: 'Finish Time',
                    flex: 2,
                  ),
                  HeaderRow(
                    title: 'BIB',
                    flex: 2,
                  ),
                  SizedBox(width:50 ),
                ],
              ),
            ),
          
          const Divider(),
          // List
          Expanded(
            child: ListView.builder(
              itemCount: finishTimes.length,
              itemBuilder: (context, index) {
                return TwoStepListTile(
                  number: finishTimes[index]["number"]!,
                  finishTime: finishTimes[index]["time"]!,
                  isSelected: index == selectedIndex,
                  selectedBib: selectedBibs[index],
                  onSelectBib: () => _showBibSelectionDialog(index),
                  onReset: () {
                    setState(() {
                      selectedBibs.remove(index);
                    });
                  },
                );
              },
            ),
          ),
         // const SizedBox(height: 15),

        ],
      ),
    );
  }
}
