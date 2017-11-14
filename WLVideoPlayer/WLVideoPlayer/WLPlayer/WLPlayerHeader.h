//
//  WLPlayerHeader.h
//  WLVideoPlayer
//
//  Created by weil on 2017/11/3.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "UIViewController+WLOrientation.h"

#define WLWeak  __weak typeof(self) weakSelf = self

//单击手势的通知
#define wl_singleTapGestureNotificationName @"SingleTapGestureNotification"
//双击手势的通知
#define wl_doubleTapGestureNotificationName @"DoubleTapGestureNotification"
//实时监控获取播放时长的通知
#define wl_getCurrentPlayTimeNotificationName @"GetCurrentPlayTimeNotification"
//更新缓冲进度
#define wl_updateCacheProgressNotificationName @"UpdateCacheProgressNotification"
//正在拖动进度条
#define wl_draggingSliderNotificationName @"DraggingSliderNotification"
//结束拖动进度条
#define wl_endedDraggingSliderNotificationName @"EndedDraggingSliderNotification"
//是否开启强制横屏模式
#define wl_openLandscapeNotificationName @"OpenLandscapeNotification"
//快进操作
#define wl_skipPlayTimeNotificationName @"SkipPlayTimeNotification"
//改变亮度操作
#define wl_changeBrightnessNotificationName @"ChangeBrightnessNotification"

#define wl_navigationBarHeight [UIScreen mainScreen].bounds.size.height == 812 ? 88 : 64
#define wl_kScreenW [UIScreen mainScreen].bounds.size.width
#define wl_kScreenH [UIScreen mainScreen].bounds.size.height
