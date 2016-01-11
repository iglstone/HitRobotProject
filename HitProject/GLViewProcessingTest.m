//
//  GLViewProcessingTest.m
//  HitProject
//
//  Created by 郭龙 on 16/1/9.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "GLViewProcessingTest.h"

@interface GLViewProcessingTest (){
    UIScrollView *_scrolView;
}

@property UIScrollView *scrolView;

@end


@implementation GLViewProcessingTest

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

#pragma mark - lifeCicle
//drawing
//- (void)drawRect:(CGRect)rect {
//    NSLog(@"xxx_drawRect..");
//}

- (instancetype)init {
    NSLog(@"xxx_init..1");
    self = [super init];
    if (self) {
        NSLog(@"xxx_init..2");
        [self addSubview:self.tmpLabel];
        [self addSubview:self.scrolView];
        return self;
    }
    return nil;
}

//addSubview会触发layoutSubviews 、、UIScrollView在滚动中是实时调用layoutSubviews方法
- (void)layoutSubviews {
    NSLog(@"layoutSubviews");
    [self.scrolView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(10, 10, 20,10));
    }];
    [self.tmpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (UILabel *)tmpLabel {
    if (!_tmpLabel) {
        _tmpLabel = [UILabel new];
        _tmpLabel.text = @"guolong111111111111";
    }
    return _tmpLabel;
}


#pragma  mark - subViews
- (UIScrollView *)scrolView {
    if (!_scrolView) {
        NSLog(@"processing scrolView");
        _scrolView = [UIScrollView new];
        _scrolView.backgroundColor = [UIColor blueColor];
        _scrolView.contentSize = CGSizeMake(100, 600);
    }
    return _scrolView;
}

- (void)setScrolView:(UIScrollView *)scrolView {
    self.scrolView = scrolView;
}
@end
