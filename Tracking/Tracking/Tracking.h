//
//  Tracking.h
//  Tracking
//
//  Created by xiaojian on 14-7-30.
//  Copyright (c) 2014年 Tab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@protocol TrackingDelegate;

@interface Tracking : NSObject

@property (nonatomic, assign) id<TrackingDelegate> delegate;

/*!
 @brief 初始化时需要提供的 mapView
 */
@property (nonatomic, unsafe_unretained) MAMapView *mapView;

/*!
 @brief 轨迹回放动画时间
 */
@property (nonatomic, assign) NSTimeInterval duration;

/*!
 @brief 边界差值
 */
@property (nonatomic, assign) UIEdgeInsets edgeInsets;

/*!
 @brief 标注对应的annotation
 */
@property (nonatomic, strong, readonly) MAPointAnnotation *annotation;

/*!
 @brief 轨迹对应的overlay
 */
@property (nonatomic, strong, readonly) MAPolyline *polyline;

/*!
 @brief Tracking的初始化方法
 @param coordinates 轨迹经纬度数组
 @param count 经纬度个数
 @return Tracking
 */
- (instancetype)initWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count;

/*!
 @brief 执行轨迹回放动画
 */
- (void)execute;

/*!
 @brief 清理对应的annotation. overlay, shapeLayer
 */
- (void)clear;

@end

@protocol TrackingDelegate <NSObject>

@optional

/*!
 @brief 轨迹回放即将开始
 @param tracking
 */
- (void)willBeginTracking:(Tracking *)tracking;

/*!
 @brief 轨迹回放完成
 @param tracking
 */
- (void)didEndTracking:(Tracking *)tracking;

@end
