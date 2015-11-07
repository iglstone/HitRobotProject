//
//  FirstViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/10/29.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import "FirstViewController.h"
#include <ifaddrs.h>
#include <arpa/inet.h>


@interface FirstViewController ()

@property (nonatomic) ServerSocket *server;

//@property (nonatomic) HitControl *control;

@end

@implementation FirstViewController
@synthesize server;
//@synthesize control;

- (instancetype)init {
    self = [super init];
    if (self) {
        self  = [super init];
        server = [ServerSocket sharedSocket];
//        control = [HitControl sharedControl];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *ipLabel= [UILabel new];
    ipLabel.text = @"本机ip地址";
    [self.view addSubview:ipLabel];
    [ipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-100);
        make.left.equalTo(self.view).offset(150);
    }];

    UITextField *ipTextField = [UITextField new];
    NSString *serverIp = [self deviceIPAdress];
    ipTextField.text = serverIp;
    ipTextField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:ipTextField];
    [ipTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ipLabel.mas_right).offset(20);
        make.centerY.equalTo(ipLabel);
    }];

    UILabel *portLabel = [UILabel new];
    portLabel.text = @"端口";
    [self.view addSubview:portLabel];
    [portLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(ipLabel);
        make.top.equalTo(ipLabel.mas_bottom).offset(15);
    }];
    
    UITextField *portTextField = [UITextField new];
    NSInteger portNum = LISTEN_PORT;
    portTextField.text = [NSString stringWithFormat:@"%ld", portNum];//@"1234";
    portTextField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:portTextField];
    [portTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(ipTextField);
        make.centerY.equalTo(portLabel);
    }];
    
    UIButton *startBtn = [UIButton new];
    [self.view addSubview:startBtn];
    [startBtn setTitle:@"开始服务" forState:UIControlStateNormal];
    startBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [startBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(ipLabel);
        make.left.equalTo(ipTextField.mas_right).offset(20);
    }];
    [startBtn addTarget:self action:@selector(playBtnTaped:) forControlEvents:UIControlEventTouchUpInside];
    [startBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    
    UIButton *stopBtn = [UIButton new];
    [self.view addSubview:stopBtn];
    [stopBtn setTitle:@"停止服务" forState:UIControlStateNormal];
    stopBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(startBtn);
        make.left.equalTo(startBtn.mas_right).offset(20);
    }];
    [stopBtn addTarget:self action:@selector(stopBtnTaped:) forControlEvents:UIControlEventTouchUpInside];
    [stopBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
}

- (void)playBtnTaped:(UIButton *)btn {
    NSLog(@"image taped");
    [btn setBackgroundColor:[UIColor lightGrayColor]];
    
    [server startListen];
}

- (void)stopBtnTaped :(UIButton *)btn {
    NSLog(@"stopTaped");
    
//    [server sendMessage];
    [server stopListen];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)deviceIPAdress {
    NSString *address = @"an error occurred when obtaining ip address";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) { // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            if( temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);  
    
    NSLog(@"server的IP是：%@", address);
    return address;  
}

@end
