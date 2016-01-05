//
//  SettingViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/12/2.
//  Copyright © 2015年 郭龙. All rights reserved.
//

#import "SettingViewController.h"
#import "LoginViewController.h"
#import "PickDeskNumViewController.h"

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate>
@property (nonatomic) UITableView *p_tableView;
@end

@implementation SettingViewController
@synthesize p_tableView;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"设置";
    self.view.backgroundColor = [CommonsFunc colorOfSystemBackground];
    
    NSInteger scrreenWidth = [UIScreen mainScreen].bounds.size.width;
    NSInteger scrreenHeight = [UIScreen mainScreen].bounds.size.height;
    p_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, scrreenWidth, scrreenHeight) style:UITableViewStylePlain];
    p_tableView.delegate = self;
    p_tableView.dataSource =self;
    p_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:p_tableView];
    p_tableView.backgroundColor = [CommonsFunc colorOfSystemBackground];
    
    [self.navigationController.navigationBar setTintColor:[UIColor grayColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    
    UIButton *backBtn = [UIButton new];
    backBtn.backgroundColor = [UIColor blueColor];
    [backBtn setTitle:@"<-返回" forState:UIControlStateNormal];
    [self.view addSubview:backBtn];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-20);
        make.left.equalTo(self.view).offset(20);
        make.size.mas_equalTo(CGSizeMake(90, 40));
    }];
    [backBtn addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] init];
    backItem.title = @"返回";
    self.navigationItem.backBarButtonItem = backItem;
    
//    self.navigationController.navigationBar.backgroundColor = [CommonsFunc colorOfSystemBackground];
    [self.navigationController.navigationBar setBarTintColor:[CommonsFunc colorOfSystemBackground]];
}

- (void)back :(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"cellofMybillss";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    if (indexPath.row == 0) {
        cell.textLabel.text =@"设置桌数";
    }
    if (indexPath.row == 1) {
        cell.textLabel.text =@"设置音乐首数";
    }
    if (indexPath.row == 2) {
        cell.textLabel.text =@"退出登陆";
    }
    cell.backgroundColor = [CommonsFunc colorOfSystemBackground];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row == 0) {
        [self.navigationController pushViewController:[PickDeskNumViewController new] animated:YES];
    }
    if (indexPath.row == 1) {
        PickDeskNumViewController *pickVC = [PickDeskNumViewController new];
        pickVC.isSongChoose = YES;
        [self.navigationController pushViewController:pickVC animated:YES];
    }
    if (indexPath.row == 2) {
        UIAlertView *alet = [[UIAlertView alloc] initWithTitle:@"确定退出登录？" message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
        [alet show];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self logout];
    }
}

- (void) logout {
    MainViewController *main =(MainViewController *) self.tabBarController;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 在delegate中初始化新的controller
    // 修改rootViewController
    // [delegate.window addSubview:delegate.main.view];
    [main.view removeFromSuperview];
    delegate.window.rootViewController = [LoginViewController new];
    
    [self dismissViewControllerAnimated:YES completion:^{
        HitControl *cont = [HitControl sharedControl];
        [cont stopAll];
//            MainViewController *main =(MainViewController *) self.tabBarController;
//            AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//            // 在delegate中初始化新的controller
//            // 修改rootViewController
//            //    [delegate.window addSubview:delegate.main.view];
//            [main.view removeFromSuperview];
//            delegate.window.rootViewController = [LoginViewController new];
    }];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
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
