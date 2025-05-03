import 'package:flutter/material.dart';
import 'package:race_traking_app/model/race_result_board.dart';
import 'package:race_traking_app/model/segment_time.dart';
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

  List<RaceResultItem> _results = [];
   String _getCurrentRange() {
    final startIndex = ((_currentPage - 1) * _rowsPerPage) + 1;
    final endIndex = _currentPage * _rowsPerPage;
    final actualEnd = endIndex > _totalItems ? _totalItems : endIndex;
    return '$startIndex-$actualEnd';
  }
  
  @override
  void initState() {
    super.initState();
    //dummy data
    _results = List.generate(
      20,
      (index) => RaceResultItem(
        bibNumber: '${(index + 1).toString().padLeft(3, '0')}',
        participantName: 'Participant ${index + 1}',
        segmentTimes: {
          'Cycle': SegmentTime(
            participantBibNumber: '${(index + 1).toString().padLeft(3, '0')}',
            segmentName: 'Cycle',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(minutes: 30)),
          ),
          'Run': SegmentTime(
            participantBibNumber: '${(index + 1).toString().padLeft(3, '0')}',
            segmentName: 'Run',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(minutes: 20)),
          ),
          'Swim': SegmentTime(
            participantBibNumber: '${(index + 1).toString().padLeft(3, '0')}',
            segmentName: 'Swim',
            startTime: DateTime.now(),
            endTime: DateTime.now().add(const Duration(minutes: 15)),
          ),
        },
        totalDuration: const Duration(minutes: 65),
        rank: index + 1,
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
              style: RaceTextStyles.body.copyWith(
                color: RaceColors.white,
                fontWeight: FontWeight.bold,
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
                            HeaderRow(title: 'Name', flex: 2),
                            HeaderRow(title: 'Cycle Time', flex: 1),
                            HeaderRow(title: 'Run Time', flex: 1),
                            HeaderRow(title: 'Swim Time', flex: 1),
                            HeaderRow(title: 'Duration', flex: 1),
                            
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
                                onEdit: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(
                                            'Editing result for ${_results[resultIndex].participantName}')),
                                  );
                                },
                                onDelete: () => _deleteResult(resultIndex),
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
                                  borderRadius: BorderRadius.circular(RaceSpacings.radius),
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
                                  if (newValue != null) {
                                    setState(() {
                                      _rowsPerPage = newValue;
                                      // Adjust current page to maintain approximate scroll position
                                      _currentPage = ((_currentPage - 1) * _rowsPerPage ~/ newValue) + 1;
                                    });
                                  }
                                },
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Text(
                                '${_getCurrentRange()} of $_totalItems',
                                style: TextStyle(color: RaceColors.white),
                              ),
                              IconButton(
                                icon: Icon(Icons.chevron_left,
                                    color: RaceColors.white),
                                onPressed: _currentPage > 1
                                    ? () {
                                        setState(() {
                                          _currentPage--;
                                        });
                                      }
                                    : null,
                              ),
                              IconButton(
                                icon: Icon(Icons.chevron_right,
                                    color: RaceColors.white),
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
 void _deleteResult(int index) {
    final deletedResult = _results[index];
    setState(() {
      _results.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Result deleted'),
        action: SnackBarAction(
          label: 'Undo',
          onPressed: () {
            setState(() {
              _results.insert(index, deletedResult);
            });
          },
        ),
      ),
    );
  }
}
