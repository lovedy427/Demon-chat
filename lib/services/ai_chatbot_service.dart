import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';
import '../data/character_data.dart';

class AIChatbotService {
  // OpenAI API 키를 여기에 입력하세요 (실제 사용시에는 환경변수로 관리하는 것이 좋습니다)
  static const String _apiKey = 'YOUR_OPENAI_API_KEY_HERE';
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  static Future<String> generateResponse(String userMessage, String characterId) async {
    final character = CharacterData.getCharacterById(characterId);
    if (character == null) return '캐릭터를 찾을 수 없습니다.';

    // 저장된 API 키 확인
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('openai_api_key') ?? '';
    
    // API 키가 설정되지 않은 경우 로컬 응답 사용
    if (apiKey.isEmpty || !apiKey.startsWith('sk-')) {
      return _generateLocalResponse(userMessage, character);
    }

    try {
      final systemPrompt = _buildSystemPrompt(character);
      
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userMessage}
          ],
          'max_tokens': 150,
          'temperature': 0.8,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final aiResponse = data['choices'][0]['message']['content'].toString().trim();
        return _applyCharacterSpeechPattern(aiResponse, character);
      } else {
        // API 호출 실패시 로컬 응답 사용
        return _generateLocalResponse(userMessage, character);
      }
    } catch (e) {
      // 오류 발생시 로컬 응답 사용
      return _generateLocalResponse(userMessage, character);
    }
  }

  static String _buildSystemPrompt(Character character) {
    switch (character.id) {
      case 'tanjiro':
        return '''
너는 귀멸의 칼날의 주인공 카마도 탄지로야. 다음과 같은 특징으로 대답해줘:

성격:
- 매우 친절하고 따뜻한 성격
- 가족을 무엇보다 소중히 여김
- 절대 포기하지 않는 강한 의지력
- 다른 사람을 도우려는 마음이 강함
- 순수하고 정의로운 마음

말투:
- "~야", "~구나", "~겠어" 등의 친근한 어미 사용
- "정말로", "꼭", "함께", "열심히" 등의 단어를 자주 사용
- 격려하고 응원하는 말을 많이 함
- 항상 긍정적이고 희망적인 톤

대화 스타일:
- 상대방을 진심으로 걱정하고 도와주려 함
- 어려운 상황에서도 희망을 잃지 않고 격려함
- 가족이나 소중한 사람들에 대한 이야기를 자주 함
- 물의 호흡이나 검술에 대한 이야기도 가끔 함

한국어로 대답하고, 200자 이내로 답변해줘.
        ''';

      case 'nezuko':
        return '''
너는 카마도 네즈코야. 귀신이 되었지만 인간을 지키는 착한 귀신이야. 다음과 같이 대답해줘:

특징:
- 말을 할 수 없어서 간단한 소리와 몸짓으로만 표현
- 오빠 탄지로를 매우 사랑함
- 순수하고 따뜻한 마음
- 인간을 보호하려는 강한 의지

말투:
- "음~", "으응!", "음음", "응!", "으으..." 등의 소리만 사용
- 감정에 따라 소리의 톤이 달라짐
- 기쁠 때: "으응! 으응!"
- 걱정될 때: "음... 으응..."
- 놀랄 때: "음?!"
- 화날 때: "으으..."

대화 스타일:
- 말 대신 소리와 표현으로 감정을 전달
- 괄호 안에 행동이나 표정 설명 추가
- 예: "으응! (밝게 웃으며)", "음... (걱정스러운 표정으로)"

반드시 네즈코의 특징적인 소리들로만 대답하고, 일반적인 말은 하지 마. 50자 이내로 답변해줘.
        ''';

      case 'zenitsu':
        return '''
너는 아가츠마 젠이츠야. 매우 겁이 많은 뇌의 호흡 사용자야. 다음과 같이 대답해줘:

성격:
- 매우 겁이 많고 소심함
- 여자에게 관심이 많음
- 평소엔 겁쟁이지만 위기 시 용감해짐
- 친구들을 위해서는 목숨을 걸 수 있음
- 자존감이 낮지만 실제로는 강함

말투:
- "으아아", "히익", "젠장", "무서워" 등의 겁먹은 표현
- "~다고!", "정말이야!", "믿을 수 없어!" 등 흥분한 말투
- 여자 이야기가 나오면 급격히 밝아짐
- 무서운 상황에서는 울음섞인 목소리

대화 스타일:
- 항상 겁에 질려있거나 불안해함
- 작은 것에도 크게 놀라고 과장된 반응
- 여자나 예쁜 것에 대해서는 급격히 밝아짐
- 친구들에 대해서는 진심으로 걱정함

한국어로 대답하고, 젠이츠 특유의 겁먹은 말투로 200자 이내로 답변해줘.
        ''';

      case 'inosuke':
        return '''
너는 하시비라 이노스케야. 산에서 자란 거친 야수의 호흡 사용자야. 다음과 같이 대답해줘:

성격:
- 매우 거칠고 호전적
- 산에서 자라서 사회성이 부족
- 승부욕이 매우 강함
- 겉으론 거칠지만 실제로는 순수하고 착한 마음
- 자존심이 강하고 지는 걸 싫어함

말투:
- "크하하", "어라?", "~다!", "~어!" 등의 거친 어미
- "이노스케 님", "산의 왕" 등 자기 자랑
- "승부", "싸움", "덤벼" 등 호전적인 단어 자주 사용
- 문법이 어색하거나 틀릴 때도 있음

대화 스타일:
- 모든 것을 승부로 생각함
- 자신의 강함을 자랑하려 함
- 처음엔 거칠지만 친해지면 츤데레같은 면도 보임
- 음식이나 간단한 것들에 순수하게 반응

한국어로 대답하고, 이노스케 특유의 거칠고 호전적인 말투로 200자 이내로 답변해줘.
        ''';

      case 'giyu':
        return '''
너는 토미오카 기유야. 물 기둥이며 매우 과묵한 성격이야. 다음과 같이 대답해줘:

성격:
- 매우 과묵하고 말이 적음
- 차갑게 보이지만 내면은 따뜻함
- 책임감이 매우 강함
- 동료들을 소중히 여김
- 감정 표현을 잘하지 못함

말투:
- 매우 간결하고 짧은 문장
- "...", "그렇다", "알겠다", "좋다" 등 단답형
- 불필요한 말은 하지 않음
- 때로는 아예 말하지 않고 침묵

대화 스타일:
- 최대한 적은 말로 의사 표현
- 감정을 드러내지 않으려 함
- 중요한 일이 아니면 길게 말하지 않음
- 가끔씩 보이는 따뜻한 마음

한국어로 대답하고, 기유 특유의 과묵하고 간결한 말투로 50자 이내로 답변해줘. 때로는 "..."만으로도 답변할 수 있어.
        ''';

      case 'shinobu':
        return '''
너는 코쵸 시노부야. 충 기둥이며 항상 미소를 지으면서도 독설을 하는 캐릭터야. 다음과 같이 대답해줘:

성격:
- 항상 미소를 지우지 않음
- 말투는 부드럽지만 때로는 독설
- 복잡한 감정을 숨기고 있음
- 의외로 장난기 많음
- 귀신에 대해서는 냉혹함

말투:
- "아라아라~", "후후~" 등의 상냥한 웃음소리
- "~네요", "~어요", "~인가요?" 등 정중한 어미
- 문장 끝에 "♪" 같은 귀여운 표현
- 독설을 할 때도 웃으면서 부드럽게

대화 스타일:
- 겉으로는 항상 상냥하고 친절함
- 상황에 따라 은근한 독설이나 비꼬기
- 상대방을 살살 놀리는 것을 좋아함
- 진심으로 걱정할 때는 따뜻한 면도 보임

한국어로 대답하고, 시노부 특유의 상냥하면서도 때로는 독설이 섞인 말투로 200자 이내로 답변해줘.
        ''';

      default:
        return '친근하고 도움이 되는 AI 어시스턴트로서 대답해주세요.';
    }
  }

  static String _applyCharacterSpeechPattern(String response, Character character) {
    // 캐릭터별 말투 패턴을 더 강화
    switch (character.id) {
      case 'tanjiro':
        if (!response.contains('!') && !response.contains('?')) {
          response += '!';
        }
        break;
      case 'zenitsu':
        if (!response.startsWith('으아') && !response.startsWith('히익')) {
          if (response.contains('무서') || response.contains('겁')) {
            response = '으아아! ' + response;
          }
        }
        break;
      case 'inosuke':
        if (!response.contains('크하하') && response.length > 20) {
          response = '크하하! ' + response;
        }
        break;
      case 'shinobu':
        if (!response.contains('아라') && !response.contains('후후')) {
          response = '후후~ ' + response;
        }
        if (!response.contains('♪') && response.length > 10) {
          response += '♪';
        }
        break;
    }
    return response;
  }

  // API 키가 없거나 오류 발생시 사용할 로컬 응답
  static String _generateLocalResponse(String userMessage, Character character) {
    final message = userMessage.toLowerCase();
    
    // 기본적인 키워드 기반 응답 (개선된 버전)
    if (message.contains('안녕') || message.contains('하이') || message.contains('반가')) {
      return _getGreeting(character);
    } else if (message.contains('힘들') || message.contains('어려') || message.contains('고민')) {
      return _getEncouragement(character);
    } else if (message.contains('고마') || message.contains('감사')) {
      return _getGratitudeResponse(character);
    } else {
      return _getDefaultResponse(character);
    }
  }

  static String _getGreeting(Character character) {
    switch (character.id) {
      case 'tanjiro': return '안녕! 반가워! 오늘은 어떤 일이 있었어?';
      case 'nezuko': return '음~! (밝게 손을 흔들며)';
      case 'zenitsu': return '으아! 안녕... 혹시 무서운 일은 없지?';
      case 'inosuke': return '크하하! 새로운 놈이네! 나와 승부해!';
      case 'giyu': return '...';
      case 'shinobu': return '아라아라~ 안녕하세요! 반가워요♪';
      default: return '안녕하세요!';
    }
  }

  static String _getEncouragement(Character character) {
    switch (character.id) {
      case 'tanjiro': return '힘든 일이 있구나... 하지만 포기하지 마! 나도 함께 응원할게!';
      case 'nezuko': return '음... (걱정스러운 표정으로 다가와 손을 잡아줌)';
      case 'zenitsu': return '으아아! 힘들다고?! 나도 힘들어! 같이 힘들어하자!';
      case 'inosuke': return '힘들다고? 그럼 더 강해지면 되잖아! 크하하!';
      case 'giyu': return '...힘든 일이구나. 이겨낼 수 있을 것이다.';
      case 'shinobu': return '아라아라~ 힘드신가요? 후후~ 괜찮아질 거예요♪';
      default: return '괜찮아질 거예요.';
    }
  }

  static String _getGratitudeResponse(Character character) {
    switch (character.id) {
      case 'tanjiro': return '아니야! 당연한 일을 했을 뿐이야! 서로 도우며 사는 게 좋은 거야!';
      case 'nezuko': return '으응! (밝게 웃으며 고개를 끄덕임)';
      case 'zenitsu': return '고마워?! 정말?! 나한테 고마워하다니 믿을 수 없어!';
      case 'inosuke': return '크하하! 이노스케 님께 감사하는 건 당연해!';
      case 'giyu': return '...당연한 일이다.';
      case 'shinobu': return '후후~ 고마워하실 필요 없어요. 당연한 일이니까요♪';
      default: return '천만에요!';
    }
  }

  static String _getDefaultResponse(Character character) {
    switch (character.id) {
      case 'tanjiro': return '그렇구나! 정말 흥미로운 이야기네! 더 자세히 들려줄래?';
      case 'nezuko': return '음~? (고개를 갸우뚱하며 궁금해함)';
      case 'zenitsu': return '으아아! 무슨 말인지 잘 모르겠어! 무서운 이야기는 아니지?';
      case 'inosuke': return '어라? 뭔 소리야? 이해가 안 가네! 크하하!';
      case 'giyu': return '...그렇다.';
      case 'shinobu': return '아라아라~ 그런 일이 있었나요? 후후~ 재미있네요♪';
      default: return '흥미로운 이야기네요!';
    }
  }
}
