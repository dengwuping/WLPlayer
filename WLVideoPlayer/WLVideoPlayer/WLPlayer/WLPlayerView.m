//
//  WLPlayerView.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/9.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "WLPlayerView.h"
#import "WLPlayerControlView.h"
#import <MediaPlayer/MediaPlayer.h>

@interface WLPlayerView ()<WLPlayerControlViewDelegate,UIGestureRecognizerDelegate>
@property (nonatomic,strong) AVURLAsset *urlAsset;
@property (nonatomic,strong) AVPlayerItem *playerItem;
//播放图层
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
//当前播放地址
@property (nonatomic,strong) NSURL *videoURL;
//控制view
@property (nonatomic,strong) WLPlayerControlView *playerControl;
//点击手势
@property (nonatomic,strong) UITapGestureRecognizer *singleGesture;
//双击手势
@property (nonatomic,strong) UITapGestureRecognizer *doubleGesture;
//拖动手势
@property (nonatomic,strong) UIPanGestureRecognizer *panGesture;
//标识是否正在播放
@property (nonatomic,assign) BOOL isPlaying;//这个是为了双击手势下暂停或者播放视频用
//标识播放是否结束
@property (nonatomic,assign) BOOL playVideoEnd;
//定时器，为了方便更新进度条信息
@property (nonatomic,strong) id timeObserver;
//记录播放进度条上次的值
@property (nonatomic,assign) float sliderLastValue;
//快进的总时长
@property (nonatomic,assign) CGFloat skipTotalTime;
//移动的方向
@property (nonatomic,assign) WLPanDirection panDirection;
//标识是否正在屏幕上滑动
@property (nonatomic,assign) BOOL isDragging;
//标识是否是在调节音量
@property (nonatomic,assign) BOOL isChangingVolume;
//声音控制
@property (nonatomic,strong) UISlider *volumeSlider;
@end

@implementation WLPlayerView

- (instancetype)initWithURL:(NSURL *)videoURL {
    self = [super init];
    if (self) {
        self.videoURL = videoURL;
        [self setupPlayer];
        [self makeSubviewsConstraints];
        [self addGestureToSelf];
        [self addNotificationToSelf];
        [self addTimerObserver];
        [self setupDelegateResponser];
    }
    return self;
}
//设置约束
- (void)makeSubviewsConstraints {
    [self.playerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
}
//设置是否开启横屏
- (void)setOpenLandscape:(BOOL)openLandscape {
    _openLandscape = openLandscape;
    [[NSNotificationCenter defaultCenter] postNotificationName:wl_openLandscapeNotificationName object:nil userInfo:@{@"landscape":@(openLandscape)}];
    
}
//设置播放的item
- (void)setPlayerItem:(AVPlayerItem *)playerItem {
    if (_playerItem == playerItem) {
        return;
    }
    if (_playerItem) {
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
         [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
    }
}
//自动播放
- (void)autoPlayTheVideo {
    [self.player play];
    self.isPlaying = YES;
}
//设置播放器
- (void)setupPlayer {
    self.urlAsset = [AVURLAsset assetWithURL:self.videoURL];
    self.playerItem = [AVPlayerItem playerItemWithAsset:self.urlAsset];
    self.player = [[AVPlayer alloc] initWithPlayerItem:self.playerItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    self.backgroundColor = [UIColor blackColor];
    [self.layer addSublayer:self.playerLayer];
}
//播放
- (void)play {
    [self.player play];
    self.isPlaying = YES;
}
//暂停
- (void)pause {
    [self.player pause];
    self.isPlaying = NO;
}
//跳转到指定时间播放
- (void)seekToTime:(CGFloat)time {
    [self.player seekToTime:CMTimeMake(time, 1) toleranceBefore:CMTimeMake(1, 1) toleranceAfter:CMTimeMake(1, 1) completionHandler:^(BOOL finished) {
        
    }];
}
//添加手势
- (void)addGestureToSelf {
    //单击手势
    UITapGestureRecognizer *singleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleGesture:)];
    singleGesture.numberOfTapsRequired = 1;
    singleGesture.numberOfTouchesRequired = 1;
    singleGesture.delegate = self;
    [self addGestureRecognizer:singleGesture];
    self.singleGesture = singleGesture;
    //双击手势
    UITapGestureRecognizer *doubleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleGesture:)];
    doubleGesture.numberOfTapsRequired = 2;
    doubleGesture.numberOfTouchesRequired = 1;
    self.doubleGesture.delegate = self;
    [self addGestureRecognizer:doubleGesture];
    self.doubleGesture = doubleGesture;
    
    [singleGesture setDelaysTouchesBegan:YES];
    [doubleGesture setDelaysTouchesBegan:YES];
    [singleGesture requireGestureRecognizerToFail:doubleGesture];
}
//添加通知
- (void)addNotificationToSelf {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(progressSliderValueChanged:) name:wl_draggingSliderNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(endDraggingProgressSlider:) name:wl_endedDraggingSliderNotificationName object:nil];
}
//添加观察者
- (void)addTimerObserver {
    WLWeak;
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(1, 1) queue:nil usingBlock:^(CMTime time) {
        AVPlayerItem *currentItem = weakSelf.playerItem;
        NSArray *loadedRanges = currentItem.seekableTimeRanges;
        if (loadedRanges.count > 0 && currentItem.duration.timescale != 0) {
            NSInteger currentTime = (NSInteger)CMTimeGetSeconds([currentItem currentTime]);
            long totalTime = (long)currentItem.duration.value / currentItem.duration.timescale;
            CGFloat value = CMTimeGetSeconds([currentItem currentTime]) / totalTime;
            [[NSNotificationCenter defaultCenter] postNotificationName:wl_getCurrentPlayTimeNotificationName object:weakSelf.playerControl userInfo:@{@"currentTime":@(currentTime),@"totalTime":@(totalTime),@"value":@(value)}];
            if (weakSelf.playerViewDelegate && [weakSelf.playerViewDelegate respondsToSelector:@selector(wl_plaerView:currentPlayTime:totalTime:)]) {
                [weakSelf.playerViewDelegate wl_plaerView:weakSelf currentPlayTime:currentTime totalTime:totalTime];
            }
        }
    }];
}
#pragma mark - 获取系统音量
- (void)getSystemVolume {
    MPVolumeView *volumeView = [[MPVolumeView alloc] init];
    self.volumeSlider = nil;
    for (UIView *view in [volumeView subviews]) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            self.volumeSlider = (UISlider *)view;
            break;
        }
    }
}

#pragma mark - 设置代理响应事件
- (void)setupDelegateResponser {
    @weakify(self);
    [[self rac_signalForSelector:@selector(wl_playerControlView:didClickBack:) fromProtocol:@protocol(WLPlayerControlViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        //返回
        if (self.playerViewDelegate && [self.playerViewDelegate respondsToSelector:@selector(wl_playerView:triggerBackAction:)]) {
            [self.playerViewDelegate wl_playerView:self triggerBackAction:tuple.last];
        }
    }];
    [[self rac_signalForSelector:@selector(wl_playerControlView:didClickPlayPause:) fromProtocol:@protocol(WLPlayerControlViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        UIButton *playButton = tuple.last;
        if (playButton.selected) {
            [self pause];
        }else {
            [self play];
        }
        if (self.playerViewDelegate && [self.playerViewDelegate respondsToSelector:@selector(wl_playerView:triggerPlayAction:)]) {
            [self.playerViewDelegate wl_playerView:self triggerPlayAction:!playButton.selected];
        }
    }];
    [[self rac_signalForSelector:@selector(wl_playerControlView:didClickFullScreen:) fromProtocol:@protocol(WLPlayerControlViewDelegate)] subscribeNext:^(RACTuple *tuple) {
        @strongify(self);
        UIButton *fullScreen = tuple.last;
        //全屏，退出全屏
        if (self.playerViewDelegate && [self.playerViewDelegate respondsToSelector:@selector(wl_playerView:triggerFullScreenAction:)]) {
            [self.playerViewDelegate wl_playerView:self triggerFullScreenAction:fullScreen.selected];
        }
    }];
}

#pragma mark - 单击双击事件
- (void)singleGesture:(UITapGestureRecognizer *)gesture {
   //告诉控制view是隐藏还是显示
    [[NSNotificationCenter defaultCenter] postNotificationName:wl_singleTapGestureNotificationName object:self.playerControl];
}
- (void)doubleGesture:(UITapGestureRecognizer *)gesture {
    if (self.playVideoEnd) {//播放结束什么也不做
        return;
    }
    if (self.isPlaying) {
        [self pause];
    }else {
        [self play];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:wl_doubleTapGestureNotificationName object:nil userInfo:@{@"play":@(self.isPlaying)}];
    if (self.playerViewDelegate && [self.playerViewDelegate respondsToSelector:@selector(wl_playerView:triggerPlayAction:)]) {
        [self.playerViewDelegate wl_playerView:self triggerPlayAction:self.isPlaying];
    }
}
- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    CGPoint locationPoint = [gesture locationInView:self];
    CGPoint veloctyPoint = [gesture velocityInView:self];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan://开始移动
        {
            CGFloat x = fabs(veloctyPoint.x);
            CGFloat y = fabs(veloctyPoint.y);
            if (x > y) {//水平移动
                self.panDirection = WLPanDirectionHorizontal;
                CMTime time = self.player.currentTime;
                self.skipTotalTime = time.value / time.timescale;
            }else if (x < y) {//垂直移动
                self.panDirection = WLPanDirectionVertical;
                if (locationPoint.x > self.bounds.size.width * 0.5) {
                    //右半屏控制声音
                    self.isChangingVolume = YES;
                }else {
                    //左半屏控制亮度
                    self.isChangingVolume = NO;
                }
            }
        }
            break;
        case UIGestureRecognizerStateChanged:
        {
            switch (self.panDirection) {
                case WLPanDirectionHorizontal:
                    //水平移动
                    [self panGestureMovedToHorizontal:veloctyPoint.x];
                    break;
                    case WLPanDirectionVertical:
                    //竖直移动
                    
                    break;
                default:
                    break;
            }
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            switch (self.panDirection) {
                case WLPanDirectionHorizontal:
                    //水平移动
                    self.isPlaying = YES;
                    [self seekToTime:self.skipTotalTime];
                    self.skipTotalTime = 0;
                    break;
                    case WLPanDirectionVertical:
                {
                    //垂直移动
                    [self panGestureMovedToVertical:veloctyPoint.y];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}
//水平移动
- (void)panGestureMovedToHorizontal:(CGFloat)value {
    //每次需要快进的时间
    self.skipTotalTime += value / 200;
    CMTime totalTime = self.playerItem.duration;
    CGFloat totalMovieDuration = (CGFloat)totalTime.value / totalTime.timescale;
    if (self.skipTotalTime > totalMovieDuration) {
        self.skipTotalTime = totalMovieDuration;
    }
    if (self.skipTotalTime < 0) {
        self.skipTotalTime = 0;
    }
    BOOL style = false;
    if (value > 0) { style = YES; }
    if (value < 0) { style = NO; }
    if (value == 0) {
        return;
    }
    self.isDragging = YES;
    //改变进度条的值
    CGFloat progressValue = self.skipTotalTime / totalMovieDuration;
    [[NSNotificationCenter defaultCenter] postNotificationName:wl_skipPlayTimeNotificationName object:self.playerControl userInfo:@{@"currentTime":@(self.skipTotalTime),@"totalTime":@(totalMovieDuration),@"value":@(progressValue),@"forward":@(style)}];
}
//竖直移动
- (void)panGestureMovedToVertical:(CGFloat)value {
    self.isChangingVolume ? (self.volumeSlider.value -= value / 10000) : ([UIScreen mainScreen].brightness -= value / 10000);
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        
    }
    return YES;
}
#pragma mark - KVO事件处理
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if (object == self.player.currentItem) {
        if ([keyPath isEqualToString:@"status"]) {
            if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
                self.playerState = WLPlayerStatePlaying;
                if (!self.panGesture) {
                    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
                    panGesture.delegate = self;
                    panGesture.maximumNumberOfTouches = 1;
                    [panGesture setDelaysTouchesBegan:YES];
                    [panGesture setDelaysTouchesEnded:YES];
                    [self addGestureRecognizer:panGesture];
                    self.panGesture = panGesture;
                }
            }else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
                self.playerState = WLPlayerStateFailed;
            }
        }else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
            NSTimeInterval timeInterval = [self availableDuration];
            CMTime duration = self.playerItem.duration;
            CGFloat totalDuration = CMTimeGetSeconds(duration);
            [[NSNotificationCenter defaultCenter] postNotificationName:wl_updateCacheProgressNotificationName object:nil userInfo:@{@"value":@(timeInterval / totalDuration)}];
        }
    }
}

- (NSTimeInterval)availableDuration {
    NSArray *loadedTimeRanges = [[self.player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;

}
#pragma mark - 通知处理事件
- (void)progressSliderValueChanged:(NSNotification *)notify {
    UISlider *slider = notify.userInfo[@"slider"] ;
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        CGFloat value = slider.value - self.sliderLastValue;
        if (value == 0) {
            return;
        }
        self.sliderLastValue = value;
        CGFloat totalTime = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        if (totalTime <= 0) {
            slider.value = 0;
        }
    }else {
        slider.value = 0;
    }
}
- (void)endDraggingProgressSlider:(NSNotification *)notify {
    UISlider *slider = notify.userInfo[@"slider"] ;
    if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
        self.isPlaying = YES;
        // 视频总时间长度
        CGFloat total   = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
        //计算出拖动的当前秒数
        NSInteger dragedSeconds = floorf(total * slider.value);
        [self seekToTime:dragedSeconds];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.playerItem removeObserver:self forKeyPath:@"status"];
    [self.playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
}

-(WLPlayerControlView *)playerControl{
    if (!_playerControl){
        _playerControl = [[WLPlayerControlView alloc] init];
        _playerControl.playerControlDelegate = self;
        [self addSubview:_playerControl];
    }
    return _playerControl;
}

@end
