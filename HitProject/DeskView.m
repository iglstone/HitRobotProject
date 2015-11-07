//
//  DeskView.m
//  HitProject
//
//  Created by 郭龙 on 15/11/2.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import "DeskView.h"

@implementation DeskView
@synthesize deskName;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init {
    self = [super init];
    if (self) {
        UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hit.png"]];
        [self addSubview:img];
        [img mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self);
            make.left.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }];
        
        deskName = [UILabel new];
//        deskName.text = @"1号桌";
        [self addSubview:deskName];
        [deskName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(img.mas_bottom).offset(10);
            make.centerX.equalTo(img);
        }];
        self.userInteractionEnabled = YES;
    }
    return self;
}

//- (instancetype)initWithFrame:(CGRect)frame {
//    self = [super initWithFrame:frame];
//    if (self) {
//        UIImageView *img = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"hit.png"]];
//        [self addSubview:img];
//        [img mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self);
//            make.centerX.equalTo(self);
//            make.size.mas_equalTo(CGSizeMake(100, 100));
//        }];
//        
//        deskName = [UILabel new];
//        deskName.text = @"1号桌";
//        [self addSubview:deskName];
//        [deskName mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(img.mas_bottom).offset(10);
//            make.centerX.equalTo(img);
//        }];
//    }
//    return self;
//}

@end
