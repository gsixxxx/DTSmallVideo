//
//  RecordViewController.h
//  DTSmallVideo
//
//  Created by quan cui on 2016/12/15.
//  Copyright © 2016年 quan cui. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DTRecordCompleteBlock) (NSURL *videoSandBoxUrl);
@interface DTRecordViewController : UIViewController
@property (nonatomic, copy) DTRecordCompleteBlock completeBlock;
- (instancetype)initRecorViewControllerWithCompleteBlock:(DTRecordCompleteBlock)completeBlock;
@end
