//
//  DTNavigationController.m
//  DTSmallVideo
//
//  Created by quan cui on 2016/12/15.
//  Copyright © 2016年 quan cui. All rights reserved.
//

#import "DTNavigationController.h"
#import "SmallVideoHeader.h"
@interface DTNavigationController ()

@end

@implementation DTNavigationController

-(id)initWithRootViewController:(UIViewController *)rootViewController{
    if(self == [super initWithRootViewController:rootViewController]){
        //上部statusBar 的颜色
        //        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        // 修改状态栏和bar外观
        if (IOS_7_OR_LATER) {
            [[UINavigationBar appearance] setBarTintColor:kNavigationColor];
            [UINavigationBar appearance].translucent = NO;
        }
        //系统自带的导航栏返回按钮颜色设置
        [[UINavigationBar appearance] setTintColor:kWhite];
        //导航栏字体颜色
        [[UINavigationBar appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:kWhite, NSForegroundColorAttributeName,kNavFont(18), NSFontAttributeName,nil]];
        //隐藏statusBar
        //        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    if (IOS_7_OR_LATER) {
        // 清空手势识别器的代理, 就能恢复以前滑动移除控制器的功能
        self.interactivePopGestureRecognizer.delegate = nil;
    }
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        viewController.navigationItem.leftBarButtonItem = [self getBarItemWithTartget:self action:@selector(customReturn) icon:@"icon_back" highlightedIcon:@"icon_back"];
    }
    [super pushViewController:viewController animated:animated];
}

//返回
- (void)customReturn
{
    [self popViewControllerAnimated:YES];
}

//辅助防范
-(UIBarButtonItem *)getBarItemWithTartget:(id)target action:(SEL)action icon:(NSString *)icon highlightedIcon:(NSString *)highlightedIcon{
    //1创建按钮
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    
    //2设置图片
    UIImage *bg = [UIImage imageNamed:icon];
    UIImage *highlightedBg = [UIImage imageNamed:highlightedIcon];
    
    //3设置按钮的背景图片
    [btn setBackgroundImage:bg forState:UIControlStateNormal];
    [btn setBackgroundImage:highlightedBg  forState:UIControlStateHighlighted];
    
    //4点击监听事件
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    //5设置按钮的frame
    btn.frame = (CGRect){CGPointZero,{18,20}};
    
    //6设置 UIBarButtonItem 的自定义为btn
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc]initWithCustomView:btn];
    
    return barButtonItem;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
