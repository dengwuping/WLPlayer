//
//  UIViewController+WLOrientation.h
//  WLVideoPlayer
//
//  Created by weil on 2017/11/11.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
//横屏
#define wl_makeScreenToLandscapeNotificationName @"MakeScreenToLandScape"
//竖屏
#define wl_makeScreenToPortraitNotificationName @"MakeScreenToPortrait"

@interface UIViewController (WLOrientation)
- (void)makeScreenToLandscape;
- (void)makeScreenToPortrait;
@end
