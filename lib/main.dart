import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/character_selection_screen.dart';
import 'providers/chat_provider.dart';
import 'theme/app_theme.dart';

void main() {
  // 웹 성능 최적화
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const DemonSlayerChatbotApp());
}

class DemonSlayerChatbotApp extends StatelessWidget {
  const DemonSlayerChatbotApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ChatProvider(),
      child: MaterialApp(
        title: '귀멸의 칼날 챗봇',
        theme: AppTheme.darkTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.dark,
        home: const CharacterSelectionScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
