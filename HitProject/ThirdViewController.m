//
//  ThirdViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/10/29.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import "ThirdViewController.h"
#import "DeskView.h"
#import "PopupView.h"
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationFade.h"
#import "DeskInfoHelper.h"

#define DESKNUMPERLINE 5;

@interface ThirdViewController ()<UIAlertViewDelegate>
{
    UIScrollView *rawView;
    NSInteger deskWidth,deskHeight;
    NSString *sss;
    DeskInfoHelper *helper;
    DeskView *tmpView;
}
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

- (instancetype)init {
    self = [super init];
    if (self) {
        NSInteger denum = [[[NSUserDefaults standardUserDefaults] objectForKey:NSDEFAULT_PickupDeskNum] integerValue];
        if (denum == 0) {
            self.TotaldeskNum = 28;
        }else
            self.TotaldeskNum = denum;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deskNumNoti:) name:NOTICE_PICKDESKNUM object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(popViewConfrimed:) name:NOTICE_POPVIEW_CONFIRM object:nil];
        helper = [DeskInfoHelper new];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLayoutSubviews {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 8.0) {//补充ios7的scrollview 不能滑动的问题。
        [self layOutRawView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MainViewController *main =(MainViewController *) self.tabBarController;
    if (![CommonsFunc isDeviceIpad]) {
        main.views.hidden = YES;
        main.m_debugLabel.hidden = NO;
    }
    [self deskView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    for (UIView *viw in rawView.subviews) {
        [viw removeFromSuperview];
    }
}

//- (void)dealloc {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [CommonsFunc colorOfSystemBackground];
    
    control = [HitControl sharedControl];
    desksArray = [[NSMutableArray alloc] init];
    NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    rawView = [UIScrollView new];
    rawView.backgroundColor = [CommonsFunc colorOfLight];
    rawView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    rawView.layer.borderWidth = 0.8;
    rawView.layer.cornerRadius = 12;
    rawView.layer.masksToBounds = YES;
    [self.view addSubview:rawView];
    [rawView mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([CommonsFunc isDeviceIpad]) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(20, 20, 185, 400));
        }else
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(20, 20, 100, screenWidth/4));
    }];
    
    infoLabel =[UILabel new];
    [self.view addSubview:infoLabel];
    infoLabel.text = @"信息窗口：";
    infoLabel.font = [UIFont systemFontOfSize:20];
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
    
    UIButton *cancelSendMealBtn = [UIButton new];
    cancelSendMealBtn.layer.cornerRadius = 5;
    cancelSendMealBtn.layer.masksToBounds = YES;
    cancelSendMealBtn.layer.borderWidth = 0.8;
    cancelSendMealBtn.layer.borderColor = [[UIColor darkGrayColor]CGColor];
    cancelSendMealBtn.backgroundColor = [UIColor orangeColor];
    [cancelSendMealBtn setTitle:@"取消送餐" forState:UIControlStateNormal];
    [self.view addSubview:cancelSendMealBtn];
    [cancelSendMealBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(loopbtn);
        make.top.equalTo(loopbtn.mas_bottom).offset(20);
    }];
    [cancelSendMealBtn addTarget:self action:@selector(cancelSendMeal:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void )deskView {
    int deknum = DESKNUMPERLINE;
    
    DeskView *desk1 = [[DeskView alloc] init];//WithFrame:CGRectMake(0, 0, 150, 150)];
    desk1.backgroundColor = [UIColor redColor];
    [rawView addSubview:desk1];
    [desk1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rawView).offset(20);
        make.left.equalTo(rawView).offset(0);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    [self layOutRawView];
    
    int deskNum = 1;
    NSInteger tt = 0;
    
    @autoreleasepool {
//      NSArray *deskNumArray = @[@"121", @"122", @"123", @"125", @"126", @"127", @"128", @"117", @"116", @"115", @"113", @"112", @"106"];
        NSArray <NSString *> *deskNumArray = [helper getDeskNamesFromUserdefaultByTag:(int)self.TotaldeskNum isSong:NO];
        for (int i = 0; i <= 12; i++) {//lie
            for (int j = 0; j < deknum; j++) {//hang
                if (deskNum > self.TotaldeskNum) {
                    tt = 1;
                    break;
                }
                DeskView *deskview = [DeskView new];
                NSString *deskNumString = nil;
                
                if (deskNum <= 13) {
                    deskNumString = deskNumArray[deskNum -1];
                    deskview.deskName.text = [NSString stringWithFormat:@"%@",deskNumString];//(NSInteger)((j+1)+(i)*(j+1))];
                }else {
                    deskview.deskName.text = [NSString stringWithFormat:@"%d桌",deskNum];//(NSInteger)((j+1)+(i)*(j+1))];
                }
                
                deskview.deskName.font = [UIFont systemFontOfSize:13];
                deskview.tag = deskNum;
                deskNum ++;
                [rawView addSubview:deskview];
                [deskview mas_makeConstraints:^(MASConstraintMaker *make) {
                    NSInteger gap = deskWidth - 60;
                    make.left.equalTo(desk1).offset((deskWidth)*j + gap/2);
                    make.top.equalTo(desk1).offset((deskHeight + 10)*i);
                    if ([CommonsFunc isDeviceIpad]) {
                        make.size.mas_equalTo(CGSizeMake(60, 60));
                    }
                    else
                        make.size.mas_equalTo(CGSizeMake(40, 40));
                }];
                deskview.userInteractionEnabled = YES;
                [deskview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(deskTaped:)]];
                [deskview addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deskLongTaped:)]];
                [desksArray addObject: deskview];
            }
            if (tt == 1) {
                break;
            }
        }
    }
    desk1.hidden = YES;
}

- (void)layOutRawView {
    NSInteger screenWidth = [UIScreen mainScreen].bounds.size.width;
    NSInteger contentWidth ;
    if ([CommonsFunc isDeviceIpad]) {
        deskWidth = (self.view.bounds.size.width - 400 -20)/5;
        deskHeight = (self.view.bounds.size.height - 100 - 20 - 40)/5;
        contentWidth = [UIScreen mainScreen].bounds.size.width - 20 - 400;
        rawView.contentSize = CGSizeMake(contentWidth, (deskHeight + 5) * ((int)(self.TotaldeskNum/5) +1) + 20);
    } else {
        deskHeight = (self.view.bounds.size.height - 100 - 20 - 40)/5 + 20;
        deskWidth = (self.view.bounds.size.width - screenWidth/4 -20)/7;
        contentWidth = [UIScreen mainScreen].bounds.size.width - 20 - screenWidth/4;
        rawView.contentSize = CGSizeMake(contentWidth, (deskHeight + 10) * ((int)(self.TotaldeskNum/6) +1) + 10);
    }
}

#pragma mark - notification
- (void) popViewConfrimed:(NSNotification *)noti {
    NSDictionary *dic  = [noti userInfo];
    NSInteger tag      = [[dic objectForKey:@"deskTag"] integerValue];
    NSString *deskNames = [dic objectForKey:@"deskName"];
    [helper changeDeskModelByTag:(int)tag name:deskNames isSong:NO];
    tmpView.deskName.text = [deskNames hasSuffix:@"桌"] ? deskNames : [NSString stringWithFormat:@"%@桌", deskNames];
}

- (void)deskNumNoti :(NSNotification *)noti {
    NSInteger denum = [[[NSUserDefaults standardUserDefaults] objectForKey:NSDEFAULT_PickupDeskNum] integerValue];
    self.TotaldeskNum = denum;
}

#pragma mark - action
- (void)backToOrigin:(UIButton *)btn {
    NSLog(@"backToOrigin");
    [control backToOrigin];
    [self setUnselectedDeskImage];
}

- (void)loopRun:(UIButton *)btn {
    NSLog(@"loopRun");
    [control loopRun];
    [self setUnselectedDeskImage];
}

- (void)cancelSendMeal :(UIButton *) btn {
    [control cancelSendMeal];
}

- (void)deskTaped:(UIGestureRecognizer *)gesture {
    tmpDeskView = (DeskView *)[gesture view];
    sss = [[tmpDeskView deskName] text];
    self.deskNum = tmpDeskView.tag - 1;
    NSString *string = [NSString stringWithFormat:@"选择%@？",sss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:string message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

- (void)deskLongTaped :(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            tmpView = (DeskView *)[gesture view];
            NSString *deskName = tmpView.deskName.text;
            NSLog(@"long taped :%@",deskName);
            PopupView *view = [PopupView defaultPopupView];
            view.deskName = deskName;
            view.signal = @"xxx";
            view.parentVC = self;
            view.deskTag = tmpView.tag;
            [view addInnerView];
            [self lew_presentPopupView:view animation:[LewPopupViewAnimationFade new] dismissed:^{
                NSLog(@"动画结束");
            }];
        }
    }
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
        infoLabel.text = [NSString stringWithFormat:@"信息窗口: %@", sss];
//        if (tmpDeskView.selected == YES) {//取消送餐
//            tmpDeskView.selected = NO;
//            [tmpDeskView.img setImage:[UIImage imageNamed:@"desk_white.png"]];
//        }
//        else
//        {
            [self setUnselectedDeskImage];
            tmpDeskView.selected = YES;
            [tmpDeskView.img setImage:[UIImage imageNamed:@"desk_red.png"]];
            if (self.deskNum <= 30) {
                [control deskNumber:self.deskNum];
            }else {
                NSLog(@"目前最多支持30桌");
            }
//        }
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
