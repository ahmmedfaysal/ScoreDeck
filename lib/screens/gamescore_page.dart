import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import 'winner_page.dart';

class GameScorePage extends StatefulWidget {
  final bool isTeamMode;
  final List<String> playerNames;
  final int targetScore;
  final List<Map<String, dynamic>>? previousTableData;
  final List<Map<String, dynamic>>? previousOperations;
  final List<bool>? previousIsRowEditable;
  final String? previousSelectedTrump;
  final bool? previousTrumpShown;

  const GameScorePage({
    super.key,
    required this.isTeamMode,
    required this.playerNames,
    required this.targetScore,
    this.previousTableData,
    this.previousOperations,
    this.previousIsRowEditable,
    this.previousSelectedTrump,
    this.previousTrumpShown,
  });

  @override
  _GameScorePageState createState() => _GameScorePageState();
}

class _GameScorePageState extends State<GameScorePage> {
  List<List<TextEditingController>> scoreControllers = [];
  List<bool> isRowEditable = [];
  List<List<String?>> operations = [];
  String? selectedTrump;
  bool trumpShown = false;

  @override
void initState() {
  super.initState();
  if (widget.previousTableData != null &&
      widget.previousOperations != null &&
      widget.previousIsRowEditable != null) {
    // Restore previous state
    scoreControllers = widget.previousTableData!
        .map((rowMap) => widget.playerNames
            .map((name) => TextEditingController(text: rowMap[name]?.toString() ?? ''))
            .toList())
        .toList();
    operations = widget.previousOperations!
        .map((rowMap) => widget.playerNames
            .map((name) => rowMap[name]?.toString())
            .toList())
        .toList();
    isRowEditable = List<bool>.from(widget.previousIsRowEditable!);
    selectedTrump = widget.previousSelectedTrump;
    trumpShown = widget.previousTrumpShown ?? false;
  } else {
    _addNewRound();
  }
}

  void _addNewRound() {
    scoreControllers.add(List.generate(
      widget.playerNames.length,
      (_) => TextEditingController(),
    ));
    operations.add(List.generate(widget.playerNames.length, (_) => null));
    isRowEditable.add(true);
    setState(() {
      selectedTrump = null;
      trumpShown = false;
    });
  }

  void _finalizeRound(int roundIndex) {
    setState(() {
      isRowEditable[roundIndex] = false;
      _addNewRound();
    });
    _checkForWinner();
  }

  void _applyOperation(int playerIndex, String op) {
    int roundIndex = scoreControllers.length - 1;
    setState(() {
      operations[roundIndex][playerIndex] = op;

      int prevScore = 0;
      if (roundIndex > 0) {
        String prevText = scoreControllers[roundIndex - 1][playerIndex].text;
        if (prevText.contains('=')) {
          prevScore = int.tryParse(prevText.split('=').last.trim()) ?? 0;
        } else {
          prevScore = int.tryParse(prevText.trim()) ?? 0;
        }
      }

      int delta = int.tryParse(scoreControllers[roundIndex][playerIndex].text) ?? 0;
      int newScore = op == '+' ? prevScore + delta : prevScore - delta;

      scoreControllers[roundIndex][playerIndex].text = "$prevScore $op $delta = $newScore";

      if (!operations[roundIndex].contains(null)) {
        isRowEditable[roundIndex] = false;
        _addNewRound();
      }
    });
    _checkForWinner();
  }

  List<int> _calculateFinalScores() {
    List<int> finalScores = List.filled(widget.playerNames.length, 0);
    for (var row in scoreControllers) {
      for (int i = 0; i < row.length; i++) {
        String text = row[i].text;
        if (text.contains('=')) {
          int score = int.tryParse(text.split('=').last.trim()) ?? 0;
          finalScores[i] = score;
        }
      }
    }
    return finalScores;
  }

  void _checkForWinner() async {
    List<int> scores = _calculateFinalScores();
    for (int i = 0; i < scores.length; i++) {
      if (scores[i] >= widget.targetScore) {
        String winner = widget.playerNames[i];
        await _saveGameTable(continueLater: false, winner: winner);
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => WinnerPage(winner: winner),
            ),
          );
        }
        return;
      }
    }
  }

  Widget _buildTrumpSelector() {
    if (selectedTrump != null || trumpShown) return Container();
    List<String> trumpIcons = ['♠', '♥', '♦', '♣'];
    return Wrap(
      alignment: WrapAlignment.center,
      children: trumpIcons.map((icon) {
        return IconButton(
          icon: Text(icon, style: TextStyle(fontSize: 28)),
          onPressed: () {
            setState(() {
              selectedTrump = icon;
            });
          },
        );
      }).toList(),
    );
  }

  Widget _buildTrumpButton() {
    if (selectedTrump == null && !trumpShown) {
      return ElevatedButton(
        onPressed: () {},
        child: Text("Set Trump"),
      );
    } else if (!trumpShown) {
      return ElevatedButton(
        onPressed: () {
          setState(() {
            trumpShown = true;
          });
        },
        child: Text("Show Trump"),
      );
    } else {
      return ElevatedButton(
        onPressed: () {},
        child: Text(selectedTrump ?? ""),
      );
    }
  }

  Widget _buildTable() {
    List<int> finalScores = _calculateFinalScores();

    List<TableRow> rows = [
      TableRow(
        children: finalScores
            .map((score) => Container(
                  padding: EdgeInsets.all(6),
                  color: Colors.deepPurple.shade50,
                  child: Text(
                    '$score',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ))
            .toList(),
      ),
      TableRow(
        children: widget.playerNames
            .map((name) => Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.deepPurple.shade100,
                  child: Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ))
            .toList(),
      ),
      for (int rowIndex = 0; rowIndex < scoreControllers.length; rowIndex++)
        TableRow(
          children: List.generate(widget.playerNames.length, (colIndex) {
            return Column(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  child: isRowEditable[rowIndex]
                      ? TextField(
                          controller: scoreControllers[rowIndex][colIndex],
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(border: InputBorder.none),
                          textAlign: TextAlign.center,
                        )
                      : Center(
                          child: Text(
                            scoreControllers[rowIndex][colIndex].text,
                            textAlign: TextAlign.center,
                          ),
                        ),
                ),
                if (rowIndex == scoreControllers.length - 1 &&
                    isRowEditable[rowIndex] &&
                    operations[rowIndex][colIndex] == null)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: FloatingActionButton(
                          heroTag: 'plus_${rowIndex}_$colIndex',
                          onPressed: () => _applyOperation(colIndex, '+'),
                          backgroundColor: Colors.green,
                          child: Icon(Icons.add, size: 14),
                        ),
                      ),
                      SizedBox(width: 4),
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: FloatingActionButton(
                          heroTag: 'minus_${rowIndex}_$colIndex',
                          onPressed: () => _applyOperation(colIndex, '-'),
                          backgroundColor: Colors.red,
                          child: Icon(Icons.remove, size: 14),
                        ),
                      ),
                    ],
                  ),
              ],
            );
          }),
        ),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Table(
            border: TableBorder.all(color: Colors.black),
            columnWidths: {
              for (int i = 0; i < widget.playerNames.length; i++) i: FlexColumnWidth(1),
            },
            children: rows,
          ),
        ),
      ),
    );
  }

  void _goToHome(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomePage()),
    );
  }

  Future<void> _saveGameTable({required bool continueLater, String? winner}) async {
    List<Map<String, String>> tableData = scoreControllers.map((row) {
      Map<String, String> rowMap = {};
      for (int i = 0; i < widget.playerNames.length; i++) {
        rowMap[widget.playerNames[i]] = row[i].text;
      }
      return rowMap;
    }).toList();

    List<Map<String, String>> operationsData = operations.map((row) {
      Map<String, String> rowMap = {};
      for (int i = 0; i < widget.playerNames.length; i++) {
        rowMap[widget.playerNames[i]] = row[i] ?? '';
      }
      return rowMap;
    }).toList();

    final data = {
      'isTeamMode': widget.isTeamMode,
      'playerNames': widget.playerNames,
      'targetScore': widget.targetScore,
      'tableData': tableData,
      'operations': operationsData,
      'isRowEditable': isRowEditable,
      'selectedTrump': selectedTrump,
      'trumpShown': trumpShown,
      'timestamp': FieldValue.serverTimestamp(),
      if (winner != null) 'winner': winner,
    };

    final collection = continueLater ? 'continue_games' : 'gamescores';
    await FirebaseFirestore.instance.collection(collection).add(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      appBar: AppBar(
        title: Text("Game Score", style: TextStyle(color: Colors.black)),
        backgroundColor: const Color(0xFFF8F6F6),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(flex: 7, child: _buildTable()),
          Expanded(
            flex: 3,
            child: Column(
              children: [
                _buildTrumpButton(),
                _buildTrumpSelector(),
                ElevatedButton(
                  onPressed: () {
                    int currentIndex = scoreControllers.length - 1;
                    _finalizeRound(currentIndex);
                  },
                  child: Text("End Round"),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        // Find winner (highest score)
                        List<int> scores = _calculateFinalScores();
                        int maxScore = scores.reduce((a, b) => a > b ? a : b);
                        int winnerIndex = scores.indexOf(maxScore);
                        String winner = widget.playerNames[winnerIndex];

                        await _saveGameTable(continueLater: false, winner: winner);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Game table saved!')),
                        );
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => WinnerPage(winner: winner),
                          ),
                        );
                      },
                      child: Text("End Game"),
                    ),
                    ElevatedButton(onPressed: () {}, child: Text("Edit")),
                    ElevatedButton(
                      onPressed: () async {
                        await _saveGameTable(continueLater: true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Game saved to continue later!')),
                        );
                        _goToHome(context);
                      },
                      child: Text("Continue Later"),
                    ),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}