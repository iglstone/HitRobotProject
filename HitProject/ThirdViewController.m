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
@property (nonatomic) HitControl *control;
@property (nonatomic) DeskView *tmpDeskView;
@property (nonatomic) NSMutableArray *desksArray;
@end

@implementation ThirdViewController
@synthesize infoLabel;
@synthesize control;
@synthesize tmpDeskView;
@synthesize desksArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [CommonsFunc colorOfSystemBackground];
    
    control = [HitControl sharedControl];
    desksArray = [[NSMutableArray alloc] init];
    
    UIScrollView *rawView = [UIScrollView new];
    rawView.backgroundColor = [CommonsFunc colorOfLight];
    rawView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    rawView.layer.borderWidth = 0.8;
    rawView.layer.cornerRadius = 12;
    rawView.layer.masksToBounds = YES;
    [self.view addSubview:rawView];
    [rawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(20, 20, 100, 400));
    }];
    rawView.contentSize= CGSizeMake(400, 1000);//(500,500);
    
    DeskView *desk1 = [[DeskView alloc] init];//WithFrame:CGRectMake(0, 0, 150, 150)];
    desk1.backgroundColor = [UIColor redColor];
    [rawView addSubview:desk1];
    [desk1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rawView).offset(20);
        make.left.equalTo(rawView).offset(20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    NSInteger deskWidth  = (self.view.bounds.size.width - 400 -20)/7;
    NSInteger deskHeight = (self.view.bounds.size.height - 100 - 20 - 40)/5;
    
    int deskNum = 1;
    
    for (int i = 0; i <= 6; i++) {
        for (int j = 0; j < 7; j++) {
            DeskView *deskview = [DeskView new];
            deskview.deskName.text = [NSString stringWithFormat:@"%d号桌",deskNum];//(NSInteger)((j+1)+(i)*(j+1))];
            deskNum ++;
            deskview.tag = deskNum;
            [rawView addSubview:deskview];
            [deskview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(desk1).offset((deskWidth)*j);
                make.top.equalTo(desk1).offset((deskHeight + 10)*i);
                make.size.mas_equalTo(CGSizeMake(60, 60));
            }];
            deskview.userInteractionEnabled = YES;
            [deskview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deskTaped:)]];
            [desksArray addObject: deskview];
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
    backToOriginBtn.layer.cornerRadius = 5;
    backToOriginBtn.layer.masksToBounds = YES;
    backToOriginBtn.layer.borderWidth = 0.8;
    backToOriginBtn.layer.borderColor = [[UIColor darkGrayColor]CGColor];
    backToOriginBtn.backgroundColor = [UIColor orangeColor];
    [backToOriginBtn setTitle:@"回到初始位置" forState:UIControlStateNormal];
    [self.view addSubview:backToOriginBtn];
    [backToOriginBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(infoLabel);
        make.top.equalTo(infoLabel.mas_bottom).offset(20);
    }];
    [backToOriginBtn addTarget:self action:@selector(backToOrigin:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *loopbtn = [UIButton new];
    loopbtn.layer.cornerRadius = 5;
    loopbtn.layer.masksToBounds = YES;
    loopbtn.layer.borderWidth = 0.8;
    loopbtn.layer.borderColor = [[UIColor darkGrayColor]CGColor];
    loopbtn.backgroundColor = [UIColor orangeColor];
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
    tmpDeskView = (DeskView *)[gesture view];
    
    self.deskNum = tmpDeskView.tag - 1;
    NSString *string = [NSString stringWithFormat:@"选择%ld号桌？",self.deskNum];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)setUnselectedDeskImage {
    for (DeskView *deskView2 in desksArray) {
        [deskView2.img setImage:[UIImage imageNamed:@"desk_white.png"]];
        deskView2.selected = NO;
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0) {
        
    }else{
        infoLabel.text = [NSString stringWithFormat:@"信息窗口: %ld号桌", (long)self.deskNum];
        if (tmpDeskView.selected == YES) {//取消送餐
            tmpDeskView.selected = NO;
            [tmpDeskView.img setImage:[UIImage imageNamed:@"desk_white.png"]];
        }
        else
        {
            [self setUnselectedDeskImage];
            tmpDeskView.selected = YES;
            [tmpDeskView.img setImage:[UIImage imageNamed:@"desk_red.png"]];
            if (self.deskNum <= 5) {
                [control deskNumber:self.deskNum];
            }else {
                [control deskNumber:3];
            }
        
        }
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
