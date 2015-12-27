//
//  PopupView.h
//  LewPopupViewController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupView : UIView
@property (nonatomic, strong) UIView *innerView;
@property (nonatomic, weak)UIViewController *parentVC;

@property (nonatomic) NSString *deskName;
@property (nonatomic) NSString *signal;

+ (instancetype)defaultPopupView;
+ (instancetype)popupViewOfFrame:(CGRect)frame;
- (void)addInnerView ;

@end
