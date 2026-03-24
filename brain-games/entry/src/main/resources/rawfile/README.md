# 本地游戏文件

此目录可用于存放本地游戏文件（可选）。

如果希望游戏离线可用，可以将H5游戏文件下载到此目录，然后修改 GameModel.ets 中的URL为本地路径：

```typescript
// 从本地加载
url: 'resource://RAWFILE/sudoku/index.html'
```

## 当前配置

当前版本使用在线URL加载游戏，无需放置文件到此目录。
