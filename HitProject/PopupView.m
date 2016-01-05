//
//  PopupView.m
//  LewPopupViewController
//
//  Created by deng on 15/3/5.
//  Copyright (c) 2015年 pljhonglu. All rights reserved.
//

#import "PopupView.h"
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationFade.h"
#import "LewPopupViewAnimationSlide.h"
#import "LewPopupViewAnimationSpring.h"
#import "LewPopupViewAnimationDrop.h"

@implementation PopupView
@synthesize isSong;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}


- (void)addInnerView {
    _innerView = [UIView new];
    UIView *view = _innerView;//[UIView new];
    [self addSubview:view];
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    view.backgroundColor = [UIColor whiteColor];
    
    UIButton *cancelBtn = [UIButton new];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [view addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view);
        make.left.equalTo(view).offset(20);
    }];
    [cancelBtn addTarget:self action:@selector(dismissViewFadeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *confirmBtn = [UIButton new];
    [confirmBtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [view addSubview:confirmBtn];
    [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(view);
        make.right.equalTo(view).offset(-20);
    }];
    [confirmBtn addTarget:self action:@selector(confirmBtnTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    //bianliang zhuangshang
    NSArray *arr = [NSArray new];
    if (isSong) {
        arr = @[@"*歌曲",@"*信号",@"备注",@"其他"];
    }else
        arr = @[@"*桌号",@"*信号",@"备注",@"其他"];
    NSArray *arr2 = @[self.deskName,self.signal,@"备注",@"其他"];
    for (int i =0; i<4; i++) {
        UIView *labelView = [self labelAndTextfield:100+i label:arr[i] textFeild:arr2[i]];
        [view addSubview:labelView];
        [labelView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(view).offset(i*50 + 60);
            make.height.mas_equalTo(40);
            make.left.equalTo(view);
            make.right.equalTo(view);
        }];
    }
}


- (UITextField *)getTextViewByTag:(NSInteger)tag {
    UIView *subView = [self viewWithTag:tag];
    for (UIView *view in subView.subviews) {
        if ([view isKindOfClass:[UITextField class]]) {
            return (UITextField *)view;
        }
    }
    return nil;
}


- (void)confirmBtnTaped:(id)sender {
    UITextField *textFeild= [self getTextViewByTag:100];//tag =100,is桌号
    NSString *string = textFeild.text;
    if (!string) {
        [self makeToast:@"桌号不能为空" duration:1.8 position:CSToastPositionCenter];
        return;
    }
    if (isSong) {
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_SONGPOPVIEW_CONFIRM object:nil userInfo:@{@"deskName":string, @"deskTag":@(self.deskTag)}];
    }else
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_POPVIEW_CONFIRM object:nil userInfo:@{@"deskName":string, @"deskTag":@(self.deskTag)}];
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationFade new]];
}

- (UIView *)labelAndTextfield:(NSInteger)tag label:(NSString *)lableText textFeild:(NSString *)feildText {
    UIView *view = [UIView new];
    view.tag = tag;
    UILabel *label = [UILabel new];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor lightGrayColor];
    label.text = lableText;
    [view addSubview:label];
    int lableWidth = 85;
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view);
        make.top.equalTo(view);
        make.bottom.equalTo(view);
        make.width.mas_equalTo(lableWidth);
    }];
    
    UITextField *textfild = [UITextField new];
    textfild.backgroundColor = [UIColor orangeColor];
    textfild.text = feildText;
    [view addSubview:textfild];
    [textfild mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(view).insets(UIEdgeInsetsMake(0, lableWidth, 0, 0));
    }];
    return view;
}



+ (instancetype)defaultPopupView{
    if ([CommonsFunc isDeviceIpad]) {
        PopupView *pop = [[PopupView alloc]initWithFrame:CGRectMake(0, 0, 300, 330)];
//        [pop addInnerView];//需要在self完全成型之后加。
        return pop;
    }
    return [[PopupView alloc]initWithFrame:CGRectMake(0, 0, 195, 210)];
}

+ (instancetype)popupViewOfFrame:(CGRect)frame{
    PopupView *pop = [[PopupView alloc]initWithFrame:frame];
//    [pop addInnerView];
    return pop;
}

- (IBAction)dismissAction:(id)sender{
    [_parentVC lew_dismissPopupView];
}

- (IBAction)dismissViewFadeAction:(id)sender{
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationFade new]];
}

- (IBAction)dismissViewSlideAction:(id)sender{
    LewPopupViewAnimationSlide *animation = [[LewPopupViewAnimationSlide alloc]init];
    animation.type = LewPopupViewAnimationSlideTypeTopBottom;
    [_parentVC lew_dismissPopupViewWithanimation:animation];
}

- (IBAction)dismissViewSpringAction:(id)sender{
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationSpring new]];
}

- (IBAction)dismissViewDropAction:(id)sender{
    [_parentVC lew_dismissPopupViewWithanimation:[LewPopupViewAnimationDrop new]];
}
@end
