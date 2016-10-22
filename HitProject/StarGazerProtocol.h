//
//  StarGazerProtocol.h
//  HitProject
//
//  Created by 郭龙 on 16/7/25.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef NS_OPTIONS(uint8_t, StarGazerMode) {
    StarGazerModeControl = 1,// << 0, // 1
    StarGazerModeSetting = 2,// << 1, // 2
    StarGazerModePath    = 3,//<< 2, // 4
    StarGazerModeOthr    = 4,// << 3, // 8
};


@interface StarGazerProtocol : NSObject

+ (instancetype )sharedStarGazerProtocol ;

- (NSString *) composeDownLoadStringOfMode:(StarGazerMode)mode data:(NSString *)dataString;

/*
//send the starGazer protocol to stargazer
- (void) sendMessage:(NSString *)string Mode:(StarGazerMode)mode;
*/

@end
