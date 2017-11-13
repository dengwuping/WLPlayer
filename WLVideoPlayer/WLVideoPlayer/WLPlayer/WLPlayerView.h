//
//  WLPlayerView.h
//  WLVideoPlayer
//
//  Created by weil on 2017/11/9.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLPlayerHeader.h"

@protocol WLPlayerViewDelegate <NSObject>
@optional
//点击返回按钮
- (void)wl_playerView:(UIView *)playerView triggerBackAction:(UIButton *)backBtn;
//暂停/开启播放
- (void)wl_playerView:(UIView *)playerView triggerPlayAction:(BOOL)play;
//全屏/退出全屏
- (void)wl_playerView:(UIView *)playerView triggerFullScreenAction:(BOOL)fullScreen;
//获取实时播放进度
- (void)wl_plaerView:(UIView *)playerView currentPlayTime:(long)currentTime totalTime:(long)totalTime;

@end

typedef enum : NSUInteger {
    WLPlayerStatePlaying,//正在播放
    WLPlayerStatePause,//暂停播放
    WLPlayerStateBuffering,//缓冲
    WLPlayerStateStop,//停止播放
    WLPlayerStateFailed//播放失败
} WLPlayerState;

typedef enum : NSUInteger {
    WLPanDirectionHorizontal,//水平移动
    WLPanDirectionVertical//竖直移动
} WLPanDirection;

@interface WLPlayerView : UIView

@property (nonatomic,weak) id<WLPlayerViewDelegate> playerViewDelegate;
@property (nonatomic,assign) WLPlayerState playerState;
//是否强制横屏
@property (nonatomic,assign) BOOL openLandscape;
- (void)autoPlayTheVideo;

- (instancetype)initWithURL:(NSURL *)videoURL;
- (void)play;
- (void)pause;
- (void)seekToTime:(CGFloat)time;
@end
