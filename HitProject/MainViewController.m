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
#import "RobotRouteViewController3.h"
#import "ConnectStatesCell.h"
#import <Toast/UIView+Toast.h>
#import "GLViewProcessingTest.h"

#define DEBUGTAG 199
#define NSUSERDEFAULT_DISCONNECT  @"NSUSERDEFAULT_DISCONNECT"

@interface MainViewController () <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate> {
    NSMutableArray *m_cellsArray;
    int disconectTimes;
    NSTimer *schedulTimer;
    NSString *ttt;
    NSMutableArray *m_messagesArray;
    NSString *tmpString;
    
    UILabel *disconnectlabel;
    UITableView *m_tableView;
    UIButton *stopBtn;
    ConnectStatesCell *tmpCell;
    HitControl *control;
    ServerSocket *server;
    UIView *tableViewHeader;
}

@end

@implementation MainViewController
@synthesize m_modelsArray;
@synthesize rightsideContainer;

#pragma mark - lifecicle
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiConnect:) name:NOTICE_CONNECTSUCCESS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiDisconnect:) name:NOTICE_DISCONNECT object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiTryAgain:) name:NOTICE_TRYAGIAN object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiChangeName:) name:NOTICE_CHANGEROBOTNAME object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiNoRobotToast:) name:NOTICE_NOROBOT object:nil];
        return self;
    }
    return nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    m_messagesArray = [NSMutableArray new];
    UIImage *image = [UIImage imageNamed:@"me.png"];
    tmpString = @"";
    m_modelsArray = [[NSMutableArray alloc] init];
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
    
    RobotRouteViewController3 *fifth = [RobotRouteViewController3 new];
    fifth.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"无轨导航" image:image selectedImage:nil];
//    self.viewControllers = @[first, second, third, fourth];// fifth];
    self.viewControllers = @[first, second, third, fourth, fifth];
    
    [self addRightSideViewContainer];
    [self.view addSubview:self.p_debugLabel];
    [self subViewsMakeConstrains];
    
    [self addDebugTableView];
    [server addObserver:self forKeyPath:@"messagesArray" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)subViewsMakeConstrains{
    [self.p_debugLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(@50);
        if ([CommonsFunc isDeviceIpad]) {
            make.bottom.equalTo(tableViewHeader.mas_top).offset(-10);
            make.width.equalTo(m_tableView);
            make.left.equalTo(m_tableView);
        }else{
            make.bottom.equalTo(rightsideContainer);
            make.right.equalTo(m_tableView);
            make.width.mas_equalTo(@150);
        }
    }];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [server removeObserver:self forKeyPath:@"messagesArray"];
}

#pragma mark - Notification & observers
- (void)notiConnect:(NSNotification *)noti {
    NSLog(@"connectSuccess notification");
    
    NSDictionary *dic = [noti userInfo];
    NSString *host = [dic objectForKey:@"host"];
    NSInteger port = [(NSNumber *)[dic objectForKey:@"port"] integerValue];
    NSString *status = [dic objectForKey:@"status"];
    AsyncSocket *sokect = (AsyncSocket *)[dic objectForKey:@"socket"];
    /**************
     schedulTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(compareMessage:) userInfo:@{@"sock":sokect} repeats:YES];
     *************/
    [self.view makeToast:[NSString stringWithFormat:@"连接%@成功", host] duration:1.5 position:CSToastPositionCenter];
    
    ConnectModel *model = [ConnectModel new];
    model.port = port;
    model.hostIp = host;
    model.status = status;
    model.socket = sokect;
    model.isCheck = NO;
//    model.status = @"已连接";
    model.robotName = [ServerSocket getRobotNameByIp:host];
    for (int i = 0; i < m_modelsArray.count; i++) {
        ConnectModel *tmpModel = [m_modelsArray objectAtIndex:i];
        if ([tmpModel.hostIp isEqualToString:model.hostIp]) {
            [[self mutableArrayValueForKey:@"m_modelsArray"] removeObject:tmpModel];
        }
    }
    //    [m_modelsArray addObject:model];
    [[self mutableArrayValueForKey:@"m_modelsArray"] addObject:model];
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_tableView reloadData];
    });
}

- (void)notiDisconnect :(NSNotification *)noti {
    NSLog(@"clientDisconnect notification");
     /*****TEST** 测试断链次数 **
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
    ***********/
    NSDictionary *dic = [noti userInfo];
    AsyncSocket *socket = (AsyncSocket *)[dic objectForKey:@"socket"];
    //去除选中的socket
//    [server.selectedSocketArray enumerateObjectsUsingBlock:^(AsyncSocket *S, NSUInteger idx, BOOL *stop) {
//        if ([socket isEqual:S]) {
//            NSLog(@"remove socket from modelArrays");
//            [server.selectedSocketArray removeObject:S];
//        }
//    }];
    
    for (int i = 0; i < server.selectedSocketArray.count; i++) {
        AsyncSocket *sock = (AsyncSocket *)[server.selectedSocketArray objectAtIndex:i];
        if ([sock isEqual:socket]) {
            NSLog(@"remove socket from modelArrays");
            [server.selectedSocketArray removeObject:sock];
        }
    }
    
    for (int i = 0; i < [m_modelsArray count]; i++) {
        ConnectModel *model = [m_modelsArray objectAtIndex:i];
        if ([model.socket isEqual:socket]) {
            //[m_modelsArray removeObject:model];
            [[self mutableArrayValueForKey:@"m_modelsArray"] removeObject:model];// for kvo
            [self.view makeToast:[NSString stringWithFormat:@"失去%@连接", model.hostIp] duration:1.5 position:CSToastPositionCenter];
        }
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_tableView reloadData];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"messagesArray"]) {
        //        m_messagesArray = (NSMutableArray *)[change objectForKey:@"new"];
        m_messagesArray = server.messagesArray;
    }
    UITableView *table = (UITableView *)[self.view viewWithTag:DEBUGTAG];
    [table reloadData];
    if (m_messagesArray.count >= 1) {
        [table scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(m_messagesArray.count -1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    } else {
        return;
    }
}

- (void)notiChangeName :(NSNotification *)noti {
    NSString *ipaddr = (NSString *) [[noti userInfo] objectForKey:@"ipAddr"];
    [m_modelsArray enumerateObjectsUsingBlock:^(ConnectModel *tmpModel, NSUInteger idx, BOOL *stop) {
        if ([ipaddr isEqualToString:tmpModel.hostIp]) {
            NSString *name = [ServerSocket getRobotNameByIp:ipaddr];
            tmpModel.robotName = name;
        }
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_tableView reloadData];
    });
}

- (void)notiTryAgain :(NSNotification *)noti {
    [self.view makeToast:@"指令发送失败，请重新发送" duration:1.2f position:CSToastPositionCenter];
}

- (void)notiNoRobotToast :(NSNotification *)noti {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"请选择机器人" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
    alert.delegate = self;
    [alert show];
}

#pragma mark - table delegete
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [ServerSocket sharedSocket].showTag = false;
    }
    
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == DEBUGTAG) {
        static NSString * identity = @"debugId";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
        if (cell == nil) {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
            cell.backgroundColor = [UIColor redColor];
        }
        if (m_messagesArray.count != 0) {
            NSString *test = [m_messagesArray objectAtIndex:indexPath.row];
            cell.textLabel.text = test;
            cell.textLabel.font = [UIFont systemFontOfSize:12];
        }
        return cell;
    }else {
        static NSString * identity = @"ipsId";
        ConnectStatesCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
        if (cell == nil) {
            cell = [[ConnectStatesCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
        }
        
        ConnectModel *model = [m_modelsArray objectAtIndex:indexPath.row];
        [cell configModel:model];
        if ([model.robotName isEqualToString:ROBOTNAME_RED]) {
            cell.backgroundColor = [UIColor redColor];
        }
        if ([model.robotName isEqualToString:ROBOTNAME_BLUE]) {
            cell.backgroundColor = [UIColor blueColor];
        }
        if ([model.robotName isEqualToString:ROBOTNAME_GOLD]) {
            cell.backgroundColor = [UIColor orangeColor];
        }
        
        [m_cellsArray addObject:cell];
        
        return cell;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (tableView.tag == DEBUGTAG) {
        return 15;
    }
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == DEBUGTAG) {
        return m_messagesArray.count;
    }
    return m_modelsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView.tag == DEBUGTAG) {
        return;
    }
    tmpCell = (ConnectStatesCell *)[tableView cellForRowAtIndexPath:indexPath];
    ConnectModel *model = [m_modelsArray objectAtIndex:indexPath.row];
    
    NSLog(@"isCkecked before %d",tmpCell.isChecked);
    tmpCell.isChecked = !tmpCell.isChecked;
    NSLog(@"isCkecked after  %d",tmpCell.isChecked);
    if (tmpCell.isChecked == YES) {
        [server.selectedSocketArray addObject:model.socket];
        [self setStopBtnRed];
        model.isCheck = YES;
        [control sendCheckSigalWithSocket:model.socket];//check mode and speed config
        //暂时不搞了
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_CONFIRMROBOT object:nil];
    }
    else
    {
        [server.selectedSocketArray removeObject:model.socket];
        model.isCheck = NO;
        if (server.selectedSocketArray.count == 0) {
            [self setStopBtnGray];
        }else
            [self setStopBtnRed];
    }
}

#pragma mark - Actions
- (void )setStopBtnRed {
    [stopBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}

- (void )setStopBtnGray {
    [stopBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

//mode :0 send
//mode :1 recv
- (void)setDebugLabelText:(NSString *)string mode:(MESSAGEMODE)mode{
    _p_debugLabel.text = nil;
    NSString *str;
    switch (mode) {
        case MESSAGEMODE_SEND:
            str = [NSString stringWithFormat:@"发送: %@",string];
            _p_debugLabel.text = [NSString stringWithFormat:@"%@ \n%@",tmpString,str];
            break;
        case MESSAGEMODE_RECV:
            str = [NSString stringWithFormat:@"接收: %@",string];
            _p_debugLabel.text = [NSString stringWithFormat:@"%@ \n%@",tmpString,str];
        default:
            break;
    }
    tmpString = str;
}

- (void)stopBtnTaped :(UIButton *)btn {
    NSLog(@"stopTaped");
    NSLog(@"selected count :%lu",(unsigned long)m_modelsArray.count);
    int i;
    for ( i = 0 ; i<[m_modelsArray count]; i++) {
        ConnectModel *model = [m_modelsArray objectAtIndex:i];
        if (model.isCheck == YES) {
            [model.socket disconnect];
        }
    }
}

- (void)compareMessage :(NSTimer  *) timer{
    AsyncSocket *S = (AsyncSocket *)[[timer userInfo] objectForKey:@"sock"];
    [S writeData:[@"A" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:-1 tag:0];
    NSLog(@"write A");
}

#pragma mark - Add views
-(void) hideTabelAndDebugLabel {
    rightsideContainer.hidden = YES;
    self.p_debugLabel.hidden = YES;
}

-(void) showTabelAndDebugLabel {
    rightsideContainer.hidden = NO;
    self.p_debugLabel.hidden = NO;
}


- (UILabel *)p_debugLabel {
    if (!_p_debugLabel) {
        _p_debugLabel = [UILabel new];
        _p_debugLabel.backgroundColor = [UIColor lightGrayColor];
        _p_debugLabel.numberOfLines = 0;
    }
    return _p_debugLabel;
}

- (void) addDebugTableView {
    UITableView *m_debugTabelView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
    [self.view addSubview:m_debugTabelView];
    [m_debugTabelView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.p_debugLabel.mas_top);
        make.left.equalTo(self.p_debugLabel);
        make.width.mas_equalTo(self.p_debugLabel);
        make.height.mas_equalTo(@80);
    }];
    m_debugTabelView.backgroundColor = [UIColor clearColor];
    m_debugTabelView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    m_debugTabelView.tag = DEBUGTAG;
    m_debugTabelView.delegate = self;
    m_debugTabelView.dataSource = self;
}

- (void) addRightSideViewContainer {
    rightsideContainer = [UIView new];
    [self.view addSubview:rightsideContainer];
    rightsideContainer.backgroundColor = [UIColor lightGrayColor];
    [rightsideContainer mas_makeConstraints:^(MASConstraintMaker *make) {
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
    [rightsideContainer addSubview:m_tableView];
    [m_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(rightsideContainer);
        make.width.equalTo(rightsideContainer);
        make.bottom.equalTo(rightsideContainer);
        if ([CommonsFunc isDeviceIpad]) {
            make.height.mas_equalTo(@250);
        }else
            make.height.mas_equalTo(@100);
    }];
    m_tableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
    
    tableViewHeader = [self tableHeaderView];
    [rightsideContainer addSubview:tableViewHeader];
    [tableViewHeader mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rightsideContainer);
        make.left.equalTo(m_tableView);
        make.width.equalTo(m_tableView);
        make.height.mas_equalTo(@30);
    }];
    
    stopBtn = [UIButton new];
    [rightsideContainer addSubview:stopBtn];
    [stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(rightsideContainer);
        make.centerX.equalTo(rightsideContainer);
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
}

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
