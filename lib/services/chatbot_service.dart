import 'dart:math';
import '../models/character.dart';
import '../models/message.dart';
import '../data/character_data.dart';

class ChatbotService {
  static final Random _random = Random();

  static String generateResponse(String userMessage, String characterId) {
    final character = CharacterData.getCharacterById(characterId);
    if (character == null) return '캐릭터를 찾을 수 없습니다.';

    // 사용자 메시지를 소문자로 변환하여 키워드 매칭
    final message = userMessage.toLowerCase();
    
    // 캐릭터별 특정 응답 찾기
    String? specificResponse = _findSpecificResponse(message, character);
    if (specificResponse != null) {
      return _addPersonality(specificResponse, character);
    }

    // 일반적인 응답 생성
    return _generateGeneralResponse(message, character);
  }

  static String? _findSpecificResponse(String message, Character character) {
    for (String keyword in character.responses.keys) {
      if (message.contains(keyword.toLowerCase()) || 
          _containsKeywordVariations(message, keyword)) {
        final responses = character.responses[keyword]!;
        return responses[_random.nextInt(responses.length)];
      }
    }
    return null;
  }

  static bool _containsKeywordVariations(String message, String keyword) {
    // 키워드의 변형들을 체크
    switch (keyword) {
      case '안녕':
        return message.contains('안녕') || message.contains('하이') || 
               message.contains('hello') || message.contains('반가');
      case '힘들다':
        return message.contains('힘들') || message.contains('어려') || 
               message.contains('고민') || message.contains('스트레스');
      case '감사':
        return message.contains('고마') || message.contains('감사') || 
               message.contains('thank');
      case '가족':
        return message.contains('가족') || message.contains('형제') || 
               message.contains('언니') || message.contains('오빠') ||
               message.contains('동생') || message.contains('부모');
      case '포기':
        return message.contains('포기') || message.contains('그만') || 
               message.contains('힘들어');
      case '무서워':
        return message.contains('무서') || message.contains('두려') || 
               message.contains('겁') || message.contains('공포');
      case '용기':
        return message.contains('용기') || message.contains('용감') || 
               message.contains('힘내') || message.contains('화이팅');
      case '여자':
        return message.contains('여자') || message.contains('소녀') || 
               message.contains('예쁜') || message.contains('귀여');
      case '싸움':
        return message.contains('싸움') || message.contains('전투') || 
               message.contains('승부') || message.contains('대결');
      case '음식':
        return message.contains('음식') || message.contains('밥') || 
               message.contains('고기') || message.contains('먹');
      case '친구':
        return message.contains('친구') || message.contains('동료') || 
               message.contains('벗');
      case '대화':
        return message.contains('말') || message.contains('이야기') || 
               message.contains('대화');
      case '슬픔':
        return message.contains('슬프') || message.contains('우울') || 
               message.contains('눈물') || message.contains('울');
      case '화남':
        return message.contains('화') || message.contains('짜증') || 
               message.contains('열받') || message.contains('분노');
      case '칭찬':
        return message.contains('잘했') || message.contains('훌륭') || 
               message.contains('멋지') || message.contains('최고');
      case '귀신':
        return message.contains('귀신') || message.contains('도깨비') || 
               message.contains('악마') || message.contains('oni');
      case '오빠':
        return message.contains('오빠') || message.contains('형') || 
               message.contains('탄지로');
      default:
        return false;
    }
  }

  static String _generateGeneralResponse(String message, Character character) {
    // 캐릭터별 기본 응답 패턴
    switch (character.id) {
      case 'tanjiro':
        return _generateTanjiroResponse(message);
      case 'nezuko':
        return _generateNezukoResponse();
      case 'zenitsu':
        return _generateZenitsuResponse(message);
      case 'inosuke':
        return _generateInosukeResponse(message);
      case 'giyu':
        return _generateGiyuResponse();
      case 'shinobu':
        return _generateShinobuResponse(message);
      default:
        return '잘 모르겠어요.';
    }
  }

  static String _generateTanjiroResponse(String message) {
    final responses = [
      '그렇구나! 정말 흥미로운 이야기네!',
      '음... 그런 일이 있었구나. 괜찮아?',
      '와! 정말 대단해! 나도 열심히 해야겠어!',
      '그런 생각을 하고 있었구나. 나도 비슷하게 생각해!',
      '힘든 일이 있으면 언제든지 말해줘. 함께 해결해보자!',
      '네 마음을 이해할 것 같아. 포기하지 말고 함께 노력하자!',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  static String _generateNezukoResponse() {
    final responses = [
      '음~! (고개를 끄덕이며)',
      '으응! 으응!',
      '음... 음...',
      '으응...? (궁금해하는 표정)',
      '음~! (밝게 웃으며)',
      '으응! (기쁜 표정으로)',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  static String _generateZenitsuResponse(String message) {
    final responses = [
      '으아아! 그런 일이?! 무서워!',
      '하아... 세상은 정말 무서운 곳이야...',
      '히익! 놀래지 말라고! 심장이 멈출 뻔했어!',
      '젠장... 왜 이런 일들이 계속 생기는 거야?',
      '으아아아! 도망가고 싶어!',
      '정말이야?! 믿을 수 없어!',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  static String _generateInosukeResponse(String message) {
    final responses = [
      '크하하! 재미있는 이야기네!',
      '어라? 그게 뭐야? 먹을 수 있어?',
      '이노스케 님께서 알려주지! 크하하!',
      '승부다! 그것도 승부야!',
      '크하하하! 산의 왕인 내가 해결해주마!',
      '어라어라? 이상한 놈이네!',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  static String _generateGiyuResponse() {
    final responses = [
      '...',
      '그렇다.',
      '알겠다.',
      '...흠.',
      '이해했다.',
      '좋다.',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  static String _generateShinobuResponse(String message) {
    final responses = [
      '아라아라~ 그런가요?',
      '후후~ 재미있는 이야기네요!',
      '그런 일이 있었나요? 아라아라~',
      '후후~ 정말 흥미롭네요♪',
      '아라~ 그런 생각을 하고 계셨군요!',
      '후후~ 당신도 참 재미있는 분이시네요♪',
    ];
    return responses[_random.nextInt(responses.length)];
  }

  static String _addPersonality(String response, Character character) {
    // 캐릭터의 말투 패턴을 더 강화
    switch (character.id) {
      case 'tanjiro':
        if (!response.contains('!') && !response.contains('?')) {
          response += '!';
        }
        break;
      case 'zenitsu':
        if (!response.startsWith('으아') && !response.startsWith('히익') && !response.startsWith('하아')) {
          if (_random.nextBool()) {
            response = '으아아! ' + response;
          }
        }
        break;
      case 'inosuke':
        if (!response.contains('크하하') && _random.nextDouble() < 0.3) {
          response = '크하하! ' + response;
        }
        break;
      case 'shinobu':
        if (!response.contains('아라') && !response.contains('후후') && _random.nextDouble() < 0.4) {
          response = '후후~ ' + response;
        }
        if (!response.contains('♪') && _random.nextDouble() < 0.3) {
          response += '♪';
        }
        break;
    }
    return response;
  }

  static String getRandomGreeting(String characterId) {
    final character = CharacterData.getCharacterById(characterId);
    if (character == null) return '안녕하세요!';
    
    return character.greetings[_random.nextInt(character.greetings.length)];
  }
}
