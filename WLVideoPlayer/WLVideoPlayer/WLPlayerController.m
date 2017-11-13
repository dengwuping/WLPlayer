//
//  WLPlayerController.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/10.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "WLPlayerController.h"
#import "WLPlayerView.h"

@interface WLPlayerController ()<WLPlayerViewDelegate>
//播放视图
@property (nonatomic,strong) WLPlayerView *playerView;
@end

@implementation WLPlayerController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:YES];
    }
}
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.navigationController) {
        [self.navigationController setNavigationBarHidden:NO];
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.playerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [self setupDelegateAction];
    [self.playerView autoPlayTheVideo];
    if (self.navigationController) {//如果是push过来的，先进行横屏设置
        [self makeLandscapeWithPush];
    }
}

//设置代理事件
- (void)setupDelegateAction {
    @weakify(self);
    [[self rac_signalForSelector:@selector(wl_playerView:triggerBackAction:) fromProtocol:@protocol(WLPlayerViewDelegate)] subscribeNext:^(id x) {
        @strongify(self);
        if (self.navigationController) {
            [self makePortraitWithPush];
            [self.navigationController popViewControllerAnimated:YES];
        }else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }];
    [[self rac_signalForSelector:@selector(wl_plaerView:currentPlayTime:totalTime:) fromProtocol:@protocol(WLPlayerViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        NSLog(@"当前播放时间： %ld,  播放总时间： %ld ",[tuple[1] longValue],[tuple[2] longValue]);
    }];
    [[self rac_signalForSelector:@selector(wl_playerView:triggerFullScreenAction:) fromProtocol:@protocol(WLPlayerViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        BOOL fullScreen = [tuple.last boolValue];
        if (fullScreen) {
            if (self.navigationController) {
                [self makeLandscapeWithPush];
            }else {
                [self makeLandscapeWithPresent];
            }
        }else {
            if (self.navigationController) {
                [self makePortraitWithPush];
            }else {
                [self makePortraitWithPresent];
            }
        }
    }];
    [[self rac_signalForSelector:@selector(wl_playerView:triggerPlayAction:) fromProtocol:@protocol(WLPlayerViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        NSLog(@"%@",[tuple.last boolValue] ? @"开始播放" : @"暂停播放");
    }];
}

// 支持哪些屏幕方向
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}
- (BOOL)shouldAutorotate {
    return NO;
}

- (void)dealloc {
    self.playerView.playerViewDelegate = nil;
}

-(WLPlayerView *)playerView{
    if (!_playerView){
        _playerView = [[WLPlayerView alloc] initWithURL:[NSURL URLWithString:@"http://baobab.wdjcdn.com/1456117847747a_x264.mp4"]];
        _playerView.playerViewDelegate = self;
        _playerView.openLandscape = YES;
        [self.view addSubview:_playerView];
    }
    return _playerView;
}
@end
