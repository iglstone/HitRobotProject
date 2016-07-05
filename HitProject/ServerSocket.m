//
//  ServerSocket.m
//  TeskSocket
//
//  Created by apple on 13-5-24.
//  Copyright (c) 2013年 Kid-mind Studios. All rights reserved.
//

#import "ServerSocket.h"
#import "SocketMessageModel.h"

#define TIMEOUT_SECKENTS -1 //12

@interface ServerSocket (){
    NSString *sendedMessageTwice;
    AsyncSocket *tmpSocket;
    NSMutableArray *socketMessageModlesArray;
}
@end

@implementation ServerSocket
@synthesize receiveMessage;
@synthesize isRunning;

static ServerSocket* _instance = nil;
#pragma mark - Lifecycle
+ (instancetype) sharedSocket
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    });
    return _instance ;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        listenSocket = [[AsyncSocket alloc] initWithDelegate:self];
        connectedSockets = [[NSMutableArray alloc] init];
        self.selectedSocketArray = [[NSMutableArray alloc] init];
        [listenSocket setRunLoopModes:[NSArray arrayWithObject:NSRunLoopCommonModes]];
        receiveMessage = nil;
        isRunning = NO;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(toBackGround:) name:NOTICE_BACKGROUND object:nil];
        socketMessageModlesArray = [[NSMutableArray alloc] init];
        self.messagesArray = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc
{
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

#pragma mark - AsyncSocketDelegate
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
    NSLog(@"Server didConnectToHost on socket:%@, port:@%d",host,port);
    [sock writeData:[ServerSocket stringToData:@"连接成功 !"] withTimeout:2 tag:0];//返回
    [sock readDataWithTimeout:TIMEOUT_SECKENTS tag:0];
    //为了解决断网问题，
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:3
                                                      target:self
                                                    selector:@selector(dealyNoticeSuccess:)
                                                    userInfo:@{@"port":@(port),@"host":host,@"status":@"已连接",@"socket":sock}
                                                     repeats:NO];
    if (!timer) {
        NSLog(@"time is nil");
    }
}

- (void)dealyNoticeSuccess:(NSTimer *)timer {
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_CONNECTSUCCESS object:nil userInfo:[timer userInfo]];
}

- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    NSString *msg = [ServerSocket dataToString:data];
    NSLog(@"Server didReadData = %@",[ServerSocket dataToString:data]);
    
    [[self mutableArrayValueForKey:@"messagesArray"] addObject:msg];
    BOOL isShow = [self dealWithReceivedMessage:msg socket:sock];
    if (isShow) {
        if ([msg isEqualToString:@"o"]) {
            msg = @"完成";
        }
        AppDelegate *dele = (AppDelegate*) [[UIApplication sharedApplication] delegate];
        if ([dele.main isKindOfClass:[MainViewController class]]) {
            MainViewController *tmpMain = (MainViewController *)dele.main;
            [tmpMain setDebugLabelText:msg mode:MESSAGEMODE_RECV];
        }
    }
    msg = nil;
    [sock readDataWithTimeout:TIMEOUT_SECKENTS tag:0];
}

/**
 * In the event of an error, the socket is closed.
 * You may call "unreadData" during this call-back to get the last bit of data off the socket.
 * When connecting, this delegate method may be called
 * before"onSocket:didAcceptNewSocket:" or "onSocket:didConnectToHost:".
 **/
/* socket发生错误时,socket关闭；连接时可能被调用，主要用于socket连接错误时读取错误发生前的数据*/
- (void)onSocket:(AsyncSocket *)sock willDisconnectWithError:(NSError *)err
{
    NSLog(@"Server willDisconnectWithError :%@",err);
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
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_DISCONNECT object:nil userInfo:@{@"socket":sock}];
    [connectedSockets removeObject:sock];
    [[self mutableArrayValueForKey:@"messagesArray"] removeAllObjects];
}

#pragma mark - Private Methods
/**
 *  处理接收到的数据
 *  @param msg  待处理数据
 *  @param sock 对应的socket
 *  @return 是否需要显示在debugLabel上
 */
- (BOOL)dealWithReceivedMessage :(NSString *) msg socket:(AsyncSocket *)sock{
    BOOL willShowOnLabel = YES;
    
    if ([msg isEqualToString:@"RED"] || [msg isEqualToString:@"BLUE"] || [msg isEqualToString:@"GOLD"]) {
        NSString *tmp ;//= [@"ROBOTNAME_" stringByAppendingString:msg];//每次新添加机器人就只需要在AppMacro.h中添加一个ROBOTNAME_开头的就行了。
        if ([msg isEqualToString:@"RED"]) {
            tmp = ROBOTNAME_RED;
        }else if([msg isEqualToString:@"BLUE"])
            tmp = ROBOTNAME_BLUE;
        else if ([msg isEqualToString:@"GOLD"])
            tmp = ROBOTNAME_GOLD;
        [[NSUserDefaults standardUserDefaults] setObject:tmp forKey:sock.connectedHost];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_CHANGEROBOTNAME object:nil userInfo:@{@"ipAddr":sock.connectedHost}];
        willShowOnLabel = NO;
        
    }else if ([msg hasPrefix:@"v"] && [msg hasSuffix:@"e"]) {
        NSString *power = [msg substringWithRange:NSMakeRange(1, msg.length-2)];
        if (power.length > 5) {
            return NO;
        }
        NSString *roboName = [ServerSocket getRobotName:sock];
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_POWERNOTIFICATION object:nil userInfo:@{@"power":power, @"roboName":roboName}];
        willShowOnLabel = NO;
        
    }else if ([msg hasPrefix:@"CARD"] || [msg hasPrefix:@"AT"] || [msg isEqualToString:@"A"] || [msg isEqualToString:@"v"]){//返回的card就不补充了。
        willShowOnLabel = NO;
        
    }else if ([msg hasPrefix:@"o"]&&[msg hasSuffix:@"e"]){
        [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_CONFIG_MODE_SPEEDN object:nil userInfo:@{@"ipAddr":sock.connectedHost, @"message":msg}];
        
    }else if ([msg hasPrefix:@"~"] && [msg hasSuffix:@"`"]) {
        self.starGazerAckString = msg;
        
    }else{
        //用来检测信息是否发送过去了，即检测发送的信号是否是msg == o;
        receiveMessage = msg;
        tmpSocket = sock;
    }
    return willShowOnLabel;
}

/**
 *  发送到client的数据，
 *  @param string :data need send to ip addr
 *  @param debugs :display on mainview debuglabel
 */
- (void)sendMessage :(NSString *)string debugstring:(NSString *)debugs
{
    if ([string hasPrefix:@"0x"]) {
        string = [CommonsFunc stringFromHexString:string];
    }
    if (string) {
        [[self mutableArrayValueForKey:@"messagesArray"] addObject:string];
    }
    AppDelegate *dele = (AppDelegate*) [[UIApplication sharedApplication] delegate];
    if (self.selectedSocketArray.count == 0 ) { //filtering the stopmove and stopSingSongs cmd.
        if ([debugs isEqualToString:@"停止"] || [debugs isEqualToString:@"停止播放"]) {
            //g:stopmove  P:stopSingSong
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:NOTICE_NOROBOT object:nil];//通知到主界面去提示没有连接
            return;
        }
    }
    if ([dele.main isKindOfClass:[MainViewController class]]) {
        MainViewController *tmpMain = (MainViewController *)dele.main;
        [tmpMain setDebugLabelText:debugs mode:MESSAGEMODE_SEND];
    }
    @autoreleasepool {
        for (AsyncSocket * s in self.selectedSocketArray)
        {
            sendedMessageTwice = string;
            if (!string) {
                continue;
            }
            receiveMessage = nil;
            if (s.isConnected) {
                [s writeData:[ServerSocket stringToData:string] withTimeout:-1 tag:0];
            }else{
                NSLog(@"s.isConnected == false");
            }
        }
    }
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
    NSString *robotName =  [[NSUserDefaults standardUserDefaults] objectForKey:ipaddr];
    if (robotName) {
        return robotName;
    }else
        return ipaddr;
}

/**
 *  十六进制准换成字符串
 *  @param hexString
 *  @return
 */
- (NSString *)stringFromHexString:(NSString *)hexString {
    if ([hexString hasPrefix:@"0x"]||[hexString hasPrefix:@"ox"]||[hexString hasPrefix:@"0X"]) {
        hexString = [hexString stringByReplacingCharactersInRange:NSMakeRange(0, 2) withString:@""];
        hexString = [hexString stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    }
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[[NSScanner alloc] initWithString:hexCharStr] autorelease];
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
    NSLog(@"----字符串===%@",unicodeString);
    return unicodeString;
}

- (void)sendMessageAgain{
    for (AsyncSocket * s in self.selectedSocketArray)
    {
        if (receiveMessage) {
            NSLog(@"开玩笑吗？有数据怎么还来玩 receive :%@",receiveMessage);
            return;
        }
        [s writeData:[ServerSocket stringToData:sendedMessageTwice] withTimeout:-1 tag:0];
        NSLog(@"send message again");
    }
}

- (void)compareMessage :(NSTimer  *) timer{
    static int times = 0;
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

@end
