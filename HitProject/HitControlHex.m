//
//  HitControlHex.m
//  HitProject
//
//  Created by 郭龙 on 16/1/7.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "HitControlHex.h"

@implementation HitControlHex
@synthesize server;

static HitControlHex* _instance = nil;

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

- (void)controlMode {
    [server sendMessage:@"0000" debugstring:@"控制模式"];
}

- (void)forward {
    [server sendMessage:@"0100" debugstring:@"前进"];
}

- (void)backward {
    [server sendMessage:@"0200" debugstring:@"后退"];
}

- (void)turnLeft {
    [server sendMessage:@"0300" debugstring:@"左转"];
}

- (void)turnRight {
    [server sendMessage:@"0400" debugstring:@"右转"];
}

- (void)stopMove {
    [server sendMessage:@"0500" debugstring:@"停止"];
}

- (void)speed:(NSInteger)dang {
    switch (dang) {
        case 0:
            [server sendMessage:nil debugstring:@"0档"];
            break;
        case 1:
            [server sendMessage:@"0601" debugstring:@"1档"];
            break;
        case 2:
            [server sendMessage:@"0602" debugstring:@"2档"];
            break;
        case 3:
            [server sendMessage:@"0603" debugstring:@"3档"];
            break;
        case 4:
//            [server sendMessage:nil debugstring:@"4档"];
            [server sendMessage:@"0604" debugstring:@"4档"];
            break;
        case 5:
//            [server sendMessage:nil debugstring:@"5档"];
            [server sendMessage:@"0605" debugstring:@"5档"];
            break;
        default:
            break;
    }
}

- (void)mealMode {
    [server sendMessage:@"0200" debugstring:@"送餐模式"];
}

//21开头
- (void)deskNumber:(NSInteger)numeber {
    int tmpNum = (int)numeber;
    NSString *str = [ [NSString alloc] initWithFormat:@"%x",tmpNum];
    NSString *tmpHex = [NSString stringWithFormat:@"21%@",str];
    [server sendMessage:tmpHex debugstring:[NSString stringWithFormat:@"第%d桌", (int)numeber]];
}

- (void)cancelSendMeal {
    [server sendMessage:@"2200" debugstring:@"取消送餐"];
}

- (void)backToOrigin {
    [server sendMessage:@"2300" debugstring:@"回到初始点"];
}

- (void)loopRun {
    [server sendMessage:@"2400" debugstring:@"循环运行"];
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
    int tmpNum = (int)numeber;
    NSString *str = [ [NSString alloc] initWithFormat:@"%x",tmpNum];
    NSString *tmpHex = [NSString stringWithFormat:@"40%@",str];
    if (numeber <= musics.count) {
        NSString *songname = musics[numeber-1];
        [server sendMessage:tmpHex debugstring:songname];
    }else {
        [server sendMessage:tmpHex debugstring:[NSString stringWithFormat:@"第%d首歌曲",(int)numeber]];
    }
}

- (void)stopSingSong {
    [server sendMessage:@"4100" debugstring:@"停止播放"];
}

- (void)voiceUp {
    [server sendMessage:@"4200" debugstring:@"音量+"];
}

- (void)voiceDown {
    [server sendMessage:@"4300" debugstring:@"音量-"];
}

- (void)songMode:(NSInteger)numeber {
    NSArray *arr = @[@"单曲播放", @"顺序播放", @"随机播放", @"单曲循环", @"列表循环"];
    int tmpNum = (int)numeber;
    NSString *str = [ [NSString alloc] initWithFormat:@"%x",tmpNum];
    NSString *tmpHex = [NSString stringWithFormat:@"44%@",str];
    [server sendMessage:tmpHex debugstring:arr[numeber-1]];
}

- (void)queryMessageAll {
    [server sendMessage:@"6000" debugstring:@"查询全部信息"];
}

- (void)queryMessagePower {
    [server sendMessage:@"6100" debugstring:@"电量查询"];
}

- (void)queryMessageVoice {
    [server sendMessage:@"6200" debugstring:@"音量查询"];
}

- (void)queryMessageSpeed {
    [server sendMessage:@"6300" debugstring:@"速度查询"];
}




@end
