//
//  PopupView.h
//  LewPopupViewController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RadioButton.h"
@interface PopupView : UIView<RadioButtonDelegate>
@property (nonatomic, strong) UIView *innerView;
@property (nonatomic, weak)UIViewController *parentVC;

@property (nonatomic) NSString  *deskName;
@property (nonatomic) NSString  *signal;
@property (nonatomic) NSInteger deskTag;
@property (nonatomic) BOOL      isSong;//这是个flag,歌曲的控制flag

@property (nonatomic) NSInteger turn;//转身全局变量,1,左转，2，右转，3，不转

+ (instancetype)defaultPopupView;
+ (instancetype)popupViewOfFrame:(CGRect)frame;
- (void)addInnerView ;

@end
