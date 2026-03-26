import 'package:dio/dio.dart';
import 'dart:convert';
import 'dart:developer' as developer;

/// AI 服务异常
class AIServiceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  AIServiceException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => 'AIServiceException: $message (status: $statusCode)';
}

/// 内容整理结果
class RefinementResult {
  final String refinedText;
  final List<String> tags;
  final String category;
  final String summary;

  const RefinementResult({
    required this.refinedText,
    required this.tags,
    required this.category,
    required this.summary,
  });

  /// 从 JSON 创建实例
  factory RefinementResult.fromJson(Map<String, dynamic> json) {
    return RefinementResult(
      refinedText: json['refinedText'] as String? ?? '',
      tags: _parseStringList(json['tags']),
      category: json['category'] as String? ?? '未分类',
      summary: json['summary'] as String? ?? '',
    );
  }

  /// 安全解析字符串列表
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  @override
  String toString() {
    return 'RefinementResult(tags: $tags, category: $category, summary: $summary)';
  }
}

/// AI 服务配置
class AIConfig {
  final String baseUrl;
  final String apiKey;
  final String model;
  final double temperature;
  final int? maxTokens;
  final Duration timeout;

  const AIConfig({
    required this.baseUrl,
    required this.apiKey,
    required this.model,
    this.temperature = 0.7,
    this.maxTokens,
    this.timeout = const Duration(seconds: 30),
  });

  /// 腾讯混元默认配置
  factory AIConfig.hunyuan({required String apiKey}) {
    return AIConfig(
      baseUrl: 'https://api.lkeap.cloud.tencent.com/v1',
      apiKey: apiKey,
      model: 'hunyuan-lite',
    );
  }

  /// Kimi 默认配置
  factory AIConfig.kimi({required String apiKey}) {
    return AIConfig(
      baseUrl: 'https://api.moonshot.cn/v1',
      apiKey: apiKey,
      model: 'moonshot-v1-8k',
    );
  }

  /// OpenAI 兼容格式默认配置
  factory AIConfig.openaiCompatible({
    required String baseUrl,
    required String apiKey,
    required String model,
  }) {
    return AIConfig(
      baseUrl: baseUrl,
      apiKey: apiKey,
      model: model,
    );
  }
}

/// AI 服务类
/// 
/// 支持 OpenAI 兼容格式的 API（腾讯混元、Kimi 等）
/// 
/// 使用示例：
/// ```dart
/// // 初始化配置
/// final aiService = AIService();
/// aiService.configure(
///   config: AIConfig.hunyuan(apiKey: 'your-api-key'),
/// );
/// 
/// // 整理内容
/// final result = await aiService.refineContent('这是一些碎片化的想法...');
/// print(result.refinedText);
/// 
/// // 继续讨论
/// final response = await aiService.continueDiscussion(
///   [{'role': 'user', 'content': '之前的对话'}],
///   '新的问题',
/// );
/// ```
class AIService {
  late Dio _dio;
  AIConfig _config = const AIConfig(
    baseUrl: 'https://api.lkeap.cloud.tencent.com/v1',
    apiKey: '',
    model: 'hunyuan-lite',
  );

  /// 创建 AI 服务实例
  AIService() {
    _initDio();
  }

  void _initDio() {
    _dio = Dio(BaseOptions(
      connectTimeout: _config.timeout,
      receiveTimeout: _config.timeout,
      sendTimeout: _config.timeout,
    ));
  }

  /// 配置 AI 服务
  /// 
  /// 可以通过 [AIConfig] 自定义 API 配置
  void configure({required AIConfig config}) {
    _config = config;
    _initDio();
    developer.log('AIService configured: ${config.baseUrl}, model: ${config.model}');
  }

  /// 直接设置配置参数（简化版）
  void setConfig({
    String? baseUrl,
    String? apiKey,
    String? model,
  }) {
    _config = AIConfig(
      baseUrl: baseUrl ?? _config.baseUrl,
      apiKey: apiKey ?? _config.apiKey,
      model: model ?? _config.model,
    );
    _initDio();
  }

  /// 检查服务是否已配置 API Key
  bool get isConfigured => _config.apiKey.isNotEmpty;

  /// 整理碎片内容为结构化 Markdown
  /// 
  /// [rawText] 原始碎片化文本
  /// 
  /// 返回 [RefinementResult] 包含整理后的内容、标签、分类和摘要
  /// 
  /// 可能抛出 [AIServiceException]
  Future<RefinementResult> refineContent(String rawText) async {
    if (!isConfigured) {
      throw AIServiceException('AI 服务未配置，请先调用 configure() 设置 API Key');
    }

    if (rawText.trim().isEmpty) {
      throw AIServiceException('输入内容不能为空');
    }

    final prompt = _buildRefinementPrompt(rawText);

    try {
      final response = await _sendChatRequest(
        messages: [
          {'role': 'system', 'content': '你是一个专业的内容整理助手，擅长将碎片化的想法整理成结构清晰的笔记。'},
          {'role': 'user', 'content': prompt},
        ],
        temperature: _config.temperature,
      );

      return _parseRefinementResponse(response);
    } on AIServiceException {
      rethrow;
    } catch (e, stackTrace) {
      developer.log('refineContent error', error: e, stackTrace: stackTrace);
      throw AIServiceException('内容整理失败', originalError: e);
    }
  }

  /// 继续讨论
  /// 
  /// [history] 历史对话记录，格式为 [{'role': 'user'|'assistant', 'content': '...'}]
  /// [userMessage] 用户新消息
  /// 
  /// 返回 AI 的回复文本
  /// 
  /// 可能抛出 [AIServiceException]
  Future<String> continueDiscussion(
    List<Map<String, String>> history,
    String userMessage,
  ) async {
    if (!isConfigured) {
      throw AIServiceException('AI 服务未配置，请先调用 configure() 设置 API Key');
    }

    if (userMessage.trim().isEmpty) {
      throw AIServiceException('消息内容不能为空');
    }

    // 验证 history 格式
    for (final msg in history) {
      if (!msg.containsKey('role') || !msg.containsKey('content')) {
        throw AIServiceException('history 格式错误：每条消息必须包含 role 和 content');
      }
      final role = msg['role'];
      if (role != 'user' && role != 'assistant' && role != 'system') {
        throw AIServiceException('role 必须是 user、assistant 或 system');
      }
    }

    final messages = [
      {
        'role': 'system',
        'content': '你是一位 thoughtful 的对话伙伴，帮助用户深入思考他们的想法。基于之前的讨论上下文，提供有价值的见解和追问。'
      },
      ...history,
      {'role': 'user', 'content': userMessage},
    ];

    try {
      final response = await _sendChatRequest(
        messages: messages,
        temperature: 0.8,
      );

      return _parseChatResponse(response);
    } on AIServiceException {
      rethrow;
    } catch (e, stackTrace) {
      developer.log('continueDiscussion error', error: e, stackTrace: stackTrace);
      throw AIServiceException('讨论失败', originalError: e);
    }
  }

  /// 发送聊天请求
  Future<Response> _sendChatRequest({
    required List<Map<String, dynamic>> messages,
    double? temperature,
  }) async {
    final data = <String, dynamic>{
      'model': _config.model,
      'messages': messages,
      'temperature': temperature ?? _config.temperature,
    };

    if (_config.maxTokens != null) {
      data['max_tokens'] = _config.maxTokens;
    }

    try {
      final response = await _dio.post(
        '${_config.baseUrl}/chat/completions',
        options: Options(
          headers: {
            'Authorization': 'Bearer ${_config.apiKey}',
            'Content-Type': 'application/json',
          },
          validateStatus: (status) => status != null && status < 500,
        ),
        data: data,
      );

      if (response.statusCode != 200) {
        final errorMsg = _extractErrorMessage(response.data);
        throw AIServiceException(
          'API 请求失败: $errorMsg',
          statusCode: response.statusCode,
        );
      }

      return response;
    } on DioException catch (e) {
      String message = '网络请求失败';
      int? statusCode;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          message = '请求超时，请检查网络连接';
          break;
        case DioExceptionType.connectionError:
          message = '网络连接错误，请检查网络';
          break;
        case DioExceptionType.badResponse:
          statusCode = e.response?.statusCode;
          message = _extractErrorMessage(e.response?.data);
          break;
        default:
          message = e.message ?? '未知错误';
      }

      throw AIServiceException(message, statusCode: statusCode, originalError: e);
    }
  }

  /// 从响应中提取错误信息
  String _extractErrorMessage(dynamic data) {
    if (data == null) return '未知错误';
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        return error['message']?.toString() ?? '未知错误';
      }
      return data['message']?.toString() ?? jsonEncode(data);
    }
    return data.toString();
  }

  /// 解析聊天响应
  String _parseChatResponse(Response response) {
    try {
      final data = response.data as Map<String, dynamic>;
      final choices = data['choices'] as List<dynamic>?;
      
      if (choices == null || choices.isEmpty) {
        throw AIServiceException('API 返回空响应');
      }

      final message = choices[0]['message'] as Map<String, dynamic>?;
      if (message == null) {
        throw AIServiceException('API 响应格式错误');
      }

      final content = message['content'] as String?;
      if (content == null || content.isEmpty) {
        throw AIServiceException('AI 返回空内容');
      }

      return content;
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('解析响应失败: $e');
    }
  }

  /// 解析内容整理响应
  RefinementResult _parseRefinementResponse(Response response) {
    final content = _parseChatResponse(response);
    
    // 尝试提取 JSON
    try {
      final jsonMatch = RegExp(r'\{[\s\S]*?\}').firstMatch(content);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        final jsonData = jsonDecode(jsonStr) as Map<String, dynamic>;
        return RefinementResult.fromJson(jsonData);
      }
    } catch (e) {
      developer.log('JSON parse failed, using fallback', error: e);
    }

    // JSON 解析失败时返回原始内容
    return RefinementResult(
      refinedText: content,
      tags: [],
      category: '未分类',
      summary: '',
    );
  }

  /// 构建整理提示词
  String _buildRefinementPrompt(String rawText) {
    return '''
请将以下碎片化的语音转文字内容进行整理：

原始内容：
$rawText

请执行以下操作：
1. 整理成结构清晰的 Markdown 格式
2. 提取 2-5 个关键词作为标签
3. 判断最适合的分类（可选：灵感、感悟、待办、读书、随笔、其他）
4. 补充合理的上下文，让内容更完整

请按以下 JSON 格式返回：
{
  "refinedText": "整理后的 Markdown 内容",
  "tags": ["标签1", "标签2"],
  "category": "分类名称",
  "summary": "一句话摘要"
}
'''
    ;
  }
}
