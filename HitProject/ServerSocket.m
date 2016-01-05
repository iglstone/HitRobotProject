//
//  ServerSocket.m
//  TeskSocket
//
//  Created by apple on 13-5-24.
//  Copyright (c) 2013年 Kid-mind Studios. All rights reserved.
//

#import "ServerSocket.h"
#import "SocketMessageModel.h"

@interface ServerSocket (){
    NSString *sendedMessage;
//    NSString *receiveMessage;
//    NSTimer *timer;
    NSInteger times;
    AsyncSocket *tmpSocket;
    NSMutableArray *socketMessageModlesArray;
}
@end

@implementation ServerSocket
@synthesize result;
@synthesize receiveMessage;

static ServerSocket* _instance = nil;
#pragma mark - Lifecycle
+ (instancetype) sharedSocket
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    
    return _instance ;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        result = [[NSMutableString alloc] init];
        listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
//        connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        connectedSockets = [[NSMutableArray alloc] init];
        self.selectedSocketArray = [[NSMutableArray alloc] init];
        [listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        receiveMessage = nil;
        isRunning = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toBackGround:) name:NOTICE_BACKGROUND object:nil];
        socketMessageModlesArray = [[NSMutableArray alloc] init];
        times = 0;
    }
    return self;
}

- (void)dealloc
{
    [result release];
    [listenSocket disconnect];
    listenSocket.delegate = nil;
    [listenSocket release];
    
    for (AsyncSocket *s in self.selectedSocketArray)
    {
        [s disconnect];
    }
    [self.selectedSocketArray release];
    for (AsyncSocket *s in connectedSockets)
    {
        [s disconnect];
    }
    [connectedSockets release];
    [super dealloc];
}

#pragma mark - Private Methods
- (void)sendMessage :(NSString *)string debugstring:(NSString *)debugs
{
    AppDelegate *dele = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    NSLog(@"selected sockets array num: %lu",(unsigned long)self.selectedSocketArray.count);
    if (self.selectedSocketArray.count == 0 ) {
        if ([string isEqualToString:@"g"] || [string isEqualToString:@"P"]) {
            //g:stopmove  P:stopSingSong
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_NOROBOT object:nil];//通知到主界面去提示没有连接
            return;
        }
    }
    [dele.main setDebugLabelText:debugs mode:0];
    for (AsyncSocket * s in self.selectedSocketArray)
    {
        sendedMessage = string;
        if (!string) {
            continue;
        }
        receiveMessage = nil;
        
//        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.23 target:self selector:@selector(compareMessage:) userInfo:@{@"sock":s} repeats:YES];
        
        if (s.isConnected) {
            [s writeData:[ServerSocket stringToData:string] withTimeout:-1 tag:0];
//            [timer fire];
        }else
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_DISCONNECT object:nil userInfo:@{@"socket":s}];
    }
}

- (void)sendMessageAgain{
    for (AsyncSocket * s in self.selectedSocketArray)
    {
        if (receiveMessage) {
            NSLog(@"开玩笑吗？有数据怎么还来玩 receive :%@",receiveMessage);
            return;
        }
        [s writeData:[ServerSocket stringToData:sendedMessage] withTimeout:-1 tag:0];
        NSLog(@"send message again");
    }
}

- (void)compareMessage :(NSTimer  *) timer{
    AsyncSocket *S = (AsyncSocket *)[[timer userInfo] objectForKey:@"sock"];
    if (!receiveMessage) {//为空，没有读取到
        NSLog(@"has not receive");
        [self sendMessageAgain];
        times ++;
        if (times == 20) {
            NSLog(@"20 times return");
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_TRYAGIAN object:nil];//显示toast
            times = 0;
            [timer invalidate];
            timer = nil;
            return;
        }
        return;
    }
    
    if ([receiveMessage isEqualToString:@"o"] && [S isEqual:tmpSocket]) {
        times = 0;
        NSLog(@"socket the same ");
        [timer invalidate];
        timer = nil;
        return;
    }
    
    NSLog(@"receive others :%@",S);
    
}

- (void)toBackGround:(NSNotification *)noti {
    NSLog(@"toBackGround noti");
    [self stopListen];
    
}

- (void)startListen
{
    if (!isRunning)
    {
        NSInteger port = LISTEN_PORT;
        NSError *error = nil;
        [listenSocket acceptOnPort:port error:&error];
        NSLog(@"acceptOnPort error = %@",error);
        isRunning = YES;
    }
}

- (void)stopListen
{
    if (isRunning)
    {
        [listenSocket disconnect];
        
        for (AsyncSocket *socket in connectedSockets)
        {
            [socket disconnect];
        }
        
        isRunning = NO;
    }
}

+ (NSString *)dataToString:(NSData *)data
{
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

+ (NSData *)stringToData:(NSString *)string
{
    return [string dataUsingEncoding:NSUTF8StringEncoding];
}

//- (void)lock
//{
//    for (AsyncSocket * s in connectedSockets)
//    {
//        [s writeData:[ServerSocket stringToData:@"9999"] withTimeout:-1 tag:0];
//    }
//}
//
//- (void)unlock
//{
//    for (AsyncSocket * s in connectedSockets)
//    {
//        [s writeData:[ServerSocket stringToData:@"10000"] withTimeout:-1 tag:0];
//    }
//}

#pragma mark - AsyncSocketDelegate
/**
 * In the event of an error, the socket is closed.
 * You may call "unreadData" during this call-back to get the last bit of data off the socket.
 * When connecting, this delegate method may be called
 * before"onSocket:didAcceptNewSocket:" or "onSocket:didConnectToHost:".
 **/
/* socket发生错误时,socket关闭；连接时可能被调用，主要用于socket连接错误时读取错误发生前的数据*/
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"Server willDisconnectWithError");
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_DISCONNECT object:nil userInfo:@{@"socket":sock}];
}

/**
 * Called when a socket disconnects with or without error.  If you want to release a socket after it disconnects,
 * do so here. It is not safe to do that during "onSocket:willDisconnectWithError:".
 *
 * If you call the disconnect method, and the socket wasn't already disconnected,
 * this delegate method will be called before the disconnect method returns.
 **/

/*socket断开连接后被调用，你调用disconnect方法，还没有断开连接，只有调用这个方法时，才断开连接；可以在这个方法中release 一个 socket*/
- (void)onSocketDidDisconnect:(AsyncSocket *)sock
{
    NSLog(@"Server onSocketDidDisconnect");
    [connectedSockets removeObject:sock];
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_DISCONNECT object:nil userInfo:@{@"socket":sock}];
}

/**
 * Called when a socket accepts a connection.  Another socket is spawned to handle it. The new socket will have
 * the same delegate and will call "onSocket:didConnectToHost:port:".
 **/

/*监听到新连接时被调用，这个新socket的代理和listen socket相同*/
- (void)onSocket:(AsyncSocket *)sock didAcceptNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"Server didAcceptNewSocket");
    [connectedSockets addObject:newSocket];
}

/**
 * Called when a new socket is spawned to handle a connection.  This method should return the run-loop of the
 * thread on which the new socket and its delegate should operate. If omitted, [NSRunLoop currentRunLoop] is used.
 **/
- (NSRunLoop *)onSocket:(AsyncSocket *)sock wantsRunLoopForNewSocket:(AsyncSocket *)newSocket
{
    NSLog(@"Server wantsRunLoopForNewSocket");
    return [NSRunLoop currentRunLoop]; 
}

/**
 * Called when a socket is about to connect. This method should return YES to continue, or NO to abort.
 * If aborted, will result in AsyncSocketCanceledError.
 *
 * If the connectToHost:onPort:error: method was called, the delegate will be able to access and configure the
 * CFReadStream and CFWriteStream as desired prior to connection.
 *
 * If the connectToAddress:error: method was called, the delegate will be able to access and configure the
 * CFSocket and CFSocketNativeHandle (BSD socket) as desired prior to connection. You will be able to access and
 * configure the CFReadStream and CFWriteStream in the onSocket:didConnectToHost:port: method.
 **/
- (BOOL)onSocketWillConnect:(AsyncSocket *)sock
{
    NSLog(@"Server onSocketWillConnect");
    return YES;
}

/**
 * Called when a socket connects and is ready for reading and writing.
 * The host parameter will be an IP address, not a DNS name.
 **/
- (void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"Server didConnectToHost");
    NSLog(@"主机 %@ 已连接上服务器",host);
    NSLog(@"端口:%hu",port);
    
    [sock writeData:[ServerSocket stringToData:@"连接成功 !"] withTimeout:-1 tag:0];//返回
    [sock readDataWithTimeout:-1 tag:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_CONNECTSUCCESS object:nil userInfo:@{@"port":@(port),
                                                                                                           @"host":host,
                                                                                                           @"status":@"已连接",
                                                                                                           @"socket":sock}];
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:20 target:self selector:@selector(aliveKeep:) userInfo:@{@"socket":sock} repeats:YES];
//    [timer fire];
}

//心跳包执行函数  十秒重联的话这个好像就没什么用了。。
- (void) aliveKeep :(NSTimer *)timer {
    AsyncSocket *socket = (AsyncSocket *)[[timer userInfo] objectForKey:@"socket"];
    
    for (SocketMessageModel *model in socketMessageModlesArray) {
        if ([model.socket isEqual:socket]) {//s
            if ([model.message hasPrefix:@"v"] && [model.message hasSuffix:@"e"]) {//控制model 的msg 来判断是否断开
                NSLog(@"socket alive");
                model.message = nil;
            } else {
                NSLog(@"socket die");
                [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_DISCONNECT object:nil userInfo:@{@"socket":socket}];
//                [socketMessageModlesArray removeObject:model];
                [timer invalidate];
                timer = nil;
            }
        }
    }
}

/**
 * Called when a socket has completed reading the requested data into memory.
 * Not called if there is an error.
 **/
- (void)update
{
    static int a = 0;
    a++;
    [[connectedSockets lastObject] writeData:[ServerSocket stringToData:[NSString stringWithFormat:@"a = %d",a]] withTimeout:-1 tag:0];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *msg = [ServerSocket dataToString:data];
    NSString *msg2 = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"Server didReadData = %@",[ServerSocket dataToString:data]);
    AppDelegate *dele = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    
    BOOL isShow = YES;
    
    if ([msg isEqualToString:@"RED"] || [msg isEqualToString:@"BLUE"]) {
        NSLog(@"sock.connect host is: %@", sock.connectedHost);
        if ([msg isEqualToString:@"RED"]) {
            [[NSUserDefaults standardUserDefaults] setObject:sock.connectedHost forKey:NSDEFAULT_REDROBOTIP];
        }else
            [[NSUserDefaults standardUserDefaults] setObject:sock.connectedHost forKey:NSDEFAULT_BLUEROBOTIP];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_CHANGEROBOTNAME object:nil userInfo:@{@"ipAddr":sock.connectedHost}];
        isShow = NO;
    }
    else if ([msg hasPrefix:@"v"] && [msg hasSuffix:@"e"]) {
        NSString *power = [msg substringWithRange:NSMakeRange(1, msg.length-2)];
        if ([[ServerSocket getRobotName:sock] isEqualToString:ROBOTNAME_RED]) {
            self.kvoPower = power;
        }
        if ([[ServerSocket getRobotName:sock] isEqualToString:ROBOTNAME_BLUE]) {
            self.bluekvoPower = power;
        }
        
//        //当成心跳包来测试
//        SocketMessageModel *model = [SocketMessageModel new];
//        model.socket = sock;
//        model.message = msg2;
//        BOOL ischange = NO;
//        for (SocketMessageModel *tmpModel in socketMessageModlesArray) {
//            if ([tmpModel.socket isEqual:sock]) {//如果socket存在，message置空
////                [socketMessageModlesArray removeObject:tmpModel];
////                [socketMessageModlesArray addObject:model];
//                tmpModel.message = nil;
//                ischange = YES;
//            }
//        }
//        if (ischange == NO) {//socket 不存在
//            [socketMessageModlesArray addObject:model];
//        }
//        NSLog(@"socketMessageModlesArray nums :%lu",(unsigned long)socketMessageModlesArray.count);
        
        isShow = NO;
    } else if ([msg hasPrefix:@"CARD"] || [msg hasPrefix:@"AT"] || [msg isEqualToString:@"A"]){//返回的card就不补充了。
        isShow = NO;
    }
    else
    {
        //用来检测信息是否发送过去了，即检测发送的信号是否是msg2 == o;
        receiveMessage = msg2;
        [msg2 release];
        msg2 = nil;
        tmpSocket = sock;
    }
    if (isShow) {
        if ([msg isEqualToString:@"o"]) {
            msg = @"完成";
        }
        [dele.main setDebugLabelText:msg mode:1];
    }
    
//    [result appendString:[ServerSocket dataToString:data]];
//    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(update) userInfo:nil repeats:YES];
    [result appendString:[NSString stringWithFormat:@"%@:%@\n",[sock connectedHost],[ServerSocket dataToString:data]]];
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_RESULT_NOTIFICATION object:nil];
    [sock readDataWithTimeout:-1 tag:0];
}

/**
 *  原理：连接一个socket，等待接收 RED / BLUE 消息来nsuserdefault 存储
 *  其ip，后面根据其ip来找到对应的小红小兰。
 *  @param sock
 *  @return 小红，小蓝
 */
+ (NSString *)getRobotName :(AsyncSocket *)sock {
    if (!sock.isConnected) {
        NSLog(@"sock 断连了");
        return nil;
    }
    NSString *conectedip = sock.connectedHost;
    NSString *string = [ServerSocket getRobotNameByIp:conectedip];
    return string;
}

+ (NSString *)getRobotNameByIp :(NSString *)ipaddr {
    NSString *conectedip = ipaddr;
    NSString *redrobotip = [[NSUserDefaults standardUserDefaults] objectForKey:NSDEFAULT_REDROBOTIP];
    NSString *bluerobotip = [[NSUserDefaults standardUserDefaults] objectForKey:NSDEFAULT_BLUEROBOTIP];
    if (!conectedip) {
        NSLog(@"connected ip is 空");
        return nil;
    }
    if ([conectedip isEqualToString:redrobotip]) {
        NSString *RED = ROBOTNAME_RED;
        return  RED;
    } else if ([conectedip isEqualToString:bluerobotip])  {
        NSString *Blue = ROBOTNAME_BLUE;
        return  Blue;
    }else {
        return conectedip;
    }
}

/**
 * Called when a socket has read in data, but has not yet completed the read.
 * This would occur if using readToData: or readToLength: methods.
 * It may be used to for things such as updating progress bars.
 **/
- (void)onSocket:(AsyncSocket *)sock didReadPartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{
    NSLog(@"Server didReadPartialDataOfLength = %lu",(unsigned long)partialLength);
}

/**
 * Called when a socket has completed writing the requested data. Not called if there is an error.
 **/
- (void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    
}

/**
 * Called when a socket has written some data, but has not yet completed the entire write.
 * It may be used to for things such as updating progress bars.
 **/
- (void)onSocket:(AsyncSocket *)sock didWritePartialDataOfLength:(NSUInteger)partialLength tag:(long)tag
{}
@end
