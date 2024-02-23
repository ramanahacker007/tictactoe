import 'dart:math';
import 'package:flutter/material.dart';

class PlayerVsComputerPage extends StatefulWidget {
  final List<List<String>>? initialBoard;
  final bool? player1Turn;

  const PlayerVsComputerPage({
    Key? key,
    required this.initialBoard,
    required this.player1Turn,
  }) : super(key: key);

  @override
  _PlayerVsComputerPageState createState() => _PlayerVsComputerPageState();
}

class _PlayerVsComputerPageState extends State<PlayerVsComputerPage> {
  late List<List<String>> _board;
  late bool _player1Turn;
  String? _winner;

  @override
  void initState() {
    super.initState();
    _board = List.generate(3, (_) => List.filled(3, ''));
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        _board[i][j] = widget.initialBoard![i][j];
      }
    }
    _player1Turn = widget.player1Turn!;
    _winner = null;
  }

  void _handleManualTap(int row, int col) {
    if (_board[row][col] == '' && _winner == null) {
      setState(() {
        _board[row][col] = _player1Turn ? 'X' : 'O';
        _player1Turn = !_player1Turn;
      });
      _checkForWinner();
      if (!_player1Turn && _winner == null) {
        _computerMove();
      }
    }
  }

  void _computerMove() {
    // Simulate computer move here
    // For simplicity, let's randomly pick an empty cell
    List<int> emptyCells = [];
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (_board[i][j] == '') {
          emptyCells.add(i * 3 + j);
        }
      }
    }
    if (emptyCells.isNotEmpty) {
      int randomIndex = Random().nextInt(emptyCells.length);
      int selectedCell = emptyCells[randomIndex];
      int row = selectedCell ~/ 3;
      int col = selectedCell % 3;
      setState(() {
        _board[row][col] = _player1Turn ? 'X' : 'O';
        _player1Turn = !_player1Turn;
      });
      _checkForWinner();
    }
  }

  void _checkForWinner() {
  // Check rows
  for (int i = 0; i < 3; i++) {
    if (_board[i][0] != '' &&
        _board[i][0] == _board[i][1] &&
        _board[i][1] == _board[i][2]) {
      _showWinnerDialog(_board[i][0]);
      return;
    }
  }

  // Check columns
  for (int i = 0; i < 3; i++) {
    if (_board[0][i] != '' &&
        _board[0][i] == _board[1][i] &&
        _board[1][i] == _board[2][i]) {
      _showWinnerDialog(_board[0][i]);
      return;
    }
  }

  // Check diagonals
  if (_board[0][0] != '' &&
      _board[0][0] == _board[1][1] &&
      _board[1][1] == _board[2][2]) {
    _showWinnerDialog(_board[0][0]);
    return;
  }
  if (_board[0][2] != '' &&
      _board[0][2] == _board[1][1] &&
      _board[1][1] == _board[2][0]) {
    _showWinnerDialog(_board[0][2]);
    return;
  }

  // Check for draw
  if (!_board.any((row) => row.any((cell) => cell == ''))) {
    _showDrawDialog();
  }
}

void _showWinnerDialog(String winner) {
  setState(() {
    _winner = winner;
  });
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Winner'),
      content: Text('$_winner wins!'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _resetBoard();
          },
          child: Text('Play Again'),
        ),
      ],
    ),
  );
}

void _showDrawDialog() {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('Draw'),
      content: Text('It\'s a draw!'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            _resetBoard();
          },
          child: Text('Play Again'),
        ),
      ],
    ),
  );
}

void _resetBoard() {
  setState(() {
    _winner = null;
    _board = List.generate(3, (_) => List.filled(3, ''));
    _player1Turn = true; // Assuming player 1 always starts first
  });
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Player vs Computer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            for (int i = 0; i < 3; i++)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  for (int j = 0; j < 3; j++)
                    GestureDetector(
                      onTap: () => _handleManualTap(i, j),
                      child: Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            _board[i][j],
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            if (_winner != null)
              Text(
                '$_winner wins!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Go back to the previous page
              },
              child: Text('Back to Main Menu'),
            ),
          ],
        ),
      ),
    );
  }
}
