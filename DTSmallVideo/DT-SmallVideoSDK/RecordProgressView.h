//
//  RecordProgressView.h
//  DTSmallVideo
//
//  Created by quan cui on 2016/12/16.
//  Copyright © 2016年 quan cui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "SmallVideoHeader.h"
@interface RecordProgressView : UIView


- (instancetype)initWithFrame:(CGRect)frame minTime:(CGFloat)minTime maxTime:(CGFloat)maxTime;

-(void)updateProgressWithValue:(CGFloat)progress;
-(void)pauseProgress;
-(void)resetProgress;

-(void)willDeleteLastProgressView;
-(void)cancelDeleteLastProgressView;
-(void)deleteAllProgressViews;
-(void)deleteLastProgressView;

@end
