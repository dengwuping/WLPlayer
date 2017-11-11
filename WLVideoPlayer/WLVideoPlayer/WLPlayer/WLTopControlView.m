//
//  WLTopControlView.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/9.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "WLTopControlView.h"
#import "WLPlayerHeader.h"

@interface WLTopControlView ()
//返回按钮
@property (nonatomic,strong) UIButton *backButton;
//视频标题
@property (nonatomic,strong) UILabel *videoTitle;

@end

@implementation WLTopControlView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
        [self makeSubviewsConstraints];
        [self setupTargetAction];
    }
    return self;
}
//设置约束
- (void)makeSubviewsConstraints {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(@20);
        make.width.and.height.equalTo(@30);
    }];
    [self.videoTitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.backButton.mas_centerY);
        make.left.equalTo(self.backButton.mas_right).offset(10);
    }];
}

//设置点击事件
- (void)setupTargetAction {
    @weakify(self);
    [[self.backButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
       //点击了返回按钮
        @strongify(self);
        NSLog(@"点击了返回按钮");
        if (self.topControlDelegate && [self.topControlDelegate respondsToSelector:@selector(wl_topControlView:didClickBack:)]) {
            [self.topControlDelegate wl_topControlView:self didClickBack:self.backButton];
        }
    }];
}

-(UIButton *)backButton{
    if (!_backButton){
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setBackgroundImage:[UIImage imageNamed:@"WLPlayer_back"] forState:UIControlStateNormal];
        [self addSubview:_backButton];
    }
    return _backButton;
}
-(UILabel *) videoTitle{
    if (!_videoTitle){
        _videoTitle = [[UILabel alloc] init];
        _videoTitle.textColor = [UIColor whiteColor];
        _videoTitle.font = [UIFont systemFontOfSize:15];
        _videoTitle.text = @"这里是视频标题";
        [self addSubview:_videoTitle];
    }
    return _videoTitle;
}
@end
