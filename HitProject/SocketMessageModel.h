//
//  SocketMessageModel.h
//  HitProject
//
//  Created by 郭龙 on 15/12/19.
//  Copyright © 2015年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SocketMessageModel : NSObject

@property (nonatomic ,strong) NSString *message;
@property (nonatomic ,strong) AsyncSocket *socket;

@end
