//
//  SecondViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/10/29.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import "SecondViewController.h"
#import "JSAnalogueStick.h"
#import <math.h>

@interface SecondViewController ()<JSAnalogueStickDelegate>{

}

@property (nonatomic) UILabel *analogueLabel;
@property (nonatomic) JSAnalogueStick *analogueStick;
@property (nonatomic) UILabel *velocityLabel;
@property (nonatomic) ServerSocket *server;
@property (nonatomic) HitControl *control;

@property (nonatomic) int direction;

@end

@implementation SecondViewController
@synthesize direction;
@synthesize server;
@synthesize control;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.server = [ServerSocket sharedSocket];
    control = [HitControl sharedControl];
    direction = 0;
    
    self.analogueLabel = [UILabel new];
    self.analogueLabel.text = @"0 , 0";
    self.analogueLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.analogueLabel];
    [self.analogueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(120, 40));
    }];
    
    self.analogueStick = [[JSAnalogueStick alloc] initWithFrame:CGRectMake(100, 100, 120, 120)];
    [self.view addSubview:self.analogueStick];
    [self.analogueStick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(120, 120));
    }];
    self.analogueStick.delegate = self;
    
    self.velocityLabel = [UILabel new];
    self.velocityLabel.text = @"速度设置：50.0";
    self.velocityLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.velocityLabel];
    [self.velocityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.analogueLabel);
        make.left.equalTo(self.analogueLabel.mas_right).offset(200);
        make.width.mas_equalTo(@150);
    }];
    
    UISlider *slide = [[UISlider alloc]initWithFrame:CGRectMake(100, 100, 200, 100)];
    slide.minimumValue = 0;
    slide.maximumValue = 100;
    slide.value = 50;
    slide.continuous = NO;
    [self.view addSubview:slide];
    [slide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.velocityLabel);
        make.top.equalTo(self.velocityLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(150, 50));
    }];
    [slide addTarget:self action:@selector(updateVelocity:) forControlEvents:UIControlEventValueChanged];
    
    UISwitch *controlSwitch = [UISwitch new];
    controlSwitch.tag = 100;
    controlSwitch.on = NO;
    [self.view addSubview:controlSwitch];
    [controlSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.analogueLabel);
        make.right.equalTo(self.analogueLabel.mas_left).offset(-240);
    }];
    [controlSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *controlLabel = [UILabel new];
    controlLabel.text = @"控制模式:";
    [self.view addSubview:controlLabel];
    [controlLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(controlSwitch);
        make.right.equalTo(controlSwitch.mas_left).offset(-20);
    }];
    
    UISwitch *mealSwitch = [UISwitch new];
    mealSwitch.tag = 101;
    [self.view addSubview:mealSwitch];
    [mealSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(controlSwitch);
        make.centerY.equalTo(controlSwitch).offset(50);
    }];
    [mealSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    
    UILabel *mealLabel = [UILabel new];
    mealLabel.text = @"送餐模式:";
    [self.view addSubview:mealLabel];
    [mealLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(mealSwitch);
        make.right.equalTo(controlLabel);
    }];
    
    UILabel *powerLabel = [UILabel new];
    powerLabel.text = @"剩余电量： 80%";
    [self.view addSubview:powerLabel];
    [powerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(mealLabel);
        make.top.equalTo(mealLabel.mas_bottom).offset(40);
    }];
    
    UILabel *speedLabel = [UILabel new];
    speedLabel.text = @"当前速度： 0.7 m/s";
    [self.view addSubview:speedLabel];
    [speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(powerLabel);
        make.top.equalTo(powerLabel.mas_bottom).offset(20);
    }];
    
    UILabel *voiceLable = [UILabel new];
    voiceLable.text = @"当前音量： 70";
    [self.view addSubview:voiceLable];
    [voiceLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(speedLabel);
        make.top.equalTo(speedLabel.mas_bottom).offset(20);
    }];
    
    UIButton *stopBtn = [UIButton new];
    [stopBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [self.view addSubview:stopBtn];
    [stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.analogueStick);
        make.top.equalTo(self.analogueStick.mas_bottom).offset(40);
    }];
    [stopBtn addTarget:self action:@selector(stopRun:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)stopRun:(UIButton *)btn {
//    [server sendMessage:@"g"];
    [control stopMove];
}

- (void)switchAction:(UISwitch *)swi {
    UISwitch *swith1 = (UISwitch *)[self.view viewWithTag:100];
    UISwitch *swith2 = (UISwitch *)[self.view viewWithTag:101];
    
    if (swi.tag == 100 && swi.on == YES) {
        if (swith2.on == YES) {
            swith2.on = NO;
            NSLog(@"开启控制模式");
//            [self.server sendMessage:@"b"];
            [control controlMode];
        }
    }
    
    if (swi.tag == 101 && swi.on == YES) {
        if (swith1.on == YES) {
            swith1.on = NO;
            NSLog(@"开启送餐模式");
//            [self.server sendMessage:@"a"];
            [control mealMode];
        }
    }
    
}

- (void )updateVelocity:(UISlider *)slider {
    self.velocityLabel.text = [NSString stringWithFormat:@"速度设置：%.1f",slider.value];
    if (slider.value < 20) {
//        [server sendMessage:@"j"];
        [control speed:1];
    }
    if (20 <= slider.value && slider.value < 40) {
//        [server sendMessage:@"k"];
        [control speed:2];
    }
    if (40 <= slider.value && slider.value < 60) {
//        [server sendMessage:@"l"];
        [control speed:3];
    }
    if (60 <= slider.value && slider.value < 80) {
//        [server sendMessage:@"m"];
        [control speed:4];
    }
    if (80 <= slider.value && slider.value < 100) {
//        [server sendMessage:@"n"];
        [control speed:5];
    }
    
}

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick {
    [self updateAnalogueLabel];
    float x = analogueStick.xValue;
    float y = analogueStick.yValue;
    if ((0 < y) &&  (fabs(x) < fabs(y))) {
        direction = 1;//向上
    }
    
    if ((0 > y) &&  (fabs(x) < fabs(y))) {
        direction = 2;//向下
    }
    
    if ((0 < x) &&  (fabs(x) > fabs(y))) {
        direction = 3;//向右
    }
    
    if ((0 > x) &&  (fabs(x) > fabs(y))) {
        direction = 4;//向左
    }
    
    if (analogueStick.xValue == 0 && analogueStick.yValue == 0) {
        NSLog(@"backToOrigine");

        switch (direction) {
            case 1:
                NSLog(@"向上");
//                [server sendMessage:@"c"];
                [control forward];
                direction = 0;
                break;
            
            case 2:
                NSLog(@"向下");
//                [server sendMessage:@"d"];
                [control backward];
                direction = 0;
                break;
            
            case 3:
                NSLog(@"向右");
//                [server sendMessage:@"f"];
                [control turnRight];
                direction = 0;
                break;
                
            case 4:
                NSLog(@"向左");
//                [server sendMessage:@"e"];
                [control turnLeft];
                direction = 0;
                break;
                
            default:
                break;
        }
    }
}

- (void)updateAnalogueLabel
{
    [self.analogueLabel setText:[NSString stringWithFormat:@"x:%.1f , y:%.1f", self.analogueStick.xValue, self.analogueStick.yValue]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
