import 'package:flutter/material.dart';
import 'package:race_traking_app/model/raceResult.dart';
import 'package:race_traking_app/ui/screens/resultBoard/widget/resultBoard_list_tile.dart';
import 'package:race_traking_app/ui/theme/theme.dart';
import 'package:race_traking_app/ui/widgets/headerRow.dart';
import 'package:race_traking_app/ui/widgets/navBar.dart';

class ResultBoardScreen extends StatefulWidget {
  const ResultBoardScreen({Key? key}) : super(key: key);

  @override
  State<ResultBoardScreen> createState() => _ResultBoardScreenState();
}

class _ResultBoardScreenState extends State<ResultBoardScreen> {
  int _rowsPerPage = 5;
  int _currentPage = 1;
  final int _totalItems = 100;

  List<RaceResult> _results = [];

  @override
  void initState() {
    super.initState();
    //dummy data
    _results = List.generate(
      20,
      (index) => RaceResult(
        rank: index + 1,
        bib: '001',
        name: 'mike',
        cycleTime: '10:10:10.10',
        runTime: '10:10:10.10',
        swimTime: '10:10:10.10',
        duration: '30:30:30.30',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: RaceColors.white,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: RaceColors.primary,
            width: double.infinity,
            child: Center(
              child: Text(
                'RESULT BOARD',
                style: TextStyle(
                  color: RaceColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(
                width: 1000,
                child: Column(
                  // crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Table Header
                    Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(color: RaceColors.lightGrey),
                          top: BorderSide(color: RaceColors.lightGrey),
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          children: [
                            HeaderRow(title: 'Rank', flex: 1),
                            HeaderRow(title: 'BIB', flex: 1),
                            HeaderRow(title: 'Name', flex: 1),
                            HeaderRow(title: 'Cycle', flex: 2),
                            HeaderRow(title: 'Run', flex: 2),
                            HeaderRow(title: 'Swim', flex: 2),
                            HeaderRow(title: 'Duration', flex: 2),
                          ],
                        ),
                      ),
                    ),

                    // Table Content
                    Expanded(
                      child: Stack(
                        children: [
                          ListView.builder(
                            itemCount: _getPageItemCount(),
                            itemBuilder: (context, index) {
                              final resultIndex =
                                  ((_currentPage - 1) * _rowsPerPage) + index;
                              if (resultIndex >= _results.length) {
                                return null;
                              }

                              return ResultListTile(
                                result: _results[resultIndex],
                                isEven: resultIndex % 2 == 0,
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Editing result for ${_results[resultIndex].name}')),
                                  );
                                },
                              );
                            },
                          ),
                          if (_results.isEmpty)
                            const Center(child: Text('No results available')),
                        ],
                      ),
                    ),

                    // Pagination Controls
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: RaceColors.primary,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Row per page',
                                style: TextStyle(color: RaceColors.white),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border.all(color: RaceColors.white),
                                ),
                                child: DropdownButton<int>(
                                  value: _rowsPerPage,
                                  dropdownColor: RaceColors.primary,
                                  iconEnabledColor: RaceColors.white,
                                  style: TextStyle(color: RaceColors.white),
                                  underline: Container(),
                                  items: [5, 10, 20, 50].map((int value) {
                                    return DropdownMenuItem<int>(
                                      value: value,
                                      child: Text('$value'),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _rowsPerPage = newValue!;
                                      _currentPage =
                                          1; // Reset to first page when changing rows per page
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '1-5 of $_totalItems',
                                style: const TextStyle(color: Colors.white),
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_left,
                                    color: Colors.white),
                                onPressed: _currentPage > 1
                                    ? () {
                                        setState(() {
                                          _currentPage--;
                                        });
                                      }
                                    : null,
                              ),
                              IconButton(
                                icon: const Icon(Icons.chevron_right,
                                    color: Colors.white),
                                onPressed:
                                    (_currentPage * _rowsPerPage) < _totalItems
                                        ? () {
                                            setState(() {
                                              _currentPage++;
                                            });
                                          }
                                        : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Bottom Navigation

          const Navbar(
            selectedIndex: 3,
          ),
        ],
      ),
    );
  }

  // Calculate the total number of pages based on the number of items and rows per page
  int _getPageItemCount() {
    final remainingItems = _totalItems - ((_currentPage - 1) * _rowsPerPage);
    return remainingItems < _rowsPerPage ? remainingItems : _rowsPerPage;
  }
}
