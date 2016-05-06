//
//  DeskView.h
//  HitProject
//
//  Created by 郭龙 on 15/11/2.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeskView : UIView

@property (nonatomic) UILabel *deskName;
@property (nonatomic) UIImageView *img;
@property (nonatomic) BOOL selected;
@property (nonatomic) NSInteger turn;//1,left,,2,right,,3,not
@end
