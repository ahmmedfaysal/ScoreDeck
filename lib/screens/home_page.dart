import 'package:flutter/material.dart';
import 'login_page.dart';
import 'createnewgame_page.dart';
import 'history_page.dart';
import 'gamescore_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'aboutus_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  String formatPlayerNames(List<dynamic> names) {
    if (names.isEmpty) return '';
    if (names.length == 1) return names.first;
    if (names.length == 2) return '${names[0]} & ${names[1]}';
    return '${names.sublist(0, names.length - 1).join(', ')} & ${names.last}';
  }

  @override
  Widget build(BuildContext context) {  
    return Scaffold(
      backgroundColor: Color(0xFFF8F6F6),
      appBar: AppBar(
        backgroundColor: Color(0xFFF8F6F6),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text('ScoreDeck Home', style: TextStyle(color: Colors.black)),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Continue Games Section
            Container(
              constraints: BoxConstraints(
                maxHeight: 340,
              ),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Continue...",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 10),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('continue_games')
                          .orderBy('timestamp', descending: true)
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Center(child: CircularProgressIndicator());
                        }
                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return Text("No games to continue.");
                        }
                        return ListView.builder(
                          itemCount: snapshot.data!.docs.length,
                          itemBuilder: (context, index) {
                            final doc = snapshot.data!.docs[index];
                            final docData = doc.data() as Map<String, dynamic>;
                            final playerNames = docData['playerNames'] as List<dynamic>;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                formatPlayerNames(playerNames),
                                style: TextStyle(color: Colors.deepPurple),
                              ),
                              trailing: Icon(Icons.play_arrow, color: Colors.deepPurple),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => GameScorePage(
                                      isTeamMode: docData['isTeamMode'] ?? false,
                                      playerNames: List<String>.from(docData['playerNames'] ?? []),
                                      targetScore: docData['targetScore'] ?? 0,
                                      previousTableData: List<Map<String, dynamic>>.from(docData['tableData'] ?? []),
                                      previousOperations: List<Map<String, dynamic>>.from(docData['operations'] ?? []),
                                      previousIsRowEditable: List<bool>.from(docData['isRowEditable'] ?? []),
                                      previousSelectedTrump: docData['selectedTrump'],
                                      previousTrumpShown: docData['trumpShown'] ?? false,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 60),
            Center(
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CreateNewGamePage()),
                      );
                    },
                    icon: Icon(Icons.add, color: Colors.white),
                    label: Text('Create New Game', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => HistoryPage()),
                      );
                    },
                    icon: Icon(Icons.history, color: Colors.white),
                    label: Text('History', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => AboutUsPage()),
                      );
                    },
                    icon: Icon(Icons.info, color: Colors.white),
                    label: Text('About Us', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      minimumSize: Size(250, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}