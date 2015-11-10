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

@interface MainViewController () <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic) UITableView *m_tableView;
@property (nonatomic) NSMutableArray *m_modelsArray;
@property (nonatomic) NSMutableArray *m_selecedModelsArray;

@end

@implementation MainViewController
@synthesize m_tableView;
@synthesize m_modelsArray;
@synthesize m_selecedModelsArray;

- (void)viewDidLoad {
    [super viewDidLoad];
    UIImage *image = [UIImage imageNamed:@"me.png"];
    
    m_modelsArray = [[NSMutableArray alloc] init];
    m_selecedModelsArray = [[NSMutableArray alloc] init];
    
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
    
    m_tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 100, 40) style:UITableViewStylePlain];
    [m_tableView setBackgroundColor:[CommonsFunc colorOfLight]];
    m_tableView.delegate = self;
    m_tableView.dataSource = self;
    [self.view addSubview:m_tableView];
    [m_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view).offset(-5);
        make.width.mas_equalTo(@300);
        make.top.equalTo(self.view).offset(300);
        make.bottom.equalTo(self.view).offset(-50-5);
    }];
    m_tableView.tableFooterView =[[UIView alloc] initWithFrame:CGRectZero];
    m_tableView.tableHeaderView = [self tableHeaderView];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectSuccess:) name:NOTICE_CONNECTSUCCESS object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(clientDisconnect:) name:NOTICE_DISCONNECT object:nil];
}

- (void)clientDisconnect :(NSNotification *)noti {
    NSDictionary *dic = [noti userInfo];
    AsyncSocket *socket = (AsyncSocket *)[dic objectForKey:@"socket"];
    for (ConnectModel *model in m_modelsArray) {
        if ([model.socket isEqual:socket]) {
            model.status = @"disconnect";
            dispatch_async(dispatch_get_main_queue(), ^{
                [m_tableView reloadData];
            });
        }
    }
}

- (void)connectSuccess:(NSNotification *)noti {
    NSDictionary *dic = [noti userInfo];
    NSString *host = [dic objectForKey:@"host"];
    NSInteger port = [(NSNumber *)[dic objectForKey:@"port"] integerValue];
    NSString *status = [dic objectForKey:@"status"];
    AsyncSocket *sokect = (AsyncSocket *)[dic objectForKey:@"socket"];
    
    ConnectModel *model = [ConnectModel new];
    model.port = port;
    model.hostIp = host;
    model.status = status;
    model.socket = sokect;
    [m_modelsArray addObject:model];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [m_tableView reloadData];
    });
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - alert delegete
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString * identity = @"ipsId";
    ConnectStatesCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[ConnectStatesCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    
    ConnectModel *model = [m_modelsArray objectAtIndex:indexPath.row];
    [cell configModel:model];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return m_modelsArray.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    ConnectStatesCell *cell = (ConnectStatesCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.isChecked = !cell.isChecked;
    ConnectModel *model = [m_modelsArray objectAtIndex:indexPath.row];
    [m_selecedModelsArray addObject:model];
}


- (UIView *)tableHeaderView {
    UIView *headerview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 30)];
    UILabel *iplabel = [UILabel new];
    iplabel.text = @"client ip";
    [headerview addSubview:iplabel];
    [iplabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(headerview);
        make.left.equalTo(headerview).offset(20);
    }];
    
    UILabel *portLable = [UILabel new];
    [portLable setText:@"port"];
    [headerview addSubview:portLable];
    [portLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(headerview);
    }];
    
    UILabel *status = [UILabel new];
    status.text = @"status";
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
