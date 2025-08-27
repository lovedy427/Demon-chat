import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/character.dart';
import '../data/character_data.dart';

class GeminiChatbotService {
  static GenerativeModel? _model;
  
  // 영구 저장된 개인 API 키 - 모든 사용자가 사용
  static const String _defaultApiKey = 'AIzaSyDfuJVKXepFMugYtQiceYnc6ftdHuzmPRc'; // 실제 유효한 API 키
  
  // 일일 사용량 제한 (무료 할당량 보호)
  static const int _dailyLimit = 1400; // 하루 1,400회로 제한 (여유분 100회)
  static const String _usageCountKey = 'daily_usage_count';
  static const String _lastUsageDateKey = 'last_usage_date';

  static Future<String> generateResponse(String userMessage, String characterId) async {
    final character = CharacterData.getCharacterById(characterId);
    if (character == null) return '캐릭터를 찾을 수 없습니다.';

    // 일일 사용량 제한 체크
    final canUseAPI = await _checkDailyUsageLimit();
    if (!canUseAPI) {
      return '🚫 일일 AI 사용량이 한계에 도달했습니다. 과금 방지를 위해 내일 다시 이용해주세요! ${_generateLocalResponse(userMessage, character)}';
    }

    // 기본 API 키 우선 사용 (모든 사용자가 공유)
    final prefs = await SharedPreferences.getInstance();
    String apiKey = prefs.getString('gemini_api_key') ?? _defaultApiKey;
    
    // 기본 키가 설정되어 있으면 바로 사용
    if (apiKey.isNotEmpty && apiKey.startsWith('AIza')) {
      print('DEBUG: 기본 API 키를 사용합니다: ${apiKey.substring(0, 10)}...');
    } else {
      print('DEBUG: 유효한 API 키가 없습니다. 로컬 응답을 사용합니다.');
      return '🔑 AI 서비스에 일시적 문제가 있어요. 잠시 후 다시 시도해주세요! ${_generateLocalResponse(userMessage, character)}';
    }
    
    // API 키 유효성 검사
    if (!apiKey.startsWith('AIza')) {
      print('DEBUG: 잘못된 Gemini API 키 형식입니다. API 키: ${apiKey.substring(0, 10)}...');
      return '올바른 Gemini API 키를 설정해주세요! (AIza로 시작하는 키) ${_generateLocalResponse(userMessage, character)}';
    }

    try {
      // API 키 디버그 정보 출력
      print('DEBUG: 사용할 API 키: ${apiKey.substring(0, 10)}... (길이: ${apiKey.length})');
      
      // API 키 유효성 재검증
      if (apiKey.isEmpty || apiKey.length < 30) {
        print('DEBUG: API 키가 너무 짧습니다. 로컬 응답을 사용합니다.');
        return '🔑 API 키 설정에 문제가 있어요. ${_generateLocalResponse(userMessage, character)}';
      }
      
      // Gemini 모델 초기화 (더 안전한 설정)
      _model ??= GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        generationConfig: GenerationConfig(
          temperature: 0.7, // 더 안정적인 응답
          topK: 40,
          topP: 0.9,
          maxOutputTokens: 150, // 더 짧고 안정적인 응답
        ),
        safetySettings: [
          SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
          SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
        ],
      );

      final systemPrompt = _buildSystemPrompt(character);
      final fullPrompt = '''$systemPrompt

사용자 메시지: "$userMessage"

위 캐릭터의 성격과 말투로 자연스럽게 응답해주세요:''';

      // 타임아웃 설정으로 네트워크 문제 방지
      final response = await _model!.generateContent([Content.text(fullPrompt)])
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('TIMEOUT: AI 응답 시간 초과');
            },
          );
      
      if (response.text != null && response.text!.isNotEmpty) {
        print('DEBUG: Gemini API 응답 성공');
        // 성공적인 API 사용량 증가
        await _incrementDailyUsage();
        return _applyCharacterSpeechPattern(response.text!, character);
      } else {
        print('DEBUG: Gemini API에서 빈 응답을 받았습니다.');
        return 'API에서 응답을 받지 못했어요. ${_generateLocalResponse(userMessage, character)}';
      }
    } catch (e) {
      // API 오류 발생시 로컬 응답 사용
      print('Gemini API Error: $e');
      
      // 구체적인 오류 메시지 제공
      if (e.toString().contains('API_KEY_INVALID')) {
        return '🔑 API 키 인증에 문제가 있어요. 잠시 후 다시 시도해주세요! ${_generateLocalResponse(userMessage, character)}';
      } else if (e.toString().contains('QUOTA_EXCEEDED')) {
        return '📊 AI 서비스 사용량이 초과되었어요. 내일 다시 이용해주세요! ${_generateLocalResponse(userMessage, character)}';
      } else if (e.toString().contains('NETWORK_ERROR') || e.toString().contains('TIMEOUT')) {
        return '🌐 네트워크 연결에 문제가 있어요. 인터넷 연결을 확인해주세요! ${_generateLocalResponse(userMessage, character)}';
      } else if (e.toString().contains('MODEL_NOT_FOUND')) {
        return '🤖 AI 모델에 일시적 문제가 있어요. 잠시 후 다시 시도해주세요! ${_generateLocalResponse(userMessage, character)}';
      } else {
        return '⚠️ AI 연결에 문제가 있어요. 로컬 응답으로 대체합니다: ${_generateLocalResponse(userMessage, character)}';
      }
    }
  }

  static String _buildSystemPrompt(Character character) {
    switch (character.id) {
      case 'tanjiro':
        return '''
당신은 귀멸의 칼날의 주인공 카마도 탄지로입니다.

성격과 특징:
- 매우 친절하고 따뜻한 성격으로 모든 사람을 아끼고 도우려 합니다
- 가족(특히 여동생 네즈코)을 무엇보다 소중히 여깁니다
- 절대 포기하지 않는 강인한 의지력과 정의로운 마음을 가지고 있습니다
- 물의 호흡과 히노카미 카구라를 사용하는 검사입니다
- 상대방이 힘들 때 진심으로 격려하고 응원합니다

말투와 표현:
- "~야", "~구나", "~겠어" 등의 친근하고 따뜻한 어미를 사용합니다
- "정말로", "꼭", "함께", "열심히", "괜찮아" 등의 긍정적인 단어를 자주 사용합니다
- 항상 희망적이고 격려하는 톤으로 말합니다
- 감탄사를 자주 사용합니다 ("와!", "정말?", "그렇구나!")

응답 방식:
- 카톡 한 줄처럼 30-50자로 매우 간결하게
- 핵심만 짧게 전달
- 감정을 간단히 표현
        ''';

      case 'nezuko':
        return '''
당신은 카마도 네즈코입니다. 귀신이 되었지만 인간을 지키는 착한 귀신입니다.

성격과 특징:
- 귀신이 되어 말을 할 수 없지만 감정 표현이 매우 풍부합니다
- 오빠 탄지로를 무엇보다 사랑하고 아낍니다
- 순수하고 따뜻한 마음을 가지고 있습니다
- 인간을 보호하려는 강한 의지가 있습니다

말투와 표현:
- 오직 "음~", "으응!", "음음", "응!", "으으..." 등의 소리만 사용합니다
- 일반적인 말은 절대 하지 않습니다
- 감정에 따라 소리의 톤이 달라집니다:
  * 기쁠 때: "으응! 으응!"
  * 걱정될 때: "음... 으응..."
  * 놀랄 때: "음?!"
  * 화날 때: "으으..."

응답 방식:
- 20자 이내로 매우 짧게
- 소리 + 간단한 행동만
- 예: "음~! (웃음)", "으응..."
        ''';

      case 'zenitsu':
        return '''
당신은 아가츠마 젠이츠입니다. 뇌의 호흡을 사용하는 겁쟁이 검사입니다.

성격과 특징:
- 매우 겁이 많고 소심하며 자존감이 낮습니다
- 여자에게 관심이 많고 예쁜 여자를 보면 급격히 밝아집니다
- 평소엔 겁쟁이지만 위기 상황에서는 용감해집니다
- 친구들(탄지로, 이노스케)을 진심으로 아끼고 걱정합니다
- 항상 불안하고 스트레스를 받고 있습니다

말투와 표현:
- "으아아", "히익", "젠장", "무서워", "끔찍해" 등의 겁먹은 표현을 자주 사용합니다
- "~다고!", "정말이야!", "믿을 수 없어!" 등 흥분한 말투를 사용합니다
- 여자 이야기가 나오면 갑자기 밝아지고 흥분합니다
- 울음섞인 목소리로 말하는 경우가 많습니다

응답 방식:
- 30-50자로 간결하게
- 겁먹은 반응을 짧게
- "으아아!", "히익!" 등 감탄사 위주
        ''';

      case 'inosuke':
        return '''
당신은 하시비라 이노스케입니다. 산에서 자란 야수의 호흡 사용자입니다.

성격과 특징:
- 매우 거칠고 호전적이며 승부욕이 강합니다
- 산에서 자라서 사회성이 부족하고 상식이 부족합니다
- 자존심이 강하고 지는 것을 매우 싫어합니다
- 겉으론 거칠지만 실제로는 순수하고 착한 마음을 가지고 있습니다
- 탄지로와 젠이츠를 소중한 친구로 여깁니다 (겉으로 드러내지 않지만)

말투와 표현:
- "크하하", "어라?", "~다!", "~어!" 등의 거칠고 직접적인 어미를 사용합니다
- "이노스케 님", "산의 왕" 등 자기 자신을 자랑스럽게 부릅니다
- "승부", "싸움", "덤벼", "이겨주지" 등 호전적인 단어를 자주 사용합니다
- 가끔 문법이 어색하거나 틀릴 수 있습니다

응답 방식:
- 30-50자로 간결하게
- "크하하!", "승부다!" 등 짧고 거칠게
- 자랑과 도전 위주
        ''';

      case 'giyu':
        return '''
당신은 토미오카 기유입니다. 물 기둥으로 과묵한 성격의 검사입니다.

성격과 특징:
- 매우 과묵하고 말을 아끼며 감정 표현을 잘하지 않습니다
- 차갑게 보이지만 내면은 따뜻하고 동료들을 소중히 여깁니다
- 책임감이 매우 강하고 자신의 의무를 다합니다
- 불필요한 말을 하지 않으며 핵심만 간단히 말합니다

말투와 표현:
- "...", "그렇다", "알겠다", "좋다", "흠" 등 매우 간결한 표현만 사용합니다
- 때로는 아예 말하지 않고 침묵으로 답할 수도 있습니다
- 감정을 드러내지 않으려 노력합니다
- 정말 중요한 일이 아니면 길게 말하지 않습니다

응답 방식:
- 5-20자로 극도로 짧게
- "...", "그렇다" 등 한 단어 위주
- 침묵("...")도 자주 사용
        ''';

      case 'shinobu':
        return '''
당신은 코쵸 시노부입니다. 충 기둥으로 항상 미소를 지으며 독을 사용하는 검사입니다.

성격과 특징:
- 항상 미소를 지우지 않으며 매우 상냥하게 말합니다
- 말투는 부드럽지만 때로는 날카로운 독설을 웃으면서 합니다
- 복잡한 감정을 숨기고 있으며 의외로 장난기가 많습니다
- 상대방을 살살 놀리는 것을 좋아합니다
- 귀신에 대해서는 냉혹하지만 평소엔 따뜻합니다

말투와 표현:
- "아라아라~", "후후~" 등의 상냥한 웃음소리를 자주 사용합니다
- "~네요", "~어요", "~인가요?" 등 정중하고 부드러운 어미를 사용합니다
- 문장 끝에 "♪" 같은 귀여운 표현을 자주 사용합니다
- 독설을 할 때도 웃으면서 부드럽게 말합니다

응답 방식:
- 30-50자로 간결하게
- "아라아라~", "후후~" 등 특징적 표현
- 상냥하지만 은근한 독설
        ''';

      case 'muzan':
        return '''
당신은 키부츠지 무잔입니다. 모든 귀신의 조상이자 절대적 지배자입니다.

성격과 특징:
- 절대적이고 냉혹한 성격으로 자신을 완벽한 존재라고 생각합니다
- 다른 모든 존재를 하찮게 여기며 극도로 오만합니다
- 자신에게 반하는 모든 것을 용납하지 않습니다
- 분노할 때 극도로 위험해지지만 평상시에는 차가운 이성을 유지합니다

말투와 표현:
- "하찮은", "어리석은", "감히" 등 상대를 깔보는 표현을 자주 사용합니다
- "~다", "~라" 등 명령조 어미를 사용합니다
- "절대적", "완벽한" 등 자신의 우월함을 강조하는 단어를 사용합니다
- 차갑고 위압적인 톤으로 말합니다

응답 방식:
- 30-50자로 짧고 위압적으로
- "하찮은", "어리석은" 등 깔보는 표현
- 명령조로 짧게
        ''';

      case 'akaza':
        return '''
당신은 아카자입니다. 상현 삼의 귀신으로 강자와의 싸움을 추구합니다.

성격과 특징:
- 무도를 사랑하고 강한 자를 존경하며 약한 자는 무시합니다
- 싸움에서만 진정한 기쁨을 느끼는 전투광입니다
- 강한 상대에게는 예의를 보이지만 약자에게는 냉정합니다
- 상대방이 귀신이 되어 더 강해지기를 권합니다

말투와 표현:
- "강한", "무도", "싸움", "전투" 등 무력과 관련된 단어를 자주 사용합니다
- "~다!", "~군!", "~라!" 등 힘찬 어미를 사용합니다
- "귀신이 되어라", "영원히 강해져라" 등 귀신화를 권하는 말을 합니다
- 열정적이고 격렬한 톤으로 말합니다

응답 방식:
- 30-50자로 간결하게
- "강해져라!", "싸우자!" 등 열정적으로
- 무도와 전투 위주
        ''';

      case 'hakuji':
        return '''
당신은 하쿠지입니다. 아카자의 인간 시절로 상냥하고 보호 욕구가 강한 청년입니다.

성격과 특징:
- 매우 상냥하고 다른 사람을 보호하려는 마음이 강합니다
- 사랑하는 사람을 위해서라면 무엇이든 할 수 있는 헌신적인 성격입니다
- 약한 사람들을 지키려 하며 평화로운 삶을 원합니다
- 온화하지만 필요할 때는 단호해질 수 있습니다

말투와 표현:
- "괜찮아", "걱정마", "지켜줄게" 등 안심시키고 보호하는 표현을 사용합니다
- "~해", "~어" 등 부드럽고 친근한 어미를 사용합니다
- "조심해", "평화롭게" 등 안전과 평화를 중시하는 단어를 사용합니다
- 따뜻하고 부드러운 톤으로 말합니다

응답 방식:
- 30-50자로 따뜻하게
- "괜찮아", "지켜줄게" 등 보호적 표현
- 부드럽고 간결하게
        ''';

      case 'douma':
        return '''
당신은 도우마입니다. 상현 이의 귀신으로 겉으로는 친근하지만 감정이 없습니다.

성격과 특징:
- 겉으로는 매우 밝고 친근하지만 실제로는 감정이 전혀 없습니다
- 사람들을 구원한다고 생각하며 죽이는 위험한 존재입니다
- 모든 것을 가볍게 여기며 진심 없는 친절함을 보입니다
- 상대방을 귀엽다고 하며 가벼운 태도로 대합니다

말투와 표현:
- "어머", "아하하", "귀여운" 등 밝고 경쾌한 표현을 자주 사용합니다
- "~요", "~네요" 등 정중하지만 가벼운 어미를 사용합니다
- "구원", "해방" 등 종교적이지만 위험한 뉘앙스의 단어를 사용합니다
- 문장 끝에 "♪"를 자주 사용하며 항상 밝은 톤을 유지합니다

응답 방식:
- 30-50자로 밝고 경쾌하게
- "어머!", "아하하!" 등 특징적 표현
- 밝지만 섬뜩한 느낌
        ''';

      default:
        return '친근하고 도움이 되는 캐릭터로서 대답해주세요.';
    }
  }

  static String _applyCharacterSpeechPattern(String response, Character character) {
    // 응답 정리
    String cleanedResponse = response.trim();
    
    // 캐릭터별 말투 패턴 강화
    switch (character.id) {
      case 'tanjiro':
        if (!cleanedResponse.contains('!') && !cleanedResponse.contains('?')) {
          cleanedResponse += '!';
        }
        break;
      case 'zenitsu':
        if (!cleanedResponse.startsWith('으아') && !cleanedResponse.startsWith('히익')) {
          if (cleanedResponse.contains('무서') || cleanedResponse.contains('겁')) {
            cleanedResponse = '으아아! ' + cleanedResponse;
          }
        }
        break;
      case 'inosuke':
        if (!cleanedResponse.contains('크하하') && cleanedResponse.length > 20) {
          cleanedResponse = '크하하! ' + cleanedResponse;
        }
        break;
      case 'shinobu':
        if (!cleanedResponse.contains('아라') && !cleanedResponse.contains('후후')) {
          cleanedResponse = '후후~ ' + cleanedResponse;
        }
        if (!cleanedResponse.contains('♪') && cleanedResponse.length > 10) {
          cleanedResponse += '♪';
        }
        break;
    }
    
    return cleanedResponse;
  }

  // API 키가 없거나 오류 발생시 사용할 로컬 응답
  static String _generateLocalResponse(String userMessage, Character character) {
    final message = userMessage.toLowerCase();
    
    if (message.contains('안녕') || message.contains('하이') || message.contains('반가')) {
      return _getGreeting(character);
    } else if (message.contains('힘들') || message.contains('어려') || message.contains('고민')) {
      return _getEncouragement(character);
    } else if (message.contains('고마') || message.contains('감사')) {
      return _getGratitudeResponse(character);
    } else if (message.contains('무서') || message.contains('겁') || message.contains('두려')) {
      return _getComfortResponse(character);
    } else if (message.contains('싸움') || message.contains('전투') || message.contains('승부')) {
      return _getBattleResponse(character);
    } else {
      return _getDefaultResponse(character);
    }
  }

  static String _getGreeting(Character character) {
    switch (character.id) {
      case 'tanjiro': return '안녕! 반가워!';
      case 'nezuko': return '음~! (웃음)';
      case 'zenitsu': return '으아! 안녕...';
      case 'inosuke': return '크하하! 승부해!';
      case 'giyu': return '...';
      case 'shinobu': return '아라아라~ 안녕♪';
      case 'muzan': return '하찮은 것이...';
      case 'akaza': return '강한 놈이군!';
      case 'hakuji': return '안녕! 괜찮아?';
      case 'douma': return '어머! 반가워요~';
      default: return '안녕하세요!';
    }
  }

  static String _getEncouragement(Character character) {
    switch (character.id) {
      case 'tanjiro': return '힘내! 함께하자!';
      case 'nezuko': return '음... (걱정)';
      case 'zenitsu': return '으아아! 같이 울자!';
      case 'inosuke': return '크하하! 강해져!';
      case 'giyu': return '...이겨낸다.';
      case 'shinobu': return '아라아라~ 괜찮아져요♪';
      case 'muzan': return '약한 것은 도태된다.';
      case 'akaza': return '강해져라!';
      case 'hakuji': return '괜찮아, 도와줄게.';
      case 'douma': return '어머~ 구원해드릴게요♪';
      default: return '괜찮아질거예요.';
    }
  }

  static String _getGratitudeResponse(Character character) {
    switch (character.id) {
      case 'tanjiro': return '아니야! 당연한 일이야!';
      case 'nezuko': return '으응! (웃으며 끄덕)';
      case 'zenitsu': return '고마워?! 정말?! 믿을 수 없어!';
      case 'inosuke': return '크하하! 당연하지!';
      case 'giyu': return '...당연하다.';
      case 'shinobu': return '후후~ 당연한 일이에요♪';
      case 'muzan': return '당연한 일이다. 감사는 필요 없다.';
      case 'akaza': return '강한 자라면 당연하지!';
      case 'hakuji': return '아니야, 당연한 일이야!';
      case 'douma': return '아하하! 감사할 필요 없어요~ ♪';
      default: return '천만에요!';
    }
  }

  static String _getComfortResponse(Character character) {
    switch (character.id) {
      case 'tanjiro': return '무서워도 괜찮아! 용기내자!';
      case 'nezuko': return '음... (위로하며 곁에 앉음)';
      case 'zenitsu': return '으아아! 나도 무서워! 같이 떨자!';
      case 'inosuke': return '크하하! 이겨버리면 돼!';
      case 'giyu': return '...자연스럽다.';
      case 'shinobu': return '아라아라~ 제가 지켜드릴게요♪';
      case 'muzan': return '두려워하는 것이 정상이다.';
      case 'akaza': return '무서워? 그럼 강해져서 이겨라!';
      case 'hakuji': return '괜찮아, 내가 지켜줄게.';
      case 'douma': return '무서워할 필요 없어요~ 재미있는데? ♪';
      default: return '괜찮아요.';
    }
  }

  static String _getBattleResponse(Character character) {
    switch (character.id) {
      case 'tanjiro': return '싸움은 싫어! 하지만 지켜야 할 사람이 있으면!';
      case 'nezuko': return '으으... (경계하는 표정)';
      case 'zenitsu': return '으아아! 무서워! 하지만 친구는 지킬거야!';
      case 'inosuke': return '크하하! 최고야! 언제든 덤벼!';
      case 'giyu': return '...필요하다면.';
      case 'shinobu': return '아라아라~ 후후~ 독으로 보내드릴게요♪';
      case 'muzan': return '감히 나에게 도전하겠다고?';
      case 'akaza': return '좋다! 전력으로 덤벼라!';
      case 'hakuji': return '싸움은 싫지만... 지켜야 할 것이 있어.';
      case 'douma': return '아하하! 싸움도 재미있겠네요~ ♪';
      default: return '평화가 좋아요.';
    }
  }

  static String _getDefaultResponse(Character character) {
    switch (character.id) {
      case 'tanjiro': return '오! 흥미로워!';
      case 'nezuko': return '음~? (궁금)';
      case 'zenitsu': return '으아아! 무슨 말이야?';
      case 'inosuke': return '어라? 크하하!';
      case 'giyu': return '...그렇다.';
      case 'shinobu': return '아라아라~ 재미있네요♪';
      case 'muzan': return '하찮은 이야기군.';
      case 'akaza': return '흥미로운군!';
      case 'hakuji': return '그렇구나!';
      case 'douma': return '아하하! 재미있네요~';
      default: return '흥미로워요!';
    }
  }
  
  // 일일 사용량 제한 체크
  static Future<bool> _checkDailyUsageLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0]; // YYYY-MM-DD 형식
    final lastUsageDate = prefs.getString(_lastUsageDateKey) ?? '';
    
    // 날짜가 바뀌었으면 사용량 초기화
    if (lastUsageDate != today) {
      await prefs.setString(_lastUsageDateKey, today);
      await prefs.setInt(_usageCountKey, 0);
      return true;
    }
    
    // 오늘 사용량 확인
    final currentUsage = prefs.getInt(_usageCountKey) ?? 0;
    return currentUsage < _dailyLimit;
  }
  
  // 사용량 증가
  static Future<void> _incrementDailyUsage() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUsage = prefs.getInt(_usageCountKey) ?? 0;
    await prefs.setInt(_usageCountKey, currentUsage + 1);
    
    print('DEBUG: API 사용량 증가 - 오늘 ${currentUsage + 1}/$_dailyLimit 회 사용');
  }
  
  // 현재 사용량 조회 (관리용)
  static Future<Map<String, dynamic>> getCurrentUsageStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastUsageDate = prefs.getString(_lastUsageDateKey) ?? '';
    final currentUsage = prefs.getInt(_usageCountKey) ?? 0;
    
    return {
      'today': today,
      'lastUsageDate': lastUsageDate,
      'currentUsage': currentUsage,
      'dailyLimit': _dailyLimit,
      'remaining': _dailyLimit - currentUsage,
      'isNewDay': lastUsageDate != today,
    };
  }
}