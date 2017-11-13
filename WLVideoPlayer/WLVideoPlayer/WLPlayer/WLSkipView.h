//
//  WLSkipView.h
//  WLVideoPlayer
//
//  Created by weil on 2017/11/13.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLPlayerHeader.h"
//快进视图
@interface WLSkipView : UIView
@property (nonatomic,strong) RACReplaySubject *skipSubject;
@end
