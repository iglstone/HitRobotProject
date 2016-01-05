//
//  SenderMessage.m
//  HitProject
//
//  Created by 郭龙 on 15/11/6.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import "HitControl.h"

@implementation HitControl
@synthesize server;

static HitControl* _instance = nil;

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

- (void)mealMode {
    [server sendMessage:@"a" debugstring:@"送餐模式"];
}

- (void)controlMode {
    [server sendMessage:@"b" debugstring:@"控制模式"];
}

- (void)forward {
    [server sendMessage:@"c" debugstring:@"前进"];
}

- (void)backward {
    [server sendMessage:@"d" debugstring:@"后退"];
}

- (void)turnLeft {
    [server sendMessage:@"e" debugstring:@"左转"];
}

- (void)turnRight {
    [server sendMessage:@"f" debugstring:@"右转"];
}

- (void)stopMove {
    [server sendMessage:@"g" debugstring:@"停止"];
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
            [server sendMessage:nil debugstring:@"4档"];
//            [server sendMessage:@"m" debugstring:@"4档"];
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
    NSArray *deskNumArray = @[@"121", @"122", @"123", @"125", @"126", @"127", @"128", @"117", @"116", @"115", @"113", @"112", @"106"];
    NSArray *messageArray = @[@"E", @"F", @"G", @"H", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y"];
    if (deskNumArray.count >= numeber) {
        [server sendMessage:messageArray[numeber - 1] debugstring:[NSString stringWithFormat:@"%@桌",deskNumArray[numeber - 1]]];
    }else {
        NSLog(@"desk num is less than input num");
        return;
    }
    
    /*
    switch (numeber) {
        case 1:
            [server sendMessage:@"E" debugstring:<#(NSString *)#>];
            break;
        case 2:
            [server sendMessage:@"F"];//13卡
            break;
        case 3:
            [server sendMessage:@"G"];//14卡
            break;
        case 4:
            [server sendMessage:@"H"];
            break;
        case 5:
            [server sendMessage:@"Q"];
            break;
        case 6:
            [server sendMessage:@"R"];
            break;
        case 7:
            [server sendMessage:@"S"];
            break;
        case 8:
            [server sendMessage:@"T"];
            break;
        case 9:
            [server sendMessage:@"U"];
            break;
        case 10:
            [server sendMessage:@"V"];
            break;
        case 11:
            [server sendMessage:@"W"];
            break;
        case 12:
            [server sendMessage:@"X"];
            break;
        case 13:
            [server sendMessage:@"Y"];
            break;
//        case 1:
//            [server sendMessage:@"D"];
//            break;
//        case 2:
//            [server sendMessage:@"E"];//12卡
//            break;
//        case 3:
//            [server sendMessage:@"F"];//13卡
//            break;
//        case 4:
//            [server sendMessage:@"G"];//14卡
//            break;
//        case 5:
//            [server sendMessage:@"H"];
//            break;
//        case 6:
//            [server sendMessage:@"Q"];
//            break;
//        case 7:
//            [server sendMessage:@"R"];
//            break;
//        case 8:
//            [server sendMessage:@"S"];
//            break;
//        case 9:
//            [server sendMessage:@"T"];
//            break;
//        case 10:
//            [server sendMessage:@"U"];
//            break;
//        case 11:
//            [server sendMessage:@"V"];
//            break;
//        case 12:
//            [server sendMessage:@"W"];
//            break;
//        case 13:
//            [server sendMessage:@"X"];
//            break;
//        case 14:
//            [server sendMessage:@"Y"];
//            break;
//        case 15:
//            [server sendMessage:@"Z"];
//            break;
//        case 16:
//            [server sendMessage:@":"];
//            break;
//        case 17:
//            [server sendMessage:@"<"];
//            break;
//        case 18:
//            [server sendMessage:@"="];
//            break;
//        case 19:
//            [server sendMessage:@">"];
//            break;
//        case 20:
//            [server sendMessage:@"?"];
//            break;
//        case 21:
//            [server sendMessage:@"0"];
//            break;
//        case 22:
//            [server sendMessage:@"1"];
//            break;
//        case 23:
//            [server sendMessage:@"2"];
//            break;
//        case 24:
//            [server sendMessage:@"3"];
//            break;
//        case 25:
//            [server sendMessage:@"4"];
//            break;
//        case 26:
//            [server sendMessage:@"5"];
//            break;
//        case 27:
//            [server sendMessage:@"6"];
//            break;
//        case 28:
//            [server sendMessage:@"7"];
//            break;
//        case 29:
//            [server sendMessage:@"8"];
//            break;
//        case 30:
//            [server sendMessage:@"9"];
//            break;
        default:
            break;
    }
     */
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
