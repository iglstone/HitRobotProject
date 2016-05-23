//
//  DataCenter.h
//  HitProject
//
//  Created by 郭龙 on 16/5/23.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NOTI_SETTINGINFOMATION @"SETTINGINFOMATION"
#define NOTI_EDITGRAPHINFO @"NOTI_EDITGRAPHINFO"

@interface DataCenter : NSObject

- (NSInteger)getVexsNum;
- (NSInteger)getMapWidth;
- (NSInteger)getMapHeight;

- (NSArray *)getGraphArr ;

@end
