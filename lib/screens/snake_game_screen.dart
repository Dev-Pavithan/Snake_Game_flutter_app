import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../game/game_provider.dart';
import '../models/game_state.dart';
import '../utils/constants.dart';

class SnakeGameScreen extends ConsumerWidget {
  const SnakeGameScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(snakeProvider);
    final logic = ref.read(snakeProvider.notifier);

    return Scaffold(
      backgroundColor: GameConstants.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(state, logic),
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanUpdate: (details) {
                  if (details.delta.dx.abs() > details.delta.dy.abs()) {
                    if (details.delta.dx < -5) logic.setDirection(SnakeDirection.left);
                    if (details.delta.dx > 5) logic.setDirection(SnakeDirection.right);
                  } else {
                    if (details.delta.dy < -5) logic.setDirection(SnakeDirection.up);
                    if (details.delta.dy > 5) logic.setDirection(SnakeDirection.down);
                  }
                },
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: RadialGradient(
                            colors: [
                              GameConstants.secondaryColor.withOpacity(0.1),
                              GameConstants.backgroundColor,
                            ],
                            radius: 1.5,
                          ),
                        ),
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: _buildGameBoard(state),
                    ),

                    if (state.status == GameStatus.idle)
                      _buildOverlay(
                        'PIXEL SERPENT',
                        'CHOOSE YOUR CHALLENGE',
                        Icons.play_arrow_rounded,
                        onAction: () => logic.startGame(),
                        buttonText: 'START GAME',
                        child: _buildLevelSelector(state, logic),
                      ),
                    if (state.status == GameStatus.gameOver)
                      _buildOverlay(
                        _getGameOverTitle(state.gameOverReason),
                        _getGameOverMessage(state.gameOverReason),
                        _getGameOverIcon(state.gameOverReason),
                        onAction: () => logic.startGame(),
                        buttonText: 'RETRY',
                        isGameOver: true,
                      ),
                    if (state.status == GameStatus.paused)
                      _buildOverlay(
                        'PAUSED',
                        'GAME IS ON HOLD',
                        Icons.pause_rounded,
                        onAction: () => logic.pauseGame(),
                        buttonText: 'RESUME',
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getGameOverTitle(GameOverReason reason) {
    switch (reason) {
      case GameOverReason.wall: return 'Oops!';
      case GameOverReason.tail: return 'Uh-oh!';
      case GameOverReason.obstacle: return 'Ouch!';
      default: return 'GAME OVER';
    }
  }

  String _getGameOverMessage(GameOverReason reason) {
    switch (reason) {
      case GameOverReason.wall: return 'You kissed the wall!';
      case GameOverReason.tail: return 'You bit your own tail!';
      case GameOverReason.obstacle: return 'You hit an obstacle!';
      default: return 'TRY AGAIN';
    }
  }

  IconData _getGameOverIcon(GameOverReason reason) {
    switch (reason) {
      case GameOverReason.wall: return Icons.sentiment_very_dissatisfied_rounded;
      case GameOverReason.tail: return Icons.pets_rounded;
      case GameOverReason.obstacle: return Icons.warning_rounded;
      default: return Icons.refresh_rounded;
    }
  }

  Widget _buildLevelSelector(SnakeState state, SnakeLogic logic) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLevelButton('EASY', GameLevel.easy, state.level == GameLevel.easy, () => logic.setLevel(GameLevel.easy)),
          const SizedBox(width: 10),
          _buildLevelButton('MED', GameLevel.medium, state.level == GameLevel.medium, () => logic.setLevel(GameLevel.medium)),
          const SizedBox(width: 10),
          _buildLevelButton('HARD', GameLevel.hard, state.level == GameLevel.hard, () => logic.setLevel(GameLevel.hard)),
        ],
      ),
    );
  }

  Widget _buildLevelButton(String label, GameLevel level, bool isSelected, VoidCallback onTap) {
    Color color;
    switch(level) {
      case GameLevel.easy: color = GameConstants.primaryColor; break;
      case GameLevel.medium: color = GameConstants.secondaryColor; break;
      case GameLevel.hard: color = GameConstants.accentColor; break;
    }
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isSelected ? color : Colors.white24, width: 2),
        ),
        child: Text(
          label,
          style: GoogleFonts.orbitron(
            color: isSelected ? Colors.white : Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(SnakeState state, SnakeLogic logic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.02),
        border: const Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          _buildIconButton(Icons.home_rounded, () => logic.resetGame(), color: Colors.white70),
          const SizedBox(width: 15),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStatItem('SCORE', state.score.toString(), GameConstants.primaryColor),
                const SizedBox(width: 30),
                _buildStatItem('BEST', state.highscore.toString(), GameConstants.accentColor),
              ],
            ),
          ),
          const SizedBox(width: 15),
          _buildIconButton(
            state.status == GameStatus.paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
            () {
              if (state.status == GameStatus.playing || state.status == GameStatus.paused) {
                logic.pauseGame();
              }
            },
            color: GameConstants.primaryColor,
            isEnabled: state.status == GameStatus.playing || state.status == GameStatus.paused,
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onTap, {Color color = Colors.white, bool isEnabled = true}) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.3,
      child: GestureDetector(
        onTap: isEnabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: GoogleFonts.orbitron(color: Colors.white38, fontSize: 10, letterSpacing: 1)),
        Text(value, style: GoogleFonts.orbitron(color: color, fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildGameBoard(SnakeState state) {
    return LayoutBuilder(builder: (context, constraints) {
      final cellSize = (constraints.maxWidth / GameConstants.gridCols < constraints.maxHeight / GameConstants.gridRows)
          ? constraints.maxWidth / GameConstants.gridCols
          : constraints.maxHeight / GameConstants.gridRows;
      
      final boardWidth = cellSize * GameConstants.gridCols;
      final boardHeight = cellSize * GameConstants.gridRows;

      return Center(
        child: Container(
          width: boardWidth,
          height: boardHeight,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.03),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white10),
          ),
          child: Stack(
            children: [
              CustomPaint(size: Size(boardWidth, boardHeight), painter: GridPainter(cellSize)),
              ...state.obstacles.map((pos) => Positioned(
                left: pos.dx * cellSize,
                top: pos.dy * cellSize,
                child: _buildObstacle(cellSize, state.level),
              )),
              Positioned(
                left: state.food.dx * cellSize,
                top: state.food.dy * cellSize,
                child: _buildFood(cellSize),
              ),
              ...state.snake.asMap().entries.map((entry) {
                return Positioned(
                  left: entry.value.dx * cellSize,
                  top: entry.value.dy * cellSize,
                  child: _buildSnakePart(cellSize, entry.key == 0),
                );
              }),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildObstacle(double size, GameLevel level) {
    final color = level == GameLevel.hard ? GameConstants.accentColor : Colors.white24;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Icon(Icons.close, size: size * 0.5, color: color.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildSnakePart(double size, bool isHead) {
    final color = isHead ? GameConstants.snakeHeadColor : GameConstants.snakeBodyColor;
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(isHead ? 6 : 4),
          boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 4)],
        ),
        child: isHead ? Center(child: Container(width: size * 0.3, height: size * 0.3, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle))) : null,
      ),
    );
  }

  Widget _buildFood(double size) {
    return Container(
      width: size,
      height: size,
      padding: const EdgeInsets.all(4),
      child: Container(
        decoration: BoxDecoration(
          color: GameConstants.foodColor,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: GameConstants.foodColor.withOpacity(0.6), blurRadius: 8, spreadRadius: 1)],
        ),
      ),
    );
  }

  Widget _buildOverlay(String title, String subtitle, IconData icon, {required VoidCallback onAction, required String buttonText, bool isGameOver = false, Widget? child}) {
    return Positioned.fill(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 500),
        curve: Curves.elasticOut,
        builder: (context, value, childStack) {
          final opacity = (0.85 * value).clamp(0.0, 1.0);
          return Container(
            color: Colors.black.withOpacity(opacity),
            child: Transform.scale(
              scale: 0.8 + (0.2 * value),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset('assets/images/logo.png', width: 100 * value, height: 100 * value),
                  const SizedBox(height: 30),
                  if (child == null) Icon(icon, size: 60 * value, color: isGameOver ? GameConstants.accentColor : GameConstants.primaryColor),
                  const SizedBox(height: 20),
                  Text(title, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: 4)),
                  const SizedBox(height: 10),
                  Text(subtitle, textAlign: TextAlign.center, style: GoogleFonts.orbitron(color: Colors.white70, fontSize: 12, letterSpacing: 1)),
                  if (child != null) child,
                  const SizedBox(height: 40),
                  _buildActionButton(buttonText, onAction, isGameOver ? GameConstants.accentColor : GameConstants.primaryColor),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActionButton(String text, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
          boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)],
        ),
        child: Text(text, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 2)),
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  final double cellSize;
  GridPainter(this.cellSize);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.white.withOpacity(0.05)..strokeWidth = 1;
    for (double i = 0; i <= size.width; i += cellSize) canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    for (double i = 0; i <= size.height; i += cellSize) canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
  }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
