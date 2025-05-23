// File: lib/screens/createnewgame_page.dart
import 'package:flutter/material.dart';
import 'gamescore_page.dart';

class CreateNewGamePage extends StatefulWidget {
  const CreateNewGamePage({super.key});

  @override
  _CreateNewGamePageState createState() => _CreateNewGamePageState();
}

class _CreateNewGamePageState extends State<CreateNewGamePage> {
  bool isTeamSelected = false;
  bool isSingleSelected = false;

  final TextEditingController player1Controller = TextEditingController();
  final TextEditingController player2Controller = TextEditingController();
  final TextEditingController player3Controller = TextEditingController();
  final TextEditingController player4Controller = TextEditingController();
  final TextEditingController scoreController = TextEditingController();

  final TextEditingController team1Controller = TextEditingController();
  final TextEditingController team2Controller = TextEditingController();
  final TextEditingController teamScoreController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F6F6),
      appBar: AppBar(
        title: Text("Create New Game", style: TextStyle(color: Colors.black)),
        backgroundColor: Color(0xFFF8F6F6),
        iconTheme: IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isSingleSelected = true;
                    isTeamSelected = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isSingleSelected ? Colors.deepPurple : Colors.deepPurple.shade100,
                ),
                child: Text("Single", style: TextStyle(color: Colors.white)),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isTeamSelected = true;
                    isSingleSelected = false;
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isTeamSelected ? Colors.deepPurple : Colors.deepPurple.shade100,
                ),
                child: Text("Team", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: isSingleSelected ? buildSingleForm(context) : isTeamSelected ? buildTeamForm(context) : SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSingleForm(BuildContext context) {
    return Column(
      children: [
        TextField(controller: player1Controller, decoration: InputDecoration(labelText: "Player 1")),
        TextField(controller: player2Controller, decoration: InputDecoration(labelText: "Player 2")),
        TextField(controller: player3Controller, decoration: InputDecoration(labelText: "Player 3")),
        TextField(controller: player4Controller, decoration: InputDecoration(labelText: "Player 4")),
        TextField(controller: scoreController, decoration: InputDecoration(labelText: "Game Score"), keyboardType: TextInputType.number),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScorePage(
                  isTeamMode: false,
                  playerNames: [
                    player1Controller.text,
                    player2Controller.text,
                    player3Controller.text,
                    player4Controller.text,
                  ],
                  targetScore: int.tryParse(scoreController.text) ?? 0,
                ),
              ),
            );
          },
          child: Text('Create'),
        )
      ],
    );
  }

  Widget buildTeamForm(BuildContext context) {
    return Column(
      children: [
        TextField(controller: team1Controller, decoration: InputDecoration(labelText: "Team 1")),
        TextField(controller: team2Controller, decoration: InputDecoration(labelText: "Team 2")),
        TextField(controller: teamScoreController, decoration: InputDecoration(labelText: "Target Score"), keyboardType: TextInputType.number),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameScorePage(
                  isTeamMode: true,
                  playerNames: [
                    team1Controller.text,
                    team2Controller.text,
                  ],
                  targetScore: int.tryParse(teamScoreController.text) ?? 0,
                ),
              ),
            );
          },
          child: Text('Create'),
        )
      ],
    );
  }
}
