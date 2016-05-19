//
//  FloydAlgorithm.h
//  TourRobot
//
//  Created by 郭龙 on 16/5/17.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RouteHeader.h"

@interface FloydAlgorithm : NSObject

//初始化angel和id成为pointIdAndAngel格式
+ (void ) initSingelPointIdAndAngel:(vexAngels *)idsAndAngels withIdAndAngels:(NSArray *)angels ;

//floyed 最短路径算法
+ (void ) floydShortestPath:(mGraph *)graph pointsTabel:(vexsPre2DTabel *)points2 shortTable:(distancesSum2DTabel *)distances2 ;

//从一点到另一点的最短路径
+ (NSString *) findShortestPath:(mGraph *)graph from:(int)m to:(int)n pointsTabel:(vexsPre2DTabel *)points2 robotAngels:(vexAngels *)idsAndAngels ;

+ (void) printShortestPath:(mGraph *)graph pointsTabel:(vexsPre2DTabel *)points2 shortestTabel:(distancesSum2DTabel *)distances2 ;

/**
 *  从start to end ,set maxint
 *  @param gragh
 *  @param start
 *  @param end   
 */
+ (void )preventTheWay:(mGraph *)gragh OfStart:(int)start toEnd:(int)end ;
@end