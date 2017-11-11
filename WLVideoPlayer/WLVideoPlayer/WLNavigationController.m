//
//  WLNavigationController.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/10.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "WLNavigationController.h"

@interface WLNavigationController ()

@end

@implementation WLNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    
    viewController.hidesBottomBarWhenPushed = YES;
    [super pushViewController:viewController animated:animated];
}

@end
