import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTheme {
  // 귀멸의 칼날 테마 컬러 - 더욱 세련되고 현대적으로
  static const Color primaryColor = Color(0xFF1a237e); // 진한 남색 (밤하늘)
  static const Color secondaryColor = Color(0xFFd32f2f); // 진홍색 (검의 색)
  static const Color accentColor = Color(0xFFff6f00); // 주황색 (불꽃)
  static const Color backgroundColor = Color(0xFF0a0e27); // 깊은 밤색
  static const Color surfaceColor = Color(0xFF1e1e2e); // 진한 회색
  static const Color cardColor = Color(0xFF2a2d3a); // 카드 배경
  static const Color textColor = Color(0xFFcdd6f4); // 밝은 회색
  static const Color lightGrey = Color(0xFF45475a);
  static const Color gradientStart = Color(0xFF1e3c72);
  static const Color gradientEnd = Color(0xFF2a5298);

  static ThemeData darkTheme = ThemeData.dark().copyWith(
    primaryColor: primaryColor,
    scaffoldBackgroundColor: backgroundColor,
    cardColor: cardColor,
    dividerColor: lightGrey,
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      background: backgroundColor,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: textColor,
      onBackground: textColor,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        color: textColor,
        fontSize: 28,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: textColor,
        fontSize: 22,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.25,
      ),
      titleLarge: TextStyle(
        color: textColor,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: TextStyle(
        color: textColor,
        fontSize: 16,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        color: textColor,
        fontSize: 14,
        height: 1.4,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 8,
        shadowColor: primaryColor.withOpacity(0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        textStyle: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: cardColor,
      margin: const EdgeInsets.all(8),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: textColor,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
        color: textColor,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: lightGrey.withOpacity(0.3)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: lightGrey.withOpacity(0.3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      filled: true,
      fillColor: cardColor,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      hintStyle: TextStyle(color: textColor.withOpacity(0.6)),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    ),
  );

  // 캐릭터별 색상 - 더욱 생동감 있고 매력적으로
  static Color getCharacterColor(String characterId) {
    switch (characterId) {
      case 'tanjiro':
        return const Color(0xFF00bcd4); // 아쿠아 블루 (물의 호흡)
      case 'nezuko':
        return const Color(0xFFff4081); // 비비드 핑크 (사랑과 보호)
      case 'zenitsu':
        return const Color(0xFFffc107); // 일렉트릭 옐로우 (번개)
      case 'inosuke':
        return const Color(0xFFff5722); // 와일드 오렌지 (야수의 본능)
      case 'giyu':
        return const Color(0xFF3f51b5); // 딥 인디고 (고요한 물)
      case 'shinobu':
        return const Color(0xFF9c27b0); // 바이올렛 퍼플 (독과 우아함)
      case 'muzan':
        return const Color(0xFF1a1a2e); // 미드나잇 블랙 (절대악)
      case 'akaza':
        return const Color(0xFFe91e63); // 크림슨 레드 (격렬한 전투)
      case 'hakuji':
        return const Color(0xFF4caf50); // 에메랄드 그린 (평화로운 마음)
      case 'douma':
        return const Color(0xFF03a9f4); // 아이스 블루 (얼음의 차가움)
      default:
        return primaryColor;
    }
  }

  static LinearGradient getCharacterGradient(String characterId) {
    final color = getCharacterColor(characterId);
    return LinearGradient(
      colors: [
        color,
        color.withOpacity(0.7),
        color.withOpacity(0.4),
      ],
      stops: const [0.0, 0.5, 1.0],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  // 귀멸의 칼날 스타일 배경 그라디언트
  static LinearGradient get backgroundGradient => const LinearGradient(
    colors: [
      Color(0xFF0a0e27), // 깊은 밤하늘
      Color(0xFF16213e), // 어둠 속의 푸른빛
      Color(0xFF1a1a2e), // 깊은 자주색
      Color(0xFF0f3460), // 물의 호흡 느낌
    ],
    stops: [0.0, 0.3, 0.7, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 귀멸의 칼날 패턴 배경 (격자무늬)
  static LinearGradient get patternGradient => const LinearGradient(
    colors: [
      Color(0xFF1a237e), // 진한 남색
      Color(0xFF283593), // 중간 남색  
      Color(0xFF3949ab), // 밝은 남색
    ],
    stops: [0.0, 0.5, 1.0],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 검의 빛 효과
  static LinearGradient get swordGlowGradient => const LinearGradient(
    colors: [
      Color(0xFF64b5f6), // 밝은 파랑
      Color(0xFF1976d2), // 중간 파랑
      Color(0xFF0d47a1), // 진한 파랑
    ],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // 카드 그라디언트
  static LinearGradient get cardGradient => LinearGradient(
    colors: [
      cardColor,
      cardColor.withOpacity(0.8),
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // 글로우 효과
  static BoxShadow getGlowEffect(Color color) {
    return BoxShadow(
      color: color.withOpacity(0.3),
      blurRadius: 20,
      spreadRadius: 2,
      offset: const Offset(0, 4),
    );
  }

  // 네온 효과
  static BoxShadow getNeonEffect(Color color) {
    return BoxShadow(
      color: color.withOpacity(0.6),
      blurRadius: 15,
      spreadRadius: 1,
      offset: const Offset(0, 0),
    );
  }
}
