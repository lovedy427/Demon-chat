import 'package:flutter/foundation.dart';
import '../models/message.dart';
import '../models/character.dart';
import '../services/gemini_chatbot_service.dart';

class ChatProvider extends ChangeNotifier {
  List<Message> _messages = [];
  Character? _selectedCharacter;
  bool _isTyping = false;

  List<Message> get messages => _messages;
  Character? get selectedCharacter => _selectedCharacter;
  bool get isTyping => _isTyping;

  void selectCharacter(Character character) {
    _selectedCharacter = character;
    _messages.clear();
    
    // 캐릭터 선택 시 인사말 추가
    _addCharacterMessage(_getRandomGreeting(character.id));
    notifyListeners();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty || _selectedCharacter == null) return;

    // 사용자 메시지 추가
    _addUserMessage(text);
    
    // 캐릭터가 타이핑 중임을 표시
    _setTyping(true);
    
    // AI 캐릭터 응답 생성 (비동기)
    _generateAIResponse(text);
  }

  void _addUserMessage(String text) {
    final message = Message(
      text: text,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );
    _messages.add(message);
    notifyListeners();
  }

  void _addCharacterMessage(String text) {
    final message = Message(
      text: text,
      type: MessageType.character,
      timestamp: DateTime.now(),
      characterId: _selectedCharacter?.id,
    );
    _messages.add(message);
    notifyListeners();
  }

  void _setTyping(bool typing) {
    _isTyping = typing;
    notifyListeners();
  }

  void clearChat() {
    _messages.clear();
    if (_selectedCharacter != null) {
      _addCharacterMessage(_getRandomGreeting(_selectedCharacter!.id));
    }
    notifyListeners();
  }

  Future<void> _generateAIResponse(String userMessage) async {
    try {
      // 실제 타이핑 시간 시뮬레이션
      await Future.delayed(Duration(milliseconds: 800 + (userMessage.length * 30)));
      
      final response = await GeminiChatbotService.generateResponse(userMessage, _selectedCharacter!.id);
      _addCharacterMessage(response);
      _setTyping(false);
    } catch (e) {
      // 오류 발생시 기본 응답
      _addCharacterMessage('음... 무슨 말인지 잘 이해하지 못했어요.');
      _setTyping(false);
    }
  }

  String _getRandomGreeting(String characterId) {
    switch (characterId) {
      case 'tanjiro':
        return '안녕! 탄지로야!';
      case 'nezuko':
        return '음~! (웃음)';
      case 'zenitsu':
        return '으아! 안녕...';
      case 'inosuke':
        return '크하하! 이노스케다!';
      case 'giyu':
        return '...';
      case 'shinobu':
        return '아라아라~ 안녕♪';
      case 'muzan':
        return '하찮은 것이...';
      case 'akaza':
        return '강한 놈이군!';
      case 'hakuji':
        return '안녕! 괜찮아?';
      case 'douma':
        return '어머! 반가워요~';
      default:
        return '안녕하세요!';
    }
  }
}
