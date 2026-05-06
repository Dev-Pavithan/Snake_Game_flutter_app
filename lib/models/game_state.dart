import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum SnakeDirection { up, down, left, right }
enum GameStatus { idle, playing, paused, gameOver }
enum GameOverReason { wall, tail, obstacle, none }
enum GameLevel { easy, medium, hard }

class SnakeState extends Equatable {
  final List<Offset> snake;
  final Offset food;
  final List<Offset> obstacles;
  final SnakeDirection direction;
  final GameStatus status;
  final GameLevel level;
  final int score;
  final int highscore;
  final GameOverReason gameOverReason;

  const SnakeState({
    this.snake = const [Offset(5, 5), Offset(5, 6), Offset(5, 7)],
    this.food = const Offset(10, 10),
    this.obstacles = const [],
    this.direction = SnakeDirection.up,
    this.status = GameStatus.idle,
    this.level = GameLevel.easy,
    this.score = 0,
    this.highscore = 0,
    this.gameOverReason = GameOverReason.none,
  });

  SnakeState copyWith({
    List<Offset>? snake,
    Offset? food,
    List<Offset>? obstacles,
    SnakeDirection? direction,
    GameStatus? status,
    GameLevel? level,
    int? score,
    int? highscore,
    GameOverReason? gameOverReason,
  }) {
    return SnakeState(
      snake: snake ?? this.snake,
      food: food ?? this.food,
      obstacles: obstacles ?? this.obstacles,
      direction: direction ?? this.direction,
      status: status ?? this.status,
      level: level ?? this.level,
      score: score ?? this.score,
      highscore: highscore ?? this.highscore,
      gameOverReason: gameOverReason ?? this.gameOverReason,
    );
  }

  @override
  List<Object?> get props => [snake, food, obstacles, direction, status, level, score, highscore, gameOverReason];
}
