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

//typedef NS_ENUM(NSInteger , RobotName) {
//    RobotName_Red = 1,
//    RobotName_Blue = 2,
//    RobotName_Gold = 3,
//} ;

@interface SecondViewController ()<JSAnalogueStickDelegate, JSDPadDelegate, UITableViewDelegate, UITableViewDataSource> {
    UILabel *redVoiceLable;
    UILabel *redSpeedLabel;
    UIView *radioContainer;
    JSDPad *jsDpadView;
    NSDate *pressedDate;
    ServerSocket    *server;
    HitControl      *control;
    
    NSString *tempRedVotage;
    NSString *tempBlueVotage;
    NSString *tempGoldVotage;
    NSMutableArray *redEleMutArray;
    NSMutableArray *blueEleMutArray;
    NSMutableArray *goldEleMutArray;
    int redTimes;
    int blueTimes;
    int goldTimes;
    
    UITableView *m_robotsDetailTableView;
    NSMutableArray *m_robotStateModelsArray;
}

@property (nonatomic) UILabel         *analogueLabel;
@property (nonatomic) JSAnalogueStick *analogueStick;
@property (nonatomic) UILabel         *velocityLabel;
@property (nonatomic) CHYSlider       *steppedSlider;
@property (nonatomic) UILabel         *redPowerLabel;
@property (nonatomic) UIButton        *pForwardBtn;
@property (nonatomic) BOOL            pIsForwardPressed;
@property (nonatomic) UIButton        *pBackwardBtn;
@property (nonatomic) BOOL            pIsBackwardPressed;
@end

@implementation SecondViewController

#pragma mark - lifeCiclye
- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(voiceChange:) name:NOTICE_VOICECHANGE object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(configModelAndSpeed:) name:NOTICE_CONFIG_MODE_SPEEDN object:nil];
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
    
    server = [ServerSocket sharedSocket];
    control = [HitControl sharedControl];
    self.pIsForwardPressed  = NO;
    self.pIsBackwardPressed = NO;
    redEleMutArray = [[NSMutableArray alloc] initWithCapacity:10];
    blueEleMutArray = [[NSMutableArray alloc] initWithCapacity:10];
    goldEleMutArray = [[NSMutableArray alloc] initWithCapacity:10];
    redTimes = 0;
    blueTimes = 0;
    goldTimes = 0;
    self.view.backgroundColor = [CommonsFunc colorOfSystemBackground];
    
    m_robotStateModelsArray = [NSMutableArray new];
    if ([self.tabBarController isKindOfClass:[MainViewController class]]) {
        MainViewController *main =(MainViewController *) self.tabBarController;
        m_robotStateModelsArray = main.m_modelsArray;
        [main addObserver:self forKeyPath:@"m_modelsArray" options:NSKeyValueObservingOptionNew context:nil];
    }
    
    [server addObserver:self forKeyPath:@"kvoPower" options:NSKeyValueObservingOptionNew context:nil];
    [server addObserver:self forKeyPath:@"bluekvoPower" options:NSKeyValueObservingOptionNew context:nil];
    [server addObserver:self forKeyPath:@"goldkvoPower" options:NSKeyValueObservingOptionNew context:nil];
    
    [self addSubViews];
    [self viewsMakeConstranins];
}

- (void)addSubViews {
    [self.view addSubview: self.pForwardBtn];
    [self.view addSubview: self.pBackwardBtn];
    [self.view addSubview: self.analogueLabel];
    [self.view addSubview: self.analogueStick];
    [self addJSDpad];
    [self.view addSubview: self.velocityLabel];
    [self.view addSubview: self.steppedSlider];
    //添加单选模式
    [self addRadioBtn];
    [self addStopButton];
    [self addRobotsDeatailTableView];
}

- (void)viewsMakeConstranins {
    [self.pForwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view).offset(180);
        make.centerX.equalTo(self.view).offset(-120);
    }];
    [self.pBackwardBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.pForwardBtn);
        make.centerY.equalTo(self.pForwardBtn).offset(100);
    }];
    [self.analogueStick mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view).offset(-150);
        make.bottom.equalTo(self.view).offset(-100);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
    [self.analogueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(120, 80));
        if ([CommonsFunc isDeviceIpad]) {
            make.top.equalTo(self.view).offset(100);
        }else {
            make.top.equalTo(self.view).offset(30);
        }
    }];
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
    [self.steppedSlider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.velocityLabel);
        make.top.equalTo(self.velocityLabel.mas_bottom).offset(30);
        if ([CommonsFunc isDeviceIpad]) {
            make.size.mas_equalTo(CGSizeMake(250, 30));
        }else
            make.size.mas_equalTo(CGSizeMake(220, 30));
    }];
}

- (void)dealloc{
    [server removeObserver:self forKeyPath:@"kvoPower"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    MainViewController *main =(MainViewController *) self.tabBarController;
    [main removeObserver:self forKeyPath:@"m_modelsArray"];
}

#pragma  mark - notis and observers oaje
- (void)configModelAndSpeed :(NSNotification *)noti {
    NSString *string = [[noti userInfo] objectForKey:@"message"];
    NSString *subModel = [string substringWithRange:NSMakeRange(1, 1)];
    RadioButton *btn = (RadioButton *)[self.view viewWithTag:100];
    RadioButton *btn2 = (RadioButton *)[self.view viewWithTag:101];
    if ([subModel isEqualToString:@"a"]) {
        //meal mode
        [btn setChecked:YES];
        [btn2 setChecked:NO];
    }else {
        //control mode
        [btn2 setChecked:YES];
        [btn setChecked:NO];
    }
    NSString *subSpeed = [string substringWithRange:NSMakeRange(2, 1)];
    if ([subSpeed isEqualToString:@"j"]) {
        _steppedSlider.value = 1;
    }else if ([subSpeed isEqualToString:@"k"]){
        _steppedSlider.value = 2;
    }else if ([subSpeed isEqualToString:@"l"]){
        _steppedSlider.value = 3;
    }else if ([subSpeed isEqualToString:@"m"]){
        _steppedSlider.value = 4;
    }else {
        _steppedSlider.value = 5;
    }
    
}

- (void)voiceChange :(NSNotification *)noti {
    NSString *voice = [[noti userInfo] objectForKey:@"voice"];
    MainViewController *main =(MainViewController *) self.tabBarController;
    NSArray *arr = main.m_modelsArray;
    if (arr.count<=0) {
        return;
    }
    for (ConnectModel *model in m_robotStateModelsArray) {
        if ([model.robotName isEqualToString:ROBOTNAME_RED]) {
            model.robotVoice = [NSString stringWithFormat:@"%@",voice];
        }else if ([model.robotName isEqualToString:ROBOTNAME_BLUE]){
            model.robotVoice = [NSString stringWithFormat:@"%@",voice];
        }else model.robotVoice = [NSString stringWithFormat:@"%@",voice];//小金或者其他
    }
    [m_robotsDetailTableView reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context{
    //bluekvoPower
    if ([keyPath isEqualToString:@"kvoPower"]) {
        NSString *string = [change objectForKey:@"new"];
        float Powerfloat = [string floatValue];
        float ele=(float) ((Powerfloat-22)/7.4)*100;
        [self calcuPower:ele times:redTimes arr:redEleMutArray robot:ROBOTNAME_RED];
        tempRedVotage = string;
    }
    
    if ([keyPath isEqualToString:@"bluekvoPower"]) {
        NSString *string = [change objectForKey:@"new"];
        float Powerfloat = [string floatValue];
        float ele=(float) ((Powerfloat-22)/7.4)*100;
        [self calcuPower:ele times:blueTimes arr:blueEleMutArray robot:ROBOTNAME_BLUE];
        tempBlueVotage = string;
    }
    
    if ([keyPath isEqualToString:@"goldkvoPower"]) {
        NSString *string = [change objectForKey:@"new"];
        float Powerfloat = [string floatValue];
        float ele=(float) ((Powerfloat-22)/7.4)*100;
        [self calcuPower:ele times:goldTimes arr:goldEleMutArray robot:ROBOTNAME_GOLD];
        tempGoldVotage = string;
    }
    
    if ([keyPath isEqualToString:@"m_modelsArray"]) {
        MainViewController *main =(MainViewController *) self.tabBarController;
        m_robotStateModelsArray = main.m_modelsArray;
        [m_robotsDetailTableView reloadData];
    }
}

#pragma mark - private
- (void)calcuPower:(float)ele times:(int)times arr:(NSMutableArray *)arr robot:(NSString *)robotName{
    if (times < 4) {
        times ++;
        [arr addObject:@(ele)];
    } else {
        times = 0;
        float sum = 0;
        for (id obj in arr) {
            float ele = [obj floatValue];
            sum += ele;
        }
        float average = sum/arr.count;
        NSLog(@"average: %f",average);
        [self disPlayPower:robotName power:average];
    }
}

//显示电量
- (void)disPlayPower :(NSString *)robot  power:(float )average {
    if (average <= 0) average = 20;
    for (ConnectModel *model in m_robotStateModelsArray) {
        if ([model.robotName isEqualToString:ROBOTNAME_RED]) {
            model.robotPower = [NSString stringWithFormat:@"%.0f%%(%@)",average,tempRedVotage];
        }else if ([model.robotName isEqualToString:ROBOTNAME_BLUE]){
            model.robotPower = [NSString stringWithFormat:@"%.0f%%(%@)",average,tempBlueVotage];
        }else
            model.robotPower = [NSString stringWithFormat:@"%.0f%%(%@)",average,tempGoldVotage];//gold or others
    }
    [m_robotsDetailTableView reloadData];
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
    
    if (m_robotStateModelsArray.count != 0) {
        ConnectModel *model = [m_robotStateModelsArray objectAtIndex:indexPath.row];
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
    
    for (ConnectModel *model in m_robotStateModelsArray) {
        if ([model.robotName isEqualToString:ROBOTNAME_RED]) {
            model.robotSpeed = [NSString stringWithFormat:@"0.%.0f",slider.value];
        }else if ([model.robotName isEqualToString:ROBOTNAME_BLUE]) {
            model.robotSpeed = [NSString stringWithFormat:@"0.%.0f",slider.value];
        }else {
            model.robotSpeed = [NSString stringWithFormat:@"0.%.0f",slider.value];//gold robot
        }
    }
    [m_robotsDetailTableView reloadData];
    
    int tem = (int)slider.value;
    if (tem == 0) {
        [control stopMove];
        [self updateAnalogueLabel:@"停止"];
    }else
        [control speed:tem];
}

- (void)analogueStickDidChangeValue:(JSAnalogueStick *)analogueStick {
    float x = analogueStick.xValue;
    float y = analogueStick.yValue;
    int direction = 0;
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
    NSString *turn = [NSString new];
    if (analogueStick.xValue == 0 && analogueStick.yValue == 0) {
        NSLog(@"backToOrigine");
        switch (direction) {
            case 1:
                NSLog(@"前进");
                turn = @"前进";
                [control forward];
                break;
            case 2:
                NSLog(@"后退");
                turn = @"后退";
                [control backward];
                break;
            case 3:
                NSLog(@"右转");
                turn = @"右转";
                [control turnRight];
                break;
            case 4:
                NSLog(@"左转");
                turn = @"左转";
                [control turnLeft];
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
- (void)addJSDpad {
    jsDpadView = [[JSDPad alloc] initWithFrame:CGRectMake(100, 100, 200, 200)];
    [self.view addSubview:jsDpadView];
    [jsDpadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(200, 200));
    }];
    jsDpadView.delegate = self;
    jsDpadView.hidden = NO;
}

- (void) addStopButton {
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
}

- (void)addRobotsDeatailTableView {
    m_robotsDetailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) style:UITableViewStylePlain];
    [self.view addSubview:m_robotsDetailTableView];
    m_robotsDetailTableView.delegate = self;
    m_robotsDetailTableView.dataSource = self;
    [m_robotsDetailTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(radioContainer.mas_bottom).offset(20);
        make.left.equalTo(radioContainer);
        make.width.equalTo(radioContainer);
        make.bottom.equalTo(self.view);
    }];
    m_robotsDetailTableView.backgroundColor = [UIColor clearColor];
    m_robotsDetailTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (JSAnalogueStick *)analogueStick {
    if (!_analogueStick) {
        _analogueStick = [[JSAnalogueStick alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
        _analogueStick.delegate = self;
        /**
         *  test hisden analogue
         */
        _analogueStick.hidden = YES;
    }
    return _analogueStick;
}

- (CHYSlider* )steppedSlider {
    if (!_steppedSlider) {
        _steppedSlider = [[CHYSlider alloc] init];//WithFrame:CGRectMake(0, 0, 250, 30)];
        _steppedSlider.stepped = YES;
        _steppedSlider.minimumValue = 0;
        _steppedSlider.maximumValue = 5;
        _steppedSlider.value = 2;
        _steppedSlider.labelAboveThumb.font = [UIFont fontWithName:@"AmericanTypewriter-Bold" size:20.f];
        _steppedSlider.labelAboveThumb.textColor = [UIColor blueColor];
        [_steppedSlider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _steppedSlider;
}

-(UILabel *)velocityLabel {
    if (!_velocityLabel) {
        _velocityLabel = [UILabel new];
        _velocityLabel.text = @"速度设置：3";
        _velocityLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _velocityLabel;
}

-(UILabel *)analogueLabel {
    if (!_analogueLabel) {
        _analogueLabel  = [UILabel new];
        _analogueLabel = [UILabel new];
        _analogueLabel.text = @"0 , 0";
        _analogueLabel.textAlignment = NSTextAlignmentCenter;
        _analogueLabel.numberOfLines = 0;
    }
    return _analogueLabel;
}

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
