//
//  WLBottomControlView.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/9.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "WLBottomControlView.h"
#import "WLPlayerHeader.h"

@interface WLBottomControlView ()
//暂停或者播放控制按钮
@property (nonatomic,strong) UIButton *playPauseBtn;
//全屏按钮
@property (nonatomic,strong) UIButton *fullScreenBtn;
//当前播放时间
@property (nonatomic,strong) UILabel *currentTimeLabel;
//缓冲进度条
@property (nonatomic,strong) UIProgressView *cacheProgress;
//播放进度条
@property (nonatomic,strong) UISlider *playSlider;
//总共播放时间
@property (nonatomic,strong) UILabel *totalTimeLabel;
//标识是否是拖拽进度条
@property (nonatomic,assign) BOOL isDragging;
@end

@implementation WLBottomControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
        [self makeSubviewsConstraints];
        [self setupTargetAction];
        [self addNotificationToSelf];
        [self addPlaySliderAction];
    }
    return self;
}

//设置约束
- (void)makeSubviewsConstraints {
    [self.playPauseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self).offset(20);
        make.height.with.equalTo(@40);
    }];
//    [self.fullScreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerY.equalTo(self.mas_centerY);
//        make.right.equalTo(self).offset(-20);
//        make.height.and.with.equalTo(@40);
//    }];
    [self.currentTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.playPauseBtn.mas_right).offset(10);
        make.width.equalTo(@40);
    }];
    [self.totalTimeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.mas_right).offset(-20);
        make.width.equalTo(@40);
    }];
    [self.cacheProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.currentTimeLabel.mas_right).offset(10);
        make.right.equalTo(self.totalTimeLabel.mas_left).offset(-10);
    }];
    [self.playSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.cacheProgress);
    }];
}

//设置事件
- (void)setupTargetAction {
    @weakify(self);
    [[self.playPauseBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.playPauseBtn.selected = !self.playPauseBtn.selected;
        NSLog(@"点击了播放暂停按钮");
        if (self.bottomDelegate && [self.bottomDelegate respondsToSelector:@selector(wl_bottomControlView:didClickPlayPauseBtn:)]) {
            [self.bottomDelegate wl_bottomControlView:self didClickPlayPauseBtn:self.playPauseBtn];
        }
    }];
    [[self.fullScreenBtn rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        @strongify(self);
        self.fullScreenBtn.selected = !self.fullScreenBtn.selected;
        NSLog(@"点击了全屏按钮");
        if (self.bottomDelegate && [self.bottomDelegate respondsToSelector:@selector(wl_bottomControlView:didClickFullScreenBtn:)]) {
            [self.bottomDelegate wl_bottomControlView:self didClickFullScreenBtn:self.fullScreenBtn];
        }
    }];
}

//添加通知
- (void)addNotificationToSelf {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateCacheProgress:) name:wl_updateCacheProgressNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(openLandscape:) name:wl_openLandscapeNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(doubleTapGesture:) name:wl_doubleTapGestureNotificationName object:nil];
}
//添加滑动或者点击进度条事件
- (void)addPlaySliderAction {
    [self.playSlider addTarget:self action:@selector(beginTouchSlider:) forControlEvents:UIControlEventTouchDown];
    [self.playSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.playSlider addTarget:self action:@selector(endedTouchSlider:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
}

//更新进度条信息
- (void)updateCurrenTime:(NSInteger)currentTime totalTime:(long)totalTime progress:(CGFloat)progressValue {
    // 当前时长进度progress
    NSInteger proMin = currentTime / 60;//当前秒
    NSInteger proSec = currentTime % 60;//当前分钟
    // duration 总时长
    NSInteger durMin = totalTime / 60;//总秒
    NSInteger durSec = totalTime % 60;//总分钟
    if (!self.isDragging) {
        // 更新slider
        self.playSlider.value           = progressValue;
        // 更新当前播放时间
        self.currentTimeLabel.text       = [NSString stringWithFormat:@"%02zd:%02zd", proMin, proSec];
    }
    // 更新总时间
    self.totalTimeLabel.text = [NSString stringWithFormat:@"%02zd:%02zd", durMin, durSec];
}

#pragma mark - 处理通知事件
- (void)updateCacheProgress:(NSNotification *)notify {
    [self.cacheProgress setProgress:[notify.userInfo[@"value"] floatValue] animated:YES];
}
- (void)openLandscape:(NSNotification *)notify {
    BOOL landscape = [notify.userInfo[@"landscape"] boolValue];
    self.fullScreenBtn.selected = landscape;
}
- (void)doubleTapGesture:(NSNotification *)notify {
    self.playPauseBtn.selected = ![notify.userInfo[@"play"] boolValue];
}
#pragma mark - 处理进度条点击事件
- (void)beginTouchSlider:(UISlider *)slider {
    
}
- (void)sliderValueChanged:(UISlider *)slider {
    [[NSNotificationCenter defaultCenter] postNotificationName:wl_draggingSliderNotificationName object:nil userInfo:@{@"slider":slider}];
}
- (void)endedTouchSlider:(UISlider *)slider {
    [[NSNotificationCenter defaultCenter] postNotificationName:wl_endedDraggingSliderNotificationName object:nil userInfo:@{@"slider":slider}];
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(UIButton *)playPauseBtn{
    if (!_playPauseBtn){
        _playPauseBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_playPauseBtn setImage:[UIImage imageNamed:@"WLPlayer_pause"] forState:UIControlStateNormal];
        [_playPauseBtn setImage:[UIImage imageNamed:@"WLPlayer_play"] forState:UIControlStateSelected];
        [self addSubview:_playPauseBtn];
    }
    return _playPauseBtn;
}
-(UIButton *)fullScreenBtn{
    if (!_fullScreenBtn){
        _fullScreenBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"WLPlayer_fullscreen"] forState:UIControlStateNormal];
        [_fullScreenBtn setImage:[UIImage imageNamed:@"WLPlayer_shrinkscreen"] forState:UIControlStateSelected];
        [self addSubview:_fullScreenBtn];
    }
    return _fullScreenBtn;
}
-(UILabel *)currentTimeLabel{
    if (!_currentTimeLabel){
        _currentTimeLabel = [[UILabel alloc] init];
        _currentTimeLabel.font = [UIFont systemFontOfSize:12];
        _currentTimeLabel.textColor = [UIColor whiteColor];
        _currentTimeLabel.text = @"00:00:00";
        _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_currentTimeLabel];
    }
    return _currentTimeLabel;
}
-(UIProgressView *)cacheProgress{
    if (!_cacheProgress){
        _cacheProgress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        _cacheProgress.progressTintColor = [UIColor whiteColor];
        _cacheProgress.tintColor = [UIColor clearColor];
        [self addSubview:_cacheProgress];
    }
    return _cacheProgress;
}
-(UISlider *)playSlider{
    if (!_playSlider){
        _playSlider = [[UISlider alloc] init];
        _playSlider.minimumTrackTintColor = [UIColor whiteColor];
        _playSlider.maximumTrackTintColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:0.5];
        _playSlider.value = 0.0;
        _playSlider.maximumValue = 1.0;
        _playSlider.minimumValue = 0.0;
        [_playSlider setThumbImage:[UIImage imageNamed:@"WLPlayer_slider"] forState:UIControlStateNormal];
        [self addSubview:_playSlider];
    }
    return _playSlider;
}
-(UILabel *)totalTimeLabel{
    if (!_totalTimeLabel){
        _totalTimeLabel = [[UILabel alloc] init];
        _totalTimeLabel.font = [UIFont systemFontOfSize:12];
        _totalTimeLabel.textColor = [UIColor whiteColor];
        _totalTimeLabel.text = @"00:00:00";
        _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_totalTimeLabel];
    }
    return _totalTimeLabel;
}
@end

