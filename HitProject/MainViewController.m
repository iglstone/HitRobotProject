//
//  MainViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/11/9.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import "MainViewController.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"
#import "FourthViewController.h"
#import "ConnectStatesCell.h"
#import <Toast/UIView+Toast.h>
#import "GLViewProcessingTest.h"

#define NSUSERDEFAULT_DISCONNECT  @"NSUSERDEFAULT_DISCONNECT"

@interface MainViewController () <UITableViewDataSource,UITableViewDelegate> {

    NSMutableArray *m_cellsArray;
    UILabel *disconnectlabel;
    int disconectTimes;
    NSTimer *schedulTimer;
    NSString *ttt;
    GLViewProcessingTest *_glView;
}

@property (nonatomic) UITableView *m_tableView;
//@property (nonatomic) NSMutableArray *m_selecedModelsArray;
@property (nonatomic) UIButton *stopBtn;
@property (nonatomic) NSString *tmpString;
@property (nonatomic) ConnectStatesCell *tmpCell;
@property (nonatomic) HitControl *control;
@property (nonatomic, strong) GLViewProcessingTest *glView ;

@end

@implementation MainViewController
@synthesize m_tableView;
@synthesize m_modelsArray;
@synthesize m_selecedModelsArray;
@synthesize stopBtn;
@synthesize m_debugLabel;
@synthesize tmpString;
@synthesize tmpCell;
@synthesize control;
@synthesize views;

#pragma mark - lifecicle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    //test
//    NSInteger a = 10;
//    self.tmpTest = a;
//    NSLog(@"%ld",(long)self.tmpTest);
//    a = 12;
//    NSLog(@"%ld",(long)self.tmpTest);
//    
//    NSString *tt = @"123";
//    self.tmpTest1 = tt;
//    NSLog(@"%p",self.tmpTest1);
    
    [self.view addSubview:self.glView];
    
    /*********TEST***********/
    ttt = nil;
    UIView *disconnectView = [UIView new];
    [self.view addSubview:disconnectView];
    [disconnectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(100, 300, 300, 500));
    }];
    disconnectView.backgroundColor = [UIColor whiteColor];
    disconnectlabel = [UILabel new];
    NSInteger TIME =[[[NSUserDefaults standardUserDefaults] objectForKey:NSUSERDEFAULT_DISCONNECT] integerValue];
    disconnectlabel.text = [NSString stringWithFormat:@"断连次数:%ld",TIME];// @"0";
    [disconnectView addSubview:disconnectlabel];
    disconnectlabel.numberOfLines = 0;
    [disconnectlabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(disconnectView);
        make.top.equalTo(disconnectView);
    }];
    
//    disconnectlabel.hidden = YES;
//    disconnectView.hidden = YES;
    /*********************/
    
    UIImage *image = [UIImage imageNamed:@"me.png"];
    tmpString = @"";
    m_modelsArray = [[NSMutableArray alloc] init];
    m_selecedModelsArray = [[NSMutableArray alloc] init];
    control = [HitControl sharedControl];
    server = [ServerSocket sharedSocket];
    m_cellsArray = [[NSMutableArray alloc] init];
    
    FirstViewController *first = [FirstViewController new];
    image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UITabBarItem *itm = [[UITabBarItem alloc]initWithTitle:@"欢迎界面" image:image selectedImage:nil];
    first.tabBarItem = itm;
    
    SecondViewController *second = [SecondViewController new];
    second.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"操作界面" image:image selectedImage:nil];
    
    ThirdViewController *third = [ThirdViewController new];
    third.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"送餐界面" image:image selectedImage:nil];
    
    FourthViewController *fourth = [FourthViewController new];
    fourth.tabBarItem = [[UITabBarItem alloc]initWithTitle:@"语音界面" image:image selectedImage:nil];
    
    self.viewControllers = @[first, second, third, fourth];
    
    views = [UIView new];
    [self.view addSubview:views];
    views.backgroundColor = [UIColor lightGrayColor];
    [views mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-5);
        make.width.mas_equalTo(@300);
        if ([CommonsFunc isDeviceIpad]) {
            make.height.mas_equalTo(@(250+30));
            make.bottom.equalTo(self.view).offset(-50-5);
        }else{
            make.bottom.equalTo(self.view).offset(-50);
            make.height.mas_equalTo(@(100+30));
        }
    }];
    
    m_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 100, 40) style:UITableViewStylePlain];
    [m_tableView setBackgroundColor:[CommonsFunc colorOfLight]];
    m_tableView.delegate = self;
    m_tableView.dataSource = self;
    [views addSubview:m_tableView];
    [m_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(views);
        make.width.equalTo(views);
        make.bottom.equalTo(views);
        if ([CommonsFunc isDeviceIpad]) {
            make.height.mas_equalTo(@250);
        }else
            make.height.mas_equalTo(@100);
    }];
    m_tableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
    
    UIView *header = [self tableHeaderView];
    [views addSubview:header];
    [header mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(views);
        make.left.equalTo(m_tableView);
        make.width.equalTo(m_tableView);
        make.height.mas_equalTo(@30);
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectSuccess:) name:NOTICE_CONNECTSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clientDisconnect:) name:NOTICE_DISCONNECT object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tryAgain:) name:NOTICE_TRYAGIAN object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeName:) name:NOTICE_CHANGEROBOTNAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noRobotToast:) name:NOTICE_NOROBOT object:nil];
    
    stopBtn = [UIButton new];
    [views addSubview:stopBtn];
    [stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(views);
        make.centerX.equalTo(views);
        make.width.mas_equalTo(@110);
    }];
    stopBtn.backgroundColor = [UIColor lightGrayColor];
    stopBtn.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    stopBtn.layer.borderWidth = 1.0;
    stopBtn.layer.masksToBounds = YES;
    stopBtn.layer.cornerRadius = 5.0;
    [self setStopBtnGray];
    [stopBtn setTitle:@"断开连接" forState:UIControlStateNormal];
    stopBtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [stopBtn addTarget:self action:@selector(stopBtnTaped:) forControlEvents:UIControlEventTouchUpInside];
    
    m_debugLabel = [UILabel new];
    m_debugLabel.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:m_debugLabel];
    m_debugLabel.numberOfLines = 0;
    if ([CommonsFunc isDeviceIpad]) {
        [m_debugLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(header.mas_top).offset(-10);
            make.width.equalTo(m_tableView);
            make.height.mas_equalTo(@50);
            make.left.equalTo(m_tableView);
        }];
    }else{
        [m_debugLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(views);
            make.right.equalTo(m_tableView);
            make.height.mas_equalTo(@50);
            make.width.mas_equalTo(@150);
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.glView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(100, 200));
    }];
    
}

- (GLViewProcessingTest *)glView {
    if (_glView == nil) {
        NSLog(@".. glviewProcessing..");
        _glView = [[GLViewProcessingTest alloc] init ];//WithFrame:CGRectMake(0, 0, 100, 100)];
        _glView.backgroundColor = [UIColor redColor];
    }
    return _glView;
}


- (void)setGlView:(GLViewProcessingTest *)glView2 {
    if (glView2) {
        self.glView = glView2;
    }
}


#pragma mark - Actions
- (void )setStopBtnRed {
    [stopBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}

- (void )setStopBtnGray {
    [stopBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

- (void)noRobotToast :(NSNotification *)noti {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择机器人" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    [alert show];
}

//mode :0 send
//mode :1 recv
- (void)setDebugLabelText:(NSString *)string mode:(int)mode{
    m_debugLabel.text = nil;
    NSString *str;
    if ( !mode) {
        str = [NSString stringWithFormat:@"发送: %@",string];
        m_debugLabel.text = [NSString stringWithFormat:@"%@ \n%@",tmpString,str];
    }else{
        str = [NSString stringWithFormat:@"接收: %@",string];
        m_debugLabel.text = [NSString stringWithFormat:@"%@ \n%@",tmpString,str];
    }
    tmpString = str;
}

- (void)stopBtnTaped :(UIButton *)btn {
    NSLog(@"stopTaped");
    for (ConnectModel *model in m_selecedModelsArray) {
        [model.socket disconnect];
    }
}


#pragma mark - Notification
- (void)tryAgain :(NSNotification *)noti {
    [self.view makeToast:@"指令发送失败，请重新发送" duration:1.2f position:CSToastPositionCenter];
}

- (void)clientDisconnect :(NSNotification *)noti {
    NSLog(@"clientDisconnect notification");
    /*****TEST*****/
    int aa = (int)[[[NSUserDefaults standardUserDefaults] objectForKey:NSUSERDEFAULT_DISCONNECT] integerValue];
    aa ++;
    NSString *tmpstring = [NSString stringWithFormat:@"断链次数:%d\n",aa];
    
    NSString* date;
    NSDateFormatter* formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    date = [NSString stringWithFormat:@"%@\n", [formatter stringFromDate:[NSDate date]]];
    
    NSString *sss = [tmpstring stringByAppendingString:date];
    
    if (!ttt) {
        ttt = @"";
    }
    ttt = [ttt stringByAppendingString:sss];
    NSLog(@"%@",sss);
    disconnectlabel.text = ttt;
    [[NSUserDefaults standardUserDefaults] setObject:@(aa) forKey:NSUSERDEFAULT_DISCONNECT];
    [schedulTimer invalidate];
    /************/
    
    
    NSDictionary *dic = [noti userInfo];
    AsyncSocket *socket = (AsyncSocket *)[dic objectForKey:@"socket"];
    //去除选中的socket
    [server.selectedSocketArray enumerateObjectsUsingBlock:^(AsyncSocket *S, NSUInteger idx, BOOL *stop) {
        if ([socket isEqual:S]) {
            [server.selectedSocketArray removeObject:S];
//            *stop = YES;
        }
    }];
    
    //设置disconnect连接标志
    [m_modelsArray enumerateObjectsUsingBlock:^(ConnectModel *model, NSUInteger idx, BOOL *stop) {
        if ([model.socket isEqual:socket]) {
            *stop = YES;
            model.status = @"未连接";
            model.isCheck = NO;
            [m_modelsArray removeObject:model];
            [m_selecedModelsArray removeObject:model];
            [self.view makeToast:[NSString stringWithFormat:@"失去%@连接", model.hostIp] duration:1.5 position:CSToastPositionCenter];
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_tableView reloadData];
            });
        }
    }];
    
//    for (ConnectModel *model in m_modelsArray) {
//        if ([model.socket isEqual:socket]) {
//            model.status = @"未连接";
//            [self.view makeToast:[NSString stringWithFormat:@"失去%@连接", model.hostIp] duration:1.5 position:CSToastPositionCenter];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [m_tableView reloadData];
//            });
//        }
//    }
    
}

- (void)changeName :(NSNotification *)noti {
    NSString *ipaddr = (NSString *) [[noti userInfo] objectForKey:@"ipAddr"];
    [m_modelsArray enumerateObjectsUsingBlock:^(ConnectModel *tmpModel, NSUInteger idx, BOOL *stop) {
        if ([ipaddr isEqualToString:tmpModel.hostIp]) {
            NSString *name = [ServerSocket getRobotNameByIp:ipaddr];
            tmpModel.robotName = name;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [m_tableView reloadData];
        });
    }];
}

- (void)connectSuccess:(NSNotification *)noti {
    NSLog(@"connectSuccess notification");
    
    NSDictionary *dic = [noti userInfo];
    NSString *host = [dic objectForKey:@"host"];
    NSInteger port = [(NSNumber *)[dic objectForKey:@"port"] integerValue];
    NSString *status = [dic objectForKey:@"status"];
    AsyncSocket *sokect = (AsyncSocket *)[dic objectForKey:@"socket"];
    
    /**************/
    schedulTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(compareMessage:) userInfo:@{@"sock":sokect} repeats:YES];
    /*************/
    
    [self.view makeToast:[NSString stringWithFormat:@"连接%@成功", host] duration:1.5 position:CSToastPositionCenter];
    
    ConnectModel *model = [ConnectModel new];
    model.port = port;
    model.hostIp = host;
    model.status = status;
    model.socket = sokect;
    model.isCheck = NO;
    model.robotName = [ServerSocket getRobotNameByIp:host];
    
    [m_modelsArray enumerateObjectsUsingBlock:^(ConnectModel *tmpModel, NSUInteger idx, BOOL *stop) {
        if ([model.hostIp isEqual:tmpModel.hostIp]) {
            [m_modelsArray removeObject:tmpModel];
//            [m_modelsArray addObject:model];
        }
    }];
    [m_modelsArray addObject:model];
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_tableView reloadData];
    });
}

- (void)compareMessage :(NSTimer  *) timer{
    AsyncSocket *S = (AsyncSocket *)[[timer userInfo] objectForKey:@"sock"];
    [S writeData:[@"A" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    NSLog(@"write A");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - table delegete
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identity = @"ipsId";
    ConnectStatesCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[ConnectStatesCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    
    ConnectModel *model = [m_modelsArray objectAtIndex:indexPath.row];
    [cell configModel:model];
    [m_cellsArray addObject:cell];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return m_modelsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    tmpCell = (ConnectStatesCell *)[tableView cellForRowAtIndexPath:indexPath];
    ConnectModel *model = [m_modelsArray objectAtIndex:indexPath.row];
    
//    if ([model.status isEqualToString:@"未连接"]) {
//        return;
//    }
    
//    //不知道这一步有没有用
//    [m_selecedModelsArray enumerateObjectsUsingBlock:^(ConnectModel *tmpModel, NSUInteger idx, BOOL *stop) {
//        if ([model isEqual:tmpModel]) {
//            *stop = YES;
//            [m_selecedModelsArray removeObject:tmpModel];
//            [m_selecedModelsArray addObject:model];
//            [server.selectedSocketArray removeObject:tmpModel.socket];
//            [server.selectedSocketArray addObject:model.socket];
//            [self setStopBtnRed];
//        }  
//    }];
    
    NSLog(@"isCkecked before %d",tmpCell.isChecked);
    tmpCell.isChecked = !tmpCell.isChecked;
    NSLog(@"isCkecked after  %d",tmpCell.isChecked);
    if (tmpCell.isChecked == YES) {
        [m_selecedModelsArray addObject:model];
        [server.selectedSocketArray addObject:model.socket];
        [self setStopBtnRed];
        model.isCheck = YES;
    }
    else
    {
        [m_selecedModelsArray removeObject:model];
        [server.selectedSocketArray removeObject:model.socket];
        model.isCheck = NO;
        if (m_selecedModelsArray.count == 0) {
            [self setStopBtnGray];
        }else
            [self setStopBtnRed];
    }
}

#pragma mark - Add views
- (UIView *)tableHeaderView {
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    headerview.backgroundColor = [UIColor orangeColor];
    UILabel *iplabel = [UILabel new];
    iplabel.text = @"机器人ip";
    [headerview addSubview:iplabel];
    [iplabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerview);
        make.left.equalTo(headerview).offset(20);
    }];
    
    UILabel *portLable = [UILabel new];
    [portLable setText:@"端口"];
    [headerview addSubview:portLable];
    [portLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headerview);
    }];
    
    UILabel *status = [UILabel new];
    status.text = @"状态";
    status.textAlignment = NSTextAlignmentCenter;
    [headerview addSubview:status];
    [status mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerview);
        make.right.equalTo(headerview).offset(-20);
    }];
    return headerview;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
