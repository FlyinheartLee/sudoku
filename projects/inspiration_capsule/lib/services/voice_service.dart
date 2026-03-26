import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:developer' as developer;
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

/// 语音识别服务异常
class VoiceServiceException implements Exception {
  final String message;
  final VoiceErrorCode code;
  final dynamic originalError;

  VoiceServiceException(this.message, {this.code = VoiceErrorCode.unknown, this.originalError});

  @override
  String toString() => 'VoiceServiceException [$code]: $message';
}

/// 语音服务错误码
enum VoiceErrorCode {
  unknown,
  permissionDenied,
  microphoneInUse,
  initializationFailed,
  recordingFailed,
  recognitionFailed,
  networkError,
  timeout,
  invalidAudio,
}

/// 语音识别结果
class RecognitionResult {
  final String text;
  final double confidence;
  final bool isFinal;
  final List<WordDetail>? wordDetails;
  final Duration? duration;

  const RecognitionResult({
    required this.text,
    this.confidence = 1.0,
    this.isFinal = true,
    this.wordDetails,
    this.duration,
  });

  @override
  String toString() => 'RecognitionResult(text: $text, confidence: $confidence, isFinal: $isFinal)';
}

/// 单词详情（用于时间戳等高级功能）
class WordDetail {
  final String word;
  final Duration startTime;
  final Duration endTime;

  const WordDetail({
    required this.word,
    required this.startTime,
    required this.endTime,
  });
}

/// 录音状态
enum RecordingState {
  idle,
  initializing,
  recording,
  processing,
  error,
}

/// 语音识别回调
abstract class RecognitionCallback {
  /// 录音音量变化（0.0 - 1.0）
  void onVolumeChanged(double volume);

  /// 识别结果（可能是中间结果）
  void onResult(RecognitionResult result);

  /// 错误回调
  void onError(VoiceServiceException error);

  /// 录音开始
  void onRecordingStarted();

  /// 录音结束
  void onRecordingStopped(Duration duration);
}

/// 语音服务配置
class VoiceConfig {
  /// 科大讯飞 AppId（目前为模拟模式，暂不使用）
  final String? xfyunAppId;
  
  /// 科大讯飞 API Key（目前为模拟模式，暂不使用）
  final String? xfyunApiKey;
  
  /// 科大讯飞 API Secret（目前为模拟模式，暂不使用）
  final String? xfyunApiSecret;
  
  /// 是否启用模拟模式
  final bool isMockMode;
  
  /// 录音采样率
  final int sampleRate;
  
  /// 录音最大时长（秒）
  final int maxDurationSeconds;
  
  /// 录音自动停止的静音时长（秒）
  final int silenceTimeoutSeconds;
  
  /// 是否返回词级时间戳
  final bool enableWordTimeStamp;
  
  /// 语言类型：zh_cn（中文）、en_us（英文）等
  final String language;

  const VoiceConfig({
    this.xfyunAppId,
    this.xfyunApiKey,
    this.xfyunApiSecret,
    this.isMockMode = true,
    this.sampleRate = 16000,
    this.maxDurationSeconds = 60,
    this.silenceTimeoutSeconds = 3,
    this.enableWordTimeStamp = false,
    this.language = 'zh_cn',
  });

  /// 检查是否配置了科大讯飞
  bool get hasXfyunConfig => 
      xfyunAppId != null && xfyunAppId!.isNotEmpty &&
      xfyunApiKey != null && xfyunApiKey!.isNotEmpty;
}

/// 语音服务接口
/// 
/// 当前为模拟实现，接口设计兼容科大讯飞语音听写
/// 后续接入科大讯飞时只需替换内部实现，保持接口不变
/// 
/// 使用示例：
/// ```dart
/// // 初始化（模拟模式）
/// final voiceService = VoiceService();
/// await voiceService.initialize();
/// 
/// // 开始录音并识别
/// await voiceService.startListening(callback: MyCallback());
/// 
/// // 停止录音
/// final result = await voiceService.stopListening();
/// 
/// // 识别本地音频文件
/// final result = await voiceService.recognizeFile('/path/to/audio.wav');
/// ```
class VoiceService {
  final AudioRecorder _recorder = AudioRecorder();
  VoiceConfig _config = const VoiceConfig();
  
  RecordingState _state = RecordingState.idle;
  String? _currentRecordingPath;
  Timer? _maxDurationTimer;
  Timer? _volumeTimer;
  RecognitionCallback? _callback;
  DateTime? _recordingStartTime;

  // 状态监听流
  final _stateController = StreamController<RecordingState>.broadcast();
  Stream<RecordingState> get onStateChanged => _stateController.stream;

  /// 获取当前状态
  RecordingState get state => _state;

  /// 是否正在录音
  bool get isRecording => _state == RecordingState.recording;

  /// 初始化语音服务
  Future<void> initialize({VoiceConfig? config}) async {
    _state = RecordingState.initializing;
    _stateController.add(_state);

    try {
      if (config != null) {
        _config = config;
      }

      // 检查录音权限
      final hasPermission = await _checkPermission();
      if (!hasPermission) {
        throw VoiceServiceException(
          '需要麦克风权限才能使用语音功能',
          code: VoiceErrorCode.permissionDenied,
        );
      }

      _state = RecordingState.idle;
      _stateController.add(_state);
      developer.log('VoiceService initialized, mock mode: ${_config.isMockMode}');
    } catch (e) {
      _state = RecordingState.error;
      _stateController.add(_state);
      rethrow;
    }
  }

  /// 配置服务
  void configure(VoiceConfig config) {
    _config = config;
    developer.log('VoiceService configured, mock mode: ${config.isMockMode}');
  }

  /// 检查并请求权限
  Future<bool> _checkPermission() async {
    final status = await Permission.microphone.status;
    if (status.isGranted) return true;
    
    final result = await Permission.microphone.request();
    return result.isGranted;
  }

  /// 开始录音并实时识别
  /// 
  /// [callback] 识别回调接口
  /// 
  /// 在模拟模式下，会定时返回模拟的识别结果
  Future<void> startListening({required RecognitionCallback callback}) async {
    if (_state == RecordingState.recording) {
      throw VoiceServiceException('正在录音中', code: VoiceErrorCode.microphoneInUse);
    }

    if (!await _checkPermission()) {
      throw VoiceServiceException(
        '没有麦克风权限',
        code: VoiceErrorCode.permissionDenied,
      );
    }

    _callback = callback;
    _state = RecordingState.recording;
    _stateController.add(_state);
    _recordingStartTime = DateTime.now();

    try {
      // 获取录音文件路径
      final tempDir = await getTemporaryDirectory();
      _currentRecordingPath = '${tempDir.path}/voice_recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

      // 配置录音参数
      const recordConfig = RecordConfig(
        encoder: AudioEncoder.aacLc,
        bitRate: 128000,
        sampleRate: 16000,
        numChannels: 1,
      );

      // 开始录音
      await _recorder.start(recordConfig, path: _currentRecordingPath!);
      callback.onRecordingStarted();
      developer.log('Recording started: $_currentRecordingPath');

      // 启动音量监听（模拟）
      _startVolumeMonitoring();

      // 启动模拟识别结果（模拟模式）
      if (_config.isMockMode) {
        _startMockRecognition();
      } else {
        // TODO: 接入科大讯飞实时语音识别
        _startXfyunRecognition();
      }

      // 设置最大时长定时器
      _maxDurationTimer = Timer(Duration(seconds: _config.maxDurationSeconds), () {
        developer.log('Max duration reached, auto stopping');
        stopListening();
      });

    } catch (e) {
      _state = RecordingState.error;
      _stateController.add(_state);
      throw VoiceServiceException(
        '启动录音失败',
        code: VoiceErrorCode.recordingFailed,
        originalError: e,
      );
    }
  }

  /// 停止录音
  /// 
  /// 返回最终识别结果
  Future<RecognitionResult> stopListening() async {
    if (_state != RecordingState.recording) {
      return RecognitionResult(text: '', confidence: 0.0);
    }

    _state = RecordingState.processing;
    _stateController.add(_state);

    // 取消定时器
    _maxDurationTimer?.cancel();
    _maxDurationTimer = null;
    _volumeTimer?.cancel();
    _volumeTimer = null;

    final recordingDuration = _recordingStartTime != null
        ? DateTime.now().difference(_recordingStartTime!)
        : Duration.zero;

    try {
      // 停止录音
      await _recorder.stop();
      _callback?.onRecordingStopped(recordingDuration);
      developer.log('Recording stopped, duration: $recordingDuration');

      // 获取识别结果
      final result = await _performRecognition();

      _state = RecordingState.idle;
      _stateController.add(_state);

      return result;
    } catch (e) {
      _state = RecordingState.error;
      _stateController.add(_state);
      throw VoiceServiceException(
        '停止录音失败',
        code: VoiceErrorCode.recordingFailed,
        originalError: e,
      );
    }
  }

  /// 取消录音
  Future<void> cancelListening() async {
    _maxDurationTimer?.cancel();
    _volumeTimer?.cancel();

    try {
      await _recorder.stop();
      
      // 删除录音文件
      if (_currentRecordingPath != null) {
        final file = File(_currentRecordingPath!);
        if (await file.exists()) {
          await file.delete();
        }
      }
    } catch (e) {
      developer.log('Error during cancel', error: e);
    }

    _state = RecordingState.idle;
    _stateController.add(_state);
    _callback = null;
  }

  /// 识别本地音频文件
  /// 
  /// [filePath] 音频文件路径（支持 wav、mp3、m4a 等格式）
  Future<RecognitionResult> recognizeFile(String filePath) async {
    _state = RecordingState.processing;
    _stateController.add(_state);

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw VoiceServiceException('文件不存在', code: VoiceErrorCode.invalidAudio);
      }

      if (_config.isMockMode) {
        // 模拟识别
        await Future.delayed(const Duration(seconds: 1));
        return _generateMockResult(isFinal: true);
      } else {
        // TODO: 接入科大讯飞音频文件识别
        return await _xfyunFileRecognition(filePath);
      }
    } catch (e) {
      _state = RecordingState.error;
      _stateController.add(_state);
      if (e is VoiceServiceException) rethrow;
      throw VoiceServiceException(
        '文件识别失败',
        code: VoiceErrorCode.recognitionFailed,
        originalError: e,
      );
    } finally {
      _state = RecordingState.idle;
      _stateController.add(_state);
    }
  }

  /// 释放资源
  Future<void> dispose() async {
    await cancelListening();
    _stateController.close();
    await _recorder.dispose();
  }

  // ==================== 内部方法 ====================

  /// 启动音量监听（模拟）
  void _startVolumeMonitoring() {
    _volumeTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      // 模拟音量变化（随机值）
      final volume = 0.1 + math.Random().nextDouble() * 0.4;
      _callback?.onVolumeChanged(volume);
    });
  }

  /// 启动模拟识别
  void _startMockRecognition() {
    // 模拟中间结果
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_state == RecordingState.recording) {
        _callback?.onResult(_generateMockResult(isFinal: false));
      }
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (_state == RecordingState.recording) {
        _callback?.onResult(_generateMockResult(isFinal: false));
      }
    });
  }

  /// 生成模拟识别结果
  RecognitionResult _generateMockResult({required bool isFinal}) {
    final mockTexts = [
      '这是一个',
      '这是一个测试',
      '这是一个测试语音',
      '这是一个测试语音输入',
      '这是一个测试语音输入的',
      '这是一个测试语音输入的结果',
    ];

    final text = mockTexts[math.Random().nextInt(mockTexts.length)];
    return RecognitionResult(
      text: text,
      confidence: 0.8 + math.Random().nextDouble() * 0.15,
      isFinal: isFinal,
    );
  }

  /// 执行语音识别
  Future<RecognitionResult> _performRecognition() async {
    if (_config.isMockMode) {
      // 模拟处理延迟
      await Future.delayed(const Duration(milliseconds: 500));
      return _generateMockResult(isFinal: true);
    } else {
      // TODO: 接入科大讯飞识别
      return await _xfyunFileRecognition(_currentRecordingPath!);
    }
  }

  /// 科大讯飞实时语音识别（待实现）
  void _startXfyunRecognition() {
    // TODO: 接入科大讯飞语音听写 WebSocket API
    // 参考：https://www.xfyun.cn/doc/asr/voicedictation/WebSocket.html
    
    /*
    实现步骤：
    1. 构建 WebSocket 连接 URL（需鉴权）
    2. 发送音频流数据
    3. 接收识别结果
    4. 处理中间结果和最终结果
    */
    
    throw UnimplementedError('科大讯飞实时识别待实现，请使用模拟模式');
  }

  /// 科大讯飞文件识别（待实现）
  Future<RecognitionResult> _xfyunFileRecognition(String filePath) async {
    // TODO: 接入科大讯飞语音听写 HTTP API
    
    /*
    实现步骤：
    1. 读取音频文件
    2. 调用科大讯飞识别接口
    3. 解析返回结果
    4. 返回 RecognitionResult
    */
    
    throw UnimplementedError('科大讯飞文件识别待实现，请使用模拟模式');
  }
}

/// 简单的回调实现示例
class SimpleRecognitionCallback extends RecognitionCallback {
  final void Function(String text, bool isFinal)? onTextResult;
  final void Function(double volume)? onVolume;
  final void Function(VoiceServiceException error)? onErrorCallback;

  SimpleRecognitionCallback({
    this.onTextResult,
    this.onVolume,
    this.onErrorCallback,
  });

  @override
  void onError(VoiceServiceException error) {
    onErrorCallback?.call(error);
  }

  @override
  void onRecordingStarted() {
    developer.log('Recording started');
  }

  @override
  void onRecordingStopped(Duration duration) {
    developer.log('Recording stopped after ${duration.inSeconds}s');
  }

  @override
  void onResult(RecognitionResult result) {
    onTextResult?.call(result.text, result.isFinal);
  }

  @override
  void onVolumeChanged(double volume) {
    onVolume?.call(volume);
  }
}
