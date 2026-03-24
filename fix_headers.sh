#!/bin/bash
# 统一修改游戏页面的顶部导航栏布局

cd /Users/flyinheart/.openclaw/workspace/BrainGamesAndroid/app/src/main/assets

# 统一的玩法按钮样式
HOW_TO_PLAY_BTN='.how-to-play-btn {
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
        }'

echo "修改文件..."

# 1. sudoku.html - 移除 padding-right: 60px，统一玩法按钮样式
sed -i '' 's/padding-right: 60px;//g' sudoku.html
sed -i '' 's/padding-right: 60px; //g' sudoku.html

# 2. number-maze.html - 同上
sed -i '' 's/padding-right: 60px;//g' number-maze.html

# 3. skyscraper.html - 同上  
sed -i '' 's/padding-right: 60px;//g' skyscraper.html

# 4. game2048.html - 同上
sed -i '' 's/padding-right: 60px;//g' game2048.html

# 5. klotski.html - 同上
sed -i '' 's/padding-right: 60px;//g' klotski.html

# 6. minesweeper.html - 同上
sed -i '' 's/padding-right: 60px;//g' minesweeper.html

# 7. pipe.html - 同上
sed -i '' 's/padding-right: 60px;//g' pipe.html

# 8. memory.html - 同上
sed -i '' 's/padding-right: 60px;//g' memory.html

# 9. sokoban.html - 同上
sed -i '' 's/padding-right: 60px;//g' sokoban.html

# 10. hashi.html - 同上
sed -i '' 's/padding-right: 60px;//g' hashi.html

echo "完成！"
