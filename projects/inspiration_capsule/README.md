# 灵感胶囊 (Inspiration Capsule)

一个 AI 驱动的语音笔记应用，支持语音/文字输入，自动整理归类，并支持与 AI 讨论想法。

## 功能特点

- 🎤 **语音输入** - 长按录音，支持科大讯飞语音识别
- ✏️ **文字输入** - 支持手动输入文本
- 🤖 **AI 整理** - 自动将碎片内容整理成结构化 Markdown
- 🏷️ **智能分类** - AI 自动建议分类和标签
- 💬 **AI 讨论** - 与 AI 深入讨论想法，记录讨论过程
- 💾 **本地存储** - 纯本地存储，保护隐私
- 📱 **跨平台** - Flutter 开发，支持 Android/iOS

## 技术栈

- **框架**: Flutter 3.x
- **状态管理**: flutter_riverpod
- **本地存储**: sqflite
- **语音识别**: 科大讯飞 (需要原生集成)
- **AI 处理**: 支持 OpenAI 兼容 API (腾讯混元、Kimi 等)
- **网络**: dio

## 项目结构

```
lib/
├── main.dart                    # 应用入口
├── models/
│   └── inspiration.dart         # 数据模型
├── providers/
│   └── app_providers.dart       # Riverpod Providers
├── screens/
│   ├── home_screen.dart         # 主界面
│   ├── input_screen.dart        # 输入界面
│   ├── refinement_screen.dart   # AI 整理确认界面
│   ├── detail_screen.dart       # 详情/讨论界面
│   └── settings_screen.dart     # 设置界面
└── services/
    ├── database_service.dart    # SQLite 数据库
    └── ai_service.dart          # AI API 服务
```

## 安装运行

### 1. 安装 Flutter

确保已安装 Flutter 3.x 版本：
```bash
flutter doctor
```

### 2. 安装依赖

```bash
cd inspiration_capsule
flutter pub get
```

### 3. 配置 AI API

在设置页面配置你的 API Key，支持：
- 腾讯混元
- Kimi (Moonshot)
- 其他 OpenAI 兼容 API

### 4. 配置科大讯飞

需要在 Android/iOS 原生代码中集成科大讯飞 SDK。

### 5. 运行

```bash
# Android
flutter run

# 或构建 APK
flutter build apk --release
```

## API 配置说明

### 腾讯混元

- Base URL: `https://api.lkeap.cloud.tencent.com/v1`
- Model: `hunyuan-lite` 或其他
- 需要申请 API Key

### Kimi

- Base URL: `https://api.moonshot.cn/v1`
- Model: `moonshot-v1-8k` 等
- 需要申请 API Key

## 后续开发计划

### Phase 2
- [ ] 科大讯飞 SDK 原生集成
- [ ] 思维导图生成
- [ ] Markdown 导出
- [ ] 搜索功能

### Phase 3
- [ ] 多笔记联动洞察
- [ ] 云端同步（可选）
- [ ] iOS 版本发布

## 许可证

MIT
