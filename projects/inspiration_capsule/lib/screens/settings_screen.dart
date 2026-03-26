import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

/// 设置页面
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // 控制器
  final TextEditingController _apiUrlController = TextEditingController();
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();
  
  // 状态
  bool _isTesting = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // 初始化默认值
    _apiUrlController.text = 'https://api.lkeap.cloud.tencent.com/v1';
    _modelController.text = 'hunyuan-lite';
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '设置',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 16),
          children: [
            // 分组1：AI配置
            _buildSectionTitle('AI配置'),
            _buildAICard(isDark),
            
            const SizedBox(height: 24),
            
            // 分组2：语音识别
            _buildSectionTitle('语音识别'),
            _buildVoiceSettingsTile(isDark),
            
            const SizedBox(height: 24),
            
            // 分组3：数据管理
            _buildSectionTitle('数据管理'),
            _buildDataManagementTiles(isDark),
            
            const SizedBox(height: 24),
            
            // 分组4：关于
            _buildSectionTitle('关于'),
            _buildAboutTiles(isDark),
          ],
        ),
      ),
    );
  }

  /// 分组标题
  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  /// AI配置卡片
  Widget _buildAICard(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // API地址输入框
            _buildTextField(
              label: 'API地址',
              hint: 'https://api.lkeap.cloud.tencent.com/v1',
              controller: _apiUrlController,
              icon: Icons.link,
            ),
            
            const SizedBox(height: 16),
            
            // API Key输入框
            _buildTextField(
              label: 'API Key',
              hint: '输入你的API Key',
              controller: _apiKeyController,
              icon: Icons.key,
              obscureText: true,
            ),
            
            const SizedBox(height: 16),
            
            // 模型输入框
            _buildTextField(
              label: '模型',
              hint: 'hunyuan-lite',
              controller: _modelController,
              icon: Icons.model_training,
            ),
            
            const SizedBox(height: 24),
            
            // 按钮行
            Row(
              children: [
                // 测试连接按钮
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isTesting ? null : _testConnection,
                    icon: _isTesting
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                            ),
                          )
                        : const Icon(Icons.wifi_tethering, size: 18),
                    label: Text(_isTesting ? '测试中...' : '测试连接'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                      side: BorderSide(color: AppTheme.primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 保存配置按钮
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isSaving ? null : _saveConfig,
                    icon: _isSaving
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Icon(Icons.save, size: 18),
                    label: Text(_isSaving ? '保存中...' : '保存配置'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 文本输入框
  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(fontSize: 15),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 14,
            ),
            prefixIcon: Icon(icon, size: 20, color: Colors.grey[500]),
            filled: true,
            fillColor: const Color(0xFFF8F9FA),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }

  /// 语音识别设置项
  Widget _buildVoiceSettingsTile(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: _buildListTile(
        icon: Icons.mic,
        iconColor: AppTheme.primaryColor,
        title: '科大讯飞语音',
        subtitle: '点击配置',
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {
          // TODO: 导航到语音识别配置页面
          _showSnackBar('语音识别配置功能开发中...');
        },
      ),
    );
  }

  /// 数据管理设置项
  Widget _buildDataManagementTiles(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 导出数据
          _buildListTile(
            icon: Icons.download,
            iconColor: AppTheme.primaryColor,
            title: '导出数据',
            subtitle: '导出为Markdown',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              // TODO: 导出数据功能
              _showSnackBar('数据导出功能开发中...');
            },
          ),
          
          // 分割线
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: Colors.grey[200],
          ),
          
          // 清除所有数据（红色）
          _buildListTile(
            icon: Icons.delete_outline,
            iconColor: Colors.red,
            title: '清除所有数据',
            titleColor: Colors.red,
            subtitle: '此操作不可撤销',
            onTap: _showClearDataDialog,
          ),
        ],
      ),
    );
  }

  /// 关于设置项
  Widget _buildAboutTiles(bool isDark) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // 版本
          _buildListTile(
            icon: Icons.info_outline,
            iconColor: Colors.grey[600]!,
            title: '版本',
            trailing: Text(
              '1.0.0',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[600],
              ),
            ),
            onTap: null,
          ),
          
          // 分割线
          Divider(
            height: 1,
            indent: 56,
            endIndent: 16,
            color: Colors.grey[200],
          ),
          
          // 使用说明
          _buildListTile(
            icon: Icons.book_outlined,
            iconColor: AppTheme.primaryColor,
            title: '使用说明',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: _showUsageInstructions,
          ),
        ],
      ),
    );
  }

  /// 通用列表项
  Widget _buildListTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, size: 22, color: iconColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: titleColor ?? Colors.black87,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  /// 显示清除数据确认对话框
  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 8),
            Text('确认清除数据'),
          ],
        ),
        content: const Text(
          '此操作将删除所有灵感记录，且无法撤销。\n\n确定要继续吗？',
          style: TextStyle(fontSize: 15, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '取消',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _clearAllData();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );
  }

  /// 显示使用说明对话框
  void _showUsageInstructions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(Icons.book, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('使用说明'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildInstructionItem('1. 记录灵感', '点击首页的语音按钮或文字输入按钮，快速记录你的灵感。'),
              const SizedBox(height: 12),
              _buildInstructionItem('2. AI 润色', '录入的内容会自动通过 AI 进行润色和结构化。'),
              const SizedBox(height: 12),
              _buildInstructionItem('3. 分类管理', '可以为每个灵感添加分类标签，方便后续查找。'),
              const SizedBox(height: 12),
              _buildInstructionItem('4. 搜索回顾', '支持全文搜索，随时回顾过往的灵感记录。'),
              const SizedBox(height: 12),
              _buildInstructionItem('5. 导出分享', '可以将灵感导出为 Markdown 格式，方便分享和整理。'),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('知道了'),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// 测试连接
  Future<void> _testConnection() async {
    setState(() => _isTesting = true);
    
    // 模拟测试
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() => _isTesting = false);
    
    if (mounted) {
      _showSnackBar('连接成功！');
    }
  }

  /// 保存配置
  Future<void> _saveConfig() async {
    setState(() => _isSaving = true);
    
    // 模拟保存
    await Future.delayed(const Duration(milliseconds: 800));
    
    setState(() => _isSaving = false);
    
    if (mounted) {
      _showSnackBar('配置已保存');
    }
  }

  /// 清除所有数据
  Future<void> _clearAllData() async {
    // 模拟清除
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (mounted) {
      _showSnackBar('所有数据已清除');
    }
  }

  /// 显示 SnackBar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
