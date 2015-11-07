//
//  ThirdViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/10/29.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import "ThirdViewController.h"
#import "DeskView.h"

@interface ThirdViewController ()<UIAlertViewDelegate>

@property (nonatomic) UILabel *infoLabel;
@property (nonatomic) NSInteger deskNum;
//@property (nonatomic) ServerSocket *server;
@property (nonatomic) HitControl *control;

@end

@implementation ThirdViewController
@synthesize infoLabel;
//@synthesize server;
@synthesize control;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
//    server = [ServerSocket sharedSocket];
    control = [HitControl sharedControl];
    
    UIView *rawView = [UIView new];
    rawView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:rawView];
    [rawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(20, 20, 100, 400));
    }];
    
    DeskView *desk1 = [[DeskView alloc] init];//WithFrame:CGRectMake(0, 0, 150, 150)];
    desk1.backgroundColor = [UIColor redColor];
    [self.view addSubview:desk1];
    [desk1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rawView).offset(20);
        make.left.equalTo(rawView).offset(20);
        make.size.mas_equalTo(CGSizeMake(50, 70));
    }];
    
    NSInteger deskWidth  = (self.view.bounds.size.width - 400 -20)/7;
    NSInteger deskHeight = (self.view.bounds.size.height - 120 - 20)/5;
    
    int deskNum = 1;
    
    for (int i = 0; i <= 4; i++) {
        for (int j = 0; j < 7; j++) {
            DeskView *deskview = [DeskView new];
            deskview.deskName.text = [NSString stringWithFormat:@"%d号桌",deskNum];//(NSInteger)((j+1)+(i)*(j+1))];
            deskNum ++;
            deskview.tag = deskNum;
            [self.view addSubview:deskview];
            [deskview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(desk1).offset((deskWidth)*j);
                make.top.equalTo(desk1).offset((deskHeight + 10)*i);
                make.size.mas_equalTo(CGSizeMake(50, 70));
            }];
            deskview.userInteractionEnabled = YES;
            [deskview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deskTaped:)]];
        }
    }
    desk1.hidden = YES;
    
    infoLabel =[UILabel new];
    [self.view addSubview:infoLabel];
    infoLabel.text = @"信息窗口：";
    [infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rawView.mas_right).offset (20);
        make.top.equalTo(rawView.mas_top).offset(20);
        make.size.mas_equalTo(CGSizeMake(200, 50));
    }];
    
    UIButton *backToOriginBtn = [UIButton new];
    backToOriginBtn.backgroundColor = [UIColor blueColor];
    [backToOriginBtn setTitle:@"回到初始位置" forState:UIControlStateNormal];
    [self.view addSubview:backToOriginBtn];
    [backToOriginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(infoLabel);
        make.top.equalTo(infoLabel.mas_bottom).offset(20);
    }];
    [backToOriginBtn addTarget:self action:@selector(backToOrigin:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *loopbtn = [UIButton new];
    loopbtn.backgroundColor = [UIColor blueColor];
    [loopbtn setTitle:@"循环运行" forState:UIControlStateNormal];
    [self.view addSubview:loopbtn];
    [loopbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(backToOriginBtn);
        make.top.equalTo(backToOriginBtn.mas_bottom).offset(20);
    }];
    [loopbtn addTarget:self action:@selector(loopRun:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)backToOrigin:(UIButton *)btn {
    NSLog(@"backToOrigin");
    [control backToOrigin];
}

- (void)loopRun:(UIButton *)btn {
    NSLog(@"loopRun");
    [control loopRun];
}

- (void)deskTaped:(UIGestureRecognizer *)gesture {
    DeskView *deskview = (DeskView *)[gesture view];
    deskview.backgroundColor = [UIColor grayColor];
    
    self.deskNum = deskview.tag - 1;
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"确定选择" message:@"确定选择1号桌？" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
    }else{
        infoLabel.text = [NSString stringWithFormat:@"信息窗口: %ld号桌", (long)self.deskNum];
        [control deskNumber:1];
    }
    
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
