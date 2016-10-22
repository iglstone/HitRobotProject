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

- (void)sendCheckSigalWithSocket:(AsyncSocket *)sock {
    AppDelegate *dele = (AppDelegate *) [[UIApplication sharedApplication] delegate];
    if ([dele.main isKindOfClass:[MainViewController class]]) {
        MainViewController *main = (MainViewController *)dele.main;
        [main setDebugLabelText:@"checkConfig" mode:MESSAGEMODE_SEND];
    }
    [[server mutableArrayValueForKey:@"messagesArray"] addObject:@"&"];
    NSString *st = [CommonsFunc stringFromHexString:@"0x600101"];
    [sock writeData:[st dataUsingEncoding:NSUTF8StringEncoding] withTimeout:1.5 tag:1];
}

- (void)mealMode {
    [server sendMessage:@"0x200101" debugstring:@"送餐模式"];
}

- (void)controlMode {
    [server sendMessage:@"0x010101" debugstring:@"控制模式"];
}

- (void)circleMode {
    [server sendMessage:@"0x800101" debugstring:@"无轨循环模式"];
}


- (void)forward {
    [server sendMessage:@"0x020101" debugstring:@"前进"];
}

- (void)backward {
    [server sendMessage:@"0x030101" debugstring:@"后退"];
}

- (void)turnLeft {
    [server sendMessage:@"0x040101" debugstring:@"左转"];
}

- (void)turnRight {
    [server sendMessage:@"0x050101" debugstring:@"右转"];
}

- (void)stopMove {
    [server sendMessage:@"0x060101" debugstring:@"停止"];
}

- (void)voiceUp {
    [server sendMessage:@"0x420101" debugstring:@"音量+"];
}

- (void)voiceDown {
    [server sendMessage:@"0x430101" debugstring:@"音量-"];
}

- (void)speed:(NSInteger)dang {
    switch (dang) {
        case 0:
            [server sendMessage:nil debugstring:@"0档"];
            break;
        case 1:
            [server sendMessage:@"0x070101" debugstring:@"1档"];
            break;
        case 2:
            [server sendMessage:@"0x070201" debugstring:@"2档"];
            break;
        case 3:
            [server sendMessage:@"0x070301" debugstring:@"3档"];
            break;
        case 4:
            [server sendMessage:@"0x070401" debugstring:@"4档"];
            break;
        case 5:
            [server sendMessage:nil debugstring:@"5档"];
//            [server sendMessage:@"0x070501" debugstring:@"5档"];
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
    
    NSString *cmd = [NSString stringWithFormat:@"0x40%@01",[CommonsFunc stringToHexString:(int)numeber]];
    [server sendMessage:cmd debugstring:songname];
//    NSArray *messageArray = @[@"o", @"p", @"q", @"r", @"s", @"t", @"u", @"v", @"w", @"x", @"y", @"z", @"A", @"B", @"C", @"(", @")", @"*", @"+", @"-"];
//    NSString *msg = messageArray[numeber -1];
//    [server sendMessage:msg debugstring:songname];
}

- (void)deskNumber:(NSInteger)numeber {
    [self deskNumber:numeber turn:0];
}

- (void)deskNumber:(NSInteger)numeber turn:(int)turn{
    /**
     *  罗欧桌号与控制代码
     */
//    NSArray *deskNumArray = @[@"121", @"122", @"123", @"125", @"126", @"127", @"128", @"117", @"116", @"115", @"113", @"112", @"106"];
//    NSArray *messageArray = @[@"E", @"F", @"G", @"H", @"Q", @"R", @"S", @"T", @"U", @"V", @"W", @"X", @"Y"];
    
    /**
     *  标准协议
     */
    if (!turn || turn == 0) {
        turn = 3;
    }
    NSArray *deskNumArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14",@"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30"];
    
    if (deskNumArray.count >= numeber) {
        NSString *cmd = [NSString stringWithFormat:@"0x21%@%@",[CommonsFunc stringToHexString:(int)(numeber+1)],[CommonsFunc stringToHexString:(int)turn]];
        [server sendMessage:cmd debugstring:[NSString stringWithFormat:@"%@桌",deskNumArray[numeber]]];
    }else {
        NSLog(@"desk num is less than input num");
        return;
    }
    
}

- (void)cancelSendMeal {
    [server sendMessage:@"0x220101" debugstring:@"取消送餐"];
}

- (void)backToOrigin {
    [server sendMessage:@"0x230101" debugstring:@"回到初始点"];
}

- (void)loopRun {
    [server sendMessage:@"0x240101" debugstring:@"循环运行"];
}

- (void)songMode:(NSInteger)numeber {
    switch (numeber) {
        case 1:
            [server sendMessage:@"0x440101" debugstring:@"单曲播放"];
            break;
        case 2:
            [server sendMessage:@"0x440201" debugstring:@"顺序播放"];
            break;
        case 3:
            [server sendMessage:@"0x440301" debugstring:@"随机播放"];
            break;
        case 4:
            [server sendMessage:@"0x440401" debugstring:@"单曲循环"];
            break;
        case 5:
            [server sendMessage:@"0x440501" debugstring:@"列表循环"];
            break;
        default:
            break;
    }
}

- (void)stopSingSong {
    [server sendMessage:@"0x410101" debugstring:@"停止播放"];
}

- (void) sendTouchPointToRobot: (CGPoint) touchPoint angle:(int )angel {
    NSString *cmd ;
    NSString *stX ;
    NSString *stY ;
    
    if (touchPoint.x >= 0) {
        stX = [NSString stringWithFormat:@"0%04d", (int)touchPoint.x];
    }else{
        stX = [NSString stringWithFormat:@"1%04d", abs((int)touchPoint.x)];
    }
    
    if (touchPoint.y >= 0) {
        stY = [NSString stringWithFormat:@"0%04d", (int)touchPoint.y];
    }else{
        stY = [NSString stringWithFormat:@"1%04d", abs((int)touchPoint.y)];
    }
    
    //后面四位数角度和正负
    if (angel >= 0) {
        cmd = [NSString stringWithFormat:@"%@%@0%03d",stX,stY,angel];
    } else {
        cmd = [NSString stringWithFormat:@"%@%@1%03d",stX,stY,abs(angel)];
    }
    
    //    NSLog(@"__String: %@", cmd);
    [[[ServerSocket sharedSocket] mutableArrayValueForKey:@"messagesArray"] addObject:[NSString stringWithFormat:@"__String: %@", cmd]];
    cmd = [CommonsFunc convertStringToHexStr:cmd];
    
    NSString *tmp = [NSString stringWithFormat: @"7e01000000%@60",cmd];
    NSString *hexSt = [CommonsFunc convertHexStrToString:tmp];
    [server sendMessage:hexSt debugstring:cmd];
}

- (void) sendTouchPointToRobot: (CGPoint) touchPoint {
    [self sendTouchPointToRobot:touchPoint angle:0];
    
    //changed 10.18 for new protocol
    /*********
    NSString *cmd = [NSString stringWithFormat:@"~#%03d,%03d`",(int)touchPoint.x,(int)touchPoint.y];
    [server sendMessage:cmd debugstring:cmd];
    ********/
}

- (void) sendPathToRobot:(NSInteger)index ofRealPosition:(NSArray *)positionArr ofDeskNum:(NSArray *)deskArr {
    switch (index) {
        case 0:
            index = 0;//起始点
            break;
        case 1:
            index = 3;//3D
            break;
        case 2:
            index = 6;//独轮车
            break;
        case 3:
            index = 7;//终点
            break;
        default:
            break;
    }
    CGPoint pt = CGPointFromString( [positionArr objectAtIndex:index] );
    [server sendMessage:[NSString stringWithFormat:@"~#%03d,%03d`",(int)pt.x,(int)pt.y] debugstring:deskArr[index]];
    
//    NSArray *deskNumArray = @[@"1", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"11", @"12", @"13", @"14",@"15", @"16", @"17", @"18", @"19", @"20", @"21", @"22", @"23", @"24", @"25", @"26", @"27", @"28", @"29", @"30"];
//    if (deskNumArray.count >= index) {
//        NSString *cmd = [NSString stringWithFormat:@"0x21%@%@",[CommonsFunc stringToHexString:(int)(index+1)],[CommonsFunc stringToHexString:(int)3]];
////        [server sendMessage:cmd debugstring:[NSString stringWithFormat:@"%@桌",deskNumArray[index]]];
//        NSString *st = [@"0D0A2B4950442C333A" stringByAppendingString:[cmd substringFromIndex:2]];
//        [server sendMessage:st debugstring:[NSString stringWithFormat:@"%@桌",deskNumArray[index]]];
//    }else {
//        NSLog(@"desk num is less than input num");
//        return;
//    }
}

@end
