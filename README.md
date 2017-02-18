# ShadowsocksFree
数据来源：[ishadowsocks](http://www.ishadowsocks.net/)

之所以有做各样一个应用的想法是因为搬瓦工前几天电信出口炸了半天，当时萌生了一个App端获取一些免费账号过渡搬瓦工不稳定时期的想法，正好想学Swift，于是做了下，把想学的都加进去玩。

# 更新记录
> 16.06.05: 使用[Fuzi](https://github.com/cezheng/Fuzi)对HTML进行解析(第一次对HTML进行类XML的解析，有点小激动呢)

> 16.06.06: 使用[RealmSwift](https://github.com/realm/realm-cocoa)进行数据持久化(项目哪集成Realm后应用会变的超大，但是Realm还是很好用)

> 16.06.06: 使用之前的用的第三方库进行二维码生成（有时间再用swift写下）

> 16.06.06: 增加保存二维码到本地

> 16.06.07: Swift封装base64加密字符串以及二维码图片生成方法

> 16.06.12: 增加 IBAnimatable 2.3 很好玩的转场动画，学习下

> 16.06.23: 学习下[corin8823](https://github.com/corin8823/Popover)在iPhone下实现popoverView, 自己写的由于做了很多实验也不知道怎么改回去，项目内还是用大神的；
实现swift下二维码扫描及base64 解码；
学习代码使用IBAnimatable 进行转场动画(用storyBoard会比较简单但是用代码去做。。。首先没有文档也没有Example，自己试了很多次才搞懂)

> 16.06.23: 实现从设备相册读取二维码扫描。

> 16.06.24: 参考[dgytdhy的DGPopUpViewController](https://github.com/dgytdhy/DGPopUpViewController)优化信息输入页面。

> 16.07.31: 增加`3D touch`支持。

> ~~16.08.21: 增加 [namaho](https://www.namaho.com/) 免费节点。~~

> 16.12.22: 删除 ~~namaho~~ 节点，~~增加 [seeout][380e7a9b] 免费节点。~~

> 17.01.17: ~~由于 `seeout` 以及 `mian233` 免费节点不稳定，所以加到 `servers` 分支。~~

  [380e7a9b]: http://www.seeout.pw/free/ "seeout"

# TODO
- [x] 归档用户自己输入的配置信息并生成二维码

- [x] 尝试新的二维码图片生成方法

- [x] 增加编辑管理用户自定义节点的选项

- [x] 买了本 [剑指人心](http://weibo.com/u/1787521145?refer_flag=1005055010_&is_all=1) 大神的《Mac应用开发技术》，想尝试写个Mac端小插件(写得很简陋，以后慢慢学，慢慢改进吧)
