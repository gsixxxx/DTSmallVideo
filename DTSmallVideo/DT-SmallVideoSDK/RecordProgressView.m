//
//  RecordProgressView.m
//  DTSmallVideo
//
//  Created by quan cui on 2016/12/16.
//  Copyright © 2016年 quan cui. All rights reserved.
//

#import "RecordProgressView.h"

@implementation RecordProgressView{
    CALayer *_currentProgressLayer;
    NSMutableArray *_layerArray;
    CGFloat _minTime;
    CGFloat _maxTime;
}
- (instancetype)initWithFrame:(CGRect)frame minTime:(CGFloat)minTime maxTime:(CGFloat)maxTime{
    if(self == [super initWithFrame:frame]){
        _layerArray = [[NSMutableArray alloc]init];
        _minTime = minTime;
        _maxTime = maxTime;
        [self setUp];
    }
    return self;
}

-(void)setUp{
    self.backgroundColor = kRGBA(50, 50, 50, 0.8);
    CALayer *line = [CALayer layer];
    line.frame = CGRectMake(self.frame.size.width *(_minTime/_maxTime), 0, 0.5, self.frame.size.height);
    line.backgroundColor = kOrange.CGColor;
    [self.layer  addSublayer:line];

    _currentProgressLayer = [CALayer layer];
    _currentProgressLayer.backgroundColor = kGreen.CGColor;
    _currentProgressLayer.frame = CGRectMake(0, 0, 0, self.frame.size.height);
    [_currentProgressLayer removeAnimationForKey:@"bounds"];
    [self.layer addSublayer:_currentProgressLayer];
}
-(void)resetProgress{
    _currentProgressLayer.frame = CGRectMake(0, 0, 0, self.frame.size.height);
    [_layerArray removeAllObjects];
}
-(void)willDeleteLastProgressView{
    if(_layerArray.count > 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            ((CALayer *)[_layerArray lastObject]).backgroundColor = kRed.CGColor;
            [CATransaction commit];
        });
    }
}
-(void)cancelDeleteLastProgressView{
    if(_layerArray.count > 0){
        dispatch_async(dispatch_get_main_queue(), ^{
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            ((CALayer *)[_layerArray lastObject]).backgroundColor = kGreen.CGColor;
            [CATransaction commit];
        });
    }
}
-(void)deleteAllProgressViews{
    dispatch_async(dispatch_get_main_queue(), ^{
        for(CALayer *layer in _layerArray){
            [layer removeFromSuperlayer];
        }
        [_layerArray removeAllObjects];
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _currentProgressLayer.frame = CGRectMake(0, 0, 0, self.frame.size.height);
        [CATransaction commit];
    });
}
-(void)deleteLastProgressView{
    [((CALayer *)[_layerArray lastObject]) removeFromSuperlayer];
    [_layerArray removeLastObject];
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    _currentProgressLayer.frame = CGRectMake(((CALayer *)[_layerArray lastObject]).frame.origin.x + ((CALayer *)[_layerArray lastObject]).frame.size.width, 0, 0, self.frame.size.height);
    [CATransaction commit];

}

-(void)updateProgressWithValue:(CGFloat)progress{
    [self cancelDeleteLastProgressView];
    dispatch_async(dispatch_get_main_queue(), ^{
        if(!_currentProgressLayer){
            CALayer *newLayer = [self generateNewProgressView];
            [self.layer addSublayer:newLayer];
            _currentProgressLayer = newLayer;
        }
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        _currentProgressLayer.frame = CGRectMake(_currentProgressLayer.frame.origin.x, _currentProgressLayer.frame.origin.y, self.frame.size.width * progress, self.frame.size.height);
        [CATransaction commit];
    });

}
-(void)pauseProgress{
    if(_currentProgressLayer){
        [_layerArray addObject:_currentProgressLayer];
        _currentProgressLayer = nil;
    }
}
-(CALayer *)generateNewProgressView{
    CALayer *newProgreLayer = [CALayer layer];
    newProgreLayer.frame = CGRectMake(((CALayer *)[_layerArray lastObject]).frame.origin.x + ((CALayer *)[_layerArray lastObject]).frame.size.width, 0, 0, self.frame.size.height);
    newProgreLayer.backgroundColor = kGreen.CGColor;
    CALayer *line = [CALayer layer];
    line.frame = CGRectMake(0, 0, 0.5, newProgreLayer.frame.size.height);
    line.backgroundColor = kWhite.CGColor;
    [newProgreLayer addSublayer:line];
    return newProgreLayer;
}

//-(void)drawRect:(CGRect)rect{
////    DLog(@"===========>%f",_progressWidth);
////    CGContextRef context = UIGraphicsGetCurrentContext();
////    CGContextMoveToPoint(context , 0 , 0);
////    CGContextAddLineToPoint(context, _progressWidth, 0);
////    CGContextAddLineToPoint(context, _progressWidth, self.frame.size.height);
////    CGContextAddLineToPoint(context, 0, self.frame.size.height);
////    CGContextClosePath(context);
////    [kGreen setFill];
////    CGContextDrawPath(context , kCGPathFillStroke);
//}
@end
