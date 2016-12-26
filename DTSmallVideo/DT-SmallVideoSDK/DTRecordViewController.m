//
//  RecordViewController.m
//  DTSmallVideo
//
//  Created by quan cui on 2016/12/15.
//  Copyright © 2016年 quan cui. All rights reserved.
//

#import "DTRecordViewController.h"
#import "SmallVideoHeader.h"
#define kNavButtonWidth 30
#define kNavButtonPadding 10
#define kRecordButtonHeight 80
typedef NS_ENUM(NSInteger, DTCameraFlashType) {
    DTCameraFlashAUTO = 0,
    DTCameraFlashOPEN = 1,
    DTCameraFlashCLOSE = 2
};

@interface DTRecordViewController ()
@property (nonatomic, strong) UIView *navigationView;
@property (nonatomic, strong) UIButton *buttonBack;
@property (nonatomic, strong) UIButton *buttonCameraSwitch;
@property (nonatomic, strong) UIButton *buttonFlash;

@property (nonatomic, strong) DTRecordView *recordView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UIButton *buttonRecord;
@property (nonatomic, strong) UIButton *buttonComplete;

@property (nonatomic, strong) UIButton *buttonBackWard;
@property (nonatomic, strong) UIButton *buttonDelete;
@property (nonatomic, strong) UIButton *buttonReset;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;
@end

@implementation DTRecordViewController{
    
}
- (instancetype)initRecorViewControllerWithCompleteBlock:(DTRecordCompleteBlock)completeBlock{
    if(self == [super init]){
        self.completeBlock = completeBlock;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kBackColor;
    [self setUpNavigationToolBar];
    [self setUpCameraView];
    [self setUPBottomView];
}
- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:YES];
}
- (void)viewWillDisappear:(BOOL)animated{
    [self.navigationController.navigationBar setHidden:NO];
}
#pragma mark - UI Building -
-(void)setUpNavigationToolBar{
    // topView
    self.navigationView = [[UIView alloc] initWithFrame:(CGRectMake(0, 0, kScreenWidth, 64))];
    self.navigationView.backgroundColor = kRGB(44, 44, 44);
    [self.view addSubview:self.navigationView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(100, 20, kScreenWidth-200, 44)];
    titleLabel.text = @"RecordVC";
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont systemFontOfSize:18];
    [self.navigationView addSubview:titleLabel];
    
    self.buttonBack = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonBack.frame = CGRectMake(kNavButtonPadding, 27, kNavButtonWidth, kNavButtonWidth);
    [self.buttonBack addTarget:self action:@selector(navigationViewButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.buttonBack setImage:[UIImage imageNamed:@"icon_back"] forState:(UIControlStateNormal)];
    [self.navigationView addSubview:self.buttonBack];
    
    self.buttonCameraSwitch = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonCameraSwitch.frame = CGRectMake(CGRectGetWidth(self.navigationView.frame) - kNavButtonWidth-15, 27, kNavButtonWidth, kNavButtonWidth);
    [self.buttonCameraSwitch setImage:[UIImage imageNamed:@"icon_camera_switch"] forState:(UIControlStateNormal)];
    [self.buttonCameraSwitch setImage:[UIImage imageNamed:@"icon_camera_switch_1.png"] forState:(UIControlStateSelected)];
    [self.buttonCameraSwitch addTarget:self action:@selector(navigationViewButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.navigationView addSubview:self.buttonCameraSwitch];
    
    self.buttonFlash = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonFlash.frame = CGRectMake(CGRectGetMinX(self.buttonCameraSwitch.frame) - kNavButtonWidth - kNavButtonPadding, 27, kNavButtonWidth, kNavButtonWidth);
    [self.buttonFlash setImage:[UIImage imageNamed:@"icon_flash_close.png"] forState:(UIControlStateNormal)];
    [self.buttonFlash addTarget:self action:@selector(navigationViewButtonAction:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.navigationView addSubview:self.buttonFlash];
}
- (void)setUpCameraView{
    self.recordView = [[DTRecordView alloc]initWithFrame:CGRectMake(0, self.navigationView.frame.size.height, kScreenWidth, kScreenWidth)];
    [self.view addSubview:self.recordView];
    [self addObserver:self forKeyPath:@"self.recordView.recordState" options:NSKeyValueObservingOptionNew context:nil];
}
- (void)setUPBottomView{
    self.bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, self.recordView.frame.origin.y + self.recordView.frame.size.height, kScreenWidth, kScreenHeight - self.navigationView.frame.size.height - self.recordView.frame.size.height)];
    self.bottomView.backgroundColor = kRGB(44, 44, 44);
    [self.view addSubview:self.bottomView];
    
    self.buttonRecord = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonRecord.frame = CGRectMake(self.bottomView.frame.size.width/2-kRecordButtonHeight/2, self.bottomView.frame.size.height/2-kRecordButtonHeight/2, kRecordButtonHeight, kRecordButtonHeight);
    [self.buttonRecord setImage:[UIImage imageNamed:@"icon_record_1"] forState:(UIControlStateNormal)];
    [self.buttonRecord setImage:[UIImage imageNamed:@"icon_record_0"] forState:(UIControlStateHighlighted)];

    [self.buttonRecord addTarget:self action:@selector(recordButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [self.buttonRecord addTarget:self action:@selector(recordButtonTouchUp:) forControlEvents:UIControlEventTouchUpInside];

    [self.bottomView addSubview:self.buttonRecord];
    
    self.buttonComplete = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonComplete.frame = CGRectMake(self.bottomView.frame.size.width-kNavButtonPadding*5-kNavButtonWidth, self.bottomView.frame.size.height/2-kNavButtonWidth/2, kNavButtonWidth, kNavButtonWidth);
    [self.buttonComplete setImage:[UIImage imageNamed:@"icon_complete"] forState:(UIControlStateNormal)];
    [self.buttonComplete addTarget:self action:@selector(completeButtonClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.bottomView addSubview:self.buttonComplete];
    
    self.buttonBackWard = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonBackWard.frame = CGRectMake(kNavButtonPadding*5, self.bottomView.frame.size.height/2-kNavButtonWidth/2, kNavButtonWidth, kNavButtonWidth);
    [self.buttonBackWard setImage:[UIImage imageNamed:@"icon_backward"] forState:(UIControlStateNormal)];
    [self.buttonBackWard addTarget:self action:@selector(backwardButtonClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    [self.bottomView addSubview:self.buttonBackWard];
    
    self.buttonDelete = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonDelete.frame = CGRectMake(kNavButtonPadding*5, self.bottomView.frame.size.height/2-kNavButtonWidth/2, kNavButtonWidth, kNavButtonWidth);
    [self.buttonDelete setImage:[UIImage imageNamed:@"icon_delete"] forState:(UIControlStateNormal)];
    [self.buttonDelete addTarget:self action:@selector(deleteLastPartButtonClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    self.buttonDelete.hidden = YES;
    [self.bottomView addSubview:self.buttonDelete];
    
    self.buttonReset = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.buttonReset.frame = CGRectMake(kNavButtonPadding*5, self.bottomView.frame.size.height/2-kNavButtonWidth/2, kNavButtonWidth, kNavButtonWidth);
    [self.buttonReset setImage:[UIImage imageNamed:@"icon_restart"] forState:(UIControlStateNormal)];
    [self.buttonReset addTarget:self action:@selector(resetButtonClicked:) forControlEvents:(UIControlEventTouchUpInside)];
    self.buttonReset.hidden = YES;
    [self.bottomView addSubview:self.buttonReset];
    
}
#pragma mark - RecordView state observing
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if ([keyPath isEqualToString:@"self.recordView.recordState"]) {
        [self updateRecordController];
    }
}
-(void)updateRecordController{
    dispatch_async(dispatch_get_main_queue(), ^{
        if(self.recordView.recordState == DTRecordStateInit){

            self.buttonFlash.enabled = YES;
            self.buttonCameraSwitch.enabled = YES;
            
            self.buttonBackWard.enabled = YES;
            self.buttonBackWard.hidden = NO;
            self.buttonDelete.hidden = YES;
            self.buttonReset.hidden = YES;
            self.buttonRecord.enabled = YES;
            self.buttonRecord.hidden = NO;
            [self.buttonComplete setImage:[UIImage imageNamed:@"icon_complete.png"] forState:(UIControlStateNormal)];
            
        }else if(self.recordView.recordState == DTRecordStateRecording){
            [self.indicator stopAnimating];
            
            self.buttonFlash.enabled = NO;
            self.buttonCameraSwitch.enabled = NO;
            
            self.buttonBackWard.enabled = NO;
            self.buttonBackWard.hidden = NO;
            self.buttonDelete.hidden = YES;
            
            self.buttonRecord.enabled = YES;
            self.buttonRecord.hidden = NO;
            
            self.buttonComplete.enabled = NO;
            
        }else if(self.recordView.recordState == DTRecordStatePause){
            
            self.buttonFlash.enabled = YES;
            self.buttonCameraSwitch.enabled = YES;
            
            [self.indicator stopAnimating];
            
            self.buttonRecord.enabled = YES;
            self.buttonRecord.hidden = NO;
            
            self.buttonBackWard.enabled = YES;
            self.buttonComplete.enabled = YES;
            
        }else if(self.recordView.recordState == DTRecordStateCombining){
            self.buttonFlash.enabled = NO;
            self.buttonCameraSwitch.enabled = NO;
            [self.indicator startAnimating];
            
            self.buttonRecord.enabled = NO;
            self.buttonRecord.hidden = YES;
            self.buttonBackWard.hidden = YES;
            self.buttonDelete.hidden = YES;
            
            self.buttonReset.hidden = NO;
            self.buttonReset.enabled = NO;
            self.buttonComplete.enabled = NO;
            
        }else if(self.recordView.recordState == DTRecordStateRePlay){
            self.buttonFlash.enabled = NO;
            self.buttonCameraSwitch.enabled = NO;
            [self.indicator stopAnimating];
            
            self.buttonBackWard.hidden = YES;
            self.buttonDelete.hidden = YES;
            self.buttonReset.enabled = YES;
            self.buttonComplete.enabled = YES;
            
            [self.buttonComplete setImage:[UIImage imageNamed:@"icon_save.png"] forState:(UIControlStateNormal)];
        }
    });
}
#pragma mark - View Action -
- (void)navigationViewButtonAction:(UIButton *)sender{
    if ( [sender isEqual:self.buttonBack]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    if ( [sender isEqual:self.buttonCameraSwitch]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.recordView switchCamera];
        });
    }
    if ( [sender isEqual:self.buttonFlash]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.recordView switchTorch];
            if(self.recordView.torchType == DTTorchClose){
                [self.buttonFlash setImage:[UIImage imageNamed:@"icon_flash_close.png"] forState:(UIControlStateNormal)];
            }else if(self.recordView.torchType == DTTorchOpen){
                [self.buttonFlash setImage:[UIImage imageNamed:@"icon_flash.png"] forState:(UIControlStateNormal)];
            }else if(self.recordView.torchType == DTTorchAuto){
                [self.buttonFlash setImage:[UIImage imageNamed:@"icon_flash_auto.png"] forState:(UIControlStateNormal)];
            }
        });
    }
}
- (void)recordButtonTouchDown:(UIButton *)sender{
    if(self.recordView.recordState == DTRecordStateInit || self.recordView.recordState == DTRecordStatePause){
        [self.recordView startRecord];
        return;
    }
}
- (void)recordButtonTouchUp:(UIButton *)sender{
    if(self.recordView.recordState != DTRecordStateRecording){
        return;
    }else{
        [self.recordView pauseRecord];
    }
}
- (void)completeButtonClicked:(UIButton *)sender{
    if(self.recordView.recordState == DTRecordStateRePlay){
        self.completeBlock(self.recordView.videoModel.videoExportUrl);
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        [self.recordView finishVideoRecord];
    }
}
- (void)backwardButtonClicked:(UIButton *)sender{
    self.buttonBackWard.hidden = YES;
    self.buttonDelete.hidden = NO;
    [self.recordView selectLastDeletePart];
}
- (void)deleteLastPartButtonClicked:(UIButton *)sender{
    self.buttonBackWard.hidden = NO;
    self.buttonDelete.hidden = YES;
    [self.recordView didDeleteLastPart];
}
- (void)resetButtonClicked:(UIButton *)sender{
    [self.recordView resetRecord];
}

-(UIActivityIndicatorView *)indicator{
    if(!_indicator){
        _indicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _indicator.center = CGPointMake(self.recordView.frame.size.width/2, self.recordView.frame.size.height/2+self.navigationView.frame.size.height);
        [self.view addSubview:_indicator];
        _indicator.color = kGreen;
        [_indicator setHidesWhenStopped:YES];
    }
    return _indicator;
}
- (void)dealloc
{
    [self removeObserver:self forKeyPath:@"self.recordView.recordState"];
}
@end
