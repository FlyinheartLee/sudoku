# 图标资源说明

此目录需要放置以下图标文件：

## 必需文件

1. **startIcon.png** - 启动页图标 (256x256)
2. **layered_image.json** - 应用图标配置
3. **ic_back.svg** - 返回按钮图标 (24x24)
4. **ic_home.svg** - 首页图标 (24x24)
5. **ic_home_filled.svg** - 首页选中图标 (24x24)
6. **ic_info.svg** - 关于图标 (24x24)
7. **ic_info_filled.svg** - 关于选中图标 (24x24)

## 图标规范

- **格式**: PNG 或 SVG
- **颜色**: 单色图标建议使用 #333333
- **尺寸**: 
  - 启动图标: 256x256px
  - 导航图标: 24x24px

## 临时解决方案

在开发阶段，可以使用 DevEco Studio 自动生成默认图标：

1. 右键 entry 模块 → New → Image Asset
2. 选择图标类型和源文件
3. 自动生成各种尺寸

或使用 HarmonyOS 提供的系统默认图标。
