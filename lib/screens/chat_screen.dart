import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/message_bubble.dart';
import '../widgets/typing_indicator.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      // 새 페이지 열림 방지
      try {
        context.read<ChatProvider>().sendMessage(text);
        _messageController.clear();
        _scrollToBottom();
      } catch (e) {
        // 오류 발생시 현재 페이지 유지
        print('메시지 전송 오류: $e');
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ChatProvider>(
      builder: (context, chatProvider, child) {
        final character = chatProvider.selectedCharacter;
        if (character == null) {
          return const Scaffold(
            body: Center(
              child: Text('캐릭터를 선택해주세요.'),
            ),
          );
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                  ),
                  child: Icon(
                    _getCharacterIcon(character.id),
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        character.name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '온라인',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            backgroundColor: AppTheme.getCharacterColor(character.id),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => chatProvider.clearChat(),
                tooltip: '대화 초기화',
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.backgroundGradient,
            ),
            child: Stack(
              children: [
                // 배경 패턴 - 성능 최적화 (단순화)
                Container(
                  decoration: BoxDecoration(
                    gradient: AppTheme.backgroundGradient,
                  ),
                ),
                // 메인 콘텐츠
                Column(
                  children: [
                    // 메시지 리스트
                    Expanded(
                      child: Container(
                        margin: EdgeInsets.only(top: MediaQuery.of(context).padding.top + kToolbarHeight),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: chatProvider.messages.length + (chatProvider.isTyping ? 1 : 0),
                          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                          cacheExtent: 1000.0,
                          itemBuilder: (context, index) {
                            if (index == chatProvider.messages.length && chatProvider.isTyping) {
                              return TypingIndicator(character: character);
                            }
                            
                            final message = chatProvider.messages[index];
                            return MessageBubble(
                              message: message,
                              character: character,
                            );
                          },
                        ),
                      ),
                    ),
              
              // 메시지 입력창 - 다크 테마 대응
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                ),
                padding: const EdgeInsets.all(16),
                child: SafeArea(
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // 탭 이벤트에서 새 페이지 열림 방지
                          },
                          child: TextField(
                            controller: _messageController,
                            enableInteractiveSelection: false,
                            readOnly: false,
                            style: const TextStyle(
                              color: AppTheme.textColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            decoration: InputDecoration(
                              hintText: '${character.name}에게 메시지를 보내세요...',
                              hintStyle: TextStyle(
                                color: AppTheme.textColor.withOpacity(0.6),
                                fontSize: 15,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: BorderSide(
                                  color: AppTheme.lightGrey.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(28),
                                borderSide: BorderSide(
                                  color: AppTheme.getCharacterColor(character.id),
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: AppTheme.backgroundColor.withOpacity(0.6),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                            ),
                            textInputAction: TextInputAction.send,
                            onSubmitted: (value) {
                              // 새 페이지 열림 방지하고 메시지만 전송
                              if (value.trim().isNotEmpty) {
                                _sendMessage();
                              }
                            },

                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.getCharacterColor(character.id),
                              AppTheme.getCharacterColor(character.id).withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.getCharacterColor(character.id).withOpacity(0.4),
                              blurRadius: 12,
                              spreadRadius: 1,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: _sendMessage,
                          icon: const Icon(
                            Icons.send_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                    ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCharacterIcon(String characterId) {
    switch (characterId) {
      case 'tanjiro':
        return Icons.water_drop;
      case 'nezuko':
        return Icons.favorite;
      case 'zenitsu':
        return Icons.flash_on;
      case 'inosuke':
        return Icons.pets;
      case 'giyu':
        return Icons.waves;
      case 'shinobu':
        return Icons.bug_report;
      case 'muzan':
        return Icons.dark_mode;
      case 'akaza':
        return Icons.sports_martial_arts;
      case 'hakuji':
        return Icons.shield;
      case 'douma':
        return Icons.ac_unit;
      default:
        return Icons.person;
    }
  }

  Widget _buildCharacterEffect(String characterId) {
    switch (characterId) {
      case 'zenitsu':
        return _buildLightningEffect();
      case 'tanjiro':
        return _buildWaterEffect();
      case 'nezuko':
        return _buildFlameEffect();
      case 'inosuke':
        return _buildBeastEffect();
      case 'giyu':
        return _buildCalmWaterEffect();
      case 'shinobu':
        return _buildButterflyEffect();
      case 'muzan':
        return _buildDarkEffect();
      case 'akaza':
        return _buildFightingEffect();
      case 'douma':
        return _buildIceEffect();
      case 'hakuji':
        return _buildProtectionEffect();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildLightningEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 3),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return CustomPaint(
              painter: LightningEffectPainter(value),
              size: Size.infinite,
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildWaterEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 4),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return CustomPaint(
              painter: WaterEffectPainter(value),
              size: Size.infinite,
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildFlameEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return CustomPaint(
              painter: FlameEffectPainter(value),
              size: Size.infinite,
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildBeastEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 2),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return CustomPaint(
              painter: BeastEffectPainter(value),
              size: Size.infinite,
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildCalmWaterEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 6),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return CustomPaint(
              painter: CalmWaterEffectPainter(value),
              size: Size.infinite,
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildButterflyEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 5),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return CustomPaint(
              painter: ButterflyEffectPainter(value),
              size: Size.infinite,
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildDarkEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 4),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return CustomPaint(
              painter: DarkEffectPainter(value),
              size: Size.infinite,
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildFightingEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 3),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return CustomPaint(
              painter: FightingEffectPainter(value),
              size: Size.infinite,
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildIceEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 4),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return CustomPaint(
              painter: IceEffectPainter(value),
              size: Size.infinite,
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }

  Widget _buildProtectionEffect() {
    return Positioned.fill(
      child: IgnorePointer(
        child: TweenAnimationBuilder<double>(
          duration: const Duration(seconds: 5),
          tween: Tween(begin: 0.0, end: 1.0),
          builder: (context, value, child) {
            return CustomPaint(
              painter: ProtectionEffectPainter(value),
              size: Size.infinite,
            );
          },
          onEnd: () {
            if (mounted) {
              setState(() {});
            }
          },
        ),
      ),
    );
  }
}

// 채팅 배경 페인터 - 캐릭터별 맞춤 패턴
class ChatBackgroundPainter extends CustomPainter {
  final String characterId;

  ChatBackgroundPainter(this.characterId);

  @override
  void paint(Canvas canvas, Size size) {
    // 성능 최적화를 위해 간소화
    if (size.width <= 0 || size.height <= 0) return;
    
    _drawOptimizedBasePattern(canvas, size);
    _drawSimpleCharacterPattern(canvas, size);
  }

  void _drawOptimizedBasePattern(Canvas canvas, Size size) {
    // 기본 격자 패턴 - 간소화
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.015)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;

    final gridSize = 80.0;
    final maxLines = 20; // 최대 라인 수 제한
    
    int count = 0;
    for (double x = 0; x < size.width && count < maxLines; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
      count++;
    }
    
    count = 0;
    for (double y = 0; y < size.height && count < maxLines; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
      count++;
    }
  }

  void _drawSimpleCharacterPattern(Canvas canvas, Size size) {
    // 캐릭터별 간단한 패턴만 표시
    switch (characterId) {
      case 'tanjiro':
        _drawSimpleWaves(canvas, size, Colors.cyan);
        break;
      case 'nezuko':
        _drawSimpleCircles(canvas, size, Colors.pink);
        break;
      case 'zenitsu':
        _drawSimpleLines(canvas, size, Colors.yellow);
        break;
      case 'inosuke':
        _drawSimpleTriangles(canvas, size, Colors.orange);
        break;
      case 'giyu':
        _drawSimpleWaves(canvas, size, Colors.blue);
        break;
      case 'shinobu':
        _drawSimpleCircles(canvas, size, Colors.purple);
        break;
      default:
        // 기본 패턴은 생략
        break;
    }
  }

  void _drawSimpleWaves(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.02)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 3; i++) {
      final path = Path();
      final y = size.height * (i + 1) / 4;
      
      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x += 40) {
        path.lineTo(x, y + sin(x * 0.02) * 10);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  void _drawSimpleCircles(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 6; i++) {
      final center = Offset(
        (size.width / 3) * (i % 3),
        (size.height / 2) * (i ~/ 3),
      );
      canvas.drawCircle(center, 30.0, paint);
    }
  }

  void _drawSimpleLines(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.025)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 5; i++) {
      final x = size.width * i / 5;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x + 50, size.height),
        paint,
      );
    }
  }

  void _drawSimpleTriangles(Canvas canvas, Size size, Color color) {
    final paint = Paint()
      ..color = color.withOpacity(0.02)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    for (int i = 0; i < 4; i++) {
      final path = Path();
      final centerX = size.width * (i + 0.5) / 5;
      final centerY = size.height * 0.5;
      
      path.moveTo(centerX, centerY - 20);
      path.lineTo(centerX - 20, centerY + 20);
      path.lineTo(centerX + 20, centerY + 20);
      path.close();
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

// 젠이츠 번개 효과
class LightningEffectPainter extends CustomPainter {
  final double animationValue;

  LightningEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.yellow.withOpacity(0.6 * (1 - animationValue))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 번개 모양 그리기
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final startX = size.width * (0.2 + i * 0.3);
      final startY = size.height * 0.1;
      
      path.moveTo(startX, startY);
      path.lineTo(startX + 20, startY + 100 * animationValue);
      path.lineTo(startX - 10, startY + 150 * animationValue);
      path.lineTo(startX + 30, startY + 250 * animationValue);
      path.lineTo(startX + 10, startY + 350 * animationValue);
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 탄지로 물 효과
class WaterEffectPainter extends CustomPainter {
  final double animationValue;

  WaterEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.4 * (1 - animationValue * 0.5))
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // 물결 효과
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final y = size.height * (i + 1) / 6;
      
      path.moveTo(0, y);
      for (double x = 0; x <= size.width; x += 20) {
        final waveY = y + sin((x * 0.01) + (animationValue * 10)) * 15;
        path.lineTo(x, waveY);
      }
      
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 네즈코 화염 효과
class FlameEffectPainter extends CustomPainter {
  final double animationValue;

  FlameEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.pink.withOpacity(0.5 * (1 - animationValue * 0.7))
      ..style = PaintingStyle.fill;

    // 화염 입자들
    for (int i = 0; i < 8; i++) {
      final x = size.width * (i / 8) + (sin(animationValue * 6 + i) * 30);
      final y = size.height - (animationValue * size.height * 0.8) + (cos(animationValue * 4 + i) * 20);
      
      if (y > 0 && y < size.height) {
        canvas.drawCircle(
          Offset(x, y),
          4 + sin(animationValue * 8 + i) * 2,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 이노스케 야수 효과
class BeastEffectPainter extends CustomPainter {
  final double animationValue;

  BeastEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.orange.withOpacity(0.4 * (1 - animationValue * 0.6))
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    // 날카로운 선들
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 + animationValue * 180) * pi / 180;
      final startX = size.width * 0.5;
      final startY = size.height * 0.5;
      final endX = startX + cos(angle) * 100 * animationValue;
      final endY = startY + sin(angle) * 100 * animationValue;
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 기유 고요한 물 효과
class CalmWaterEffectPainter extends CustomPainter {
  final double animationValue;

  CalmWaterEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3 * (1 - animationValue * 0.8))
      ..style = PaintingStyle.fill;

    // 부드러운 원들
    for (int i = 0; i < 4; i++) {
      final radius = (50 + i * 30) * animationValue;
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 시노부 나비 효과
class ButterflyEffectPainter extends CustomPainter {
  final double animationValue;

  ButterflyEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.purple.withOpacity(0.6 * (1 - animationValue * 0.5))
      ..style = PaintingStyle.fill;

    // 나비 모양 입자들
    for (int i = 0; i < 6; i++) {
      final x = size.width * (i / 6) + sin(animationValue * 4 + i) * 50;
      final y = size.height * 0.3 + cos(animationValue * 3 + i) * 100;
      
      if (x > 0 && x < size.width && y > 0 && y < size.height) {
        // 간단한 나비 모양
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x, y), width: 8, height: 12),
          paint,
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(x + 6, y), width: 6, height: 8),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 무잔 어둠 효과
class DarkEffectPainter extends CustomPainter {
  final double animationValue;

  DarkEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.red.withOpacity(0.3 * (1 - animationValue * 0.7))
      ..style = PaintingStyle.fill;

    // 어둠의 입자들
    for (int i = 0; i < 10; i++) {
      final x = size.width * Random().nextDouble();
      final y = size.height * Random().nextDouble();
      
      canvas.drawCircle(
        Offset(x, y),
        3 + sin(animationValue * 8 + i) * 2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 아카자 격투 효과
class FightingEffectPainter extends CustomPainter {
  final double animationValue;

  FightingEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.red.withOpacity(0.5 * (1 - animationValue * 0.6))
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    // 충격파 원들
    for (int i = 0; i < 3; i++) {
      final radius = (80 + i * 40) * animationValue;
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.7),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 도우마 얼음 효과
class IceEffectPainter extends CustomPainter {
  final double animationValue;

  IceEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.lightBlue.withOpacity(0.4 * (1 - animationValue * 0.8))
      ..style = PaintingStyle.fill;

    // 얼음 결정들
    for (int i = 0; i < 8; i++) {
      final x = size.width * (i / 8) + cos(animationValue * 2 + i) * 30;
      final y = animationValue * size.height + sin(animationValue * 3 + i) * 50;
      
      if (y > 0 && y < size.height) {
        // 간단한 얼음 결정 모양
        canvas.drawRect(
          Rect.fromCenter(center: Offset(x, y), width: 6, height: 6),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

// 하쿠지 보호 효과
class ProtectionEffectPainter extends CustomPainter {
  final double animationValue;

  ProtectionEffectPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final paint = Paint()
      ..color = Colors.green.withOpacity(0.4 * (1 - animationValue * 0.6))
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // 보호막 효과
    final radius = 100 * animationValue;
    canvas.drawCircle(
      Offset(size.width * 0.5, size.height * 0.5),
      radius,
      paint,
    );
    
    // 내부 원들
    for (int i = 1; i < 4; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.5, size.height * 0.5),
        radius * (i / 4),
        paint..strokeWidth = 1.0,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
