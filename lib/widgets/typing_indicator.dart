import 'package:flutter/material.dart';
import '../models/character.dart';
import '../theme/app_theme.dart';

class TypingIndicator extends StatefulWidget {
  final Character character;

  const TypingIndicator({
    super.key,
    required this.character,
  });

  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.4,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 캐릭터 아바타
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.getCharacterColor(widget.character.id).withOpacity(0.1),
              border: Border.all(
                color: AppTheme.getCharacterColor(widget.character.id),
                width: 2,
              ),
            ),
            child: Icon(
              _getCharacterIcon(widget.character.id),
              size: 20,
              color: AppTheme.getCharacterColor(widget.character.id),
            ),
          ),
          const SizedBox(width: 8),
          
          // 타이핑 버블
          AnimatedBuilder(
            animation: _fadeAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      topRight: Radius.circular(18),
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.character.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getCharacterColor(widget.character.id),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDot(0),
                          const SizedBox(width: 4),
                          _buildDot(1),
                          const SizedBox(width: 4),
                          _buildDot(2),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        final delay = index * 0.2;
        final progress = (_animationController.value + delay) % 1.0;
        final opacity = progress < 0.5 ? progress * 2 : (1.0 - progress) * 2;
        
        return Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey.withOpacity(0.4 + opacity * 0.6),
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
}
