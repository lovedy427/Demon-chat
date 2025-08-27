import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../services/gemini_chatbot_service.dart';

class ApiKeySettingScreen extends StatefulWidget {
  const ApiKeySettingScreen({super.key});

  @override
  State<ApiKeySettingScreen> createState() => _ApiKeySettingScreenState();
}

class _ApiKeySettingScreenState extends State<ApiKeySettingScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _usageStatus;

  @override
  void initState() {
    super.initState();
    _loadApiKey();
    _loadUsageStatus();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString('gemini_api_key') ?? '';
    _apiKeyController.text = apiKey;
  }

  Future<void> _loadUsageStatus() async {
    final status = await GeminiChatbotService.getCurrentUsageStatus();
    setState(() {
      _usageStatus = status;
    });
  }

  Future<void> _saveApiKey() async {
    final apiKey = _apiKeyController.text.trim();
    
    // API 키 유효성 검사
    if (apiKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('API 키를 입력해주세요!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    if (!apiKey.startsWith('AIza')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('올바른 Gemini API 키를 입력해주세요! (AIza로 시작)'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('gemini_api_key', apiKey);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ API 키가 저장되었습니다! 이제 AI 채팅을 즐기세요!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ API 키 저장에 실패했습니다.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text(
          'AI 설정',
          style: TextStyle(color: AppTheme.textColor),
        ),
        backgroundColor: AppTheme.primaryColor,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '🎉 AI 서비스 정보',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.blue.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: Colors.blue,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '🎉 자동 설정 완료!\n소유자의 API 키가 이미 설정되어 있어 모든 사용자가 바로 사용할 수 있습니다. 일일 1,400회까지 무료로 AI 대화를 즐기세요!',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppTheme.textColor.withOpacity(0.9),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // 일일 사용량 정보 표시
              _buildUsageInfoCard(),
              const SizedBox(height: 16),
              Text(
                '🔒 자동 설정된 무료 AI 서비스\n소유자의 API 키로 일일 1,400회까지 모든 사용자가 무료로 이용 가능합니다.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.textColor.withOpacity(0.8),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.green.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✅ API 키 자동 설정됨',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '소유자의 API 키가 이미 설정되어 있어 별도 입력이 필요 없습니다.',
                            style: TextStyle(
                              color: AppTheme.textColor.withOpacity(0.8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '🎉 자동 설정 완료!',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildStepText('✅ 소유자의 API 키가 자동으로 설정됨'),
                      _buildStepText('✅ 모든 사용자가 별도 설정 없이 바로 사용 가능'),
                      _buildStepText('✅ 일일 1,400회까지 무료로 AI 대화 가능'),
                      _buildStepText('✅ 과금 방지를 위한 자동 사용량 제한'),
                      _buildStepText('✅ 로컬 응답으로 백업 시스템 제공'),
                      const SizedBox(height: 12),
                      Text(
                        '💡 설정 완료! 바로 AI 대화를 시작하세요!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    '닫기',
                    style: TextStyle(
                      color: AppTheme.textColor.withOpacity(0.7),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: TextStyle(
          color: AppTheme.textColor.withOpacity(0.8),
          fontSize: 15,
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildUsageInfoCard() {
    if (_usageStatus == null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            CircularProgressIndicator(
              strokeWidth: 2,
              color: AppTheme.primaryColor,
            ),
            const SizedBox(width: 12),
            Text(
              '사용량 정보 로딩 중...',
              style: TextStyle(
                color: AppTheme.textColor.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    final currentUsage = _usageStatus!['currentUsage'] as int;
    final dailyLimit = _usageStatus!['dailyLimit'] as int;
    final remaining = _usageStatus!['remaining'] as int;
    final usagePercentage = (currentUsage / dailyLimit * 100).round();

    Color statusColor = Colors.green;
    String statusText = '양호';
    if (usagePercentage > 80) {
      statusColor = Colors.red;
      statusText = '주의';
    } else if (usagePercentage > 60) {
      statusColor = Colors.orange;
      statusText = '경고';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '📊 오늘의 AI 사용량',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppTheme.textColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  statusText,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: currentUsage / dailyLimit,
            backgroundColor: Colors.grey.withOpacity(0.3),
            valueColor: AlwaysStoppedAnimation<Color>(statusColor),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$currentUsage / $dailyLimit 회 사용',
                style: TextStyle(
                  color: AppTheme.textColor.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              Text(
                '$remaining 회 남음',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (remaining < 50) ...[
            const SizedBox(height: 8),
            Text(
              '⚠️ 과금 방지를 위해 사용량이 제한됩니다',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }
}
