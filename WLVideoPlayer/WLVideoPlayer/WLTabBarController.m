//
//  WLTabBarController.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/10.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "WLTabBarController.h"
#import "WLNavigationController.h"
#import "ViewController.h"

@interface WLTabBarController ()

@end

@implementation WLTabBarController
- (instancetype)init {
    self =[super init];
    if (self) {
        self.selectedIndex = 0;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    ViewController *vc = [[ViewController alloc] init];
    vc.title = @"首页";
    WLNavigationController *nav = [[WLNavigationController alloc] initWithRootViewController:vc];
    [self addChildViewController:nav];
}

@end
