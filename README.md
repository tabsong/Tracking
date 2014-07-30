Tracking
========

基于高德地图 iOS SDK 的轨迹回放 库

#### 使用方法
- 创建 Tracking 类

  ```
    self.tracking = [[Tracking alloc] initWithCoordinates:coordinates count:count];
    self.tracking.delegate   = self;
    self.tracking.mapView    = self.mapView;
    self.tracking.duration   = 5.f;
    self.tracking.edgeInsets = UIEdgeInsetsMake(50, 50, 50, 50);
  ```
- 执行轨迹回放

  ```
    [self.tracking execute];
  ```

#### 效果
![screenshot](https://raw.githubusercontent.com/tabsong/Tracking/master/PictureBed/screenshot.PNG)

#### 在线安装Demo

* `手机扫描如下二维码直接安装`

![twoDemision](https://raw.githubusercontent.com/tabsong/Tracking/master/PictureBed/twoDemision.png)

* `手机上打开地址:http://fir.im/rAFu>`
