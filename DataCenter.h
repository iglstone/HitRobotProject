//
//  DataCenter.h
//  HitProject
//
//  Created by 郭龙 on 16/5/23.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteHeader.h"
#import "EditGraphModelAndCell.h"

#define NOTI_SETTINGINFOMATION @"SETTINGINFOMATION"
#define NOTI_REFRESHDRAW @"NOTI_REFRESHDRAW"
#define NOTI_EDITGRAPHINFO @"NOTI_EDITGRAPHINFO"

@interface DataCenter : NSObject
+ (instancetype )sharedDataCenter ;

- (void)creatMGragh:(mGraph *)graph OfModelsArr: (NSArray<EditGraphModel *> *)modelsArr;

- (NSInteger)getVexsNum;
- (NSInteger)getMapWidth;
- (NSInteger)getMapHeight;

- (NSArray *)getRealPositionsArr ;
- (NSArray *)getAngelsArr ;
- (NSArray *)getGraphModlesArr;
- (void)setRealPositonsOfIndex:(int)index ofPoint:(CGPoint)pt ;
- (void)setRealPoisitonsOfArr :(NSArray *)arr ;

@end
