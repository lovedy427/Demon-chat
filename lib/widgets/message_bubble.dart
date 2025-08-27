import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/message.dart';
import '../models/character.dart';
import '../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final Character character;

  const MessageBubble({
    super.key,
    required this.message,
    required this.character,
  });

  @override
  Widget build(BuildContext context) {
    final isUser = message.type == MessageType.user;
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            // 캐릭터 아바타 - 더욱 매력적으로
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.getCharacterColor(character.id).withOpacity(0.8),
                    AppTheme.getCharacterColor(character.id).withOpacity(0.4),
                  ],
                ),
                border: Border.all(
                  color: AppTheme.getCharacterColor(character.id),
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.getCharacterColor(character.id).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _getCharacterIcon(character.id),
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
          ],
          
          // 메시지 버블 - 더욱 현대적으로
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                gradient: isUser 
                    ? LinearGradient(
                        colors: [
                          AppTheme.getCharacterColor(character.id),
                          AppTheme.getCharacterColor(character.id).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          AppTheme.cardColor,
                          AppTheme.cardColor.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 24),
                ),
                border: Border.all(
                  color: isUser 
                      ? AppTheme.getCharacterColor(character.id).withOpacity(0.3)
                      : AppTheme.lightGrey.withOpacity(0.3),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser 
                        ? AppTheme.getCharacterColor(character.id).withOpacity(0.2)
                        : Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    spreadRadius: 1,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.getCharacterColor(character.id).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        character.name,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.getCharacterColor(character.id),
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  if (!isUser) const SizedBox(height: 8),
                  Text(
                    message.text,
                    style: TextStyle(
                      fontSize: 16,
                      color: isUser ? Colors.white : AppTheme.textColor,
                      height: 1.4,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 시간 표시
                  Text(
                    timeFormat.format(message.timestamp),
                    style: TextStyle(
                      fontSize: 11,
                      color: isUser 
                          ? Colors.white.withOpacity(0.7)
                          : AppTheme.textColor.withOpacity(0.6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          if (isUser) ...[
            const SizedBox(width: 12),
            // 사용자 아바타 - 더욱 매력적으로
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                border: Border.all(
                  color: AppTheme.primaryColor,
                  width: 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.person,
                size: 24,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
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
