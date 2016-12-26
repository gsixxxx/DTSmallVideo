//
//  SmallVideoHeader.h
//  DTSmallVideo
//
//  Created by quan cui on 2016/12/15.
//  Copyright © 2016年 quan cui. All rights reserved.
//

#ifndef SmallVideoHeader_h
#define SmallVideoHeader_h
#import "DTRecordViewController.h"
#import "DTRecordView.h"
#import "DTVideoModel.h"
#import "RecordProgressView.h"

#pragma mark version definition
#define kAppVersion [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#pragma mark size definition
#define kScreenWidth ([UIScreen mainScreen].bounds.size.width)
#define kScreenHeight [UIScreen mainScreen].bounds.size.height
#define kTabBarHeight 49
#define kNavHeight 64

#pragma mark color definition
#define kClearColor [UIColor clearColor]
#define kWhite [UIColor whiteColor]
#define kBlack [UIColor blackColor]
#define kBlack242 [UIColor colorWithRed:242/255.0 green:242/255.0 blue:242/255.0 alpha:1]
#define kPure(x) [UIColor colorWithRed:x/255.0f green:x/255.0f blue:x/255.0f                                                                                  alpha:1.0]
#define kRGB(x,y,z) [UIColor colorWithRed:x/255.0f green:y/255.0f blue:z/255.0f                                                                                  alpha:1.0]
#define kRGBA(x,y,z,a) [UIColor colorWithRed:x/255.0f green:y/255.0f blue:z/255.0f                                                                                  alpha:a]
#define kColorFromHex(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define kNavigationColor [UIColor colorWithRed:55/255.0 green:70/255.0 blue:101/255.0 alpha:1]

#define kBackColor kRGB(242, 242, 242)
#define kTextColor kRGB(39,37,54)
#define kTextLightColor kRGB(153, 153, 153)
#define kLightBlue kRGB(95,182,215)
#define kDarkBlue kRGB(46, 57, 89)
#define kBlue kRGB(48, 69, 99)
#define kGreen kRGB(63, 182, 90)
#define kOrange kRGB(224, 172, 97)
#define kPink kRGB(238, 83, 151)
#define kPurple kRGB(193, 122, 240)
#define kRed kRGB(253,101,94)

#pragma mark font definition
//@"HelveticaNeue"
//@"HelveticaNeue-Thin"
//[UIFont boldSystemFontOfSize:x]
#define kBoldSystemFont(x) [UIFont fontWithName:@"HelveticaNeue" size:x]//HelveticaNeue-UltraLight
#define kNumberFontType(x) [UIFont fontWithName:@"HelveticaNeue-Thin" size:x]//[UIFont fontWithName:@"Heiti SC" size:x]
#define kNavFont(x) [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:x]

#pragma mark -- system definition
#define IOS_7_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0)
#define IOS_8_OR_LATER    ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)

#define WeakSelf(weakSelf)  __weak __typeof(&*self)weakSelf = self
#define WEAKSELF  typeof(self) __weak weakSelf=self;


#pragma mark nslog definition
#ifdef DEBUG
#define DLog(...) NSLog(__VA_ARGS__)

#else
#define DLog(...)
#endif

#pragma main thread definition
#define kMainQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif

#endif /* SmallVideoHeader_h */
