//
//  UIViewController+WLOrientation.h
//  WLVideoPlayer
//
//  Created by weil on 2017/11/11.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (WLOrientation)
- (void)makeLandscapeWithPush;
- (void)makePortraitWithPush;
- (void)makePortraitWithPresent;
- (void)makeLandscapeWithPresent;
@end
