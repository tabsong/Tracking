//
//  Tracking.m
//  Tracking
//
//  Created by xiaojian on 14-7-30.
//  Copyright (c) 2014年 Tab. All rights reserved.
//

#import "Tracking.h"

@interface Tracking ()
{
    CLLocationCoordinate2D *_coordinates;
    NSUInteger              _count;
}

@property (nonatomic, strong) CAShapeLayer *shapeLayer;

@property (nonatomic, strong, readwrite) MAPointAnnotation *annotation;
@property (nonatomic, strong, readwrite) MAPolyline *polyline;

@end

@implementation Tracking
@synthesize mapView     = _mapView;
@synthesize shapeLayer  = _shapeLayer;

@synthesize annotation  = _annotation;
@synthesize polyline    = _polyline;

#pragma mark - CoreAnimation Delegate

- (void)animationDidStart:(CAAnimation *)anim
{
    [self makeMapViewEnable:NO];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(willBeginTracking:)])
    {
        [self.delegate willBeginTracking:self];
    }
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if (flag)
    {
        [self.mapView addOverlay:self.polyline];
        
        [self.shapeLayer removeFromSuperlayer];
    }
    
    [self makeMapViewEnable:YES];
    
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(didEndTracking:)])
    {
        [self.delegate didEndTracking:self];
    }
}

#pragma mark - Utility

/* Enable/Disable mapView. */
- (void)makeMapViewEnable:(BOOL)enabled
{
    self.mapView.scrollEnabled          = enabled;
    self.mapView.zoomEnabled            = enabled;
    self.mapView.rotateEnabled          = enabled;
    self.mapView.rotateCameraEnabled    = enabled;
}

/* 经纬度转屏幕坐标, 调用着负责释放内存. */
- (CGPoint *)pointsForCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    if (coordinates == NULL || count <= 1)
    {
        return NULL;
    }
    
    /* 申请屏幕坐标存储空间. */
    CGPoint *points = (CGPoint *)malloc(count * sizeof(CGPoint));
    
    /* 经纬度转换为屏幕坐标. */
    for (int i = 0; i < count; i++)
    {
        points[i] = [self.mapView convertCoordinate:coordinates[i] toPointToView:self.mapView];
    }
    
    return points;
}

/* 构建path, 调用着负责释放内存. */
- (CGMutablePathRef)pathForPoints:(CGPoint *)points count:(NSUInteger)count
{
    if (points == NULL || count <= 1)
    {
        return NULL;
    }
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGPathAddLines(path, NULL, points, count);
    
    return path;
}

/* 构建annotationView的keyFrameAnimation. */
- (CAAnimation *)constructAnnotationAnimationWithPath:(CGPathRef)path
{
    if (path == NULL)
    {
        return nil;
    }
    
    CAKeyframeAnimation *thekeyFrameAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    thekeyFrameAnimation.duration        = self.duration;
    thekeyFrameAnimation.path            = path;
    thekeyFrameAnimation.calculationMode = kCAAnimationPaced;
    
    return thekeyFrameAnimation;
}

/* 构建shapeLayer的basicAnimation. */
- (CAAnimation *)constructShapeLayerAnimation
{
    CABasicAnimation *theStrokeAnimation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    theStrokeAnimation.duration         = self.duration;
    theStrokeAnimation.fromValue        = @0.f;
    theStrokeAnimation.toValue          = @1.f;
    
    return theStrokeAnimation;
}

#pragma mark - Interface

- (void)execute
{
    [self clear];
    
    /* 使轨迹在地图可视范围内. */
    [self.mapView setVisibleMapRect:self.polyline.boundingMapRect edgePadding:self.edgeInsets animated:NO];
    
    /* 构建path. */
    CGPoint *points = [self pointsForCoordinates:_coordinates count:_count];
    CGPathRef path = [self pathForPoints:points count:_count];
    
    self.shapeLayer.path = path;
    
    [self.mapView.layer insertSublayer:self.shapeLayer atIndex:1];
    
    [self.mapView addAnnotation:self.annotation];
    
    MAAnnotationView *annotationView = [self.mapView viewForAnnotation:self.annotation];
    if (annotationView != nil)
    {
        /* Annotation animation. */
        CAAnimation *annotationAnimation = [self constructAnnotationAnimationWithPath:path];
        [annotationView.layer addAnimation:annotationAnimation forKey:@"annotation"];
        
        [annotationView.annotation setCoordinate:_coordinates[_count - 1]];
        
        /* ShapeLayer animation. */
        CAAnimation *shapeLayerAnimation = [self constructShapeLayerAnimation];
        shapeLayerAnimation.delegate = self;
        [self.shapeLayer addAnimation:shapeLayerAnimation forKey:@"shape"];
    }
    
    free(points),           points  = NULL;
    CGPathRelease(path),    path    = NULL;
}

- (void)clear
{
    /* 删除annotation. */
    [self.mapView removeAnnotation:self.annotation];
    
    /* 删除polyline. */
    [self.mapView removeOverlay:self.polyline];
    
    /* 删除shapeLayer. */
    [self.shapeLayer removeFromSuperlayer];
}

#pragma mark - Initialization

/* 构建shapeLayer. */
- (void)initShapeLayer
{
    self.shapeLayer = [[CAShapeLayer alloc] init];
    self.shapeLayer.lineWidth         = 4;
    self.shapeLayer.strokeColor       = [UIColor redColor].CGColor;
    self.shapeLayer.fillColor         = [UIColor clearColor].CGColor;
    self.shapeLayer.lineJoin          = kCALineCapRound;
}

/* 构建annotation. */
- (void)initAnnotation
{
    self.annotation = [[MAPointAnnotation alloc] init];
    
    self.annotation.coordinate = _coordinates[0];
}

/* 构建annotation. */
- (void)initPolyline
{
    self.polyline = [MAPolyline polylineWithCoordinates:_coordinates count:_count];
}

- (void)initBaseData
{
    [self initAnnotation];
    
    [self initPolyline];
    
    [self initShapeLayer];
}

#pragma mark - Life Cycle

- (instancetype)initWithCoordinates:(CLLocationCoordinate2D *)coordinates count:(NSUInteger)count
{
    if (self = [super init])
    {
        if (coordinates == NULL || count <= 1)
        {
            return nil;
        }
        
        self.duration = 2.f;
        
        self.edgeInsets = UIEdgeInsetsMake(30, 30, 30, 30);
        
        _count = count;
        
        _coordinates = (CLLocationCoordinate2D *)malloc(count * sizeof(CLLocationCoordinate2D));
        
        if (_coordinates == NULL)
        {
            return nil;
        }
        
        /* 内存拷贝. */
        memcpy(_coordinates, coordinates, count * sizeof(CLLocationCoordinate2D));
        
        [self initBaseData];
    }
    
    return self;
}

- (void)dealloc
{
    [self clear];
    
    if (_coordinates != NULL)
    {
        free(_coordinates), _coordinates = NULL;
    }
}


@end
