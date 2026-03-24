#!/usr/bin/env python3
"""
确保玩法按钮在正确的位置
"""

import os
import re

# 需要确保有玩法按钮的文件（这些文件已有玩法按钮，需要确保位置正确）
files_with_btn = [
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

def ensure_header_right(filepath):
    print(f"处理: {os.path.basename(filepath)}")
    
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    original = content
    
    # 检查是否已有 header-right
    if 'class="header-right"' not in content:
        # 查找 header 中的右侧 div
        # 替换 <div style="display: flex; gap: 8px; align-items: center;"> 为 <div class="header-right">
        content = re.sub(
            r'(<div class="header">.*?<div class="logo">.*?</div>.*?)<div style="display:\s*flex;\s*gap:\s*8px;\s*align-items:\s*center;">',
            r'\1<div class="header-right">',
            content,
            flags=re.DOTALL
        )
        # 也匹配其他可能的内联样式
        content = re.sub(
            r'(<div class="header">.*?<div class="logo">.*?</div>.*?)<div style="[^"]*gap:\s*8px[^"]*">',
            r'\1<div class="header-right">',
            content,
            flags=re.DOTALL
        )
    
    if content != original:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"  ✓ 已修改")
    else:
        print(f"  - 无需修改")

for filepath in files_with_btn:
    if os.path.exists(filepath):
        ensure_header_right(filepath)

print("\n完成!")
