import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inspiration.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';

// ==================== 服务 Providers ====================

/// 数据库服务 Provider
/// 提供单例的 DatabaseService 实例
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

/// AI 服务 Provider
/// 提供单例的 AIService 实例
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// ==================== 数据 Providers ====================

/// 灵感列表 Provider
/// 从数据库获取所有灵感记录，按创建时间倒序排列
final inspirationsProvider = FutureProvider<List<Inspiration>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getAllInspirations();
});

/// 分类筛选 Provider
/// 根据分类名称获取灵感列表
/// 使用 family 修饰符支持参数传递
final inspirationsByCategoryProvider = FutureProvider.family<List<Inspiration>, String>((ref, category) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getInspirationsByCategory(category);
});

/// 分类列表 Provider
/// 获取所有分类列表，包含默认分类
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final dbService = ref.watch(databaseServiceProvider);
  final categories = await dbService.getAllCategories();
  
  // 确保默认分类存在
  const defaultCategories = ['全部', '灵感', '感悟', '待办', '读书', '随笔', '其他'];
  
  // 合并数据库中的分类和默认分类，去重并保持顺序
  final allCategories = <String>['全部'];
  
  // 添加数据库中已有的分类（排除'全部'）
  for (final category in categories) {
    if (category != '全部' && !allCategories.contains(category)) {
      allCategories.add(category);
    }
  }
  
  // 添加剩余的默认分类
  for (final category in defaultCategories) {
    if (category != '全部' && !allCategories.contains(category)) {
      allCategories.add(category);
    }
  }
  
  return allCategories;
});

/// 灵感详情 Provider
/// 根据 ID 获取单条灵感记录
/// 使用 family 修饰符支持 ID 参数传递
final inspirationDetailProvider = FutureProvider.family<Inspiration?, String>((ref, id) async {
  final dbService = ref.watch(databaseServiceProvider);
  return await dbService.getInspiration(id);
});

// ==================== 状态 Providers ====================

/// 当前选中分类 StateProvider
/// 用于管理当前选中的分类筛选状态，默认值为 '全部'
final selectedCategoryProvider = StateProvider<String>((ref) => '全部');

/// 录音状态枚举
enum RecordingState {
  /// 空闲状态
  idle,
  /// 正在录音
  recording,
  /// 处理中（语音识别、AI 整理等）
  processing,
}

/// 录音状态 StateProvider
/// 管理录音界面的当前状态
final recordingStateProvider = StateProvider<RecordingState>((ref) => RecordingState.idle);

/// 录音时长 StateProvider
/// 记录当前录音的持续时间（秒）
final recordingDurationProvider = StateProvider<int>((ref) => 0);
