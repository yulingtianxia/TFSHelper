TFSConvertor
===========


![](TFS.png)

鹅厂用 Mac 的小伙伴们的福利！噗，其实也不算什么福利。

## 什么是TFSHelper

TFSHelper 是我开发的一个 Mac 上的 tfs 辅助工具。它可以在我们复制 tfs 链接时自动连接 tfs 服务器，并自动识别 windows 下的 tfs 格式，将其转化成 Mac OS X 的格式后连接到服务器。它不占用 Dock 上的宝贵空间，只停留在上方的菜单栏，当你想手动打开剪贴板中的 tfs 链接时，也可以点击菜单栏的 ![](TFSmenuicon.png) 图标来打开。

可以在 [https://github.com/yulingtianxia/TFSHelper/releases](https://github.com/yulingtianxia/TFSHelper/releases) 下载 TFSHelper 最新的 Release 版本。

## 为什么要做这个小工具
作为一名 iOS 开发，平时使用 Mac 作为开发机。而身边很多人发的 tfs 链接为 windows 格式，需要手动转换或者照着路径手动一层一层点进去，由于 Mac 解析文件 tfs 的路径较慢，所以十分费时。本着 **“所有超过90秒的重复工作都应自动化”** 的原则，我开发了这款小工具。

## 实现原理

开发语言主要是如今火爆的 Swift 语言和古老的 AppleScript 脚本语言。有兴趣的同学可以加入进来，或是提 PR。

原理是监听 Mac OS X 的 Clipboard，匹配其中的文字，如果是 `\\tencent\` 或 `smb://tencent.com` 开头的字符串，就使用 AppleScript 脚本打开 Finder 来连接 tfs 地址。

##License

The MIT License.

