//
//  QQViewController.m
//  QQLogin
//
//  Created by 郭龙 on 15/12/2.
//  Copyright © 2015年 郭龙. All rights reserved.
//

#import "LoginViewController.h"
#import "SettingViewController.h"
#import "ResetSecurityViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WebViewController.h"
#import <UIView+Toast.h>

#define ANIMATION_DURATION 0.3f

@interface LoginViewController ()
{
    UIImageView *userNumberBackImg;
    UITextField *userNumberTf;
    UILabel *numberLabel;
    BOOL isResetPW;
}
@property (strong, nonatomic) IBOutlet UIButton *m_settingBtn;
@property (strong, nonatomic) IBOutlet UIButton *m_securitySetting;
@property (strong, nonatomic) IBOutlet UIView *countGroup;
@property (strong, nonatomic) IBOutlet UIImageView *passWordBg;
@property (nonatomic) BOOL isremmber;
@property (nonatomic) UIButton *rembtn;

@end

@implementation LoginViewController
@synthesize countGroup;
@synthesize isremmber;
@synthesize userNamesArray;
@synthesize rembtn;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    userNumberBackImg = [UIImageView new];
    userNumberBackImg.contentMode = UIViewContentModeScaleToFill;
    [userNumberBackImg setImage:[UIImage imageNamed:@"login_textfield_top.png"]];
    [self.view addSubview:userNumberBackImg];
    [userNumberBackImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.passWordBg.mas_top).offset(-1);
        make.centerX.equalTo(self.passWordBg);
        make.left.equalTo(self.passWordBg).offset(-1);
        make.right.equalTo(self.passWordBg).offset(1);
    }];
    
    numberLabel = [UILabel new];
    [self.view addSubview:numberLabel];
    numberLabel.text = @"账号";
    numberLabel.font = [UIFont systemFontOfSize:15];
    [numberLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.passwordLabel);
        make.centerY.equalTo(userNumberBackImg);
    }];
    
    userNumberTf = [UITextField new];
    userNumberTf.font = [UIFont systemFontOfSize:15];
    userNumberTf.textColor = [UIColor darkGrayColor];
    userNumberTf.text = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:NSDEFAULT_USERNAME];//@"Admin";
    if (userNumberTf.text.length == 0 || !userNumberTf.text) {
        userNumberTf.text = @"Admin";
    }
    [self.view addSubview:userNumberTf];
    [userNumberTf mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.userPassword);
        make.width.equalTo(self.userPassword);
        make.centerY.equalTo(numberLabel);
    }];
    
//    moveDownGroup
    rembtn = [UIButton new];
    rembtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [rembtn setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.view addSubview:rembtn];
    [rembtn setTitle:@"  记住密码" forState:UIControlStateNormal];
    [rembtn setImage:[UIImage imageNamed:@"checkbox1_unchecked"] forState:UIControlStateNormal];
    [rembtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.moveDownGroup.mas_bottom).offset(-5);
        make.centerX.equalTo(self.view);
    }];
    [rembtn addTarget:self action:@selector(remenber:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIImageView *logoView = [UIImageView new];
    logoView.image = [UIImage imageNamed:@"login_avatar.png"];
    [self.view addSubview:logoView];
    [logoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        if ([CommonsFunc isDeviceIpad]) {
            make.bottom.equalTo(userNumberBackImg.mas_top).offset(-30);
            make.size.mas_equalTo(CGSizeMake(65, 65));
        }else {
            make.bottom.equalTo(userNumberBackImg.mas_top).offset(-10);
            make.size.mas_equalTo(CGSizeMake(50, 50));
        }
    }];
    
    UIImageView *logoView2 = [UIImageView new];
    logoView2.image = [UIImage imageNamed:@"logo.png"];
    [self.view addSubview:logoView2];
    [logoView2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(logoView);
        if ([CommonsFunc isDeviceIpad]) {
            make.size.mas_equalTo(CGSizeMake(60, 60));
        }else
            make.size.mas_equalTo(CGSizeMake(45, 45));
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetNoti:) name:NOTICE_RESETPASSWORD object:nil];
    

}

- (void)resetNoti :(id)sender {
    isResetPW = YES;
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"origionPW"];
}


- (void)viewWillAppear:(BOOL)animated {
    isremmber = [[NSUserDefaults standardUserDefaults] boolForKey:NSDEFAULT_REMEMBERCODE];
    if (isremmber) {
        [rembtn setImage:[UIImage imageNamed:@"checkbox1_checked"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NSDEFAULT_REMEMBERCODE];
        if (isResetPW) {
            self.userPassword.text = nil;
        }else
            self.userPassword.text = [[NSUserDefaults standardUserDefaults] objectForKey:userNumberTf.text];
    }else {
        [rembtn setImage:[UIImage imageNamed:@"checkbox1_unchecked"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NSDEFAULT_REMEMBERCODE];
        self.userPassword.text = nil;
    }
}

#pragma mark - actions
- (void)remenber :(UIButton *)sender {
    isremmber = !isremmber;
    if (isremmber) {
        [sender setImage:[UIImage imageNamed:@"checkbox1_checked"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:NSDEFAULT_REMEMBERCODE];
    }else {
        [sender setImage:[UIImage imageNamed:@"checkbox1_unchecked"] forState:UIControlStateNormal];
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:NSDEFAULT_REMEMBERCODE];
    }
}

- (IBAction)settingSecurityCode:(id)sender {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[ResetSecurityViewController new]];
    nav.title = @"密码重置";
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)setting:(UIButton *)sender {
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:[WebViewController new]];
    nav.title = @"公司简介";
    [self presentViewController:nav animated:YES completion:nil];
}

- (IBAction)login:(id)sender {
    
    NSString *tmpName = userNumberTf.text;
    NSString *tmpPassword = self.userPassword.text;
    NSString *defaultPs = (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:tmpName];
    if (!tmpName || tmpName.length == 0) {
        [self toastShow:@"请输入用户名"];
        return;
    }
    if (!tmpPassword || tmpPassword.length == 0 ) {
        [self toastShow:@"请输入密码"];
        return;
    }
    //不管什么情况都记录输入的用户名
    [[NSUserDefaults standardUserDefaults] setObject:tmpName forKey:NSDEFAULT_USERNAME];
    
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"origionPW"]) {
        //表示没修改过了密码，使用初始密码
        if ([tmpName isEqualToString:@"Admin"] && [tmpPassword isEqualToString:@"123456"]) {
            [[NSUserDefaults standardUserDefaults] setObject:tmpPassword forKey:tmpName];
            [self changeViewController];
        }else {
            [self toastShow:@"用户名或密码错误"];
        }
    }else{
        //修改过密码，初始密码失效
        if ([tmpPassword isEqualToString:defaultPs]) {
            [[NSUserDefaults standardUserDefaults] setObject:tmpPassword forKey:tmpName];
            [self changeViewController];
        }else {
            [self toastShow:@"用户名或密码错误"];
        }
    }
}

- (void)changeViewController {
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    // 在delegate中初始化新的controller // 修改rootViewController
    delegate.main = [MainViewController new];
//    [delegate.window addSubview:delegate.main.view];
    [self.view removeFromSuperview];
    delegate.window.rootViewController = delegate.main;
}

- (void)toastShow :(NSString *)msg{
    [self.view makeToast:msg duration:1.0 position:CSToastPositionCenter];
}

- (void)remmenber :(BOOL)yesno name:(NSString *)name password:(NSString *)pw {
//    if (yesno) {
//        [[NSUserDefaults standardUserDefaults] setObject:pw forKey:name];
//    }else {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey: name];
//    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
//    [_userNumber release];
    [_userPassword release];
    [_userLargeHead release];
//    [_numberLabel release];
    [_passwordLabel release];
    [super dealloc];
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    [_userNumber resignFirstResponder];
//    [_userPassword resignFirstResponder];
}
@end
