//
//  ResetSecurityViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/12/2.
//  Copyright © 2015年 郭龙. All rights reserved.
//

#import "ResetSecurityViewController.h"
#import <UIView+Toast.h>

@interface ResetSecurityViewController ()

@end

@implementation ResetSecurityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"密码重置";
    self.view.backgroundColor = [UIColor colorWithHexString:@"9f9f5f"];
    
    self.view.backgroundColor = [UIColor colorOfSxiNine];
    
//    NSInteger scrreenWidth = [UIScreen mainScreen].bounds.size.width;
//    NSInteger scrreenHeight = [UIScreen mainScreen].bounds.size.height;
    
    UIView *view1 = [self customView:@"原始密码" textFieldTag:100];
    [self.view addSubview:view1];
    [view1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-60);
        make.size.mas_equalTo(CGSizeMake(300, 50));
    }];

    UIView *view2 = [self customView:@"输入新密码" textFieldTag:101];
    [self.view addSubview:view2];
    [view2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view1);
        make.top.equalTo(view1.mas_bottom).offset(1);
        make.size.mas_equalTo(CGSizeMake(300, 50));
    }];

    UIView *view3 = [self customView:@"重输新密码" textFieldTag:102];
    [self.view addSubview:view3];
    [view3 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view2);
        make.top.equalTo(view2.mas_bottom).offset(1);
        make.size.mas_equalTo(CGSizeMake(300, 50));
    }];
    
    UIButton *btn = [UIButton new];
    [self.view addSubview:btn];
    [btn setBackgroundColor:[UIColor orangeColor]];
    [btn setTitle:@"确定" forState:UIControlStateNormal];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-40);
        make.right.equalTo(view3);
        make.size.mas_equalTo(CGSizeMake(130, 45));
    }];
    [btn addTarget:self action:@selector(done:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *cancelBtn = [UIButton new];
    [self.view addSubview:cancelBtn];
    [cancelBtn setBackgroundColor:[UIColor orangeColor]];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(btn);
        make.left.equalTo(view3);
        make.size.mas_equalTo(CGSizeMake(130, 45));
    }];
    [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
//    [self.navigationController.navigationBar setTintColor:[UIColor lightGrayColor]];
    [self.navigationController.navigationBar setBarTintColor:[UIColor orangeColor]];
}

- (void)done:(id)sender {
    UITextField *tx1 = [self.view viewWithTag:100];
    UITextField *tx2 = [self.view viewWithTag:101];
    UITextField *tx3 = [self.view viewWithTag:102];
    if (!tx1 || !tx2 || !tx3) {
        [self toastShow:@"请填写完整"];
        return;
    }
    
    NSString *username= (NSString *)[[NSUserDefaults standardUserDefaults] objectForKey:NSDEFAULT_USERNAME];
    if (!username) {
        username = @"Admin";
    }
    
    NSString *code = [[NSUserDefaults standardUserDefaults] objectForKey:username];
    if (!code) {
        code = @"123456";
    }
    if (![tx1.text isEqualToString:code]) {
        [self toastShow:@"密码不对"];
        return;
    }
    if (![tx2.text isEqualToString:tx3.text]) {
        [self toastShow:@"两次输入密码不同,请重新输入"];
        tx2.text = nil;tx3.text = nil;
        return;
    }
    if (tx2.text.length < 4) {
        [self toastShow:@"密码长度不能小于4位"];
        return;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_RESETPASSWORD object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:tx2.text forKey:username];
//    NSString *st = [[NSUserDefaults standardUserDefaults] objectForKey:username];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toastShow :(NSString *)msg{
    [self.view makeToast:msg duration:1.0 position:CSToastPositionCenter];
}

- (UIView *)customView :(NSString *)labelText textFieldTag :(NSInteger )tag {
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [UILabel new];
    label.backgroundColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:15];
    label.text = labelText;
    [view addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(view).offset(15);
        make.centerY.equalTo(view);
        make.width.mas_equalTo(@90);
        make.height.mas_equalTo(@40);
    }];
    
    UITextField *textField = [UITextField new];
    textField.backgroundColor = [UIColor whiteColor];
    textField.tag = tag;
    if (tag == 101 || tag == 102) {
        textField.secureTextEntry = YES;
    }
    [view addSubview:textField];
    [textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(view).offset(-15);
        make.centerY.equalTo(label);
        make.left.equalTo(label.mas_right);//.offset(-15);
        make.height.mas_equalTo(@40);
    }];
    
    return view;
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
