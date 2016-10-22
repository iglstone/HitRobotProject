//
//  SettingViewController.m
//  HitProject
//
//  Created by 郭龙 on 16/5/24.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "MapInfoViewController.h"


@interface MapInfoViewController ()
{
    NSInteger screenW;
    NSInteger screenH;
}
@end
@implementation MapInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setBackgroundColor:[CommonsFunc colorOfLight]];
    screenW =[[UIScreen mainScreen] bounds].size.width;
    screenH = [[UIScreen mainScreen] bounds].size.height;
    
    UIButton *cancelBtn = [UIButton new];
    cancelBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:cancelBtn];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(10);
        make.left.equalTo(self.view).offset(20);
        make.width.mas_equalTo(@100);
    }];
    [cancelBtn addTarget:self action:@selector(btnTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *doneBtn = [UIButton new];
    doneBtn.backgroundColor = [UIColor orangeColor];
    [self.view addSubview:doneBtn];
    [doneBtn setTitle:@"完成" forState:UIControlStateNormal];
    [doneBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(cancelBtn);
        make.right.equalTo(self.view.mas_right).offset(-20);
        make.width.mas_equalTo(cancelBtn);
    }];
    [doneBtn addTarget:self action:@selector(btnTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    int i = 0;
    NSArray *arr = @[@"点个数", @"地图长度(cm)", @"地图高度(cm)", @"水平偏移(cm)", @"竖直偏移(cm)", @"循环起始点" ,@"循环终点"];
    NSArray *arrTag = @[@"100", @"101", @"102", @"103", @"104", @"105", @"106"];
    NSArray *arr2 = @[@">=4", @"2365", @"1395", @"600", @"935", @"0", @"1"];
    NSInteger vexNum = [[DataCenter sharedDataCenter] getVexsNum];
    NSInteger mapW = [[DataCenter sharedDataCenter] getMapWidth];
    NSInteger mapH = [[DataCenter sharedDataCenter] getMapHeight];
    NSInteger offW = [[DataCenter sharedDataCenter] getOffsetWidth];
    NSInteger offH = [[DataCenter sharedDataCenter] getOffsetHeight];
    NSInteger circleS = [[DataCenter sharedDataCenter] getCircleStart];
    NSInteger circleE = [[DataCenter sharedDataCenter] getCircleEnd];
    NSArray *ttt = @[@(vexNum), @(mapW), @(mapH), @(offW), @(offH),@(circleS), @(circleE)];
    
    for (i = 0 ; i < arr.count; i++) {
        UILabel *label = [UILabel new];
        label.text = arr[i];
        label.textAlignment = NSTextAlignmentCenter ;
        [self.view addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view.mas_centerX).offset(-20);
            make.top.equalTo(self.view.mas_top).offset(80 + 65 *i);
            make.size.mas_equalTo(CGSizeMake(120, 45));
        }];
        
        UITextField *text = [UITextField new];
        text.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:text];
        text.tag = [arrTag[i] integerValue];
        text.placeholder = arr2[i] ;
        text.text = [NSString stringWithFormat:@"%ld",(long)[ttt[i] integerValue]];
        [text mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view.mas_centerX).offset(20);
            make.top.equalTo(label);
            make.size.mas_equalTo(label);
        }];
    }
    
}

- (void) btnTaped:(UIButton *)btn {
    NSString *title = btn.titleLabel.text;
    if ([title isEqualToString:@"完成"]) {
        NSArray *keyArr = @[@"vexs", @"mapW", @"mapH", @"offsetW", @"offsetH", @"circleS", @"circleE"];
        NSMutableDictionary *dic = [NSMutableDictionary new];
        
        UITextField *vexNumText = (UITextField *) [self.view viewWithTag:100 ];
        UITextField *circleSText = (UITextField *) [self.view viewWithTag:100 + 5 ];
        UITextField *circleEText = (UITextField *) [self.view viewWithTag:100 + 6 ];
        if ([circleSText.text integerValue] >= [vexNumText.text integerValue]
            || [circleEText.text integerValue] >= [vexNumText.text integerValue])
        {
            [self.view makeToast:@"循环参数超过点个数" duration:1.2 position:CSToastPositionCenter];
            return;
        }
        
        for (int i = 0; i < keyArr.count; i++) {
            UITextField *te = (UITextField *) [self.view viewWithTag:100 + i];
            if (te.text.length == 0 ) {
                [self.view makeToast:@"参数不完整" duration:1.2 position:CSToastPositionCenter];
                return;
            }
            [dic setValue:te.text forKey:keyArr[i]];
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTI_SETTINGINFOMATION object:nil userInfo:dic];
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    if ([title isEqualToString:@"取消"]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
