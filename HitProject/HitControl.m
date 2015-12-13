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
    [server sendMessage:@"a"];
}

- (void)controlMode {
    [server sendMessage:@"b"];
}

- (void)forward {
    [server sendMessage:@"c"];
}

- (void)backward {
    [server sendMessage:@"d"];
}

- (void)turnLeft {
    [server sendMessage:@"e"];
}

- (void)turnRight {
    [server sendMessage:@"f"];
}

- (void)stopMove {
    [server sendMessage:@"g"];
}

- (void)voiceUp {
    [server sendMessage:@"h"];
}

- (void)voiceDown {
    [server sendMessage:@"i"];
}

- (void)speed:(NSInteger)dang {
    switch (dang) {
        case 1:
            [server sendMessage:@"j"];
            break;
        case 2:
            [server sendMessage:@"k"];
            break;
        case 3:
            [server sendMessage:@"l"];
            break;
        case 4:
            [server sendMessage:@"m"];
            break;
        case 5:
            [server sendMessage:@"n"];
            break;
        default:
            break;
    }
}

- (void)singSong:(NSInteger)numeber {
    switch (numeber) {
        case 1:
            [server sendMessage:@"o"];
            break;
        case 2:
            [server sendMessage:@"p"];
            break;
        case 3:
            [server sendMessage:@"q"];
            break;
        case 4:
            [server sendMessage:@"r"];
            break;
        case 5:
            [server sendMessage:@"s"];
            break;
        case 6:
            [server sendMessage:@"t"];
            break;
        case 7:
            [server sendMessage:@"u"];
            break;
        case 8:
            [server sendMessage:@"v"];
            break;
        case 9:
            [server sendMessage:@"w"];
            break;
        case 10:
            [server sendMessage:@"x"];
            break;
        case 11:
            [server sendMessage:@"y"];
            break;
        case 12:
            [server sendMessage:@"z"];
            break;
        case 13:
            [server sendMessage:@"A"];
            break;
        case 14:
            [server sendMessage:@"B"];
            break;
        case 15:
            [server sendMessage:@"C"];
            break;
        default:
            break;
    }
}

- (void)deskNumber:(NSInteger)numeber {
    switch (numeber) {
        case 1:
            [server sendMessage:@"D"];
            break;
        case 2:
            [server sendMessage:@"E"];
            break;
        case 3:
            [server sendMessage:@"F"];
            break;
        case 4:
            [server sendMessage:@"G"];
            break;
        case 5:
            [server sendMessage:@"H"];
            break;
        case 6:
            [server sendMessage:@"Q"];
            break;
        case 7:
            [server sendMessage:@"R"];
            break;
        case 8:
            [server sendMessage:@"S"];
            break;
        case 9:
            [server sendMessage:@"T"];
            break;
        case 10:
            [server sendMessage:@"U"];
            break;
        case 11:
            [server sendMessage:@"V"];
            break;
        case 12:
            [server sendMessage:@"W"];
            break;
        case 13:
            [server sendMessage:@"X"];
            break;
        case 14:
            [server sendMessage:@"Y"];
            break;
        case 15:
            [server sendMessage:@"Z"];
            break;
        case 16:
            [server sendMessage:@":"];
            break;
        case 17:
            [server sendMessage:@"<"];
            break;
        case 18:
            [server sendMessage:@"="];
            break;
        case 19:
            [server sendMessage:@">"];
            break;
        case 20:
            [server sendMessage:@"?"];
            break;
        default:
            break;
    }
}

- (void)cancelSendMeal {
    [server sendMessage:@"@"];
}

- (void)backToOrigin {
    [server sendMessage:@"I"];
}

- (void)loopRun {
    [server sendMessage:@"J"];
}

- (void)songMode:(NSInteger)numeber {
    switch (numeber) {
        case 1:
            [server sendMessage:@"K"];
            break;
        case 2:
            [server sendMessage:@"L"];
            break;
        case 3:
            [server sendMessage:@"M"];
            break;
        case 4:
            [server sendMessage:@"N"];
            break;
        case 5:
            [server sendMessage:@"O"];
            break;
        default:
            break;
    }
}

- (void)stopSingSong {
    [server sendMessage:@"P"];
}


@end
