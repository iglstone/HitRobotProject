//
//  DataCenter.m
//  HitProject
//
//  Created by 郭龙 on 16/5/23.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "DataCenter.h"

@interface DataCenter () {
    NSArray *keySettingArr;

}

@end

@implementation DataCenter

- (instancetype)init {
    self = [super init];
    if (self) {
        keySettingArr = @[@"vexs", @"mapW", @"mapH"];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiInfo:) name:NOTI_SETTINGINFOMATION object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notiInfo:) name:NOTI_EDITGRAPHINFO object:nil];
        return self;
    }
    return nil;
}

- (void) notiInfo :(NSNotification *)noti {
    NSDictionary *dic = [noti userInfo];
    if ([[noti name] isEqualToString:NOTI_SETTINGINFOMATION]) {
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:NOTI_SETTINGINFOMATION];//用noti做key来保存本地
        
        NSNumber *vexsNum = [dic objectForKey:keySettingArr[0]];
        NSNumber *mapWidth = [dic objectForKey:keySettingArr[1]];
        NSNumber *mapHeight = [dic objectForKey:keySettingArr[2]];
        if (vexsNum || mapHeight || mapWidth) {
            NSLog(@"something wrong");
        }
    }
    
    if ([[noti name]isEqualToString:NOTI_EDITGRAPHINFO]) {
        NSArray *dicsArr = [dic objectForKey:@"dicsArr"];
        [[NSUserDefaults standardUserDefaults] setObject:dic forKey:NOTI_EDITGRAPHINFO];
        NSArray *keyArr = @[@"ptXY", @"ptAngel", @"ptJoints", @"ptJointsAngels"];
        for (int i = 0; i < [self getVexsNum]; i++) {
            NSDictionary *dic = [dicsArr objectAtIndex:i];
            NSString *xy = [dic objectForKey:keyArr[0]];
            NSString *angel = [dic objectForKey:keyArr[1]];
            NSString *joints = [dic objectForKey:keyArr[2]];
            NSString *jointAngels = [dic objectForKey:keyArr[3]];
            if (!xy || !angel || !joints || !jointAngels) {
                NSLog(@"error of graph data");
                return;
            }
        }
    }
}


-(NSArray *)getGraphArr {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:NOTI_EDITGRAPHINFO];
    NSArray *dicsArr = [dic objectForKey:@"dicsArr"];
    if (!dicsArr) {
        NSLog(@"nil of graph data");
    }
    return dicsArr;
}

- (NSInteger)getVexsNum {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:NOTI_SETTINGINFOMATION];
    NSNumber *number = [dic objectForKey:keySettingArr[0]];
    if (!number || [number integerValue] == 0) {
        return 4;
    }
    return [number integerValue];
}

- (NSInteger)getMapWidth {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:NOTI_SETTINGINFOMATION];
    NSNumber *number = [dic objectForKey:keySettingArr[1]];
    if (!number || [number integerValue] == 0) {
        return 1000;
    }
    return [number integerValue];
}

- (NSInteger)getMapHeight {
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:NOTI_SETTINGINFOMATION];
    NSNumber *number = [dic objectForKey:keySettingArr[2]];
    if (!number || [number integerValue] == 0) {
        return 500;
    }
    return [number integerValue];
}


@end
