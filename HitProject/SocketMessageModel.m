//
//  SocketMessageModel.m
//  HitProject
//
//  Created by 郭龙 on 15/12/19.
//  Copyright © 2015年 郭龙. All rights reserved.
//

#import "SocketMessageModel.h"

@implementation SocketMessageModel
@synthesize socket;
@synthesize message;

- (instancetype)init {
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}
@end
