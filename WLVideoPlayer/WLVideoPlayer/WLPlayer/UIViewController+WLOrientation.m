//
//  UIViewController+WLOrientation.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/11.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "UIViewController+WLOrientation.h"

@implementation UIViewController (WLOrientation)
- (void)makeScreenToLandscape {
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationLandscapeRight;
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    if (self.navigationController) {
        self.view.transform = CGAffineTransformMakeRotation(M_PI*(90)/180.0);
        self.view.frame = CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }else {
        self.view.transform = CGAffineTransformIdentity;
        self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }
    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] postNotificationName:wl_makeScreenToLandscapeNotificationName object:nil];
}
- (void)makeScreenToPortrait {
    [UIApplication sharedApplication].statusBarOrientation = UIInterfaceOrientationPortrait;
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    if (self.navigationController) {
        self.view.transform = CGAffineTransformIdentity;
        self.view.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    }else {
        self.view.transform = CGAffineTransformMakeRotation(-M_PI*(90)/180.0);
        self.view.frame = CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    }
    [UIView commitAnimations];
    [[NSNotificationCenter defaultCenter] postNotificationName:wl_makeScreenToPortraitNotificationName object:nil];
}



@end
