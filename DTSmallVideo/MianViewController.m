//
//  MianViewController.m
//  DTSmallVideo
//
//  Created by quan cui on 2016/12/15.
//  Copyright © 2016年 quan cui. All rights reserved.
//

#import "MianViewController.h"
#import "SmallVideoHeader.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface MianViewController ()

@end

@implementation MianViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setTitle:@"SmallVideoDemo"];
    //右上角
    UIButton *saveBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame = CGRectMake(0, 0, 56, 26);
    saveBtn.titleLabel.font = [UIFont systemFontOfSize:16.f];
    [saveBtn setTitleColor:kOrange forState:UIControlStateNormal];
    [saveBtn setTitle:@"Record" forState:UIControlStateNormal];
    [saveBtn addTarget:self action:@selector(popUpRecordViewController) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:saveBtn];
}
-(void)popUpRecordViewController{
    DTRecordViewController *recordViewController = [[DTRecordViewController alloc]initRecorViewControllerWithCompleteBlock:^(NSURL *videoSandBoxUrl) {
        
        NSLog(@"videoSandBoxUrl:%@",videoSandBoxUrl);
        BOOL ios8Later = [[[UIDevice currentDevice] systemVersion] floatValue] >= 8;
        if (ios8Later) {
            [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
                [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoSandBoxUrl];
            } completionHandler:^(BOOL success, NSError * _Nullable error) {
                if (!error && success) {
                    NSLog(@"save to camear roll success");
                }
                else {
                    NSLog(@"save to camear roll Failed :%@",error);
                }
            }];
        }
        else {
            [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:videoSandBoxUrl completionBlock:^(NSURL *assetURL, NSError *error) {
                if (!error) {
                    NSLog(@"save to camear roll sccess!");
                }
                else {
                    NSLog(@"save to camear roll Failed");
                }
            }];
        }
    }];
    [self.navigationController pushViewController:recordViewController animated:YES];
    
}


@end
