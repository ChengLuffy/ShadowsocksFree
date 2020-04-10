# ShadowsocksFree
![Language](https://img.shields.io/badge/language-swift-orange.svg)

Data Source: [ishadowsocks](https://go.ishadowx.net)

TestFlight 申请 [点击申请](https://testflight.apple.com/join/I4GSKgX1)

Made by Love.

```
carthage update --no-use-binaries --platform ios
```

# 2018-4-23
现在，您可以使用 ShadowsocksFree 链接其中的 Shadowsocks 节点。

**相关代码 copy 自 [yichengchen/RabbitVpnDemo][d83b77ef]**

**核心框架使用开源的 [zhuhaow/NEKit][33cbd2c3]**

  [d83b77ef]: https://github.com/yichengchen/RabbitVpnDemo "Github"
  [33cbd2c3]: https://github.com/zhuhaow/NEKit "Github"

#  App Store
2017.12.14: 加州审核团队的电话通知

1. 国区开发者即使选择非国区上架也是违反国家法律的，准确的说 `Shadowsocks` 的用户就是大陆用户，所以涉及到的其账户都是不合国内法律的；
2. Shadowsocks 属于 Open source，作为非开发维护人员不应该使用这个名称，所以名字更改为 '1/4DSSA'，但是由于 '1' 还是没有办法上架。

# LICENSE
你可以在 [SATA-LICENSE][907fa31f] 下自由使用本项目。

  [907fa31f]: ./LICENSE "LICENSE"

解决打包上传时遇到的 `CFBundleShortVersionString` 问题
---
```
defaults write "$PWD/Carthage/Build/iOS/NEKit.framework/Info.plist" CFBundleShortVersionString 0.2.0
defaults write "$PWD/Carthage/Build/iOS/NEKit.framework.dSYM/Contents/Info.plist" CFBundleShortVersionString 0.2.0
```
