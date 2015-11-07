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
        default:
            break;
    }
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
