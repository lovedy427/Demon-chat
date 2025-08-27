import 'package:flutter/material.dart';
import '../models/character.dart';
import '../theme/app_theme.dart';

class CharacterCard extends StatefulWidget {
  final Character character;
  final VoidCallback onTap;

  const CharacterCard({
    super.key,
    required this.character,
    required this.onTap,
  });

  @override
  State<CharacterCard> createState() => _CharacterCardState();
}

class _CharacterCardState extends State<CharacterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150), // 더 빠른 애니메이션
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.03, // 더 작은 스케일
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut, // 더 부드러운 커브
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.01, // 더 작은 회전
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: Transform.rotate(
                angle: _rotationAnimation.value,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: AppTheme.getCharacterGradient(widget.character.id),
                    boxShadow: [
                      AppTheme.getGlowEffect(AppTheme.getCharacterColor(widget.character.id)),
                      if (_isHovered)
                        AppTheme.getNeonEffect(AppTheme.getCharacterColor(widget.character.id)),
                    ],
                  ),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 캐릭터 아바타 - 더욱 매력적으로
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white,
                                  Colors.white.withOpacity(0.8),
                                  AppTheme.getCharacterColor(widget.character.id).withOpacity(0.1),
                                ],
                                stops: const [0.0, 0.7, 1.0],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.getCharacterColor(widget.character.id).withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                  offset: const Offset(0, 5),
                                ),
                                const BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 10,
                                  offset: Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTheme.getCharacterColor(widget.character.id),
                                  width: 3,
                                ),
                              ),
                              child: Icon(
                                _getCharacterIcon(widget.character.id),
                                size: 56,
                                color: AppTheme.getCharacterColor(widget.character.id),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 16),
                          
                          // 캐릭터 이름 - 더욱 세련되게
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              widget.character.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black54,
                                    offset: Offset(1, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // 캐릭터 설명 - 더욱 읽기 쉽게
                          Text(
                            widget.character.description,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                              shadows: const [
                                Shadow(
                                  color: Colors.black38,
                                  offset: Offset(0.5, 0.5),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _onHover(bool isHovered) {
    setState(() {
      _isHovered = isHovered;
    });
    if (isHovered) {
      _animationController.forward();
    } else {
      _animationController.reverse();
    }
  }

  IconData _getCharacterIcon(String characterId) {
    switch (characterId) {
      case 'tanjiro':
        return Icons.water_drop; // 물의 호흡
      case 'nezuko':
        return Icons.favorite; // 사랑
      case 'zenitsu':
        return Icons.flash_on; // 번개
      case 'inosuke':
        return Icons.pets; // 야수
      case 'giyu':
        return Icons.waves; // 물
      case 'shinobu':
        return Icons.bug_report; // 곤충/독
      case 'muzan':
        return Icons.dark_mode; // 어둠
      case 'akaza':
        return Icons.sports_martial_arts; // 무도
      case 'hakuji':
        return Icons.shield; // 보호
      case 'douma':
        return Icons.ac_unit; // 얼음
      default:
        return Icons.person;
    }
  }
}
