//
//  WLBrightnessView.m
//  WLVideoPlayer
//
//  Created by weil on 2017/11/13.
//  Copyright © 2017年 liwei. All rights reserved.
//

#import "WLBrightnessView.h"

@interface WLBrightnessView ()
//背景图片
@property (nonatomic,strong) UIImageView *brightImageView;
//标题
@property (nonatomic,strong) UILabel *titleLabel;
//亮度条数组
@property (nonatomic,strong) NSMutableArray *brightTipArray;

@end

@implementation WLBrightnessView

+ (instancetype)sharedInstance {
    static WLBrightnessView *brightnessView;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        brightnessView = [[WLBrightnessView alloc] init];
    });
    return brightnessView;
}
- (instancetype)init {
    self = [super init];
    if (self) {
        self.layer.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.97].CGColor;
        self.alpha = 0.0;
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
        [self makeSubviewsConstraints];
        [[UIScreen mainScreen] addObserver:self
                                forKeyPath:@"brightness"
                                   options:NSKeyValueObservingOptionNew context:NULL];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeBrightness) name:wl_changeBrightnessNotificationName object:nil];
    }
    return self;
}
//添加约束
- (void)makeSubviewsConstraints {
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.mas_top).offset(5);
        make.left.and.right.equalTo(self);
    }];
    [self.brightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(5);
        make.width.and.height.equalTo(@76);
    }];
    [self.brightTipArray mas_distributeViewsAlongAxis:MASAxisTypeHorizontal withFixedSpacing:2 leadSpacing:20 tailSpacing:20];
    [self.brightTipArray mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.brightImageView.mas_bottom).offset(5);
        make.height.equalTo(@5);
    }];
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    
    CGFloat brightness = [change[@"new"] floatValue];
    [self updateBrightnessView:brightness];
    [self showBrightnessView];
}


- (void)showBrightnessView {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self.superview bringSubviewToFront:self];
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.97;
    } completion:^(BOOL finished) {
        [self performSelector:@selector(hideBrightnessView) withObject:self afterDelay:3.0];
    }];
}
- (void)hideBrightnessView {
    [UIView animateWithDuration:0.3 animations:^{
        self.alpha = 0.0;
    }];
}
- (void)updateBrightnessView:(CGFloat)brightness {
    CGFloat stage = 1 / 15.0;
    NSInteger level = brightness / stage;
    
    for (int i = 0; i < self.brightTipArray.count; i++) {
        UIImageView *img = self.brightTipArray[i];
        if (i <= level) {
            img.alpha = 1.0;
        } else {
            img.alpha = 0.3;
        }
    }
}
- (void)changeBrightness {
    [self showBrightnessView];
}
- (void)dealloc {
    [self hideBrightnessView];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[UIScreen mainScreen] removeObserver:self forKeyPath:@"brightness"];
}

-(UIImageView *)brightImageView{
    if (!_brightImageView){
        _brightImageView = [[UIImageView alloc] init];
        _brightImageView.image = [UIImage imageNamed:@"WLPlayer_brightness"];
        [self addSubview:_brightImageView];
    }
    return _brightImageView;
}
-(NSMutableArray *)brightTipArray{
    if (!_brightTipArray){
        _brightTipArray = [NSMutableArray array];
        for (int i = 0; i < 16; i++) {
            UIImageView *image = [UIImageView new];
            [self addSubview:image];
            image.alpha = 0.3;
            image.backgroundColor = [UIColor whiteColor];
            [_brightTipArray addObject:image];
        }
    }
    return _brightTipArray;
}
-(UILabel *)titleLabel{
    if (!_titleLabel){
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textColor = [UIColor colorWithRed:0.25f green:0.22f blue:0.21f alpha:1.00f];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = @"亮度";
        [self addSubview:_titleLabel];
    }
    return _titleLabel;
}


@end
