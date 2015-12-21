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
#import "MainViewController.h"
#import "ConnectStatesCell.h"

@interface SecondViewController ()<JSAnalogueStickDelegate> {
    UILabel *redVoiceLable;
    UILabel *redSpeedLabel;
    
    UILabel *bluePowerLabel;
    UILabel *blueVoiceLable;
    UILabel *blueSpeedLabel;
    
    UIView *redMessageContainer;
    NSMutableArray *eleMutArray;
    int times;
}

@property (nonatomic) UILabel *analogueLabel;
@property (nonatomic) JSAnalogueStick *analogueStick;
@property (nonatomic) UILabel *velocityLabel;
@property (nonatomic) ServerSocket *server;
@property (nonatomic) HitControl *control;
@property (nonatomic) CHYSlider *steppedSlider;
@property (nonatomic) UIView *radioContainer;
@property (nonatomic) int direction;
@property (nonatomic) UILabel *redPowerLabel;

@end

@implementation SecondViewController
@synthesize direction;
@synthesize server;
@synthesize control;
@synthesize radioContainer;
@synthesize redPowerLabel;

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceChange:) name:NOTICE_VOICECHANGE object:nil];
        eleMutArray = [[NSMutableArray alloc] initWithCapacity:10];
        times = 0;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    MainViewController *main =(MainViewController *) self.tabBarController;
    if (![CommonsFunc isDeviceIpad]) {
        main.views.hidden = YES;
        main.m_debugLabel.hidden = NO;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [CommonsFunc colorOfSystemBackground];
    
    self.server = [ServerSocket sharedSocket];
    control = [HitControl sharedControl];
    direction = 0;
    [server addObserver:self forKeyPath:@"kvoPower" options:NSKeyValueObservingOptionNew context:nil];
    [server addObserver:self forKeyPath:@"bluekvoPower" options:NSKeyValueObservingOptionNew context:nil];
    
    self.analogueLabel = [UILabel new];
    self.analogueLabel.text = @"0 , 0";
    self.analogueLabel.textAlignment = NSTextAlignmentCenter;
    self.analogueLabel.numberOfLines = 0;
    [self.view addSubview:self.analogueLabel];
    if ([CommonsFunc isDeviceIpad]) {
        [self.analogueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(100);
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(120, 80));
        }];
    }else {
        [self.analogueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view).offset(30);
            make.centerX.equalTo(self.view);
            make.size.mas_equalTo(CGSizeMake(120, 80));
        }];
    }
    
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
        if ([CommonsFunc isDeviceIpad]) {
            make.centerY.equalTo(self.analogueLabel);
            make.left.equalTo(self.analogueLabel.mas_right).offset(200);
        } else {
            make.centerY.equalTo(self.analogueLabel).offset(-20);
            make.right.equalTo(self.view).offset(-50);
        }
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
        if ([CommonsFunc isDeviceIpad]) {
            make.size.mas_equalTo(CGSizeMake(250, 30));
        }else
            make.size.mas_equalTo(CGSizeMake(220, 30));
        
    }];
    
    [_steppedSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    //添加单选模式
    [self addRadioBtn];
    
    //添加信息显示模式
    [self addRedRobotMessageContainner];
    [self addBlueRobotMessageContainer];
    
    UIButton *stopBtn = [UIButton new];
    [stopBtn setTitle:@"STOP" forState:UIControlStateNormal];
    [stopBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [stopBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [self.view addSubview:stopBtn];
    [stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([CommonsFunc isDeviceIpad]) {
            make.centerX.equalTo(self.analogueStick);
            make.bottom.equalTo(self.view).offset(-40-40);
        } else
        {
            make.right.equalTo(self.view).offset(-20);
            make.bottom.equalTo(self.view).offset(-40-40-30);
        }
    }];
    [stopBtn addTarget:self action:@selector(stopRun:) forControlEvents:UIControlEventTouchUpInside];
    
}

//平均十次显示电量
- (void)lvbo:(float)ele robot:(NSString *)robot{
    if (times < 10) {
        if (times == 1) {//第二次显示电量
            [self disPlayPower:robot power:ele];
        }
        times ++;
        [eleMutArray addObject:@(ele)];
        
    } else {
        eleMutArray = nil;
        times = 0;
        float sums = 0;
        
        for (id obj in eleMutArray) {
            float tpm =[obj floatValue];
            sums += tpm;
        }
        float average = sums/times;
        [self disPlayPower:robot power:average];
    }
}

//显示电量
- (void)disPlayPower :(NSString *)robot  power:(float )average {
    if ([robot isEqualToString:@"red"]) {
        redPowerLabel.text = [NSString stringWithFormat:@"剩余电量： %.1f%%",average];
        if (average < 0) {
            redPowerLabel.text = [NSString stringWithFormat:@"剩余电量： 20%%"];
            redPowerLabel.textColor = [UIColor darkGrayColor];
        }else {
            if (average <= 15) {
                redPowerLabel.textColor = [UIColor redColor];
            }else {
                redPowerLabel.textColor = [UIColor darkGrayColor];
            }
        }
        
    } else {
        
        bluePowerLabel.text = [NSString stringWithFormat:@"剩余电量： %.1f%%",average];
        if (average < 0) {
            bluePowerLabel.text = [NSString stringWithFormat:@"剩余电量： 20%%"];
            bluePowerLabel.textColor = [UIColor darkGrayColor];
        } else {
            if (average <= 15) {
                bluePowerLabel.textColor = [UIColor redColor];
            }else {
                bluePowerLabel.textColor = [UIColor darkGrayColor];
            }
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    //bluekvoPower
    if ([keyPath isEqualToString:@"kvoPower"]) {
        NSString *string = [change objectForKey:@"new"];
        float Powerfloat = [string floatValue];
        float ele=(float) ((Powerfloat-22)/7.4)*100;
        [self lvbo:ele robot:@"red"];
    }
    
    if ([keyPath isEqualToString:@"bluekvoPower"]) {
        NSString *string = [change objectForKey:@"new"];
        float Powerfloat = [string floatValue];
        float ele=(float) ((Powerfloat-22)/7.4)*100;
        [self lvbo:ele robot:@"blue"];
    }
}

- (void)voiceChange :(NSNotification *)noti {
    NSString *voice = [[noti userInfo] objectForKey:@"voice"];
    MainViewController *main =(MainViewController *) self.tabBarController;
    NSArray *arr = main.m_modelsArray;
    if (arr.count<=0) {
        return;
    }
    for (ConnectModel *model in arr) {
        if ([model.robotName isEqualToString:ROBOTNAME_RED]) {
            redVoiceLable.text = [NSString stringWithFormat:@"当前音量：%@",voice];  //@"当前音量： 50";
        }else {
            blueVoiceLable.text = [NSString stringWithFormat:@"当前音量：%@",voice];  //@"当前音量： 50";
        }
    }
//    redVoiceLable.text = [NSString stringWithFormat:@"当前音量：%@",voice];  //@"当前音量： 50";
}

- (void)dealloc{
    [server removeObserver:self forKeyPath:@"kvoPower"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)addBlueRobotMessageContainer {
    UIView *messageContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 20, 300, 400)];
    messageContainer.backgroundColor = [CommonsFunc colorOfLight];
    messageContainer.layer.cornerRadius = 4;
    messageContainer.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    messageContainer.layer.borderWidth = 1.0;
    [self.view addSubview:messageContainer];
    [messageContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(redMessageContainer.mas_bottom).offset(20);
        make.left.equalTo(redMessageContainer);
        make.size.equalTo(redMessageContainer);
    }];
    
    UILabel *questionText = [[UILabel alloc] initWithFrame:CGRectMake(0,0,280,20)];
    questionText.backgroundColor = [UIColor clearColor];
    questionText.text = @"机器人小蓝：";
    if (![CommonsFunc isDeviceIpad]) {
        questionText.font = [UIFont systemFontOfSize:15];
    }
    [messageContainer addSubview:questionText];
    [questionText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(messageContainer);
        make.left.equalTo(messageContainer);
    }];
    
    bluePowerLabel = [UILabel new];
    bluePowerLabel.text = @"剩余电量： 50%";
    bluePowerLabel.textColor = [UIColor darkGrayColor];
    if (![CommonsFunc isDeviceIpad]) {
        bluePowerLabel.font = [UIFont systemFontOfSize:14];
    }
    [self.view addSubview:bluePowerLabel];
    [bluePowerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(questionText).offset(20);
//        make.top.equalTo(questionText.mas_bottom).offset(20);//后期电量不显示
        make.top.equalTo(questionText.mas_bottom).offset(0);
    }];
    bluePowerLabel.hidden = YES;//后期电量不显示
    
    blueSpeedLabel = [UILabel new];
    blueSpeedLabel.text = @"当前速度： 0.3 m/s";
    if (![CommonsFunc isDeviceIpad]) {
        blueSpeedLabel.font = [UIFont systemFontOfSize:14];
    }
    blueSpeedLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:blueSpeedLabel];
    [blueSpeedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(bluePowerLabel);
        make.top.equalTo(bluePowerLabel.mas_bottom).offset(20);
    }];
    
    blueVoiceLable = [UILabel new];
    blueVoiceLable.text = @"当前音量： 50";
    if (![CommonsFunc isDeviceIpad]) {
        blueVoiceLable.font = [UIFont systemFontOfSize:14];
    }
    blueVoiceLable.textColor = [UIColor darkGrayColor];
    [self.view addSubview:blueVoiceLable];
    [blueVoiceLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(blueSpeedLabel);
        make.top.equalTo(blueSpeedLabel.mas_bottom).offset(20);
    }];
}


- (void)addRedRobotMessageContainner {
    redMessageContainer = [[UIView alloc] initWithFrame:CGRectMake(10, 20, 300, 400)];
    redMessageContainer.backgroundColor = [CommonsFunc colorOfLight];
    redMessageContainer.layer.cornerRadius = 4;
    redMessageContainer.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    redMessageContainer.layer.borderWidth = 1.0;
    [self.view addSubview:redMessageContainer];
    [redMessageContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(radioContainer.mas_bottom).offset(20);
        make.left.equalTo(radioContainer);
        make.width.equalTo(radioContainer);
        if (![CommonsFunc isDeviceIpad]) {
            make.height.mas_equalTo(@150);
        }else
            make.height.mas_equalTo(@180);
    }];
    
    UILabel *questionText = [[UILabel alloc] initWithFrame:CGRectMake(0,0,280,20)];
    questionText.backgroundColor = [UIColor clearColor];
    questionText.text = @"机器人小红：";
    if (![CommonsFunc isDeviceIpad]) {
        questionText.font = [UIFont systemFontOfSize:15];
    }
    [redMessageContainer addSubview:questionText];
    [questionText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(redMessageContainer);
        make.left.equalTo(redMessageContainer);
    }];
    
    redPowerLabel = [UILabel new];
    redPowerLabel.text = @"剩余电量： 50%";
    redPowerLabel.textColor = [UIColor darkGrayColor];
    if (![CommonsFunc isDeviceIpad]) {
        redPowerLabel.font = [UIFont systemFontOfSize:14];
    }
    [self.view addSubview:redPowerLabel];
    [redPowerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(questionText).offset(20);
//        make.top.equalTo(questionText.mas_bottom).offset(20);//后期电量不显示
        make.top.equalTo(questionText.mas_bottom).offset(0);
    }];
    redPowerLabel.hidden = YES;//后期电量不显示
    
    redSpeedLabel = [UILabel new];
    redSpeedLabel.text = @"当前速度： 0.3 m/s";
    if (![CommonsFunc isDeviceIpad]) {
        redSpeedLabel.font = [UIFont systemFontOfSize:14];
    }
    redSpeedLabel.textColor = [UIColor darkGrayColor];
    [self.view addSubview:redSpeedLabel];
    [redSpeedLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(redPowerLabel);
        make.top.equalTo(redPowerLabel.mas_bottom).offset(20);
    }];
    
    redVoiceLable = [UILabel new];
    redVoiceLable.text = @"当前音量： 50";
    if (![CommonsFunc isDeviceIpad]) {
        redVoiceLable.font = [UIFont systemFontOfSize:14];
    }
    redVoiceLable.textColor = [UIColor darkGrayColor];
    [self.view addSubview:redVoiceLable];
    [redVoiceLable mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(redSpeedLabel);
        make.top.equalTo(redSpeedLabel.mas_bottom).offset(20);
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
        if ([CommonsFunc isDeviceIpad]) {
            make.top.equalTo(self.view).offset(50);
            make.left.equalTo(self.view).offset(50);
            make.width.mas_equalTo(@200);
            make.height.mas_equalTo(@150);
        }else {
            make.top.equalTo(self.view).offset(10);
            make.left.equalTo(self.view).offset(10);
            make.width.mas_equalTo(@165);
            make.height.mas_equalTo(@120);
        }
        
    }];
    
    UILabel *questionText = [[UILabel alloc] initWithFrame:CGRectMake(0,0,280,20)];
    questionText.backgroundColor = [UIColor clearColor];
    questionText.text = @"选择服务模式：";
    if (![CommonsFunc isDeviceIpad]) {
        questionText.font = [UIFont systemFontOfSize:15];
    }
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
            if ([CommonsFunc isDeviceIpad]) {
                make.top.equalTo(radioContainer).offset(40 + 50*i);
            }else
                make.top.equalTo(radioContainer).offset(40 + 35*i);
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
    
    MainViewController *main =(MainViewController *) self.tabBarController;
    NSArray *arr = main.m_selecedModelsArray;
    if (arr.count<=0) {
        return;
    }
    for (ConnectModel *model in arr) {
        if ([model.robotName isEqualToString:ROBOTNAME_RED]) {
            redSpeedLabel.text = [NSString stringWithFormat:@"当前速度： 0.%.0f m/s",slider.value];//当前速度： 0.3 m/s
        }else {
            blueSpeedLabel.text = [NSString stringWithFormat:@"当前速度： 0.%.0f m/s",slider.value];//当前速度： 0.3 m/s
        }
    }

//    redSpeedLabel.text = [NSString stringWithFormat:@"当前速度： 0.%.0f m/s",slider.value];//当前速度： 0.3 m/s
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
                NSLog(@"前进");
                turn = @"前进";
                [control forward];
                direction = 0;
                break;
            
            case 2:
                NSLog(@"后退");
                turn = @"后退";
                [control backward];
                direction = 0;
                break;
            
            case 3:
                NSLog(@"右转");
                turn = @"右转";
                [control turnRight];
                direction = 0;
                break;
                
            case 4:
                NSLog(@"左转");
                turn = @"左转";
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
