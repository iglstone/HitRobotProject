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

+ (instancetype) sharedSocket;

- (void)lock;
- (void)unlock;
- (void)sendMessage:(NSString *)string;

- (void)startListen;
- (void)stopListen;

@end
