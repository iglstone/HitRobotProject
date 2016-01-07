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
#import "PopupView.h"
#import "UIViewController+LewPopupViewController.h"
#import "LewPopupViewAnimationFade.h"
#import "DeskInfoHelper.h"

@interface FourthViewController () {
    DeskView *tmpView;
    DeskInfoHelper *helper;
    NSInteger totalSongNum;
    NSInteger screenWidth ;
}

@property (nonatomic) UILabel *voiceLabel;
@property (nonatomic) UIScrollView *rawView;
@property (nonatomic) NSInteger deskNum;
@property (nonatomic) HitControl *control;
@property (nonatomic) NSInteger voice;
@property (nonatomic) BOOL isPlay;
@property (nonatomic) UILabel *playLabel;
@property (nonatomic) NSMutableArray *musicsArray;

@end

@implementation FourthViewController
@synthesize rawView;
@synthesize control;
@synthesize voice;
@synthesize isPlay;
@synthesize playLabel;
@synthesize musicsArray;

- (instancetype)init {
    self = [super init];
    if (self) {
        helper = [DeskInfoHelper new];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songPopViewConfrimed:) name:NOTICE_SONGPOPVIEW_CONFIRM object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(songsNumPicked:) name:NOTICE_PICKSONGNUM object:nil];
        totalSongNum = [[[NSUserDefaults standardUserDefaults] objectForKey:NSDEFAULT_PickupSongsNum] integerValue];
        if (!totalSongNum) {
            totalSongNum = 20;
        }
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
    [self initDeskView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    for (UIView *view in rawView.subviews) {
        [view removeFromSuperview];
    }
}

- (void)viewDidLayoutSubviews {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] <= 8.0) {//补充ios7的scrollview 不能滑动的问题。
        NSInteger contentWidth ;
        NSInteger screenWidth2 = [UIScreen mainScreen].bounds.size.width;
        if ([CommonsFunc isDeviceIpad]) {
            contentWidth = [UIScreen mainScreen].bounds.size.width - 20 - 400;
            rawView.contentSize = CGSizeMake(contentWidth, 600);
        }else {
            contentWidth = [UIScreen mainScreen].bounds.size.width - 20 - screenWidth2/4;
            rawView.contentSize = CGSizeMake(contentWidth, 300);
        }
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [CommonsFunc colorOfSystemBackground];
    voice = 50;
    isPlay = NO;
    control = [HitControl sharedControl];
    screenWidth = [UIScreen mainScreen].bounds.size.width;
    musicsArray = [[NSMutableArray alloc] init];
    
    rawView = [UIScrollView new];
    rawView.backgroundColor = [CommonsFunc colorOfLight];
    rawView.layer.borderColor = [[UIColor darkGrayColor] CGColor];
    rawView.layer.borderWidth = 0.8;
    rawView.layer.cornerRadius = 12;
    rawView.layer.masksToBounds = YES;
    rawView.backgroundColor = [CommonsFunc colorOfLight];
    [self.view addSubview:rawView];
    [rawView mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([CommonsFunc isDeviceIpad]) {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(20, 20, 250, 400));
        }else {
            make.edges.equalTo(self.view).insets(UIEdgeInsetsMake(20, 20, 150, screenWidth/4));
        }
    }];
    
//    [self initDeskView];
    
    self.voiceLabel = [UILabel new];
    self.voiceLabel.text = @"音量调节：";
    self.voiceLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:self.voiceLabel];
    [self.voiceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(rawView).offset(50);
        make.width.mas_equalTo(@150);
        make.top.equalTo(rawView.mas_bottom).offset(10);
    }];
    
    UIButton *voiceUpBtn = [UIButton new];
    [self.view addSubview:voiceUpBtn];
    [voiceUpBtn setImage:[UIImage imageNamed:@"voiceUp.png"] forState:UIControlStateNormal];
    [voiceUpBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.voiceLabel.mas_bottom).offset(10);
        make.left.equalTo(self.voiceLabel);
    }];
    [voiceUpBtn addTarget:self action:@selector(voiceUp:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *voiceDownBtn = [UIButton new];
    [self.view addSubview:voiceDownBtn];
    [voiceDownBtn setImage:[UIImage imageNamed:@"voiceDown.png"] forState:UIControlStateNormal];
    [voiceDownBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.voiceLabel.mas_bottom).offset(10);
        make.right.equalTo(self.voiceLabel);
    }];
    [voiceDownBtn addTarget:self action:@selector(voiceDown:) forControlEvents:UIControlEventTouchUpInside];
    
    if ([CommonsFunc isDeviceIpad]) {
        [self ipadAddPlayAndCancelBtn];
    }
    
    [self addRadioBtn];
}

/**
 *  初始化对应的歌曲列表
 */
- (void)initDeskView {
    DeskView *desk1 = [[DeskView alloc] init];
    desk1.backgroundColor = [UIColor redColor];
    [rawView addSubview:desk1];
    [desk1 mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([CommonsFunc isDeviceIpad]) {
            make.top.equalTo(rawView).offset(20);
        }else
            make.top.equalTo(rawView).offset(10);
        make.left.equalTo(rawView).offset(20);
        make.size.mas_equalTo(CGSizeMake(60, 60));
    }];
    
    
    NSInteger contentWidth ;
    NSInteger deskWidth,deskHeight;
    if ([CommonsFunc isDeviceIpad]) {
        deskWidth = 100;//(self.view.bounds.size.width - 20 - 400)/6;
        deskHeight = 121;//(self.view.bounds.size.height - 250 - 20 -40)/4;
        contentWidth = [UIScreen mainScreen].bounds.size.width - 20 - 400;
        rawView.contentSize = CGSizeMake(contentWidth, (deskHeight + 10) * ((int)(totalSongNum/6) +1) + 10);
    }else {
        deskHeight = (self.view.bounds.size.height - 100 - 20 - 40)/5 + 20;
        deskWidth = (self.view.bounds.size.width - screenWidth/4 -20)/6;
        contentWidth = [UIScreen mainScreen].bounds.size.width - 20 - screenWidth/4;
        rawView.contentSize = CGSizeMake(contentWidth, (deskHeight + 10) * ((int)(totalSongNum/6) +1) + 10);//300);
    }
    
    int deskNum = 1;
    
    NSArray *musics = [helper getDeskNamesFromUserdefaultByTag:(int)totalSongNum isSong:YES];
    
    @autoreleasepool {
        NSInteger tt = 0;
        for (int i = 0; i <= 6; i++) {
            for (int j = 0; j < 6; j++) {
                if (deskNum > totalSongNum) {
                    tt = 1;
                    break;
                }
                DeskView *deskview = [DeskView new];
                [deskview.img setImage:[UIImage imageNamed:@"music_unplay.png"]];
                deskview.tag = deskNum;
                if (deskNum <= musics.count) {
                    deskview.deskName.text = musics[deskNum-1];//[NSString stringWithFormat:@"歌曲%d",deskNum];
                }else
                    deskview.deskName.text = [NSString stringWithFormat:@"歌曲%d",deskNum];
                
                deskNum ++;
                
                deskview.deskName.font = [UIFont systemFontOfSize:13];
                
                [rawView addSubview:deskview];
                [deskview mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.left.equalTo(desk1).offset((deskWidth)*j);
                    make.top.equalTo(desk1).offset((deskHeight + 5)*i);
                    make.size.mas_equalTo(CGSizeMake(60, 60));
                }];
                deskview.userInteractionEnabled = YES;
                [deskview addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(songTaped:)]];
                [deskview addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(deskLongTaped:)]];
                [musicsArray addObject:deskview];
            }
            
            if (tt ==1 ) {
                break;
            }
        }
        desk1.hidden = YES;
    }
}

#pragma mark - actions
- (void)songsNumPicked:(NSNotification *)noti {
    NSInteger num = [[[noti userInfo] objectForKey:@"desknum"] integerValue];
    totalSongNum = num;
}

- (void)songPopViewConfrimed :(NSNotification *)noti {
    NSDictionary *dic     = [noti userInfo];
    NSInteger tag         = [[dic objectForKey:@"deskTag"] integerValue];
    NSString *deskNames   = [dic objectForKey:@"deskName"];
    [helper changeDeskModelByTag:(int)tag name:deskNames isSong:YES];
    tmpView.deskName.text = deskNames;//[deskNames hasSuffix:@"桌"] ? deskNames : [NSString stringWithFormat:@"%@桌", deskNames];
}

- (void)deskLongTaped :(UIGestureRecognizer *)gesture {
    if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if (gesture.state == UIGestureRecognizerStateBegan) {
            tmpView = (DeskView *)[gesture view];
            NSString *deskName = tmpView.deskName.text;
            NSLog(@"long taped :%@",deskName);
            PopupView *view = [PopupView defaultPopupView];
            view.deskName = deskName;
            view.signal = @"xxx";
            view.parentVC = self;
            view.deskTag = tmpView.tag;
            view.isSong = YES;
            [view addInnerView];
            [self lew_presentPopupView:view animation:[LewPopupViewAnimationFade new] dismissed:^{
                NSLog(@"动画结束");
            }];
        }
    }
}

- (void)voiceUp:(UIButton *)button {
    NSLog(@"voice up");
    if (voice <= 90) {
        voice += 10;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_VOICECHANGE object:nil userInfo:@{@"voice":@(voice)}];
//        self.voiceLabel.text = [NSString stringWithFormat:@"音量设置：%ld",(long)voice];
    }
    [control voiceUp];
}

- (void)voiceDown :(UIButton *)button {
    NSLog(@"voice down");
    if (voice >= 10) {
        voice -= 10;
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_VOICECHANGE object:nil userInfo:@{@"voice":@(voice)}];
//        self.voiceLabel.text = [NSString stringWithFormat:@"音量设置：%ld",(long)voice];
    }
    [control voiceDown];
}


-(void)radioButtonSelectedAtIndex:(NSUInteger)index inGroup:(NSString *)groupId{
    NSLog(@"changed to %lu in %@",(unsigned long)index,groupId);
    [control songMode:(index +1)];
}


- (void)play:(UIButton *)btn {
    if (self.deskNum <= 20) {
        [control singSong:(self.deskNum)];
    }else
        [control singSong:5];
    
//    UIButton *stopBtn = (UIButton *)[self.view viewWithTag:1001];
    
//    if (isPlay == NO) {
//        isPlay = YES;
//        [btn setBackgroundImage:[UIImage imageNamed:@"pause2.png"] forState:UIControlStateNormal];
//        [stopBtn setBackgroundImage:[UIImage imageNamed:@"pause.png"] forState:UIControlStateNormal];
//        playLabel.text = @"暂停";
//    }else
//    {
//        isPlay = NO;
//        [btn setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
//        playLabel.text = @"播放";
//        //本来应该是暂停的
//        [self setUnPlayImage];
//        [control stopSingSong];
//    }
}

- (void)cancel:(UIButton *)btn {
    NSLog(@"cancel button taped..");
    [control stopSingSong];
    [self setUnPlayImage];
    [btn setBackgroundImage:[UIImage imageNamed:@"stop_pressed.png"] forState:UIControlStateNormal];
    
    isPlay = NO;
    UIButton *play = (UIButton *)[self.view viewWithTag:1000];
    [play setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
    playLabel.text = @"播放";
}

- (void)songTaped:(UITapGestureRecognizer *)tap {
    DeskView *deskview = (DeskView *)[tap view];
    [self setUnPlayImage];
    [deskview.img setImage:[UIImage imageNamed:@"music_play.png"]];
    
    self.deskNum = deskview.tag ;
    NSLog(@"song num ;%ld",(long)self.deskNum);
    if (![CommonsFunc isDeviceIpad]) {
        if (self.deskNum <= 20) {
            [control singSong:(self.deskNum)];
        }else
            [control singSong:5];
    }
}

- (void)setUnPlayImage {
    for (DeskView *deskView2 in musicsArray) {
        [deskView2.img setImage:[UIImage imageNamed:@"music_unplay.png"]];
    }
}

- (void)updateVoice:(UISlider *)slider {
    self.voiceLabel.text = [NSString stringWithFormat:@"音量设置：%.1f",slider.value];
}

#pragma mark - add views
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)addRadioBtn {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(10, 20, 300, 400)];
    container.backgroundColor = [CommonsFunc colorOfLight];
    [self.view addSubview:container];
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(rawView);
        if ([CommonsFunc isDeviceIpad]) {
            make.left.equalTo(rawView.mas_right).offset(50);
        }else
            make.left.equalTo(rawView.mas_right).offset(17);
        
        make.right.equalTo(self.view.mas_right).offset(-5);
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
        RadioButton *rb = [[RadioButton alloc] initWithGroupId:@"sencond group" index:i];
        rb.tag = i + 100;
        [container addSubview:rb];
        [rb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(container).offset(40 + 30*i);
            make.left.equalTo(container).offset(10);
            make.size.mas_equalTo(CGSizeMake(100, 22));
        }];
        [rb.button setTitle:arr[i] forState:UIControlStateNormal];
    }
    //默认列表循环
    RadioButton *rb = (RadioButton *)[self.view viewWithTag:104];
    [rb setChecked:YES];
    [RadioButton addObserverForGroupId:@"sencond group" observer:self];
}

- (void) ipadAddPlayAndCancelBtn {
    // uislide is no use.
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
    
    UIButton *playBtn = [UIButton new];
    playBtn.tag = 1000;
    [playBtn setBackgroundImage:[UIImage imageNamed:@"play.png"] forState:UIControlStateNormal];
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
