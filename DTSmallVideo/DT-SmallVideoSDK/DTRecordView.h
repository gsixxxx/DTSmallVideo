//
//  RecordView.h
//  DTSmallVideo
//
//  Created by quan cui on 2016/12/15.
//  Copyright © 2016年 quan cui. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SmallVideoHeader.h"
#import "DTVideoModel.h"

typedef NS_ENUM(NSInteger, DTRecordState) {
    DTRecordStateInit,
    DTRecordStateRecording,
    DTRecordStatePause,
    DTRecordStateCombining,
    DTRecordStateRePlay,
};

typedef NS_ENUM(NSInteger, DTTorchState) {
    DTTorchClose = 0,
    DTTorchOpen,
    DTTorchAuto,
};

@interface DTRecordView : UIView

@property (nonatomic) NSInteger recordState;
@property (nonatomic) NSInteger torchType;
@property (nonatomic, strong) DTVideoModel *videoModel;

- (instancetype)initWithFrame:(CGRect)frame;

- (void)startRecord;
- (void)pauseRecord;
- (void)finishVideoRecord;

- (void)selectLastDeletePart;
- (void)didDeleteLastPart;
- (void)resetRecord;

- (void)switchTorch;
- (void)switchCamera;

@end
