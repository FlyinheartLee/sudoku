# TOOLS.md - Local Notes

Skills define _how_ tools work. This file is for _your_ specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:

- Camera names and locations
- SSH hosts and aliases
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras

- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH

- home-server → 192.168.1.100, user: admin

### TTS

- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

---

## Browser Automation

### browser-use
- **安装位置**: `~/.browser-use/`
- **Python**: 3.14.3 (uv 虚拟环境)
- **使用方法**: `browser-use <command>`
- **注意**: Python 3.14 有 Pydantic 兼容性警告，但不影响基本功能

常用命令：
```bash
browser-use open <url>          # 打开网页
browser-use state               # 获取页面元素
browser-use click <index>       # 点击元素
browser-use screenshot          # 截图
```

---

Add whatever helps you do your job. This is your cheat sheet.
