import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../models/inspiration.dart';

/// 底部弹窗 - AI整理确认界面
class RefinementScreen extends ConsumerStatefulWidget {
  final String rawText;
  final RefinementResult result;

  const RefinementScreen({
    super.key,
    required this.rawText,
    required this.result,
  });

  @override
  ConsumerState<RefinementScreen> createState() => _RefinementScreenState();
}

class _RefinementScreenState extends ConsumerState<RefinementScreen> {
  late TextEditingController _refinedController;
  late TextEditingController _rawController;
  late List<String> _tags;
  late String _category;
  bool _isEditingRaw = false;
  bool _isReRefining = false;

  final List<String> _defaultCategories = [
    '灵感',
    '感悟',
    '待办',
    '读书',
    '随笔',
  ];

  @override
  void initState() {
    super.initState();
    _refinedController = TextEditingController(text: widget.result.refinedText);
    _rawController = TextEditingController(text: widget.rawText);
    _tags = List.from(widget.result.tags);
    _category = widget.result.category;
  }

  @override
  void dispose() {
    _refinedController.dispose();
    _rawController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // 顶部栏："整理结果" + 关闭按钮
          _buildHeader(),
          
          // 内容区域
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 原文区域（灰色背景）
                  _buildOriginalSection(),
                  
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  
                  // AI整理区域
                  _buildRefinedSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 标签区域
                  _buildTagsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // 分类区域
                  _buildCategorySection(),
                  
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // 底部按钮：重新整理（左） + 确认保存（右，主色）
          _buildBottomButtons(),
          
          SizedBox(height: bottomPadding),
        ],
      ),
    );
  }

  /// 标题栏："整理结果" + 关闭按钮
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
            tooltip: '关闭',
          ),
          const Expanded(
            child: Text(
              '整理结果',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // 平衡关闭按钮的宽度
        ],
      ),
    );
  }

  /// 原文区域（灰色背景）
  Widget _buildOriginalSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签"原文" + 编辑按钮
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '原文',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _isEditingRaw = !_isEditingRaw),
              icon: Icon(
                _isEditingRaw ? Icons.check : Icons.edit,
                size: 16,
                color: AppTheme.primaryColor,
              ),
              label: Text(
                _isEditingRaw ? '完成' : '编辑',
                style: const TextStyle(color: AppTheme.primaryColor),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        // 灰色背景区域
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF3A3A3C) : Colors.grey[200]!,
            ),
          ),
          child: _isEditingRaw
              ? TextField(
                  controller: _rawController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    hintText: '原始内容...',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[200] : Colors.grey[700],
                    height: 1.6,
                  ),
                )
              : Text(
                  _rawController.text,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? Colors.grey[300] : Colors.grey[700],
                    height: 1.6,
                  ),
                ),
        ),
      ],
    );
  }

  /// AI整理区域
  Widget _buildRefinedSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 标签"AI整理"
        Text(
          'AI整理',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        // 多行文本框（可编辑）
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2E) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? const Color(0xFF3A3A3C) : Colors.grey[200]!,
            ),
          ),
          child: TextField(
            controller: _refinedController,
            maxLines: 8,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              hintText: 'AI整理后的内容...',
              hintStyle: TextStyle(color: Colors.grey[400]),
            ),
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.grey[200] : Colors.grey[800],
              height: 1.7,
            ),
          ),
        ),
      ],
    );
  }

  /// 标签区域：现有标签（可删除） + "+添加"按钮
  Widget _buildTagsSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '标签',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            // 现有标签（可删除）
            ..._tags.map((tag) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2C2C2E) : Colors.grey[100],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF3A3A3C) : Colors.grey[200]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '#$tag',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? Colors.grey[300] : Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: () => setState(() => _tags.remove(tag)),
                    child: Icon(
                      Icons.close,
                      size: 14,
                      color: isDark ? Colors.grey[500] : Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )),
            // "+添加"按钮
            GestureDetector(
              onTap: _addTag,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.add,
                      size: 14,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '添加',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 分类区域：单选标签（灵感、感悟、待办、读书、随笔）
  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '分类',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _defaultCategories.map((cat) {
            final isSelected = cat == _category;
            final color = _getCategoryColor(cat);
            
            return GestureDetector(
              onTap: () => setState(() => _category = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? color : color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? color : color.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getCategoryIcon(cat),
                      size: 14,
                      color: isSelected ? Colors.white : color,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      cat,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? Colors.white : color,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// 底部按钮：重新整理（左） + 确认保存（右，主色）
  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 重新整理（左）
          Expanded(
            child: OutlinedButton(
              onPressed: _isReRefining ? null : _reRefine,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.grey[700],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
              child: _isReRefining
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.grey[700],
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.refresh, size: 18),
                        SizedBox(width: 6),
                        Text('重新整理'),
                      ],
                    ),
            ),
          ),
          const SizedBox(width: 12),
          // 确认保存（右，主色#6C63FF）
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryColor, AppTheme.primaryLight],
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: AppTheme.primaryShadow,
              ),
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '确认保存',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 获取分类颜色
  Color _getCategoryColor(String category) {
    switch (category) {
      case '灵感':
        return AppTheme.categoryIdea;
      case '感悟':
        return AppTheme.categoryInsight;
      case '待办':
        return AppTheme.categoryTodo;
      case '读书':
        return AppTheme.categoryReading;
      case '随笔':
        return AppTheme.categoryEssay;
      default:
        return AppTheme.primaryColor;
    }
  }

  /// 获取分类图标
  IconData _getCategoryIcon(String category) {
    switch (category) {
      case '灵感':
        return Icons.lightbulb_outline;
      case '感悟':
        return Icons.favorite_border;
      case '待办':
        return Icons.check_circle_outline;
      case '读书':
        return Icons.book_outlined;
      case '随笔':
        return Icons.edit_note;
      default:
        return Icons.label_outline;
    }
  }

  /// 添加标签
  Future<void> _addTag() async {
    final controller = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加标签'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '输入标签名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, controller.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('添加'),
          ),
        ],
      ),
    );
    
    if (result != null && result.isNotEmpty && !_tags.contains(result)) {
      setState(() => _tags.add(result));
    }
  }

  /// 重新整理
  Future<void> _reRefine() async {
    setState(() => _isReRefining = true);
    
    try {
      final aiService = ref.read(aiServiceProvider);
      final result = await aiService.refineContent(_rawController.text);

      if (!mounted) return;

      setState(() {
        _refinedController.text = result.refinedText;
        _tags = result.tags;
        _category = result.category;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('重新整理失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isReRefining = false);
      }
    }
  }

  /// 保存
  Future<void> _save() async {
    final inspiration = Inspiration(
      id: const Uuid().v4(),
      rawText: _rawController.text,
      refinedText: _refinedController.text,
      tags: _tags,
      category: _category,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final db = ref.read(databaseServiceProvider);
    await db.insertInspiration(inspiration);

    // 刷新列表
    ref.invalidate(inspirationsProvider);

    if (!mounted) return;
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存')),
    );
  }
}
