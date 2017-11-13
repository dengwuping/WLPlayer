//
//  WLSkipView.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/13.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "WLSkipView.h"


@interface WLSkipView ()
//快进/快退图片
@property (nonatomic,strong) UIButton *fastButton;
//时间控件
@property (nonatomic,strong) UILabel *timeLabel;
//进度条
@property (nonatomic,strong) UIProgressView *fastProgress;
@end

@implementation WLSkipView

- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5].CGColor;
        [self makeSubviewsConstraints];
        [self setupSubjects];
    }
    return self;
}
//设置约束
- (void)makeSubviewsConstraints {
    [self.fastButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self).offset(5);
        make.width.and.height.equalTo(@30);
    }];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.fastButton.mas_bottom).offset(5);
        make.leading.and.trailing.equalTo(self).offset(0);
    }];
    [self.fastProgress mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.timeLabel.mas_bottom).offset(10);
        make.leading.equalTo(self).offset(10);
        make.trailing.equalTo(self).offset(-10);
    }];
}

//设置subjects
- (void)setupSubjects {
    @weakify(self);
    [self.skipSubject subscribeNext:^(NSDictionary *params) {
        @strongify(self);
        [self showSkipView];
        int proMin = [params[@"fastTime"] intValue] / 60;//当前秒
        int proSec = [params[@"fastTime"] intValue] % 60;//当前分钟
        // duration 总时长
        int durMin = [params[@"totalTime"] intValue] / 60;//总秒
        int durSec = [params[@"totalTime"] intValue] % 60;//总分钟
        self.timeLabel.text = [NSString stringWithFormat:@"%02d:%02d/%02d:%02d",proMin,proSec,durMin,durSec];
        [self.fastProgress setProgress:((float)[params[@"fastTime"] intValue] / [params[@"totalTime"] intValue]) animated:YES];
        self.fastButton.selected = [params[@"forward"] boolValue];
    }];
}

- (void)showSkipView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.hidden = NO;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideSkipeView) withObject:self afterDelay:5];
    }];
}
- (void)hideSkipeView {
    [UIView animateWithDuration:0.3 animations:^{
        self.hidden = YES;
    }];
}

-(RACReplaySubject *)skipSubject{
    if (!_skipSubject){
        _skipSubject = [[RACReplaySubject alloc] init];
    }
    return _skipSubject;
}
-(UIButton *)fastButton{
    if (!_fastButton){
        _fastButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_fastButton setImage:[UIImage imageNamed:@"WLPlayer_fast_backward"] forState:UIControlStateNormal];
        [_fastButton setImage:[UIImage imageNamed:@"WLPlayer_fast_forward"] forState:UIControlStateSelected];
        [self addSubview:_fastButton];
    }
    return _fastButton;
}
-(UILabel *)timeLabel{
    if (!_timeLabel){
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.textColor = [UIColor whiteColor];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        [self addSubview:_timeLabel];
    }
    return _timeLabel;
}
-(UIProgressView *)fastProgress{
    if (!_fastProgress){
        _fastProgress = [[UIProgressView alloc] init];
        _fastProgress.progressTintColor = [UIColor whiteColor];
        _fastProgress.trackTintColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        [self addSubview:_fastProgress];
    }
    return _fastProgress;
}

@end
