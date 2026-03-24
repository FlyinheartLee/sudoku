#!/usr/bin/env python3
"""
统一调整游戏页面的顶部导航栏布局
"""

import os
import re

# 文件列表
files = [
    '/Users/flyinheart/.openclaw/workspace/sudoku-h5.html',
    '/Users/flyinheart/.openclaw/workspace/BrainGamesAndroid/app/src/main/assets/sudoku.html',
    '/Users/flyinheart/.openclaw/workspace/BrainGamesAndroid/app/src/main/assets/number-maze.html',
    '/Users/flyinheart/.openclaw/workspace/BrainGamesAndroid/app/src/main/assets/skyscraper.html',
    '/Users/flyinheart/.openclaw/workspace/BrainGamesAndroid/app/src/main/assets/game2048.html',
    '/Users/flyinheart/.openclaw/workspace/BrainGamesAndroid/app/src/main/assets/klotski.html',
    '/Users/flyinheart/.openclaw/workspace/BrainGamesAndroid/app/src/main/assets/minesweeper.html',
    '/Users/flyinheart/.openclaw/workspace/BrainGamesAndroid/app/src/main/assets/pipe.html',
    '/Users/flyinheart/.openclaw/workspace/BrainGamesAndroid/app/src/main/assets/memory.html',
    '/Users/flyinheart/.openclaw/workspace/BrainGamesAndroid/app/src/main/assets/sokoban.html',
    '/Users/flyinheart/.openclaw/workspace/BrainGamesAndroid/app/src/main/assets/hashi.html',
]

# 统一的玩法按钮样式
HOW_TO_PLAY_BTN_CSS = '''.how-to-play-btn {
            padding: 5px 10px;
            background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%);
            color: white;
            border: none;
            border-radius: 16px;
            font-size: 0.7rem;
            font-weight: 700;
            cursor: pointer;
            transition: all 0.2s ease;
            box-shadow: 0 3px 10px rgba(245, 158, 11, 0.4);
            white-space: nowrap;
        }

        .how-to-play-btn:active {
            transform: scale(0.95);
        }'''

# header-right CSS
HEADER_RIGHT_CSS = '''.header-right {
            display: flex;
            gap: 8px;
            align-items: center;
        }'''

def fix_file(filepath):
    print(f"处理: {filepath}")
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # 1. 移除 header 中的 padding-right: 60px
    content = re.sub(r'padding-right:\s*60px;\s*\n?', '\n', content)
    content = re.sub(r'padding-right:\s*60px;', '', content)
    
    # 2. 修改 header padding 为 8px 12px
    content = re.sub(r'padding:\s*12px\s+16px;', 'padding: 8px 12px;', content)
    content = re.sub(r'padding:\s*10px\s+16px;', 'padding: 8px 12px;', content)
    content = re.sub(r'padding:\s*8px\s+16px;', 'padding: 8px 12px;', content)
    
    # 3. 添加 header-right CSS（如果不存在）
    if '.header-right' not in content:
        # 在 .header { 后面添加
        content = re.sub(
            r'(\.header\s*\{[^}]+)(\})',
            r'\1\n        ' + HEADER_RIGHT_CSS.replace('\n', '\n        ') + '\n}',
            content,
            count=1
        )
    
    # 4. 统一玩法按钮样式
    # 查找并替换 .how-to-play-btn 样式
    how_to_play_pattern = r'\.how-to-play-btn\s*\{[^}]+\}(?:\s*\.how-to-play-btn:active\s*\{[^}]+\})?'
    if '.how-to-play-btn' in content:
        content = re.sub(how_to_play_pattern, HOW_TO_PLAY_BTN_CSS, content, flags=re.DOTALL)
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✓ 已修改")
    else:
        print(f"  - 无变化")

for filepath in files:
    if os.path.exists(filepath):
        fix_file(filepath)
    else:
        print(f"跳过（不存在）: {filepath}")

print("\n完成!")
