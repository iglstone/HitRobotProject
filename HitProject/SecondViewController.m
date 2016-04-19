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
#import "JSDPad.h"
#import "RobotStateCell.h"

@interface SecondViewController ()<JSAnalogueStickDelegate, JSDPadDelegate, UITableViewDelegate, UITableViewDataSource> {
    UILabel *redVoiceLable;
    UILabel *redSpeedLabel;
    
    UILabel *bluePowerLabel;
    UILabel *blueVoiceLable;
    UILabel *blueSpeedLabel;
    
    NSMutableArray *eleMutArray;
    int times;
    
    JSDPad *_jsDpadView;
    NSDate *pressedDate;
    
    NSString *tempRedVotage;
    NSString *tempBlueVotage;
    
    UITableView *pTableView;
    NSMutableArray *pRobotStateModelsArray;
}

@property (nonatomic) UILabel         *analogueLabel;
@property (nonatomic) JSAnalogueStick *analogueStick;
@property (nonatomic) UILabel         *velocityLabel;
@property (nonatomic) ServerSocket    *server;
@property (nonatomic) HitControl      *control;
@property (nonatomic) CHYSlider       *steppedSlider;
@property (nonatomic) UIView          *radioContainer;
@property (nonatomic) int             direction;
@property (nonatomic) UILabel         *redPowerLabel;
@property (nonatomic) UIButton        *pForwardBtn;
@property (nonatomic) BOOL            pIsForwardPressed;
@property (nonatomic) UIButton        *pBackwardBtn;
@property (nonatomic) BOOL            pIsBackwardPressed;
@end

@implementation SecondViewController
@synthesize direction;
@synthesize server;
@synthesize control;
@synthesize radioContainer;
@synthesize redPowerLabel;

#pragma mark - lifeCiclye
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
    
    self.pIsForwardPressed  = NO;
    self.pIsBackwardPressed = NO;
    [self.view addSubview: self.pForwardBtn];
    [self.pForwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(180);
        make.centerX.equalTo(self.view).offset(-120);
    }];
    
    [self.view addSubview:self.pBackwardBtn];
    [self.pBackwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.pForwardBtn);
        make.centerY.equalTo(self.pForwardBtn).offset(100);
    }];
    
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
    
    self.analogueStick = [[JSAnalogueStick alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    [self.view addSubview:self.analogueStick];
    [self.analogueStick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(-150);
        make.bottom.equalTo(self.view).offset(-100);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    self.analogueStick.delegate = self;
    /**
     *  test hisden analogue
     */
    self.analogueStick.hidden = YES;
    
    _jsDpadView = [[JSDPad alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    [self.view addSubview:_jsDpadView];
    [_jsDpadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];
    _jsDpadView.delegate = self;
    _jsDpadView.hidden = NO;
    
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
    _steppedSlider.value = 2;
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
    
    UIButton *stopBtn = [UIButton new];
    [stopBtn setTitle:@"STOP" forState:UIControlStateNormal];
    [stopBtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [stopBtn setBackgroundImage:[UIImage imageNamed:@"button.png"] forState:UIControlStateNormal];
    [self.view addSubview:stopBtn];
    [stopBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([CommonsFunc isDeviceIpad]) {
            make.centerX.equalTo(self.analogueStick).offset(150);
            make.centerY.equalTo(self.analogueStick);
        } else
        {
            make.right.equalTo(self.view).offset(-20);
            make.bottom.equalTo(self.view).offset(-40-40-30);
        }
    }];
    [stopBtn addTarget:self action:@selector(stopRun:) forControlEvents:UIControlEventTouchUpInside];
    
    
    pRobotStateModelsArray = [NSMutableArray new];
    MainViewController *main =(MainViewController *) self.tabBarController;
    pRobotStateModelsArray = main.m_modelsArray;
    [main addObserver:self forKeyPath:@"m_modelsArray" options:NSKeyValueObservingOptionNew context:nil];
    
    pTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
    [self.view addSubview:pTableView];
    pTableView.delegate = self;
    pTableView.dataSource = self;
    [pTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(radioContainer.mas_bottom).offset(20);
        make.left.equalTo(radioContainer);
        make.width.equalTo(radioContainer);
        make.bottom.equalTo(self.view);
    }];
    pTableView.backgroundColor = [UIColor clearColor];
    pTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)dealloc{
    [server removeObserver:self forKeyPath:@"kvoPower"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    MainViewController *main =(MainViewController *) self.tabBarController;
    [main removeObserver:self forKeyPath:@"m_modelsArray"];
}

#pragma mark - private
//平均十次显示电量
- (void)lvbo:(float)ele robot:(NSString *)robot {
    if (times < 4) {
        if (times == 1) {//第二次显示电量
            [self disPlayPower:robot power:ele];
        }
        times ++;
        [eleMutArray addObject:@(ele)];
    } else {
        float sums = 0;
        for (id obj in eleMutArray) {
            float tpm =[obj floatValue];
            sums += tpm;
        }
        float average = sums/times;
        times = 0;
        [eleMutArray removeAllObjects];
        [self disPlayPower:robot power:average];
        NSLog(@"average: %f",average);
    }
    NSLog(@"..%f",ele);
}

//显示电量
- (void)disPlayPower :(NSString *)robot  power:(float )average {
    for (ConnectModel *model in pRobotStateModelsArray) {
        if ([model.robotName isEqualToString:ROBOTNAME_RED]) {
            model.robotPower = [NSString stringWithFormat:@"%.0f%%(%@)",average,tempRedVotage];
        }else
            model.robotPower = [NSString stringWithFormat:@"%.0f%%(%@)",average,tempBlueVotage];
    }
    [pTableView reloadData];
    
//    if ([robot isEqualToString:@"red"]) {
//        redPowerLabel.text = [NSString stringWithFormat:@"剩余电量:%.0f%%(%@)",average,tempRedVotage];
//        
////        redPowerLabel.text = [NSString stringWithFormat:@"剩余电量： %.1f%%",average];
////        if (average < 0) {
////            redPowerLabel.text = [NSString stringWithFormat:@"剩余电量： 20%%"];
////            redPowerLabel.textColor = [UIColor darkGrayColor];
////        }else {
////            if (average <= 15) {
////                redPowerLabel.textColor = [UIColor redColor];
////            }else {
////                redPowerLabel.textColor = [UIColor darkGrayColor];
////            }
////        }
//    } else {
//        bluePowerLabel.text = [NSString stringWithFormat:@"剩余电量:%.0f%%(%@)",average,tempBlueVotage];
//        
////        bluePowerLabel.text = [NSString stringWithFormat:@"剩余电量： %.1f%%",average];
////        if (average < 0) {
////            bluePowerLabel.text = [NSString stringWithFormat:@"剩余电量： 20%%"];
////            bluePowerLabel.textColor = [UIColor darkGrayColor];
////        } else {
////            if (average <= 15) {
////                bluePowerLabel.textColor = [UIColor redColor];
////            }else {
////                bluePowerLabel.textColor = [UIColor darkGrayColor];
////            }
////        }
//    }
}

#pragma  mark - notis and observers
- (void)voiceChange :(NSNotification *)noti {
    NSString *voice = [[noti userInfo] objectForKey:@"voice"];
    MainViewController *main =(MainViewController *) self.tabBarController;
    NSArray *arr = main.m_modelsArray;
    if (arr.count<=0) {
        return;
    }
    for (ConnectModel *model in pRobotStateModelsArray) {
        if ([model.robotName isEqualToString:ROBOTNAME_RED]) {
            model.robotVoice = [NSString stringWithFormat:@"%@",voice];
        }else model.robotVoice = [NSString stringWithFormat:@"%@",voice];
    }
    [pTableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    //bluekvoPower
    if ([keyPath isEqualToString:@"kvoPower"]) {
        NSString *string = [change objectForKey:@"new"];
        float Powerfloat = [string floatValue];
        float ele=(float) ((Powerfloat-22)/7.4)*100;
        [self lvbo:ele robot:ROBOTNAME_RED];
        tempRedVotage = string;
    }
    
    if ([keyPath isEqualToString:@"bluekvoPower"]) {
        NSString *string = [change objectForKey:@"new"];
        float Powerfloat = [string floatValue];
        float ele=(float) ((Powerfloat-22)/7.4)*100;
        [self lvbo:ele robot:ROBOTNAME_BLUE];
        tempBlueVotage = string;
    }
    
    if ([keyPath isEqualToString:@"m_modelsArray"]) {
        MainViewController *main =(MainViewController *) self.tabBarController;
        pRobotStateModelsArray = main.m_modelsArray;
        [pTableView reloadData];
    }
}

#pragma mark - tableviewDelegates
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * identity = @"robotState";
    RobotStateCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (cell == nil) {
        cell = [[RobotStateCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identity];
    }
    cell.backgroundColor = [CommonsFunc colorOfLight];
    cell.layer.cornerRadius = 4;
    cell.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    cell.layer.borderWidth = 1.0;
    
    if (pRobotStateModelsArray.count != 0) {
        ConnectModel *model = [pRobotStateModelsArray objectAtIndex:indexPath.row];
        [cell configRobotState:model];
    }
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    MainViewController *main =(MainViewController *) self.tabBarController;
    NSArray *arr = main.m_modelsArray;
    if (arr) {
        return [arr count];
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![CommonsFunc isDeviceIpad]) {
        return 150;
    }else
        return 180;
}

#pragma mark - delegates
-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId {
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

-(void)dPad:(JSDPad *)dPad didPressDirection:(JSDPadDirection)direction2 {
    pressedDate = [NSDate date];
    //    tmpDirection = direction2;
    NSString *string = nil;
    switch (direction2) {
        case JSDPadDirectionNone:
            string = @"None";
            //            [control stopMove];
            break;
        case JSDPadDirectionUp:
            string = @"Up";
            [control forward];
            break;
        case JSDPadDirectionDown:
            string = @"Down";
            [control backward];
            break;
        case JSDPadDirectionLeft:
            [control turnLeft];
            string = @"Left";
            break;
        case JSDPadDirectionRight:
            [control turnRight];
            string = @"Right";
            break;
        case JSDPadDirectionUpLeft:
            string = @"Up Left";
            break;
        case JSDPadDirectionUpRight:
            string = @"Up Right";
            break;
        case JSDPadDirectionDownLeft:
            string = @"Down Left";
            break;
        case JSDPadDirectionDownRight:
            string = @"Down Right";
            break;
        default:
            string = @"None";
            break;
    }
    NSLog(@"%@",string);
}

- (void)dPadDidReleaseDirection:(JSDPad *)dPad {
    NSTimeInterval interval = [pressedDate timeIntervalSinceNow];
    interval = -interval;
    if (interval < 0.2) {
        NSTimer *time = [NSTimer timerWithTimeInterval:0.8 target:self selector:@selector(timeNotEnoughStop:) userInfo:nil repeats:NO];
        [[NSRunLoop currentRunLoop] addTimer:time forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] run];
    }else {
        NSLog(@"release button .. to stop");
        [control stopMove];
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
    
    for (ConnectModel *model in pRobotStateModelsArray) {
        if ([model.robotName isEqualToString:ROBOTNAME_RED]) {
            model.robotSpeed = [NSString stringWithFormat:@"0.%.0f",slider.value];
        }else {
            model.robotSpeed = [NSString stringWithFormat:@"0.%.0f",slider.value];
        }
    }
    [pTableView reloadData];

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

#pragma mark - action
-(void)timeNotEnoughStop:(NSTimer *)timer {
    NSLog(@"timeNotEnough Stop");
    [control stopMove];
}

- (void)pForwardBtnPressed:(UIButton *)btn {
    NSLog(@"pForwardBtnPressed..");
    [btn setImage:[UIImage imageNamed:@"forwardPressed"] forState:UIControlStateNormal];
    [control forward];
}

- (void)pBackwardBtnPressed :(UIButton *)btn {
    NSLog(@"pBackwardBtnPressed");
    [btn setImage:[UIImage imageNamed:@"backwardPressed"] forState:UIControlStateNormal];
    [control backward];
}

- (void)stopRun:(UIButton *)btn {
    [control stopMove];
    [self updateAnalogueLabel:@"停止"];
    
    [self.pForwardBtn setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
    [self.pBackwardBtn setImage:[UIImage imageNamed:@"backward"] forState:UIControlStateNormal];
}

#pragma mark - views
- (UIButton *)pForwardBtn {
    if (!_pForwardBtn) {
        _pForwardBtn = [UIButton new];
        [_pForwardBtn setImage:[UIImage imageNamed:@"forward"] forState:UIControlStateNormal];
        [_pForwardBtn addTarget:self action:@selector(pForwardBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pForwardBtn;
}

- (UIButton *)pBackwardBtn {
    if (!_pBackwardBtn) {
        _pBackwardBtn = [UIButton new];
        [_pBackwardBtn setImage:[UIImage imageNamed:@"backward"] forState:UIControlStateNormal];
        [_pBackwardBtn addTarget:self action:@selector(pBackwardBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _pBackwardBtn;
}

- (void) addRadioBtn{
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
