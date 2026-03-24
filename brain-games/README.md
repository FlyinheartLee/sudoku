# 脑力训练 - HarmonyOS 益智游戏合集

一款集成了10款经典H5益智游戏的鸿蒙原生应用。

## 📱 应用信息

- **应用名称**: 脑力训练 (Brain Games)
- **目标系统**: HarmonyOS 4.2+
- **API版本**: API 11+
- **开发语言**: ArkTS
- **目标设备**: 手机

## 🎮 游戏列表

| 序号 | 游戏名称 | 类型 | 描述 |
|------|----------|------|------|
| 1 | 数独 | 逻辑 | 经典数字逻辑游戏，锻炼大脑推理能力 |
| 2 | 数字迷宫 | 迷宫 | 数字解谜迷宫，寻找正确路径 |
| 3 | 摩天楼 | 逻辑 | 摩天大楼数独变种，观察视野推理 |
| 4 | 2048 | 数字 | 滑动数字方块，合成2048 |
| 5 | 华容道 | 传统 | 中国传统益智游戏，移动方块解围 |
| 6 | 扫雷 | 经典 | 经典扫雷游戏，数字推理排除地雷 |
| 7 | 接水管 | 拼图 | 旋转管道，连接完整通路 |
| 8 | 记忆翻牌 | 记忆 | 考验记忆力的配对游戏 |
| 9 | 推箱子 | 经典 | 经典推箱子游戏，规划最优路线 |
| 10 | 数桥 | 逻辑 | 连接岛屿，搭建桥梁的数字谜题 |

## 📁 项目结构

```
brain-games/
├── entry/src/main/ets/
│   ├── entryability/
│   │   └── EntryAbility.ets    # 应用入口
│   ├── pages/
│   │   ├── Index.ets           # 游戏选择主页
│   │   └── GamePage.ets        # 游戏页面
│   ├── components/
│   │   └── GameWebView.ets     # WebView组件(已整合到GamePage)
│   └── model/
│       └── GameModel.ets       # 游戏数据模型
├── entry/src/main/resources/
│   ├── base/element/           # 字符串、颜色、数值资源
│   ├── base/media/             # 图标资源
│   └── rawfile/                # 本地文件
├── entry/src/main/module.json5 # 模块配置
└── build-profile.json5         # 构建配置
```

## 🛠️ 开发环境要求

- **DevEco Studio**: 4.1 Release 或更高版本
- **HarmonyOS SDK**: API 11 (5.0.0) 或更高
- **Node.js**: 16.x 或更高
- **Git**: 用于版本控制

## 🔧 构建与运行

### 1. 导入项目

1. 打开 DevEco Studio
2. 选择 `File` → `Open` → 选择 `brain-games` 文件夹
3. 等待 Gradle 同步完成

### 2. 配置签名

**调试模式:**
- 自动签名：DevEco Studio 会自动生成调试签名

**发布模式:**
1. 在华为开发者联盟创建应用
2. 生成发布证书和私钥
3. 在 `build-profile.json5` 中配置签名

### 3. 运行应用

**模拟器运行:**
1. 打开 Device Manager
2. 创建或启动 HarmonyOS 模拟器 (API 11+)
3. 点击运行按钮 (▶️)

**真机运行:**
1. 连接 HarmonyOS 4.2+ 设备
2. 开启开发者模式
3. 允许 USB 调试
4. 点击运行按钮

### 4. 构建 HAP 包

```bash
# 调试包
./gradlew assembleDebug

# 发布包
./gradlew assembleRelease
```

构建产物路径: `entry/build/default/outputs/default/`

## 📦 安装应用

### 方式一：通过 DevEco Studio
直接点击运行按钮安装到连接的设备

### 方式二：通过 hdc 命令行

```bash
# 安装 HAP 包
hdc install entry-debug-rich-signed.hap

# 卸载应用
hdc uninstall com.braingames.entry
```

### 方式三：通过 AppGallery Connect
1. 上传 HAP 包到华为应用市场
2. 完成审核后用户可下载安装

## ✨ 功能特性

- ✅ **网格布局** - 2列网格展示10款游戏卡片
- ✅ **深色模式** - 支持系统深色/浅色模式切换
- ✅ **加载动画** - 游戏加载进度显示
- ✅ **防误触设计** - 
  - 顶部导航栏高度增加
  - 返回时弹出确认对话框
  - WebView全屏沉浸式体验
- ✅ **游戏分类** - 按类型标记游戏（逻辑/经典/数字等）
- ✅ **主题色彩** - 每款游戏独特主题色
- ✅ **响应式设计** - 适配各种手机屏幕尺寸

## 🌐 游戏源

所有游戏均托管在 GitHub Pages：
```
https://flyinheartlee.github.io/sudoku/
```

**注意**: 游戏需要网络连接才能正常加载。

## 📝 权限说明

| 权限 | 用途 |
|------|------|
| `ohos.permission.INTERNET` | 访问网络加载H5游戏内容 |

## 🔒 隐私说明

- 本应用不收集任何用户数据
- 游戏数据存储在网页端
- 无需登录即可使用

## 🐛 常见问题

**Q: 游戏加载慢怎么办？**
A: 检查网络连接，或稍后重试。游戏资源托管在海外服务器，国内访问可能需要等待。

**Q: 如何返回游戏列表？**
A: 点击顶部导航栏的返回按钮，或在游戏页面从左侧边缘右滑。

**Q: 支持平板设备吗？**
A: 当前版本主要针对手机优化，平板设备可以运行但布局可能不是最佳。

## 📄 开源协议

MIT License

## 👨‍💻 开发者

Brain Games Team

---

**享受游戏的乐趣，锻炼你的大脑！** 🧠🎮
