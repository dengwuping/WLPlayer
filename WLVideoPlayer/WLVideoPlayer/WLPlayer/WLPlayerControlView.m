//
//  WLPlayerControlView.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/9.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "WLPlayerControlView.h"
#import "WLTopControlView.h"
#import "WLBottomControlView.h"
#import "WLPlayerHeader.h"
#import "WLSkipView.h"

@interface WLPlayerControlView ()<WLTopControlViewDelegate,WLBottomControlViewDelegate>
//顶部视图
@property (nonatomic,strong) WLTopControlView *topControl;
//底部视图
@property (nonatomic,strong) WLBottomControlView *bottomControl;
//标识是否显示控制视图
@property (nonatomic,assign) BOOL showingPlayerControl;
//快进/快退
@property (nonatomic,strong) WLSkipView *skipView;
@end

@implementation WLPlayerControlView
- (instancetype)init {
   self = [super init];
    if (self) {
        self.showingPlayerControl = NO;
        [self makeSubviewsConstraints];
        self.alpha = 0.0;
        [self addNotificationToSelf];
        [self setupDelegateAction];
    }
    return self;
}
//设置约束
- (void)makeSubviewsConstraints {
    [self.topControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.and.top.equalTo(self);
        make.height.equalTo(@(wl_navigationBarHeight));
    }];
    [self.bottomControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.and.bottom.equalTo(self);
        make.height.equalTo(@50);
    }];
    [self.skipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
        make.width.equalTo(@125);
        make.height.equalTo(@80);
    }];
    
}
//添加通知
- (void)addNotificationToSelf {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(singleNotificationAction) name:wl_singleTapGestureNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getCurrentPlayTime:) name:wl_getCurrentPlayTimeNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skipPlayTime:) name:wl_skipPlayTimeNotificationName object:nil];
}
//设置代理事件
- (void)setupDelegateAction {
    @weakify(self);
    [[self rac_signalForSelector:@selector(wl_topControlView:didClickBack:) fromProtocol:@protocol(WLTopControlViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        if (self.playerControlDelegate && [self.playerControlDelegate respondsToSelector:@selector(wl_playerControlView:didClickBack:)]) {
            [self.playerControlDelegate wl_playerControlView:self didClickBack:tuple.last];
        }
    }];
    [[self rac_signalForSelector:@selector(wl_bottomControlView:didClickPlayPauseBtn:) fromProtocol:@protocol(WLBottomControlViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        if (self.playerControlDelegate && [self.playerControlDelegate respondsToSelector:@selector(wl_playerControlView:didClickPlayPause:)]) {
            [self.playerControlDelegate wl_playerControlView:self didClickPlayPause:tuple.last];
        }
    }];
    [[self rac_signalForSelector:@selector(wl_bottomControlView:didClickFullScreenBtn:) fromProtocol:@protocol(WLBottomControlViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        if (self.playerControlDelegate && [self.playerControlDelegate respondsToSelector:@selector(wl_playerControlView:didClickFullScreen:)]) {
            [self.playerControlDelegate wl_playerControlView:self didClickFullScreen:tuple.last];
        }
    }];
}

#pragma mark - 处理通知事件
- (void)singleNotificationAction {
    if (self.showingPlayerControl) {
        [self hidePlayerControl];
    }else {
        [self showPlayerControl];
    }
}
- (void)getCurrentPlayTime:(NSNotification *)notify {
    NSDictionary *videoData = notify.userInfo;
    NSInteger currentTime = [videoData[@"currentTime"] integerValue];
    long totalTime = [videoData[@"totalTime"] longValue];
    CGFloat value = (CGFloat)[videoData[@"value"] floatValue];
    //更新时间和进度条
    [self.bottomControl updateCurrenTime:currentTime totalTime:totalTime progress:value];
}
- (void)skipPlayTime:(NSNotification *)notify {
    NSDictionary *videoData = notify.userInfo;
    NSInteger currentTime = [videoData[@"currentTime"] integerValue];
    long totalTime = [videoData[@"totalTime"] longValue];
    CGFloat value = (CGFloat)[videoData[@"value"] floatValue];
    BOOL forward = [videoData[@"forward"] boolValue];
    //更新时间和进度条
    [self.bottomControl updateCurrenTime:currentTime totalTime:totalTime progress:value];
    [self showPlayerControl];
    [self.skipView.skipSubject sendNext:@{@"forward":@(forward),@"fastTime":@(currentTime),@"totalTime":@(totalTime)}];
}
//显示控制视图
- (void)showPlayerControl {
    [self playerCancelAutoFadeOutControlView];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.showingPlayerControl = YES;
        [self performSelector:@selector(hidePlayerControl) withObject:self afterDelay:5];
    }];
}
//隐藏控制视图
- (void)hidePlayerControl {
    [self playerCancelAutoFadeOutControlView];
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.showingPlayerControl = NO;
    }];
}
/**
 *  取消延时隐藏controlView的方法
 */
- (void)playerCancelAutoFadeOutControlView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
-(WLTopControlView *)topControl{
    if (!_topControl){
        _topControl = [[WLTopControlView alloc] init];
        _topControl.topControlDelegate = self;
        [self addSubview:_topControl];
    }
    return _topControl;
}
-(WLBottomControlView *)bottomControl{
    if (!_bottomControl){
        _bottomControl = [[WLBottomControlView alloc] init];
        _bottomControl.bottomDelegate = self;
        [self addSubview:_bottomControl];
    }
    return _bottomControl;
}
-(WLSkipView *)skipView{
    if (!_skipView){
        _skipView = [[WLSkipView alloc] init];
        _skipView.hidden = YES;
        [self addSubview:_skipView];
    }
    return _skipView;
}
@end
