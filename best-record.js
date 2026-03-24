/**
 * BrainGames 最佳记录管理器
 * 支持按游戏类型和难度记录最佳成绩
 */
(function() {
    'use strict';

    const STORAGE_KEY = 'braingames_records_v1';

    // 记录管理器
    const gameRecords = {
        /**
         * 获取所有记录
         */
        getAll() {
            try {
                const data = localStorage.getItem(STORAGE_KEY);
                return data ? JSON.parse(data) : {};
            } catch (e) {
                console.error('[BestRecord] 读取记录失败:', e);
                return {};
            }
        },

        /**
         * 保存所有记录
         */
        saveAll(records) {
            try {
                localStorage.setItem(STORAGE_KEY, JSON.stringify(records));
            } catch (e) {
                console.error('[BestRecord] 保存记录失败:', e);
            }
        },

        /**
         * 获取特定游戏的记录
         * @param {string} gameKey - 游戏标识 (如 'sudoku_easy', '2048')
         */
        getRecord(gameKey) {
            const records = this.getAll();
            return records[gameKey] || null;
        },

        /**
         * 记录成绩
         * @param {string} gameType - 游戏类型 (如 'sudoku', '2048')
         * @param {object} data - 成绩数据
         *   - time: 用时(毫秒)
         *   - steps: 步数(可选)
         *   - difficulty: 难度(可选, 如 'easy', 'medium', 'hard')
         * @returns {object} - 记录结果
         */
        record(gameType, data) {
            const records = this.getAll();
            const difficulty = data.difficulty || 'default';
            const gameKey = data.difficulty ? `${gameType}_${difficulty}` : gameType;

            const now = Date.now();
            const currentRecord = records[gameKey] || {
                gameType,
                difficulty,
                bestTime: null,
                bestSteps: null,
                totalGames: 0,
                createdAt: now
            };

            const result = {
                gameKey,
                timeRecord: { isNewRecord: false, previous: currentRecord.bestTime },
                stepsRecord: { isNewRecord: false, previous: currentRecord.bestSteps }
            };

            // 更新游戏次数
            currentRecord.totalGames = (currentRecord.totalGames || 0) + 1;
            currentRecord.lastPlayed = now;

            // 记录时间 (越小越好)
            if (data.time && data.time > 0) {
                if (!currentRecord.bestTime || data.time < currentRecord.bestTime) {
                    result.timeRecord.isNewRecord = true;
                    result.timeRecord.previous = currentRecord.bestTime;
                    currentRecord.bestTime = data.time;
                }
            }

            // 记录步数 (越小越好, 可选)
            if (data.steps && data.steps > 0) {
                if (!currentRecord.bestSteps || data.steps < currentRecord.bestSteps) {
                    result.stepsRecord.isNewRecord = true;
                    result.stepsRecord.previous = currentRecord.bestSteps;
                    currentRecord.bestSteps = data.steps;
                }
            }

            // 保存记录
            records[gameKey] = currentRecord;
            this.saveAll(records);

            // 显示庆祝提示
            if (result.timeRecord.isNewRecord || result.stepsRecord.isNewRecord) {
                this.showCelebration(result, gameType, difficulty);
            }

            console.log('[BestRecord] 记录已保存:', gameKey, currentRecord);
            return result;
        },

        /**
         * 显示打破纪录的庆祝提示
         */
        showCelebration(result, gameType, difficulty) {
            const messages = [];
            const difficultyNames = {
                'easy': '简单',
                'medium': '中等', 
                'hard': '困难',
                'default': ''
            };
            const diffName = difficultyNames[difficulty] || difficulty;

            if (result.timeRecord.isNewRecord) {
                const prevTime = result.timeRecord.previous;
                const prevStr = prevTime ? this.formatTime(prevTime) : '无';
                messages.push(`🎉 新时间纪录！击败了之前的 ${prevStr}`);
            }

            if (result.stepsRecord.isNewRecord) {
                const prevSteps = result.stepsRecord.previous;
                const prevStr = prevSteps ? `${prevSteps}步` : '无';
                messages.push(`🎉 新步数纪录！击败了之前的 ${prevStr}`);
            }

            if (messages.length > 0 && typeof showToast === 'function') {
                // 使用游戏自带的 toast 显示
                setTimeout(() => {
                    showToast(messages.join('\n'), 'success');
                }, 500);
            }

            // 同时触发一次庆祝动画
            this.celebrationEffect();
        },

        /**
         * 庆祝动画效果
         */
        celebrationEffect() {
            // 创建彩纸效果
            const colors = ['#ff6b6b', '#4ecdc4', '#45b7d1', '#96ceb4', '#feca57', '#ff9ff3'];
            const container = document.createElement('div');
            container.style.cssText = `
                position: fixed;
                top: 0;
                left: 0;
                width: 100%;
                height: 100%;
                pointer-events: none;
                z-index: 9999;
                overflow: hidden;
            `;
            document.body.appendChild(container);

            // 创建彩纸片
            for (let i = 0; i < 50; i++) {
                const confetti = document.createElement('div');
                const color = colors[Math.floor(Math.random() * colors.length)];
                const left = Math.random() * 100;
                const delay = Math.random() * 2;
                const duration = 2 + Math.random() * 2;

                confetti.style.cssText = `
                    position: absolute;
                    width: 10px;
                    height: 10px;
                    background: ${color};
                    left: ${left}%;
                    top: -20px;
                    border-radius: ${Math.random() > 0.5 ? '50%' : '0'};
                    animation: confetti-fall ${duration}s ease-out ${delay}s forwards;
                `;
                container.appendChild(confetti);
            }

            // 添加动画样式
            if (!document.getElementById('confetti-style')) {
                const style = document.createElement('style');
                style.id = 'confetti-style';
                style.textContent = `
                    @keyframes confetti-fall {
                        0% { transform: translateY(0) rotate(0deg); opacity: 1; }
                        100% { transform: translateY(100vh) rotate(720deg); opacity: 0; }
                    }
                `;
                document.head.appendChild(style);
            }

            // 清理
            setTimeout(() => {
                container.remove();
            }, 5000);
        },

        /**
         * 格式化时间显示
         */
        formatTime(ms) {
            const totalSeconds = Math.floor(ms / 1000);
            const mins = Math.floor(totalSeconds / 60);
            const secs = totalSeconds % 60;
            if (mins > 0) {
                return `${mins}分${secs}秒`;
            }
            return `${secs}秒`;
        },

        /**
         * 清除所有记录
         */
        clearAll() {
            localStorage.removeItem(STORAGE_KEY);
            console.log('[BestRecord] 所有记录已清除');
        },

        /**
         * 清除特定游戏的记录
         */
        clear(gameKey) {
            const records = this.getAll();
            delete records[gameKey];
            this.saveAll(records);
            console.log('[BestRecord] 记录已清除:', gameKey);
        }
    };

    // 暴露到全局
    window.gameRecords = gameRecords;

    console.log('[BestRecord] 最佳记录管理器已加载');
})();
