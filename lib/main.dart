import 'package:flame/flame.dart';
import 'package:flame/util.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame/game.dart';
import 'package:flame/gestures.dart';
import 'package:flame/sprite.dart';
import 'package:flame/components.dart';
import 'package:flame_audio/flame_audio.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Util flameUtil = Util();
  await flameUtil.fullScreen();
  await flameUtil.setOrientation(DeviceOrientation.portraitUp);
  Flame.audio.disableLog();
  Flame.audio.loadAll([
    'background_music.mp3',
    'crash_sound.wav',
    'finish_line_sound.wav',
  ]);

  runApp(PadRaceGame().widget);
}

class PadRaceGame extends BaseGame with TapDetector {
  final Size screenSize;
  Background background;
  Player player;
  List<Obstacle> obstacles;

  PadRaceGame() : screenSize = Size(320, 480) {
    background = Background();
    player = Player();
    obstacles = List<Obstacle>();
    spawnObstacle();
    add(background);
    add(player);
    obstacles.forEach((obstacle) => add(obstacle));
  }

  @override
  void onTapDown(TapDownDetails details) {
    player.jump();
  }

  @override
  void update(double t) {
    super.update(t);
    player.update(t);
    obstacles.forEach((obstacle) {
      obstacle.update(t);
      if (obstacle.isOffScreen) {
        // If an obstacle is off-screen, remove it and spawn a new one.
        obstacles.remove(obstacle);
        add(obstacle);
      }
      if (player.collidesWith(obstacle)) {
        // Game over condition: Player collided with an obstacle.
        gameOver();
      }
    });
  }

  void spawnObstacle() {
    double y = screenSize.height - 100;
    double x = screenSize.width;
    obstacles.add(Obstacle(x, y));
  }

  void gameOver() {
    // Implement your game over logic here.
    // You can show a game over screen, score, play sound effects, etc.
    // You may also want to reset the game for a new play.
    print('Game Over');
  }
}

class Background extends SpriteComponent {
  Background()
      : super.fromSprite(
    320,
    480,
    Sprite('background.png'),
  );
}

class Player extends SpriteComponent {
  static const double gravity = 500.0;
  static const double jumpVelocity = -400.0;
  double velocityY = 0;

  Player()
      : super.fromSprite(
    32,
    32,
    Sprite('player.png'),
  );

  @override
  void update(double t) {
    super.update(t);
    velocityY += gravity * t;
    y += velocityY * t;
    if (y > 380) {
      y = 380;
      velocityY = 0;
    }
  }

  void jump() {
    FlameAudio.play('jump_sound.wav');
    velocityY = jumpVelocity;
  }

  bool collidesWith(Obstacle obstacle) {
    return toRect().overlaps(obstacle.toRect());
  }
}

class Obstacle extends SpriteComponent {
  static const double speed = -200.0;
  bool isOffScreen = false;

  Obstacle(double x, double y)
      : super.fromSprite(
    48,
    48,
    Sprite('obstacle.png'),
  ) {
    this.x = x;
    this.y = y;
  }

  @override
  void update(double t) {
    super.update(t);
    x += speed * t;
    if (x + width < 0) {
      isOffScreen = true;
    }
  }
}
