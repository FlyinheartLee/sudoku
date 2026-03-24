interface GameInfo {
  id: string;
  name: string;
  icon: string;
  description: string;
  url: string;
  themeColor: string;
  category: string;
}

export const GameList: GameInfo[] = [
  {
    id: 'sudoku',
    name: '数独',
    icon: '🎯',
    description: '经典数字逻辑游戏，锻炼大脑推理能力',
    url: 'https://flyinheartlee.github.io/sudoku/sudoku-h5.html',
    themeColor: '#FF6B6B',
    category: '逻辑'
  },
  {
    id: 'number-maze',
    name: '数字迷宫',
    icon: '🧩',
    description: '数字解谜迷宫，寻找正确路径',
    url: 'https://flyinheartlee.github.io/sudoku/number-maze.html',
    themeColor: '#4ECDC4',
    category: '迷宫'
  },
  {
    id: 'skyscraper',
    name: '摩天楼',
    icon: '🏢',
    description: '摩天大楼数独变种，观察视野推理',
    url: 'https://flyinheartlee.github.io/sudoku/skyscraper.html',
    themeColor: '#45B7D1',
    category: '逻辑'
  },
  {
    id: 'game2048',
    name: '2048',
    icon: '🔢',
    description: '滑动数字方块，合成2048',
    url: 'https://flyinheartlee.github.io/sudoku/game2048.html',
    themeColor: '#96CEB4',
    category: '数字'
  },
  {
    id: 'klotski',
    name: '华容道',
    icon: '🀄',
    description: '中国传统益智游戏，移动方块解围',
    url: 'https://flyinheartlee.github.io/sudoku/klotski.html',
    themeColor: '#FFEAA7',
    category: '传统'
  },
  {
    id: 'minesweeper',
    name: '扫雷',
    icon: '💣',
    description: '经典扫雷游戏，数字推理排除地雷',
    url: 'https://flyinheartlee.github.io/sudoku/minesweeper.html',
    themeColor: '#DDA0DD',
    category: '经典'
  },
  {
    id: 'pipe',
    name: '接水管',
    icon: '🔧',
    description: '旋转管道，连接完整通路',
    url: 'https://flyinheartlee.github.io/sudoku/pipe.html',
    themeColor: '#74B9FF',
    category: '拼图'
  },
  {
    id: 'memory',
    name: '记忆翻牌',
    icon: '🃏',
    description: '考验记忆力的配对游戏',
    url: 'https://flyinheartlee.github.io/sudoku/memory.html',
    themeColor: '#A29BFE',
    category: '记忆'
  },
  {
    id: 'sokoban',
    name: '推箱子',
    icon: '📦',
    description: '经典推箱子游戏，规划最优路线',
    url: 'https://flyinheartlee.github.io/sudoku/sokoban.html',
    themeColor: '#FD79A8',
    category: '经典'
  },
  {
    id: 'hashi',
    name: '数桥',
    icon: '🌉',
    description: '连接岛屿，搭建桥梁的数字谜题',
    url: 'https://flyinheartlee.github.io/sudoku/hashi.html',
    themeColor: '#FDCB6E',
    category: '逻辑'
  }
];

export type { GameInfo };
