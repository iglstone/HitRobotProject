//
//  FloydAlgorithm.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/17.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "FloydAlgorithm.h"

@implementation FloydAlgorithm

#pragma mark - init graph and algrithem

/**
 *  辅助初始化mGragh函数, 只初始化一半, 带绝对角度，不是相对角度的
 *  @param g      gragh
 *  @param start,要求 start < end
 *  @param end
 *  @param angles
 */
+ (void)initGrghNode:(mGraph *)graph Start:(int)start end:(NSArray*)ends realPositions:(NSArray *)realPosotionsArray realAngels:(NSArray *)angels {
    if (!realPosotionsArray) {
        NSMutableArray *arr = [NSMutableArray new];
        for (int i = 0 ; i < MAXVEX; i++) {
            [arr insertObject:[NSValue valueWithCGPoint:CGPointZero] atIndex:i];
        }
        realPosotionsArray = [NSArray arrayWithArray:arr];
    }
    for (int i = 0; i<ends.count; i++) {
        NSInteger end = [[ends objectAtIndex:i] integerValue];
        if (start >= end) {
            NSLog(@"start num >= ending num");
            continue;
        }
        
        CGPoint st = [[realPosotionsArray objectAtIndex:start] CGPointValue];
        CGPoint ed = [[realPosotionsArray objectAtIndex:end] CGPointValue];
        float disX = ed.x - st.x;
        float disY = ed.y - st.y;
        float weight = sqrtf(disX*disX + disY*disY);
        float angel = [[angels objectAtIndex:i] floatValue];
        graph->weightAndAngels[start][end].weight = weight;
        graph->weightAndAngels[start][end].angel = angel;
    }
}

/**
 *  辅助初始化mGragh函数, 只初始化一半，自己计算相对角度，非绝对角度
 *  @param g      gragh
 *  @param start,要求 start < end
 *  @param end
 *  @param weight
 *  @param angles
 */
+ (void)initGrghNode:(mGraph *)graph Start:(int)start end:(NSArray*)ends realPosition:(NSArray *) realPosotionsArray {
    for (int i = 0; i<ends.count; i++) {
        NSInteger end = [[ends objectAtIndex:i] integerValue];
        if (start >= end) {
            NSLog(@"start num >= ending num");
            continue;
        }
        
        CGPoint st = [[realPosotionsArray objectAtIndex:start] CGPointValue];
        CGPoint ed = [[realPosotionsArray objectAtIndex:end] CGPointValue];
        float disX = ed.x - st.x;float disY = ed.y - st.y;
        float weight = sqrtf(disX*disX + disY*disY);
        float angelf = atan2f(disY, disX);//  atan2f(disY/disX);
        int angel = (int) (angelf / M_PI *180);
        //        if (angel < 0) {
        //            angel = angel +180;
        //        }
        graph->weightAndAngels[start][end].weight = weight;
        graph->weightAndAngels[start][end].angel = angel;
    }
}

/**
 *  初始化终点的角度信息
 *  @param vexsAngel 一维数组
 *  @param angels    角度信息
 */
+ (void )initSingelPointIdAndAngel:(vexAngels *)vexAngels withIdAndAngels:(NSArray *)angels {
    int v;
    if (angels.count != MAXVEX) {
        NSLog(@"points num is not equal to angels num");
        return;
    }
    for (v = 0; v < MAXVEX; v++) {
        float angel = [[angels objectAtIndex:v] floatValue];
        (*vexAngels)[v] = angel;
    }
}

//Floyd algorithm : 计算图graph中各定点v到其余定点w的最短路径points[v][w]及带权长度distances[v][w]
+ (void) floydShortestPath:(mGraph *)graph pointsTabel:(vexsPre2DTabel *)points2 shortTable:(distancesSum2DTabel *)distances2 {
    int v,w,k;
    for (v = 0; v < graph->numVertexes; v++) {// init points distances
        for (w = 0; w < graph->numVertexes; w++) {
            (*distances2)[v][w] = graph->weightAndAngels[v][w].weight;//distances[v][w]为对应的权值
            (*points2)[v][w] = w;//初始化points
        }
    }
    for (k = 0; k < graph->numVertexes; k++) {
        for (v = 0; v < graph->numVertexes; v++) {
            for (w = 0; w < graph->numVertexes; w++) {
                if ((*distances2)[v][w] > (*distances2)[v][k] + (*distances2)[k][w]) {
                    (*distances2)[v][w] = (*distances2)[v][k] + (*distances2)[k][w];
                    (*points2)[v][w] = (*points2)[v][k];//路径设置为净多下标为k的顶点
                }
            }
        }
    }
}

/**
 *  输出任意两点最短路径，以及路径上的角度以及终点信息(终点角度和路途角度不要混淆)
 *  @param graph       图
 *  @param m           start
 *  @param n           end
 *  @param points      pointsTable, 前驱信息
 *  @param distances   distanceTable,距离信息
 *  @param vexsAngel   终点角度信息
 */
+(NSString *)findShortestPath:(mGraph *)graph from:(int)start to:(int)end pointsTabel:(vexsPre2DTabel *)vexPres robotAngels:(vexAngels *)angels{
    int pontIndexFirst =  (*vexPres)[start][end];//robot.pointNum;
    int angelmOfStart = graph->weightAndAngels[start][pontIndexFirst].angel;
    NSString *tem = [NSString stringWithFormat:@"path: %d,%d -> %d,", start, angelmOfStart, pontIndexFirst];
    
    while (pontIndexFirst != end) {
        int pointIndexSaveFirst = pontIndexFirst;
        pontIndexFirst = (*vexPres)[pontIndexFirst][end];// get next vertex point
        int angelOfFirst = graph->weightAndAngels[pointIndexSaveFirst][pontIndexFirst].angel;
        tem = [tem stringByAppendingString:[NSString stringWithFormat:@"%d -> %d,",angelOfFirst, pontIndexFirst]];
    }
    tem = [tem stringByAppendingString:[NSString stringWithFormat:@"%f",(*angels)[end]]];
    return tem;
}

/**
 *  输出图中任意两点的前驱点信息和距离和信息
 *  @param graph     图
 *  @param points    点前驱二维数组
 *  @param distances 距离和二维数组
 */
+ (void)printShortestPath:(mGraph *)graph pointsTabel:(vexsPre2DTabel *)points2 shortestTabel:(distancesSum2DTabel *)distances2 {
    int v,w,k;
    //    for (v  = 0; v < graph->numVertexes; v++) {
    for (v  = 0; v < 1; v++) { //测试从0到任意一点
        for (w = v+1; w < graph->numVertexes; w++) {
            NSLog(@"v%d - w%d: weight :%d",v,w,(*distances2)[v][w]);
            k = (*points2)[v][w];       //get the first point
            NSLog(@"path: %d",v); // log sorce point
            while (k != w) {
                NSLog(@"-> %d",k);// log vertex
                k = (*points2)[k][w];   //get next vertex point
            }
            NSLog(@"-> %d",w);    // log final point
        }
    }
}

/**
 *  当机器人在朝着一个方向走的时候，反方向给堵住，，设置为intmax即可
 *  @param start 相邻两点的起始点
 *  @param end   相邻两点的终点
 *  @param gragh 待修改的图
 */
+ (void )preventTheWay:(mGraph *)gragh OfStart:(int)start toEnd:(int)end {
    int weight = gragh -> weightAndAngels[start][end].weight;
    if (weight == INTMAX) {
        NSLog(@"start and end point not in passed by");
        return;
    }
    gragh->weightAndAngels[start][end].weight = INTMAX;//反方向给堵住
    //    gragh.weightAndAngels[end][start].weight = INTMAX;//反方向给堵住
}


@end
