//
//  UIViewController+WLOrientation.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/11.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "UIViewController+WLOrientation.h"

@implementation UIViewController (WLOrientation)
- (void)makeLandscapeWithPush {
//    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    self.navigationController.view.transform = CGAffineTransformMakeRotation(M_PI*(90)/180.0);
    self.navigationController.view.bounds = CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    [UIView commitAnimations];
}
- (void)makePortraitWithPush {
//     [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    self.navigationController.view.transform = CGAffineTransformIdentity;
    self.navigationController.view.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [UIView commitAnimations];
}

- (void)makeLandscapeWithPresent {
//     [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationLandscapeRight];
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    self.view.transform = CGAffineTransformIdentity;
    self.view.bounds = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [UIView commitAnimations];
}

- (void)makePortraitWithPresent {
//     [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait];
    CGFloat duration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:duration];
    self.view.transform = CGAffineTransformMakeRotation(-M_PI*(90)/180.0);
    self.view.bounds = CGRectMake(0, 0,  [UIScreen mainScreen].bounds.size.height, [UIScreen mainScreen].bounds.size.width);
    [UIView commitAnimations];
}
- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return  UIStatusBarStyleDefault;
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}



@end
