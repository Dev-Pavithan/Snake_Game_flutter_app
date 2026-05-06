import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';
import '../services/storage_service.dart';
import '../services/haptic_service.dart';

final snakeProvider = StateNotifierProvider<SnakeLogic, SnakeState>((ref) {
  return SnakeLogic(ref);
});

class SnakeLogic extends StateNotifier<SnakeState> {
  final Ref ref;
  Timer? _timer;
  bool _shuffled100 = false;
  bool _shuffled200 = false;
  
  SnakeLogic(this.ref) : super(const SnakeState()) {
    _loadHighscore();
  }

  Future<void> _loadHighscore() async {
    final highscore = await ref.read(storageServiceProvider).getHighscore();
    state = state.copyWith(highscore: highscore);
  }

  void setLevel(GameLevel level) {
    state = state.copyWith(level: level);
  }

  void startGame() {
    final startX = (GameConstants.gridCols / 2).floor().toDouble();
    final startY = (GameConstants.gridRows / 2).floor().toDouble();
    _shuffled100 = false;
    _shuffled200 = false;
    
    List<Offset> obstacles = [];
    if (state.level == GameLevel.medium || state.level == GameLevel.hard) {
      obstacles = _generateMediumLevelObstacles();
    }

    state = state.copyWith(
      status: GameStatus.playing,
      score: 0,
      snake: [
        Offset(startX, startY),
        Offset(startX, startY + 1),
        Offset(startX, startY + 2),
      ],
      obstacles: obstacles,
      direction: SnakeDirection.up,
      gameOverReason: GameOverReason.none,
    );
    
    state = state.copyWith(food: _getRandomFood());
    _startTimer();
  }

  List<Offset> _generateMediumLevelObstacles() {
    List<Offset> obs = [];
    // Symmetric islands
    for(int i=4; i<7; i++) {
      for(int j=5; j<8; j++) obs.add(Offset(i.toDouble(), j.toDouble()));
    }
    for(int i=GameConstants.gridCols-7; i<GameConstants.gridCols-4; i++) {
      for(int j=5; j<8; j++) obs.add(Offset(i.toDouble(), j.toDouble()));
    }
    for(int i=4; i<7; i++) {
      for(int j=GameConstants.gridRows-8; j<GameConstants.gridRows-5; j++) obs.add(Offset(i.toDouble(), j.toDouble()));
    }
    for(int i=GameConstants.gridCols-7; i<GameConstants.gridCols-4; i++) {
      for(int j=GameConstants.gridRows-8; j<GameConstants.gridRows-5; j++) obs.add(Offset(i.toDouble(), j.toDouble()));
    }
    return obs;
  }

  void _shuffleObstacles() {
    final random = Random();
    List<Offset> newObs = [];
    int obstacleCount = 20; // Number of random blocks
    
    while (newObs.length < obstacleCount) {
      Offset pos = Offset(
        random.nextInt(GameConstants.gridCols).toDouble(),
        random.nextInt(GameConstants.gridRows).toDouble(),
      );
      
      // Don't place on snake or food
      if (!state.snake.contains(pos) && state.food != pos && !newObs.contains(pos)) {
        newObs.add(pos);
      }
    }
    state = state.copyWith(obstacles: newObs);
  }

  void _startTimer() {
    _timer?.cancel();
    Duration speed;
    switch(state.level) {
      case GameLevel.hard: speed = const Duration(milliseconds: 100); break;
      case GameLevel.medium: speed = const Duration(milliseconds: 150); break;
      case GameLevel.easy: default: speed = const Duration(milliseconds: 200); break;
    }
      
    _timer = Timer.periodic(speed, (timer) {
      _moveSnake();
    });
  }

  void setDirection(SnakeDirection newDir) {
    if (state.status != GameStatus.playing) return;
    if (state.direction == SnakeDirection.up && newDir == SnakeDirection.down) return;
    if (state.direction == SnakeDirection.down && newDir == SnakeDirection.up) return;
    if (state.direction == SnakeDirection.left && newDir == SnakeDirection.right) return;
    if (state.direction == SnakeDirection.right && newDir == SnakeDirection.left) return;
    state = state.copyWith(direction: newDir);
  }

  void _moveSnake() {
    if (state.status != GameStatus.playing) return;

    final List<Offset> newSnake = List.from(state.snake);
    Offset head = newSnake.first;

    switch (state.direction) {
      case SnakeDirection.up: head = Offset(head.dx, head.dy - 1); break;
      case SnakeDirection.down: head = Offset(head.dx, head.dy + 1); break;
      case SnakeDirection.left: head = Offset(head.dx - 1, head.dy); break;
      case SnakeDirection.right: head = Offset(head.dx + 1, head.dy); break;
    }

    // Wall collision
    if (head.dx < 0 || head.dx >= GameConstants.gridCols || 
        head.dy < 0 || head.dy >= GameConstants.gridRows) {
      _gameOver(GameOverReason.wall);
      return;
    }

    // Obstacle collision
    if (state.obstacles.contains(head)) {
      _gameOver(GameOverReason.obstacle);
      return;
    }

    // Tail collision
    if (newSnake.contains(head)) {
      _gameOver(GameOverReason.tail);
      return;
    }

    newSnake.insert(0, head);

    if (head == state.food) {
      ref.read(hapticServiceProvider).vibrate();
      final newScore = state.score + 10;
      state = state.copyWith(
        score: newScore,
        food: _getRandomFood(),
      );
      
      // Hard level shuffle logic
      if (state.level == GameLevel.hard) {
        if (newScore >= 100 && !_shuffled100) {
          _shuffled100 = true;
          _shuffleObstacles();
        } else if (newScore >= 200 && !_shuffled200) {
          _shuffled200 = true;
          _shuffleObstacles();
        }
      }
    } else {
      newSnake.removeLast();
    }

    state = state.copyWith(snake: newSnake);
  }

  Offset _getRandomFood() {
    final random = Random();
    Offset newFood;
    do {
      newFood = Offset(
        random.nextInt(GameConstants.gridCols).toDouble(),
        random.nextInt(GameConstants.gridRows).toDouble(),
      );
    } while (state.snake.contains(newFood) || state.obstacles.contains(newFood));
    return newFood;
  }

  void _gameOver(GameOverReason reason) {
    _timer?.cancel();
    state = state.copyWith(status: GameStatus.gameOver, gameOverReason: reason);
    if (state.score > state.highscore) {
      state = state.copyWith(highscore: state.score);
      ref.read(storageServiceProvider).saveHighscore(state.score);
    }
  }

  void pauseGame() {
    if (state.status == GameStatus.playing) {
      _timer?.cancel();
      state = state.copyWith(status: GameStatus.paused);
    } else if (state.status == GameStatus.paused) {
      state = state.copyWith(status: GameStatus.playing);
      _startTimer();
    }
  }

  void resetGame() {
    _timer?.cancel();
    state = const SnakeState().copyWith(highscore: state.highscore, level: state.level);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
