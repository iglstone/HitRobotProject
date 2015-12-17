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

@interface MainViewController () <UITableViewDataSource,UITableViewDelegate> {

    NSMutableArray *m_cellsArray;
}

@property (nonatomic) UITableView *m_tableView;
@property (nonatomic) NSMutableArray *m_modelsArray;
//@property (nonatomic) NSMutableArray *m_selecedModelsArray;
@property (nonatomic) UIButton *stopBtn;
@property (nonatomic) NSString *tmpString;
@property (nonatomic) ConnectStatesCell *tmpCell;
@property (nonatomic) HitControl *control;

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
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    [self presentViewController:[LoginViewController new] animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
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

#pragma mark - Actions
- (void )setStopBtnRed {
    [stopBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
}

- (void )setStopBtnGray {
    [stopBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
}

//mode :0 send
//mode :1 recv
- (void)setDebugLabelText:(NSString *)string mode:(int)mode{
    m_debugLabel.text = nil;
    NSString *str;
    if ( !mode) {
        str = [NSString stringWithFormat:@"send: %@",string];
        m_debugLabel.text = [NSString stringWithFormat:@" %@ \n %@",tmpString,str];
    }else{
        str = [NSString stringWithFormat:@"recv: %@",string];
        m_debugLabel.text = [NSString stringWithFormat:@"%@ \n %@",tmpString,str];
    }
    tmpString = str;
}

- (void)stopBtnTaped :(UIButton *)btn {
    NSLog(@"stopTaped");
//    tmpCell.isChecked = NO;
    [m_selecedModelsArray enumerateObjectsUsingBlock:^(ConnectModel *model, NSUInteger idx, BOOL *stop) {
        [model.socket disconnect];
    }];
    
//    for (ConnectModel *model in m_selecedModelsArray) {
//        [model.socket disconnect];
//        tmpCell.isChecked = NO;
//        //接下来会传到clientDisconnect方法里，具体操作在那里面进行。
//    }
}


#pragma mark - Notification
- (void)tryAgain :(NSNotification *)noti {
    [self.view makeToast:@"指令发送失败，请重新发送" duration:1.2f position:CSToastPositionCenter];
}

- (void)clientDisconnect :(NSNotification *)noti {
    NSLog(@"clientDisconnect notification");
    NSDictionary *dic = [noti userInfo];
    AsyncSocket *socket = (AsyncSocket *)[dic objectForKey:@"socket"];
    
//    for (ConnectStatesCell *cell in m_cellsArray) {
//            cell.isChecked = NO;
//    }
    
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

- (void)connectSuccess:(NSNotification *)noti {
    NSLog(@"connectSuccess notification");
    NSDictionary *dic = [noti userInfo];
    NSString *host = [dic objectForKey:@"host"];
    NSInteger port = [(NSNumber *)[dic objectForKey:@"port"] integerValue];
    NSString *status = [dic objectForKey:@"status"];
    AsyncSocket *sokect = (AsyncSocket *)[dic objectForKey:@"socket"];
    
    [self.view makeToast:[NSString stringWithFormat:@"连接%@成功", host] duration:1.5 position:CSToastPositionCenter];
    
    ConnectModel *model = [ConnectModel new];
    model.port = port;
    model.hostIp = host;
    model.status = status;
    model.socket = sokect;
    model.isCheck = NO;
    
    [m_modelsArray enumerateObjectsUsingBlock:^(ConnectModel *tmpModel, NSUInteger idx, BOOL *stop) {
        if ([model.hostIp isEqual:tmpModel.hostIp]) {
            [m_modelsArray removeObject:tmpModel];
            [m_modelsArray addObject:model];
        }
    }];
    [m_modelsArray addObject:model];
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_tableView reloadData];
    });
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
