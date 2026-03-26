import 'package:uuid/uuid.dart';

/// 灵感记录数据模型
class Inspiration {
  final String id;
  final String rawText;
  final String refinedText;
  final List<String> tags;
  final String category;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Discussion> discussions;

  Inspiration({
    required this.id,
    required this.rawText,
    required this.refinedText,
    this.tags = const [],
    this.category = '未分类',
    required this.createdAt,
    required this.updatedAt,
    this.discussions = const [],
  });

  /// 创建新的灵感记录
  factory Inspiration.create({
    required String rawText,
    required String refinedText,
    List<String> tags = const [],
    String category = '未分类',
  }) {
    final now = DateTime.now();
    return Inspiration(
      id: const Uuid().v4(),
      rawText: rawText,
      refinedText: refinedText,
      tags: tags,
      category: category,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rawText': rawText,
      'refinedText': refinedText,
      'tags': tags.join(','),
      'category': category,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// 从数据库 Map 创建对象
  factory Inspiration.fromMap(Map<String, dynamic> map) {
    return Inspiration(
      id: map['id'] as String,
      rawText: map['rawText'] as String,
      refinedText: map['refinedText'] as String,
      tags: (map['tags'] as String? ?? '').split(',').where((t) => t.isNotEmpty).toList(),
      category: map['category'] as String? ?? '未分类',
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  /// 复制并修改部分字段
  Inspiration copyWith({
    String? id,
    String? rawText,
    String? refinedText,
    List<String>? tags,
    String? category,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<Discussion>? discussions,
  }) {
    return Inspiration(
      id: id ?? this.id,
      rawText: rawText ?? this.rawText,
      refinedText: refinedText ?? this.refinedText,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      discussions: discussions ?? this.discussions,
    );
  }

  @override
  String toString() {
    return 'Inspiration(id: $id, rawText: ${rawText.substring(0, rawText.length > 20 ? 20 : rawText.length)}..., category: $category)';
  }
}

/// 讨论记录数据模型
class Discussion {
  final String id;
  final String role; // 'user' or 'assistant'
  final String content;
  final DateTime timestamp;

  Discussion({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
  });

  /// 创建新的讨论记录
  factory Discussion.create({
    required String role,
    required String content,
  }) {
    return Discussion(
      id: const Uuid().v4(),
      role: role,
      content: content,
      timestamp: DateTime.now(),
    );
  }

  /// 转换为数据库 Map
  Map<String, dynamic> toMap(String inspirationId) {
    return {
      'id': id,
      'inspirationId': inspirationId,
      'role': role,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// 从数据库 Map 创建对象
  factory Discussion.fromMap(Map<String, dynamic> map) {
    return Discussion(
      id: map['id'] as String,
      role: map['role'] as String,
      content: map['content'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
    );
  }

  @override
  String toString() {
    return 'Discussion(role: $role, content: ${content.substring(0, content.length > 20 ? 20 : content.length)}...)';
  }
}
