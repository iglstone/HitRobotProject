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
#import "CHYSlider.h"
#import "RadioButton.h"

@interface SecondViewController ()<JSAnalogueStickDelegate>{
    
}

@property (nonatomic) UILabel *analogueLabel;
@property (nonatomic) JSAnalogueStick *analogueStick;
@property (nonatomic) UILabel *velocityLabel;
@property (nonatomic) ServerSocket *server;
@property (nonatomic) HitControl *control;
@property (nonatomic) CHYSlider *steppedSlider;
@property (nonatomic) UIView *radioContainer;
@property (nonatomic) int direction;

@end

@implementation SecondViewController
@synthesize direction;
@synthesize server;
@synthesize control;
@synthesize radioContainer;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [CommonsFunc colorOfSystemBackground];
    
    self.server = [ServerSocket sharedSocket];
    control = [HitControl sharedControl];
    direction = 0;
    
    self.analogueLabel = [UILabel new];
    self.analogueLabel.text = @"0 , 0";
    self.analogueLabel.textAlignment = NSTextAlignmentCenter;
    self.analogueLabel.numberOfLines = 0;
    [self.view addSubview:self.analogueLabel];
    [self.analogueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(100);
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(120, 80));
    }];
    
    self.analogueStick = [[JSAnalogueStick alloc] initWithFrame:CGRectMake(100, 100, 120, 120)];
    [self.view addSubview:self.analogueStick];
    [self.analogueStick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(120, 120));
    }];
    self.analogueStick.delegate = self;
    
    self.velocityLabel = [UILabel new];
    self.velocityLabel.text = @"速度设置：3";
    self.velocityLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.velocityLabel];
    [self.velocityLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.analogueLabel);
        make.left.equalTo(self.analogueLabel.mas_right).offset(200);
        make.width.mas_equalTo(@150);
    }];
    
    _steppedSlider = [[CHYSlider alloc] init];//WithFrame:CGRectMake(0, 0, 250, 30)];
    _steppedSlider.stepped = YES;
    _steppedSlider.minimumValue = 0;
    _steppedSlider.maximumValue = 5;
    _steppedSlider.value = 3;
    _steppedSlider.labelAboveThumb.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.f];
    _steppedSlider.labelAboveThumb.textColor = [UIColor blueColor];
    [self.view addSubview:_steppedSlider];
    [_steppedSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.velocityLabel);
        make.top.equalTo(self.velocityLabel.mas_bottom).offset(30);
        make.size.mas_equalTo(CGSizeMake(250, 30));
    }];
    [_steppedSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    //添加单选模式
    [self addRadioBtn];
    
    //添加信息显示模式
    [self addMessageContainner];
    
    UIButton *stopBtn = [UIButton new];
    [stopBtn setTitle:@"STOP" forState:UIControlStateNormal];
    [stopBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [stopBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [self.view addSubview:stopBtn];
    [stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.analogueStick);
        make.bottom.equalTo(self.view).offset(-40-40);
    }];
    [stopBtn addTarget:self action:@selector(stopRun:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)addMessageContainner {
    UIView *messageContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 20, 300, 400)];
    messageContainer.backgroundColor = [CommonsFunc colorOfLight];
    messageContainer.layer.cornerRadius = 4;
    messageContainer.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    messageContainer.layer.borderWidth = 1.0;
    [self.view addSubview:messageContainer];
    [messageContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(radioContainer.mas_bottom).offset(20);
        make.left.equalTo(radioContainer);
        make.width.mas_equalTo(@200);
        make.height.mas_equalTo(@200);
    }];
    
    UILabel *questionText = [[UILabel alloc] initWithFrame:CGRectMake(0,0,280,20)];
    questionText.backgroundColor = [UIColor clearColor];
    questionText.text = @"信息显示：";
    [messageContainer addSubview:questionText];
    [questionText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageContainer);
        make.left.equalTo(messageContainer);
    }];
    
    UILabel *powerLabel = [UILabel new];
    powerLabel.text = @"剩余电量： 80%";
    powerLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:powerLabel];
    [powerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(questionText).offset(20);
        make.top.equalTo(questionText.mas_bottom).offset(20);
    }];
    
    UILabel *speedLabel = [UILabel new];
    speedLabel.text = @"当前速度： 0.7 m/s";
    speedLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:speedLabel];
    [speedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(powerLabel);
        make.top.equalTo(powerLabel.mas_bottom).offset(20);
    }];
    
    UILabel *voiceLable = [UILabel new];
    voiceLable.text = @"当前音量： 70";
    voiceLable.textColor = [UIColor darkGrayColor];
    [self.view addSubview:voiceLable];
    [voiceLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(speedLabel);
        make.top.equalTo(speedLabel.mas_bottom).offset(20);
    }];
}

- (void)addRadioBtn {
    radioContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 20, 300, 400)];
    radioContainer.backgroundColor = [CommonsFunc colorOfLight];
    radioContainer.layer.cornerRadius = 4;
    radioContainer.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    radioContainer.layer.borderWidth = 1.0;
    [self.view addSubview:radioContainer];
    [radioContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(50);
        make.left.equalTo(self.view).offset(50);
        make.width.mas_equalTo(@200);
        make.height.mas_equalTo(@150);
    }];
    
    UILabel *questionText = [[UILabel alloc] initWithFrame:CGRectMake(0,0,280,20)];
    questionText.backgroundColor = [UIColor clearColor];
    questionText.text = @"选择服务模式：";
    [radioContainer addSubview:questionText];
    [questionText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(radioContainer);
        make.left.equalTo(radioContainer);
    }];
    
    NSArray *arr = @[@"送餐模式",@"控制模式"];
    for (int i = 0; i < 2; i++) {
        RadioButton *rb = [[RadioButton alloc] initWithGroupId:@"first group" index:i];
        rb.tag = i + 100;
        [radioContainer addSubview:rb];
        [rb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(radioContainer).offset(40 + 50*i);
            make.left.equalTo(radioContainer).offset(10);
            make.size.mas_equalTo(CGSizeMake(100, 22));
        }];
        [rb.button setTitle:arr[i] forState:UIControlStateNormal];
    }
    
    RadioButton *rb = (RadioButton *)[self.view viewWithTag:100];
    [rb setChecked:YES];
    [RadioButton addObserverForGroupId:@"first group" observer:self];
}

-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{
    NSLog(@"changed to %lu in %@",(unsigned long)index,groupId);
    if (index == 0) {
        NSLog(@"meal mode");
        [control mealMode];
    }
    else
    {
        NSLog(@"control mode");
        [control controlMode];
    }
}

- (void)sliderValueChanged :(CHYSlider *)slider {
    NSLog(@"change %f",slider.value);
    self.velocityLabel.text = [NSString stringWithFormat:@"速度设置：%.0f",slider.value];
    if (slider.value == 0) {
        [control stopMove];
        [self updateAnalogueLabel:@"停止"];
    }
    if (slider.value == 1) {
        [control speed:1];
    }
    if (slider.value == 2) {
        [control speed:2];
    }
    if (slider.value == 3) {
        [control speed:3];
    }
    if (slider.value == 4) {
        [control speed:4];
    }
    if (slider.value == 5) {
        [control speed:5];
    }

}

- (void)stopRun:(UIButton *)btn {
    [control stopMove];
    [self updateAnalogueLabel:@"停止"];
}

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick {
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
    
    NSString *turn = @"";
    if (analogueStick.xValue == 0 && analogueStick.yValue == 0) {
        NSLog(@"backToOrigine");
        
        switch (direction) {
            case 1:
                NSLog(@"向上");
                turn = @"向上";
                [control forward];
                direction = 0;
                break;
            
            case 2:
                NSLog(@"向下");
                turn = @"向下";
                [control backward];
                direction = 0;
                break;
            
            case 3:
                NSLog(@"向右");
                turn = @"向右";
                [control turnRight];
                direction = 0;
                break;
                
            case 4:
                NSLog(@"向左");
                turn = @"向左";
                [control turnLeft];
                direction = 0;
                break;
                
            default:
                break;
        }
    }
    [self updateAnalogueLabel: turn];
}

- (void)updateAnalogueLabel: (NSString *)turn
{
    [self.analogueLabel setText:[NSString stringWithFormat:@"x:%.1f , y:%.1f \n %@", self.analogueStick.xValue, self.analogueStick.yValue, turn]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
