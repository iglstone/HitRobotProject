//
//  DataCenter.m
//  HitProject
//
//  Created by 郭龙 on 15/12/3.
//  Copyright © 2015年 郭龙. All rights reserved.
//

#import "DataCenter.h"

@implementation DataCenter
static DataCenter* _instance = nil;

+ (instancetype) sharedControl
{
    static dispatch_once_t onceToken ;
    dispatch_once(&onceToken, ^{
        _instance = [[self alloc] init];
    }) ;
    return _instance ;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

@end
