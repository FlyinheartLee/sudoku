import { GameInfo, GameList } from '../model/GameModel';
import { router } from '@kit.ArkUI';

@Entry
@Component
struct Index {
  @State currentTab: number = 0;
  @StorageLink('isDarkMode') isDarkMode: boolean = false;
  @State isLoading: boolean = true;

  aboutToAppear() {
    // 模拟加载
    setTimeout(() => {
      this.isLoading = false;
    }, 800);
  }

  // 游戏卡片构建器
  @Builder
  GameCard(game: GameInfo) {
    Column() {
      // 图标区域
      Stack() {
        // 背景圆
        Circle()
          .width(70)
          .height(70)
          .fill(game.themeColor + '20')

        // 游戏图标
        Text(game.icon)
          .fontSize(36)
          .textAlign(TextAlign.Center)
      }
      .width(80)
      .height(80)
      .margin({ bottom: 12 })

      // 游戏名称
      Text(game.name)
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.isDarkMode ? '#FFFFFF' : '#1A1A1A')
        .margin({ bottom: 6 })

      // 游戏简介
      Text(game.description)
        .fontSize(12)
        .fontColor(this.isDarkMode ? '#AAAAAA' : '#666666')
        .maxLines(2)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .textAlign(TextAlign.Center)
        .padding({ left: 8, right: 8 })

      // 分类标签
      Text(game.category)
        .fontSize(10)
        .fontColor(game.themeColor)
        .backgroundColor(game.themeColor + '15')
        .padding({ left: 8, right: 8, top: 2, bottom: 2 })
        .borderRadius(10)
        .margin({ top: 8 })
    }
    .width('100%')
    .padding(16)
    .backgroundColor(this.isDarkMode ? '#2A2A2A' : '#FFFFFF')
    .borderRadius(16)
    .shadow({
      radius: 8,
      color: this.isDarkMode ? '#00000030' : '#00000015',
      offsetX: 0,
      offsetY: 4
    })
    .onClick(() => {
      router.pushUrl({
        url: 'pages/GamePage',
        params: {
          game: JSON.stringify(game)
        }
      });
    })
    .animation({
      duration: 200,
      curve: Curve.EaseInOut
    })
    .stateStyles({
      pressed: {
        .scale({ x: 0.96, y: 0.96 })
        .shadow({
          radius: 4,
          color: this.isDarkMode ? '#00000020' : '#00000010',
          offsetX: 0,
          offsetY: 2
        })
      }
    })
  }

  // 关于页面
  @Builder
  AboutPage() {
    Scroll() {
      Column() {
        // 应用图标
        Stack() {
          Circle()
            .width(100)
            .height(100)
            .fill('#FF6B6B')
            .shadow({
              radius: 16,
              color: '#FF6B6B40',
              offsetX: 0,
              offsetY: 8
            })

          Text('🧠')
            .fontSize(56)
        }
        .margin({ top: 40, bottom: 24 })

        // 应用名称
        Text('脑力训练')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor(this.isDarkMode ? '#FFFFFF' : '#1A1A1A')
          .margin({ bottom: 8 })

        Text('Brain Games Collection')
          .fontSize(14)
          .fontColor(this.isDarkMode ? '#888888' : '#666666')
          .margin({ bottom: 32 })

        // 版本信息
        Column() {
          AboutItem('版本', 'v1.0.0')
          AboutItem('系统要求', 'HarmonyOS 4.2+')
          AboutItem('游戏数量', '10款精选益智游戏')
          AboutItem('开发者', 'Brain Games Team')
        }
        .width('100%')
        .padding(16)
        .backgroundColor(this.isDarkMode ? '#2A2A2A' : '#FFFFFF')
        .borderRadius(16)
        .margin({ bottom: 16 })

        // 说明
        Text('本应用集成了10款经典H5益智游戏，无需下载即可畅玩。游戏数据来自网络，请确保网络连接正常。')
          .fontSize(14)
          .fontColor(this.isDarkMode ? '#888888' : '#666666')
          .textAlign(TextAlign.Center)
          .padding({ left: 24, right: 24 })
          .margin({ top: 16 })

        // 版权信息
        Text('© 2026 Brain Games. All rights reserved.')
          .fontSize(12)
          .fontColor(this.isDarkMode ? '#666666' : '#999999')
          .margin({ top: 40, bottom: 24 })
      }
      .width('100%')
      .padding(16)
    }
    .scrollable(ScrollDirection.Vertical)
    .scrollBar(BarState.Off)
  }

  @Builder
  AboutItem(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(16)
        .fontColor(this.isDarkMode ? '#AAAAAA' : '#666666')

      Text(value)
        .fontSize(16)
        .fontColor(this.isDarkMode ? '#FFFFFF' : '#1A1A1A')
        .fontWeight(FontWeight.Medium)
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
    .padding({ top: 12, bottom: 12 })
    .border({
      width: { bottom: 1 },
      color: this.isDarkMode ? '#3A3A3A' : '#F0F0F0'
    })
  }

  build() {
    Stack() {
      Column() {
        // 顶部标题栏
        Row() {
          Column() {
            Text('脑力训练')
              .fontSize(24)
              .fontWeight(FontWeight.Bold)
              .fontColor(this.isDarkMode ? '#FFFFFF' : '#1A1A1A')

            Text('Brain Games')
              .fontSize(12)
              .fontColor(this.isDarkMode ? '#888888' : '#666666')
          }
          .alignItems(HorizontalAlign.Start)
          .layoutWeight(1)

          // 深色模式切换
          Toggle({ type: ToggleType.Switch, isOn: this.isDarkMode })
            .selectedColor('#FF6B6B')
            .onChange((isOn: boolean) => {
              this.isDarkMode = isOn;
            })
        }
        .width('100%')
        .height(60)
        .padding({ left: 16, right: 16 })
        .backgroundColor(this.isDarkMode ? '#1A1A1A' : '#FFFFFF')

        if (this.currentTab === 0) {
          // 游戏列表页面
          Scroll() {
            Grid() {
              ForEach(GameList, (game: GameInfo) => {
                GridItem() {
                  this.GameCard(game)
                }
              }, (game: GameInfo) => game.id)
            }
            .columnsTemplate('1fr 1fr')
            .columnsGap(12)
            .rowsGap(12)
            .padding(16)
            .width('100%')
          }
          .scrollable(ScrollDirection.Vertical)
          .scrollBar(BarState.Off)
          .layoutWeight(1)
        } else {
          // 关于页面
          this.AboutPage()
            .layoutWeight(1)
        }

        // 底部导航栏
        Row() {
          Column() {
            Image(this.currentTab === 0 ? $r('app.media.ic_home_filled') : $r('app.media.ic_home'))
              .width(24)
              .height(24)
              .fillColor(this.currentTab === 0 ? '#FF6B6B' : (this.isDarkMode ? '#888888' : '#999999'))

            Text('首页')
              .fontSize(11)
              .fontColor(this.currentTab === 0 ? '#FF6B6B' : (this.isDarkMode ? '#888888' : '#999999'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .onClick(() => {
            this.currentTab = 0;
          })

          Column() {
            Image(this.currentTab === 1 ? $r('app.media.ic_info_filled') : $r('app.media.ic_info'))
              .width(24)
              .height(24)
              .fillColor(this.currentTab === 1 ? '#FF6B6B' : (this.isDarkMode ? '#888888' : '#999999'))

            Text('关于')
              .fontSize(11)
              .fontColor(this.currentTab === 1 ? '#FF6B6B' : (this.isDarkMode ? '#888888' : '#999999'))
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .onClick(() => {
            this.currentTab = 1;
          })
        }
        .width('100%')
        .height(56)
        .backgroundColor(this.isDarkMode ? '#2A2A2A' : '#FFFFFF')
        .border({
          width: { top: 1 },
          color: this.isDarkMode ? '#3A3A3A' : '#F0F0F0'
        })
      }
      .width('100%')
      .height('100%')
      .backgroundColor(this.isDarkMode ? '#121212' : '#F5F5F5')

      // 加载动画
      if (this.isLoading) {
        Column() {
          LoadingProgress()
            .width(60)
            .height(60)
            .color('#FF6B6B')

          Text('正在加载...')
            .fontSize(14)
            .fontColor('#FFFFFF')
            .margin({ top: 16 })
        }
        .width('100%')
        .height('100%')
        .backgroundColor('#00000080')
        .justifyContent(FlexAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }
}
