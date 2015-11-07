//
//  ServerSocket.m
//  TeskSocket
//
//  Created by apple on 13-5-24.
//  Copyright (c) 2013年 Kid-mind Studios. All rights reserved.
//

#import "ServerSocket.h"

@implementation ServerSocket
@synthesize result;
//@synthesize selectA,selectB,selectC,selectD;

static ServerSocket* _instance = nil;

+ (instancetype) sharedSocket
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init] ;
    }) ;
    
    return _instance ;
}

#pragma mark - Private Methods
- (void)lock
{
    for (AsyncSocket * s in connectedSockets)
    {
        [s writeData:[ServerSocket stringToData:@"9999"] withTimeout:-1 tag:0];
    }
}
- (void)unlock
{
    for (AsyncSocket * s in connectedSockets)
    {
        [s writeData:[ServerSocket stringToData:@"10000"] withTimeout:-1 tag:0];
    }
}

- (void)sendMessage :(NSString *)string
{
    for (AsyncSocket * s in connectedSockets)
    {
        [s writeData:[ServerSocket stringToData:string] withTimeout:-1 tag:0];
    }
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
#pragma mark - Lifecycle
- (id)init
{
    self = [super init];
    if (self)
    {
        result = [[NSMutableString alloc] init];
        
        listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
        connectedSockets = [[NSMutableArray alloc] initWithCapacity:1];
        [listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        
        isRunning = NO;
    }
    return self;
}

- (void)dealloc
{
    [result release];
    [listenSocket disconnect];
    listenSocket.delegate = nil;
    [listenSocket release];
    
    for (AsyncSocket *s in connectedSockets)
    {
        [s disconnect];
    }
    [connectedSockets release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

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
    
    [sock writeData:[ServerSocket stringToData:@"connect success!"] withTimeout:-1 tag:0];//返回
    [sock readDataWithTimeout:-1 tag:0];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_CONNECTSUCCESS object:nil userInfo:@{@"port":@(port),
                                                                                                           @"host":host}];
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
    NSLog(@"Server didReadData = %@",[ServerSocket dataToString:data]);
//    [result appendString:[ServerSocket dataToString:data]];
//    [NSTimer scheduledTimerWithTimeInterval:3.0f target:self selector:@selector(update) userInfo:nil repeats:YES];
    [result appendString:[NSString stringWithFormat:@"%@:%@\n",[sock connectedHost],[ServerSocket dataToString:data]]];
    if ([msg isEqualToString:@"中国"])
    {
//        selectA++;
    }
    else if([msg isEqualToString:@"日本"])
    {
//        selectB++;
    }
    else if([msg isEqualToString:@"英国"])
    {
//        selectC++;
    }
    else if([msg isEqualToString:@"美国"])
    {
//        selectD++;
    }
    
    if ([msg isEqualToString:@"alowscreen"])
    {
//        [self startShareScreen];
    }
    
//    [[NSNotificationCenter defaultCenter] postNotificationName:UPDATE_RESULT_NOTIFICATION object:nil];
    [sock readDataWithTimeout:-1 tag:0];
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
