import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/inspiration.dart';
import '../services/database_service.dart';
import '../services/ai_service.dart';

// 数据库服务
final databaseServiceProvider = Provider<DatabaseService>((ref) {
  return DatabaseService();
});

// AI 服务
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// 灵感列表
final inspirationsProvider = StateNotifierProvider<InspirationsNotifier, List<Inspiration>>((ref) {
  return InspirationsNotifier(ref);
});

class InspirationsNotifier extends StateNotifier<List<Inspiration>> {
  final Ref ref;
  
  InspirationsNotifier(this.ref) : super([]);
  
  Future<void> loadInspirations() async {
    final db = ref.read(databaseServiceProvider);
    final inspirations = await db.getAllInspirations();
    state = inspirations;
  }
  
  Future<void> refresh() async {
    await loadInspirations();
  }
}

// 分类列表
final categoriesProvider = FutureProvider<List<String>>((ref) async {
  final db = ref.read(databaseServiceProvider);
  final categories = await db.getAllCategories();
  final defaultCategories = ['全部', '灵感', '感悟', '待办', '读书', '随笔'];
  for (var cat in defaultCategories) {
    if (!categories.contains(cat)) {
      categories.add(cat);
    }
  }
  return categories;
});

// 当前选中分类
final selectedCategoryProvider = StateProvider<String>((ref) => '全部');

// 灵感详情
final inspirationDetailProvider = FutureProvider.family<Inspiration?, String>((ref, id) async {
  final db = ref.read(databaseServiceProvider);
  return await db.getInspiration(id);
});

// 录音状态
enum RecordingState { idle, recording, processing }
final recordingStateProvider = StateProvider<RecordingState>((ref) => RecordingState.idle);
final recordingDurationProvider = StateProvider<int>((ref) => 0);

// 搜索查询
final searchQueryProvider = StateProvider<String>((ref) => '');

// 过滤后的灵感列表
final filteredInspirationsProvider = Provider<List<Inspiration>>((ref) {
  final inspirations = ref.watch(inspirationsProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);
  
  return inspirations.where((inspiration) {
    // 分类过滤
    if (selectedCategory != '全部' && inspiration.category != selectedCategory) {
      return false;
    }
    // 搜索过滤
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      return inspiration.refinedText.toLowerCase().contains(query) ||
             inspiration.tags.any((tag) => tag.toLowerCase().contains(query));
    }
    return true;
  }).toList();
});
