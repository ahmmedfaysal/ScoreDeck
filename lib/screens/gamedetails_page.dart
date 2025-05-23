import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GameDetailsPage extends StatelessWidget {
  final QueryDocumentSnapshot gameDoc;
  const GameDetailsPage({super.key, required this.gameDoc});

  @override
  Widget build(BuildContext context) {
    final playerNames = List<String>.from(gameDoc['playerNames'] ?? []);
    final tableData = List<Map<String, dynamic>>.from(gameDoc['tableData'] ?? []);
    final winner = gameDoc.data().toString().contains('winner')
        ? gameDoc['winner'] as String
        : 'N/A';
    final selectedTrump = gameDoc['selectedTrump'];
    final timestamp = gameDoc['timestamp'] != null
        ? (gameDoc['timestamp'] as Timestamp).toDate()
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F6F6),
        elevation: 0,
        title: const Text('Game Details', style: TextStyle(color: Colors.black)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Card(
          color: Colors.deepPurple.shade50,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Players: ${playerNames.join(', ')}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.deepPurple,
                    ),
                  ),
                  if (selectedTrump != null && selectedTrump != '')
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Trump: $selectedTrump',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                  if (timestamp != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'Played on: ${timestamp.toLocal()}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Text(
                    'Score Table',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.deepPurple.shade700,
                    ),
                  ),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: playerNames
                          .map((name) => DataColumn(
                                label: Text(
                                  name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
                                  ),
                                ),
                              ))
                          .toList(),
                      rows: tableData
                          .map<DataRow>((row) => DataRow(
                                cells: playerNames
                                    .map((name) => DataCell(
                                          Text(row[name]?.toString() ?? ''),
                                        ))
                                    .toList(),
                              ))
                          .toList(),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Winner',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.deepPurple.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          winner,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}