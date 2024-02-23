import 'dart:math';
import 'package:flutter/material.dart';
import 'PlayerVsComputerPage.dart';

void main() {
  runApp(TicTacToe());
}

class TicTacToe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tic Tac Toe',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TicTacToeBoard(),
    );
  }
}

class TicTacToeBoard extends StatefulWidget {
  @override
  _TicTacToeBoardState createState() => _TicTacToeBoardState();
}

class _TicTacToeBoardState extends State<TicTacToeBoard> {
  List<List<String>>? _board;
  bool? _player1Turn;

  @override
  void initState() {
    super.initState();
    _initializeBoard();
  }

  void _initializeBoard() {
    _board = List.generate(3, (_) => List.filled(3, ''));
    _player1Turn = true;
  }

  void _handleTap(int row, int col) {
    if (_board![row][col] == '') {
      setState(() {
        _board![row][col] = _player1Turn! ? 'X' : 'O';
        _player1Turn = !_player1Turn!;
      });
      _checkForWinner();
    }
  }

  void _checkForWinner() {
    // Check rows
    for (int i = 0; i < 3; i++) {
      if (_board![i][0] != '' &&
          _board![i][0] == _board![i][1] &&
          _board![i][1] == _board![i][2]) {
        _showWinnerDialog(_board![i][0]);
        return;
      }
    }

    // Check columns
    for (int i = 0; i < 3; i++) {
      if (_board![0][i] != '' &&
          _board![0][i] == _board![1][i] &&
          _board![1][i] == _board![2][i]) {
        _showWinnerDialog(_board![0][i]);
        return;
      }
    }

    // Check diagonals
    if (_board![0][0] != '' &&
        _board![0][0] == _board![1][1] &&
        _board![1][1] == _board![2][2]) {
      _showWinnerDialog(_board![0][0]);
      return;
    }
    if (_board![0][2] != '' &&
        _board![0][2] == _board![1][1] &&
        _board![1][1] == _board![2][0]) {
      _showWinnerDialog(_board![0][2]);
      return;
    }

    // Check for draw
    if (!_board!.any((row) => row.any((cell) => cell == ''))) {
      _showDrawDialog();
    }
  }

  void _showWinnerDialog(String winner) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Winner'),
        content: Text('$winner wins!'),
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
    _board = List.generate(3, (_) => List.filled(3, ''));
    _player1Turn = true;
  });
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tic Tac Toe'),
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
                      onTap: () => _handleTap(i, j),
                      child: Container(
                        width: 75,
                        height: 75,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black),
                        ),
                        child: Center(
                          child: Text(
                            _board![i][j],
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24.0),
            Text(
              _player1Turn! ? 'Player 1\'s turn (X)' : 'Player 2\'s turn (O)',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PlayerVsComputerPage(
                      initialBoard: _board,
                      player1Turn: _player1Turn,
                    ),
                  ),
                );
              },
              child: Text('Play with Computer'),
            ),
          ],
        ),
      ),
    );
  }
}