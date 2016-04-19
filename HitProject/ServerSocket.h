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
@property (nonatomic,retain) NSMutableArray  *selectedSocketArray;
@property (nonatomic,retain) NSString        *kvoPower;//红的电量
@property (nonatomic,retain) NSString        *bluekvoPower;//蓝的电量
@property (nonatomic,retain) NSString        *receiveMessage;
@property (nonatomic,retain) NSMutableArray *messagesArray;

+ (instancetype) sharedSocket;

/**
 *  发送指令代码
 *  @param string 具体指令
 *  @param debugs 在debug区域显示的命令
 */
- (void)sendMessage :(NSString *)string debugstring:(NSString *)debugs;

//开始监听端口1234
- (void)startListen;
//停止监听端口1234
- (void)stopListen;

/**
 *  根据socket来获取机器人name
 *  @param sock 具体的sock
 *  @return 返回具体的机器人名字 :ROBOTNAME_RED || ROBOTNAME_BLUE
 */
+ (NSString *)getRobotName :(AsyncSocket *)sock ;

/**
 *  @brief 根据ip返回机器人名称
 *  @param ipaddr ip地址
 *  @return 机器人名称，小红，小兰
 */
+ (NSString *)getRobotNameByIp :(NSString *)ipaddr ;
@end
