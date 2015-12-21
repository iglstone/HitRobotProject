//
//  ServerSocket.h
//  TeskSocket
//
//  Created by apple on 13-5-24.
//  Copyright (c) 2013年 Kid-mind Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"


@interface ServerSocket : NSObject <AsyncSocketDelegate>
{
    AsyncSocket *listenSocket;
    NSMutableArray *connectedSockets;
    
    BOOL isRunning;
}

@property (nonatomic,retain) NSMutableString *result;
@property (nonatomic,retain) NSMutableArray *selectedSocketArray;
@property (nonatomic,retain) NSString *kvoPower;//红的电量
@property (nonatomic,retain) NSString *bluekvoPower;//蓝的电量
@property (nonatomic,retain) NSString *receiveMessage;

+ (instancetype) sharedSocket;

//- (void)lock;
//- (void)unlock;
//- (void)sendMessage:(NSString *)string;
- (void)sendMessage :(NSString *)string debugstring:(NSString *)debugs;

- (void)startListen;
- (void)stopListen;

+ (NSString *)getRobotName :(AsyncSocket *)sock ;
+ (NSString *)getRobotNameByIp :(NSString *)ipaddr ;
@end
