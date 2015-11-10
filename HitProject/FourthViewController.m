//
//  FourthViewController.m
//  HitProject
//
//  Created by 郭龙 on 15/10/29.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import "FourthViewController.h"
#import "DeskView.h"
#import "RadioButton.h"

@interface FourthViewController ()

@property (nonatomic) UILabel *voiceLabel;
@property (nonatomic) UIView *rawView;
@property (nonatomic) NSInteger deskNum;
@property (nonatomic) HitControl *control;
@property (nonatomic) NSInteger voice;
@property (nonatomic) BOOL isPlay;
@property (nonatomic) UILabel *playLabel;

@end

@implementation FourthViewController
@synthesize rawView;
@synthesize control;
@synthesize voice;
@synthesize isPlay;
@synthesize playLabel;

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [CommonsFunc colorOfSystemBackground];
    voice = 50;
    isPlay = NO;
    control = [HitControl sharedControl];
    
    rawView = [UIView new];
    rawView.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:rawView];
    [rawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(20, 5, 250, 300+15));
    }];
    
    DeskView *desk1 = [[DeskView alloc] init];//WithFrame:CGRectMake(0, 0, 150, 150)];
    desk1.backgroundColor = [UIColor redColor];
    [self.view addSubview:desk1];
    [desk1 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rawView).offset(20);
        make.left.equalTo(rawView).offset(20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    NSInteger deskWidth  = (self.view.bounds.size.width - 315 -5)/7;
    NSInteger deskHeight = (self.view.bounds.size.height - 250 - 20 -40)/4;
    
    int deskNum = 1;
    
    for (int i = 0; i <= 3; i++) {
        for (int j = 0; j < 7; j++) {
            DeskView *deskview = [DeskView new];
            [deskview.img setImage:[UIImage imageNamed:@"music.png"]];
            deskview.deskName.text = [NSString stringWithFormat:@"歌曲%d",deskNum];
            deskNum ++;
            deskview.tag = deskNum;
            [self.view addSubview:deskview];
            [deskview mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(desk1).offset((deskWidth)*j);
//                make.top.equalTo(desk1).offset((deskHeight + 10)*i);
                make.top.equalTo(desk1).offset((deskHeight + 5)*i);
                make.size.mas_equalTo(CGSizeMake(60, 60));
            }];
            deskview.userInteractionEnabled = YES;
            [deskview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(songTaped:)]];
        }
    }
    desk1.hidden = YES;
    
    self.voiceLabel = [UILabel new];
    self.voiceLabel.text = @"音量设置：50";
    self.voiceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.voiceLabel];
    [self.voiceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rawView).offset(50);
        make.width.mas_equalTo(@150);
        make.top.equalTo(rawView.mas_bottom).offset(50);
    }];
    
    UISlider *slide = [[UISlider alloc]initWithFrame:CGRectMake(100, 100, 200, 100)];
    slide.minimumValue = 0;
    slide.maximumValue = 100;
    slide.value = 50;
    slide.continuous = NO;
    [self.view addSubview:slide];
    [slide mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.voiceLabel);
        make.top.equalTo(self.voiceLabel.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(150, 50));
    }];
    [slide addTarget:self action:@selector(updateVoice:) forControlEvents:UIControlEventValueChanged];
    slide.hidden = YES;
    
    UIButton *voiceUpBtn = [UIButton new];
    [self.view addSubview:voiceUpBtn];
    [voiceUpBtn setImage:[UIImage imageNamed:@"voiceUp.png"] forState:UIControlStateNormal];
    [voiceUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.voiceLabel.mas_bottom).offset(20);
        make.left.equalTo(self.voiceLabel);
    }];
    [voiceUpBtn addTarget:self action:@selector(voiceUp:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *voiceDownBtn = [UIButton new];
    [self.view addSubview:voiceDownBtn];
    [voiceDownBtn setImage:[UIImage imageNamed:@"voiceDown.png"] forState:UIControlStateNormal];
    [voiceDownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.voiceLabel.mas_bottom).offset(20);
        make.right.equalTo(self.voiceLabel);
    }];
    [voiceDownBtn addTarget:self action:@selector(voiceDown:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *playBtn = [UIButton new];
    playBtn.tag = 1000;
    [playBtn setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
//    [playBtn setTitle:@"播放" forState:UIControlStateNormal];
    [self.view addSubview:playBtn];
    [playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(slide);
        make.left.equalTo(slide.mas_right).offset(200);
    }];
    [playBtn addTarget:self action:@selector(play:) forControlEvents:UIControlEventTouchUpInside];
    
    playLabel = [UILabel new];
    playLabel.text = @"播放";
    [self.view addSubview:playLabel];
    [playLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(playBtn);
        make.top.equalTo(playBtn.mas_bottom).offset(2);
    }];
    
    UIButton *cancelBtn = [UIButton new];
    cancelBtn.tag = 1001;
    [cancelBtn setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
    [self.view addSubview:cancelBtn];
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(playBtn);
        make.left.equalTo(playBtn.mas_right).offset(70);
    }];
    [cancelBtn addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *pauseLabel = [UILabel new];
    pauseLabel.text = @"停止";
    [self.view addSubview:pauseLabel];
    [pauseLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(cancelBtn);
        make.top.equalTo(playBtn.mas_bottom).offset(2);
    }];
    
    [self addRadioBtn];
}

- (void)voiceUp:(UIButton *)button {
    NSLog(@"voice up");
    if (voice <= 90) {
        voice += 10;
        self.voiceLabel.text = [NSString stringWithFormat:@"音量设置：%ld",(long)voice];
    }
    
    [control voiceUp];
}

- (void)voiceDown :(UIButton *)button {
    NSLog(@"voice down");
    if (voice >= 10) {
        voice -= 10;
        self.voiceLabel.text = [NSString stringWithFormat:@"音量设置：%ld",(long)voice];
    }
    [control voiceDown];
}

- (void)addRadioBtn {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(10, 20, 300, 400)];
    container.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:container];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rawView);
        make.left.equalTo(rawView.mas_right).offset(50);
        make.right.equalTo(self.view.mas_right).offset(-50);
        make.height.mas_equalTo(@200);
    }];
    
    UILabel *questionText = [[UILabel alloc] initWithFrame:CGRectMake(0,0,280,20)];
    questionText.backgroundColor = [UIColor clearColor];
    questionText.text = @"可选择播放模式：";
    [container addSubview:questionText];
    [questionText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(container);
        make.left.equalTo(container);
    }];
    
    NSArray *arr = @[@"单曲播放",@"顺序播放",@"随机播放",@"单曲循环",@"列表循环"];
    for (int i = 0; i < 5; i++) {
        RadioButton *rb = [[RadioButton alloc] initWithGroupId:@"first group" index:i];
        rb.tag = i + 100;
        [container addSubview:rb];
        [rb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(container).offset(40 + 30*i);
            make.left.equalTo(container).offset(10);
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
    
    [control songMode:(index +1)];
}


- (void)play:(UIButton *)btn {
    [control singSong:(self.deskNum + 1)];
    
    UIButton *stopBtn = (UIButton *)[self.view viewWithTag:1001];
    
    if (isPlay == NO) {
        isPlay = YES;
        [btn setBackgroundImage:[UIImage imageNamed:@"pause2.png"] forState:UIControlStateNormal];
        [stopBtn setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
        playLabel.text = @"暂停";
    }else
    {
        isPlay = NO;
        [btn setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
        playLabel.text = @"播放";
    }
}

- (void)cancel:(UIButton *)btn {
    NSLog(@"cancel button taped..");
    [control stopSingSong];
    
    [btn setBackgroundImage:[UIImage imageNamed:@"stop_pressed.png"] forState:UIControlStateNormal];
    
    isPlay = NO;
    UIButton *play = (UIButton *)[self.view viewWithTag:1000];
    [play setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    playLabel.text = @"播放";
}

- (void)songTaped:(UITapGestureRecognizer *)tap {
    DeskView *deskview = (DeskView *)[tap view];
    deskview.backgroundColor = [UIColor grayColor];
    
    self.deskNum = deskview.tag - 1;
    NSLog(@"song num ;%ld",(long)self.deskNum);
}

- (void)updateVoice:(UISlider *)slider {
    self.voiceLabel.text = [NSString stringWithFormat:@"音量设置：%.1f",slider.value];
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
