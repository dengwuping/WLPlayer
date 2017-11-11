//
//  ViewController.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/3.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "ViewController.h"
#import <Masonry.h>
#import <ReactiveCocoa.h>
#import "WLPlayerController.h"

@interface ViewController ()
@property (nonatomic,strong) UIButton *presentButton;
//push进入的控制器
@property (nonatomic,strong) UIButton *pushButton;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.presentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view.mas_centerX);
        make.top.equalTo(self.view.mas_top).offset(100);
        make.width.equalTo(@300);
        make.height.equalTo(@40);
    }];
    [self.pushButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.presentButton.mas_bottom).offset(50);
        make.width.and.height.and.centerX.equalTo(self.presentButton);
    }];
    @weakify(self);
    [[self.presentButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        WLPlayerController *playerC = [[WLPlayerController alloc] init];
        [self presentViewController:playerC animated:YES completion:nil];
    }];
    [[self.pushButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        WLPlayerController *playerC = [[WLPlayerController alloc] init];
        [self.navigationController pushViewController:playerC animated:YES];
    }];
}
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

-(UIButton *)presentButton{
    if (!_presentButton){
        _presentButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_presentButton setTitle:@"present进入播放界面" forState:UIControlStateNormal];
        _presentButton.backgroundColor = [UIColor blackColor];
        [_presentButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _presentButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.view addSubview:_presentButton];
    }
    return _presentButton;
}
-(UIButton *)pushButton{
    if (!_pushButton){
        _pushButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_pushButton setTitle:@"push进入播放界面" forState:UIControlStateNormal];
        _pushButton.backgroundColor = [UIColor blackColor];
        [_pushButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _pushButton.titleLabel.font = [UIFont systemFontOfSize:16];
        [self.view addSubview:_pushButton];
    }
    return _pushButton;
}

@end
