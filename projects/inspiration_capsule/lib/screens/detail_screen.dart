import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:uuid/uuid.dart';
import '../providers/providers.dart';
import '../services/ai_service.dart';
import '../services/database_service.dart';
import '../models/inspiration.dart';

class DetailScreen extends ConsumerStatefulWidget {
  final String inspirationId;

  const DetailScreen({super.key, required this.inspirationId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  final _messageController = TextEditingController();
  bool _isDiscussing = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inspirationAsync = ref.watch(inspirationDetailProvider(widget.inspirationId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('记录详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
      body: inspirationAsync.when(
        data: (inspiration) {
          if (inspiration == null) {
            return const Center(child: Text('记录不存在'));
          }
          return _buildContent(context, inspiration);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('加载失败: $error')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, Inspiration inspiration) {
    return Column(
      children: [
        // 内容区域
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 分类和时间
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(inspiration.category).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getCategoryIcon(inspiration.category),
                            size: 14,
                            color: _getCategoryColor(inspiration.category),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            inspiration.category,
                            style: TextStyle(
                              fontSize: 13,
                              color: _getCategoryColor(inspiration.category),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatDate(inspiration.createdAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
                
                // 标签
                if (inspiration.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: inspiration.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Markdown 内容
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: MarkdownBody(
                    data: inspiration.refinedText,
                    selectable: true,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(
                        fontSize: 16,
                        height: 1.8,
                        color: Colors.black87,
                      ),
                      h1: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      h2: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      h3: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                      code: TextStyle(
                        backgroundColor: Colors.grey[200],
                        fontSize: 14,
                      ),
                      blockquote: TextStyle(
                        color: Colors.grey[700],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                
                // 讨论记录
                if (inspiration.discussions.isNotEmpty) ...[
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 20,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '讨论记录',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${inspiration.discussions.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6C63FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...inspiration.discussions.map((d) => _buildDiscussionItem(d)),
                ],
                
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        
        // 底部讨论输入
        _buildDiscussionInput(context, inspiration),
      ],
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case '灵感':
        return const Color(0xFF6C63FF);
      case '感悟':
        return const Color(0xFFFF6B6B);
      case '待办':
        return const Color(0xFF4ECDC4);
      case '读书':
        return const Color(0xFFFFA07A);
      case '随笔':
        return const Color(0xFF95E1D3);
      default:
        return const Color(0xFF6C63FF);
    }
  }

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

  Widget _buildDiscussionItem(Discussion discussion) {
    final isUser = discussion.role == 'user';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: isUser ? Colors.grey[200] : const Color(0xFF6C63FF),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isUser ? Colors.grey : const Color(0xFF6C63FF)).withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              isUser ? Icons.person : Icons.smart_toy,
              size: 18,
              color: isUser ? Colors.grey[700] : Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isUser ? Colors.grey[100] : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 16 : 4),
                  topRight: Radius.circular(isUser ? 4 : 16),
                  bottomLeft: const Radius.circular(16),
                  bottomRight: const Radius.circular(16),
                ),
                border: isUser
                    ? null
                    : Border.all(color: const Color(0xFF6C63FF).withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    discussion.content,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.6,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _formatTime(discussion.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiscussionInput(BuildContext context, Inspiration inspiration) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: InputDecoration(
                    hintText: '和 AI 讨论这个想法...',
                    hintStyle: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
            ),
            const SizedBox(width: 12),
            _isDiscussing
                ? Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(12),
                    child: const CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C63FF)),
                    ),
                  )
                : Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: Color(0xFF6C63FF),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => _sendMessage(inspiration),
                      icon: const Icon(Icons.send),
                      color: Colors.white,
                      iconSize: 22,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendMessage(Inspiration inspiration) async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;

    setState(() => _isDiscussing = true);
    _messageController.clear();

    try {
      // 构建对话历史
      final history = inspiration.discussions.map<Map<String, String>>((d) => {
        'role': d.role,
        'content': d.content,
      }).toList();

      // 添加当前上下文
      history.insert(0, {
        'role': 'system',
        'content': '这是关于以下想法的讨论：\n${inspiration.refinedText}',
      });

      final aiService = ref.read(aiServiceProvider);
      final response = await aiService.continueDiscussion(history, message);

      // 保存用户消息
      final userDiscussion = Discussion(
        id: const Uuid().v4(),
        role: 'user',
        content: message,
        timestamp: DateTime.now(),
      );

      // 保存 AI 回复
      final aiDiscussion = Discussion(
        id: const Uuid().v4(),
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      );

      final db = ref.read(databaseServiceProvider);
      await db.insertDiscussion(inspiration.id, userDiscussion);
      await db.insertDiscussion(inspiration.id, aiDiscussion);

      // 刷新
      ref.invalidate(inspirationDetailProvider(widget.inspirationId));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('讨论失败: $e')),
      );
    } finally {
      setState(() => _isDiscussing = false);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('删除记录'),
        content: const Text('确定要删除这条记录吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = ref.read(databaseServiceProvider);
              await db.deleteInspiration(widget.inspirationId);
              ref.invalidate(inspirationsProvider);
              
              if (!mounted) return;
              Navigator.pop(context); // 关闭对话框
              Navigator.pop(context); // 返回列表
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} '
        '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
