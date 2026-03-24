#!/usr/bin/env python3
"""Browser-use 演示脚本"""
import asyncio
import os
import sys

# 添加到路径
sys.path.insert(0, os.path.expanduser('~/.browser-use/.venv/lib/python3.14/site-packages'))

from browser_use import Agent, Browser
from browser_use.llm import ChatOpenAI

async def demo():
    """演示：获取 GitHub 项目 stars 数量"""
    print("🌐 启动浏览器自动化演示...")
    print("=" * 50)
    
    # 启动浏览器
    browser = Browser()
    print("✅ 浏览器已启动")
    
    # 创建 Agent
    agent = Agent(
        task="访问 https://github.com/obra/superpowers，告诉我这个仓库有多少 stars",
        llm=ChatOpenAI(model="gpt-4o-mini"),  # 需要 API key
        browser=browser,
    )
    
    print("🤖 Agent 任务已创建")
    print("📋 任务: 查看 superpowers 项目的 stars 数量")
    print()
    
    # 运行任务
    try:
        result = await agent.run()
        print("✅ 任务完成!")
        print(f"结果: {result}")
    except Exception as e:
        print(f"❌ 错误: {e}")
    finally:
        await browser.close()
        print("🔒 浏览器已关闭")

if __name__ == "__main__":
    # 检查 API key
    if not os.getenv("OPENAI_API_KEY"):
        print("⚠️  需要设置 OPENAI_API_KEY 环境变量")
        print("   export OPENAI_API_KEY=your-key")
        sys.exit(1)
    
    asyncio.run(demo())
