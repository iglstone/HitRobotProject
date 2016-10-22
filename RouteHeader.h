//
//  RouteHeader.h
//  TourRobot
//
//  Created by 郭龙 on 16/5/18.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#ifndef RouteHeader_h
#define RouteHeader_h

#import <math.h>

#define MAXVEX      30
//#define MAXEDGE    4
//#define POINTSNUM  9
#define INTMAX     65535
#define POINTRADUS 7

/*******207办公室******/
//#define MAPMAXWIDTH  900//实际地图尺寸,CM
//#define MAPMAXHEIGHT  400//实际地图尺寸,CM
/*****一楼展厅尺寸******/
#define MAPMAXWIDTH  2365//实际地图尺寸,CM
#define MAPMAXHEIGHT  1395//实际地图尺寸,CM

#define MAPOFFSETOFSCREEN 30

#define OFFSETPICW  600//地图上0点水平偏移地图实际位置，cm
#define OFFSETPICH  935// = 1395 - 460//地图上0点竖直偏移地图实际位置，cm


typedef struct {
    float weight;//连线长度
    float angel;//连线在空间的角度
} lineWeightAndAngel;//连接线的长度角度

typedef struct {
    int vexs[MAXVEX];
    lineWeightAndAngel weightAndAngels[MAXVEX][MAXVEX];//连线长度和连线角度
    int numVertexes, numEdges;
} mGraph;

typedef int         vexsPre2DTabel[MAXVEX][MAXVEX];//路径前驱下标列表
typedef int         distancesSum2DTabel[MAXVEX][MAXVEX];//两点间最短路径“和“值列表
typedef float       vexAngels[MAXVEX];


// we can find how to use
//typedef struct {
//    int pointNum;//到达指定地点的id号
//    float angel;//指定点的Angel
//} pointIdAndAngel;//指定点的id&角度
//
//typedef pointIdAndAngel ponitIdAngelsArr[POINTSNUM];//路径下标列表以及对应下标下的角度

#endif /* RouteHeader_h */
