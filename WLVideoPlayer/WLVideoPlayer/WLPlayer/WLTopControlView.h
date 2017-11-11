//
//  WLTopControlView.h
//  WLVideoPlayer
//
//  Created by weil on 2017/11/9.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol WLTopControlViewDelegate <NSObject>
@optional
- (void)wl_topControlView:(UIView *)topControl didClickBack:(UIButton *)backBtn;
@end

@interface WLTopControlView : UIView
@property (nonatomic,weak) id<WLTopControlViewDelegate> topControlDelegate;
@end
