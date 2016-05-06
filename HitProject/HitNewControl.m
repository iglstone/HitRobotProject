//
//  SenderMessage.m
//  HitProject
//
//  Created by 郭龙 on 15/11/6.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import "HitNewControl.h"

@implementation HitNewControl
@synthesize server;

static HitNewControl* _instance = nil;

+ (instancetype) sharedControl
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    
    return _instance ;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        server = [ServerSocket sharedSocket];
    }
    return self;
}

- (void)startListen {
    [server startListen];
}

- (void)stopAll {
    [self stopMove];
    [self stopSingSong];
    [self stopListen];
}

- (void)stopListen {
    [server stopListen];
}

- (void)sendCheckSigalWithSocket:(AsyncSocket *)sock {
    AppDelegate *dele = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([dele.main isKindOfClass:[MainViewController class]]) {
        MainViewController *main = (MainViewController *)dele.main;
        [main setDebugLabelText:@"checkConfig" mode:MESSAGEMODE_SEND];
    }
    [[server mutableArrayValueForKey:@"messagesArray"] addObject:@"&"];
    [sock writeData:[@"&" dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1.5 tag:1];
}

- (void)mealMode {
    NSString *st = [CommonsFunc stringFromHexString:@"200101"];
    [server sendMessage:st debugstring:@"送餐模式"];
    //    [server sendMessage:@"0x200x030x10" debugstring:@"送餐模式"];
    
    NSLog(@"xxx:%@",st);
}

- (void)controlMode {
    //    [server sendMessage:@"b" debugstring:@"控制模式"];
    [server sendMessage:[CommonsFunc stringFromHexString:@"010101"] debugstring:@"控制模式"];
}

- (void)forward {
    //    [server sendMessage:@"c" debugstring:@"前进"];
    [server sendMessage:[CommonsFunc stringFromHexString:@"020101"] debugstring:@"控制模式"];
}

- (void)backward {
    //    [server sendMessage:@"d" debugstring:@"后退"];
    [server sendMessage:[CommonsFunc stringFromHexString:@"030101"] debugstring:@"控制模式"];
}

- (void)turnLeft {
    //    [server sendMessage:@"e" debugstring:@"左转"];
    [server sendMessage:[CommonsFunc stringFromHexString:@"040101"] debugstring:@"控制模式"];
}

- (void)turnRight {
    //    [server sendMessage:@"f" debugstring:@"右转"];
    [server sendMessage:[CommonsFunc stringFromHexString:@"050101"] debugstring:@"控制模式"];
}

- (void)stopMove {
    //    [server sendMessage:@"g" debugstring:@"停止"];
    [server sendMessage:[CommonsFunc stringFromHexString:@"060101"] debugstring:@"控制模式"];
}

- (void)voiceUp {
    [server sendMessage:@"h" debugstring:@"音量+"];
}

- (void)voiceDown {
    [server sendMessage:@"i" debugstring:@"音量-"];
}

- (void)speed:(NSInteger)dang {
    switch (dang) {
        case 0:
            [server sendMessage:nil debugstring:@"0档"];
            break;
        case 1:
            [server sendMessage:@"j" debugstring:@"1档"];
            break;
        case 2:
            [server sendMessage:@"k" debugstring:@"2档"];
            break;
        case 3:
            [server sendMessage:@"l" debugstring:@"3档"];
            break;
        case 4:
            [server sendMessage:@"m" debugstring:@"4档"];
            break;
        case 5:
            [server sendMessage:nil debugstring:@"5档"];
            //            [server sendMessage:@"n" debugstring:@"5档"];
            break;
        default:
            break;
    }
}

- (void)singSong:(NSInteger)numeber {
    NSArray *musics = @[@"铃儿响叮当",
                        @"生日歌",
                        @"熊出没",
                        @"恭喜发财",
                        @"My Soul",
                        @"The Truth That U Leave",
                        @"Not going anyway",
                        @"Annie's Wonderland",
                        @"Kiss The Rain",
                        @"卡农",
                        @"红豆",
                        @"滴答",
                        @"飘雪",
                        @"Angel",
                        @"Whatever will be",
                        @"The Show",
                        @"Black Black Heart",
                        @"Only Love",
                        @"Right Now Right Here",
                        @"See You Again"
                        ];
    NSString *songname = musics[numeber-1];
    NSArray *messageArray = @[@"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"A", @"B", @"C", @"(", @")", @"*", @"+", @"-"];
    NSString *msg = messageArray[numeber -1];
    [server sendMessage:msg debugstring:songname];
}

- (void)deskNumber:(NSInteger)numeber {
    /**
     *  罗欧桌号与控制代码
     */
    //    NSArray *deskNumArray = @[@"121", @"122", @"123", @"125", @"126", @"127", @"128", @"117", @"116", @"115", @"113", @"112", @"106"];
    //    NSArray *messageArray = @[@"E", @"F", @"G", @"H", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y"];
    
    /**
     *  标准协议
     */
    NSArray *deskNumArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14",@"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30"];
    NSArray *messageArray = @[@"D", @"E", @"F", @"G", @"H", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y", @"Z", @":", @"<", @"=", @">", @"?", @"0", @"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9"];
    
    if (deskNumArray.count >= numeber) {
        [server sendMessage:messageArray[numeber] debugstring:[NSString stringWithFormat:@"%@桌",deskNumArray[numeber]]];
    }else {
        NSLog(@"desk num is less than input num");
        return;
    }
}

- (void)cancelSendMeal {
    [server sendMessage:@"@" debugstring:@"取消送餐"];
}

- (void)backToOrigin {
    [server sendMessage:@"I" debugstring:@"回到初始点"];
}

- (void)loopRun {
    [server sendMessage:@"J" debugstring:@"循环运行"];
}

- (void)songMode:(NSInteger)numeber {
    switch (numeber) {
        case 1:
            [server sendMessage:@"K" debugstring:@"单曲播放"];
            break;
        case 2:
            [server sendMessage:@"L" debugstring:@"顺序播放"];
            break;
        case 3:
            [server sendMessage:@"M" debugstring:@"随机播放"];
            break;
        case 4:
            [server sendMessage:@"N" debugstring:@"单曲循环"];
            break;
        case 5:
            [server sendMessage:@"O" debugstring:@"列表循环"];
            break;
        default:
            break;
    }
}

- (void)stopSingSong {
    [server sendMessage:@"P" debugstring:@"停止播放"];
}


@end
