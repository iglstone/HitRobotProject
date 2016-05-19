//
//  RouteView.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/18.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "RouteView.h"

#define POSITIONOFFSET 30

@interface RouteView (){
    UIBezierPath *m_bezierPath;
    CAShapeLayer *m_lineShapLayer;
}

@end

@implementation RouteView
@synthesize m_pointPositionsArray;

- (instancetype)init {
    self = [super init];
    if (self) {
        m_bezierPath = [UIBezierPath new];
        m_lineShapLayer = [[CAShapeLayer alloc] init];
        m_lineShapLayer.strokeColor = [UIColor blueColor].CGColor;
        [self.layer addSublayer:m_lineShapLayer];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        m_bezierPath = [UIBezierPath new];
        m_lineShapLayer = [[CAShapeLayer alloc] init];
        m_lineShapLayer.strokeColor = [UIColor redColor].CGColor;
        [self.layer addSublayer:m_lineShapLayer];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (CGPoint)changeCood:(CGPoint) pt {
    int scH = [[UIScreen mainScreen] bounds].size.height;
    int scW = [[UIScreen mainScreen] bounds].size.width;
    float scaleX = (float)  (scW - 2*POSITIONOFFSET) / MAPMAXWIDTH ;
    float scaleY = (float)  (scH - 2*POSITIONOFFSET) / MAPMAXHEIGHT ;
    
    int newPty = scH - 2*POSITIONOFFSET - pt.y * scaleY ;
    
    CGPoint new = CGPointMake(POSITIONOFFSET + pt.x * scaleX, newPty *scaleY - POSITIONOFFSET*2 );
    return new;
}



#pragma mark - draw views
/**
 *  @param graph
 *  @param arr
 *  @param angels 角度信息
 */
- (void)drawLineAndPoints :(mGraph *)graph withTailAngel:(vexAngels *)angels {
    for (int i = 0 ; i<m_pointPositionsArray.count; i++) {
        CGPoint old = [[m_pointPositionsArray objectAtIndex:i] CGPointValue];
        CGPoint new = [self changeCood:old];
        [m_pointPositionsArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:new]];
    }
    
    int i,j;
    for (i = 0; i < graph->numVertexes; i++) {
        for (j = i+1; j < graph->numVertexes; j++) {
            int weight = graph->weightAndAngels[i][j].weight;
            float angel = graph->weightAndAngels[i][j].angel;
            if (weight != INTMAX && weight != 0) {
                CGPoint ptI = [[m_pointPositionsArray objectAtIndex:i] CGPointValue];
                CGPoint ptJ = [[m_pointPositionsArray objectAtIndex:j] CGPointValue];
                UIBezierPath *path = [UIBezierPath new];
                [path moveToPoint:ptI];
                [path addLineToPoint:ptJ];
                [m_bezierPath appendPath:path];
                
                UILabel *numL = [[UILabel alloc] initWithFrame:CGRectMake(ptI.x/2+ptJ.x/2, ptI.y/2 + ptJ.y/2, 30, 10)];
                numL.font = [UIFont systemFontOfSize:10];
                numL.text = [NSString stringWithFormat:@"%d,%.0f",weight,angel];
                [self addSubview:numL];
                numL.backgroundColor = [UIColor blueColor];
            }
        }
    }
    
    for (int i = 0; i  < m_pointPositionsArray.count; i++ ) {
        CGPoint position = [[m_pointPositionsArray objectAtIndex:i] CGPointValue];
        UIBezierPath *pointPath = [UIBezierPath bezierPathWithArcCenter:position radius:POINTRADUS startAngle:0 endAngle:2*M_PI clockwise:0];
        [m_bezierPath appendPath:pointPath];
        
        UILabel *numL = [[UILabel alloc] initWithFrame:CGRectMake(position.x+POINTRADUS/2, position.y+POINTRADUS/2, 13, 10)];
        numL.font = [UIFont systemFontOfSize:10];
        numL.text = [NSString stringWithFormat:@"%d",i];
        [self addSubview:numL];
        numL.backgroundColor = [UIColor orangeColor];
        
        float angel =((*angels)[i] / 180) * M_PI;
        
        UIBezierPath *path = [UIBezierPath new];//画tail箭头
        path.lineWidth = 3.0;
        [path moveToPoint:position];
        [path addLineToPoint:CGPointMake(position.x + 20*cosf(angel), position.y + 20*sinf(angel))];
        [m_bezierPath appendPath:path];
    }
    
    m_lineShapLayer.path = m_bezierPath.CGPath;
}

/*
//根据角度信息来的**************更新信息
- (void)initDrawDataSource :(mGraph *)graph withRealPoints:(NSMutableArray *) m_pointPositionsArray {
    int i,j;
    CGPoint positionZero = CGPointMake(50, 50);

    [m_pointPositionsArray replaceObjectAtIndex:0 withObject:[NSValue valueWithCGPoint:positionZero]];
    
    for (i = 0; i < graph->numVertexes; i++) {
        for (j = i+1; j < graph->numVertexes; j++) {
            int weight = graph->weightAndAngels[i][j].weight;
            if (weight != INTMAX && weight != 0) {
                weight = weight * 100;//测试用
                //确定J的点坐标
                float angel = graph->weightAndAngels[i][j].angel;
                angel = (angel/360)*M_PI*2;
                
                CGPoint positionI = [[m_pointPositionsArray objectAtIndex:i] CGPointValue];
                CGPoint positionJ = CGPointMake(positionI.x + weight*cosf(angel), positionI.y + weight*sinf(angel)); // 这里可以考虑平均值一下
                NSValue *oldJ ;
                if (j >= m_pointPositionsArray.count) {
                    
                }else
                    oldJ = [m_pointPositionsArray objectAtIndex:j];
                
                if (((CGPoint )[oldJ CGPointValue]).x != 0 && ((CGPoint )[oldJ CGPointValue]).y != 0) {
                    CGPoint oldJPosition = [oldJ CGPointValue];
                    CGPoint newJPosition = CGPointMake(positionJ.x/2 + oldJPosition.x/2, positionJ.y/2 + oldJPosition.y/2);
                    [m_pointPositionsArray replaceObjectAtIndex:j withObject:[NSValue valueWithCGPoint:newJPosition]];
                }else{
                    //                    [m_pointPositionsArray insertObject:[NSValue valueWithCGPoint:positionJ] atIndex:j];//如果没有怎么办
                    [m_pointPositionsArray replaceObjectAtIndex:j withObject:[NSValue valueWithCGPoint:positionJ]];
                }
            }
        }
    }
}
*/

@end
