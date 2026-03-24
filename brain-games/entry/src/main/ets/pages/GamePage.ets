import { GameInfo } from '../model/GameModel';
import { router } from '@kit.ArkUI';
import { promptAction } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';

@Entry
@Component
struct GamePage {
  @State game: GameInfo | null = null;
  @State isLoading: boolean = true;
  @State loadProgress: number = 0;
  @State isDarkMode: boolean = false;
  @State showExitConfirm: boolean = false;
  private controller: webview.WebviewController = new webview.WebviewController();

  aboutToAppear() {
    // 获取深色模式设置
    const darkMode = AppStorage.get<boolean>('isDarkMode');
    if (darkMode !== undefined) {
      this.isDarkMode = darkMode;
    }

    // 获取传递的游戏参数
    const params = router.getParams() as Record<string, string>;
    if (params && params['game']) {
      try {
        this.game = JSON.parse(params['game']) as GameInfo;
      } catch (e) {
        console.error('[GamePage] Failed to parse game data');
      }
    }

    // 监听返回事件
    this.setupBackHandler();
  }

  setupBackHandler() {
    // 设置页面返回拦截
  }

  onBackPress(): boolean {
    this.showExitConfirm = true;
    return true;
  }

  handleBack() {
    if (this.controller.accessBackward()) {
      this.controller.backward();
    } else {
      this.showExitConfirm = true;
    }
  }

  confirmExit() {
    router.back();
  }

  build() {
    Stack() {
      Column() {
        // 顶部导航栏 - 增加高度防止误触
        Row() {
          // 返回按钮区域 - 增大点击区域
          Row() {
            Image($r('app.media.ic_back'))
              .width(24)
              .height(24)
              .fillColor('#FFFFFF')
          }
          .width(48)
          .height(48)
          .justifyContent(FlexAlign.Center)
          .onClick(() => {
            this.handleBack();
          })

          // 游戏名称
          Text(this.game?.name ?? '游戏')
            .fontSize(18)
            .fontWeight(FontWeight.Bold)
            .fontColor('#FFFFFF')
            .layoutWeight(1)
            .textAlign(TextAlign.Center)
            .maxLines(1)
            .textOverflow({ overflow: TextOverflow.Ellipsis })

          // 右侧占位保持居中
          Blank()
            .width(48)
        }
        .width('100%')
        .height(64)
        .padding({ left: 8, right: 8 })
        .backgroundColor(this.game?.themeColor ?? '#FF6B6B')

        // 进度条
        if (this.isLoading) {
          Progress({ value: this.loadProgress, total: 100, type: ProgressType.Linear })
            .width('100%')
            .height(3)
            .color(this.game?.themeColor ?? '#FF6B6B')
            .backgroundColor('#E0E0E0')
        }

        // WebView 游戏区域
        Web({
          src: this.game?.url ?? '',
          controller: this.controller
        })
          .width('100%')
          .layoutWeight(1)
          .darkMode(this.isDarkMode ? WebDarkMode.On : WebDarkMode.Off)
          .javaScriptAccess(true)
          .domStorageAccess(true)
          .mixedMode(MixedMode.All)
          .zoomAccess(true)
          .cacheMode(CacheMode.Default)
          .onProgressChange((event) => {
            if (event) {
              this.loadProgress = event.newProgress;
              if (event.newProgress >= 100) {
                this.isLoading = false;
              }
            }
          })
          .onErrorReceive((event) => {
            console.error('[GamePage] WebView error:', event?.error.getErrorInfo());
            this.isLoading = false;
          })
          .onPageBegin(() => {
            this.isLoading = true;
            this.loadProgress = 0;
          })
          .onPageEnd(() => {
            this.isLoading = false;
            this.loadProgress = 100;
          })

        // 底部安全区域提示
        Row() {
          Text('从底部向上滑动返回桌面')
            .fontSize(11)
            .fontColor(this.isDarkMode ? '#666666' : '#999999')
        }
        .width('100%')
        .height(24)
        .justifyContent(FlexAlign.Center)
        .backgroundColor(this.isDarkMode ? '#1A1A1A' : '#F5F5F5')
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.isDarkMode ? '#121212' : '#FFFFFF')

      // 退出确认对话框
      if (this.showExitConfirm) {
        Column() {
          Column() {
            Text('确认退出？')
              .fontSize(18)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDarkMode ? '#FFFFFF' : '#1A1A1A')
              .margin({ bottom: 8 })

            Text('游戏进度可能不会被保存')
              .fontSize(14)
              .fontColor(this.isDarkMode ? '#888888' : '#666666')
              .margin({ bottom: 24 })

            Row() {
              Button('继续游戏')
                .fontSize(14)
                .fontColor('#666666')
                .backgroundColor(this.isDarkMode ? '#3A3A3A' : '#F0F0F0')
                .width(120)
                .height(40)
                .onClick(() => {
                  this.showExitConfirm = false;
                })

              Button('退出')
                .fontSize(14)
                .fontColor('#FFFFFF')
                .backgroundColor(this.game?.themeColor ?? '#FF6B6B')
                .width(120)
                .height(40)
                .margin({ left: 12 })
                .onClick(() => {
                  this.confirmExit();
                })
            }
          }
          .width('85%')
          .padding(24)
          .backgroundColor(this.isDarkMode ? '#2A2A2A' : '#FFFFFF')
          .borderRadius(16)
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000060')
        .justifyContent(FlexAlign.Center)
      }

      // 加载动画
      if (this.isLoading && this.loadProgress < 100) {
        Column() {
          Stack() {
            // 背景圆环
            Circle()
              .width(80)
              .height(80)
              .fill(this.isDarkMode ? '#2A2A2A' : '#FFFFFF')
              .shadow({
                radius: 16,
                color: '#00000020',
                offsetX: 0,
                offsetY: 8
              })

            // 进度圆环
            Progress({ value: this.loadProgress, total: 100, type: ProgressType.Ring })
              .width(70)
              .height(70)
              .color(this.game?.themeColor ?? '#FF6B6B')
              .backgroundColor('#E8E8E8')

            // 百分比
            Text(`${this.loadProgress}%`)
              .fontSize(14)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDarkMode ? '#FFFFFF' : '#1A1A1A')
          }

          Text('正在加载游戏...')
            .fontSize(14)
            .fontColor(this.isDarkMode ? '#AAAAAA' : '#666666')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor(this.isDarkMode ? '#121212F0' : '#FFFFFFF0')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
