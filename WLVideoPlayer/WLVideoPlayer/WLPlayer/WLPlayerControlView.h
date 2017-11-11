//
//  WLPlayerControlView.h
//  WLVideoPlayer
//
//  Created by weil on 2017/11/9.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WLPlayerControlViewDelegate <NSObject>
@optional
//返回按钮
- (void)wl_playerControlView:(UIView *)playerControl didClickBack:(UIButton *)backBtn;
//暂停/播放
- (void)wl_playerControlView:(UIView *)playerControl didClickPlayPause:(UIButton *)playPause;
//全屏/小屏
- (void)wl_playerControlView:(UIView *)playerControl didClickFullScreen:(UIButton *)fullScreen;

@end

@interface WLPlayerControlView : UIView
@property (nonatomic,weak) id<WLPlayerControlViewDelegate> playerControlDelegate;
@end
