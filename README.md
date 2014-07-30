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
