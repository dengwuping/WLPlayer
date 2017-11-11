//
//  WLBottomControlView.h
//  WLVideoPlayer
//
//  Created by weil on 2017/11/9.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WLBottomControlViewDelegate <NSObject>
@optional
//点击播放暂停按钮
- (void)wl_bottomControlView:(UIView *)bottomControl didClickPlayPauseBtn:(UIButton *)playPause;
//点击全屏按钮
- (void)wl_bottomControlView:(UIView *)bottomControl didClickFullScreenBtn:(UIButton *)fullScreen;

@end

@interface WLBottomControlView : UIView
@property (nonatomic,weak) id<WLBottomControlViewDelegate> bottomDelegate;
//更新播放进度
- (void)updateCurrenTime:(NSInteger)currentTime totalTime:(long)totalTime progress:(CGFloat)progressValue;
@end
