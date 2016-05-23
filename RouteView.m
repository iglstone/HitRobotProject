//
//  RouteView.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/18.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "RouteView.h"
#import "STModel.h"
#import "FloydAlgorithm.h"

#define POSITIONOFFSET 30 //整体地图相对于背景的偏移
#define ROUTEOFFSET    30 //路径相对于整体地图的偏移，，0，0 点不是在地图的最坐下角

@interface RouteView (){
    UIBezierPath *m_bezierPath ; // globel line and point path
    CAShapeLayer *m_lineShapLayer ; //show globel and point path
    CAShapeLayer *m_realTimePointLayer ; // robot dispalay on screen realtime
    CGPoint robotPositionOfScreen ;
    float robotAngelOfScreen ;
    
    mGraph *tmpGraph;
    vexAngels *vexsAngels;
    NSMutableArray *labelsArray;
    NSMutableArray *m_pointPositionsArray;
}
@end

@implementation RouteView
@synthesize canEdit;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        m_bezierPath = [UIBezierPath new];
        m_lineShapLayer = [[CAShapeLayer alloc] init];
        m_lineShapLayer.strokeColor = [UIColor redColor].CGColor;
        m_realTimePointLayer = [CAShapeLayer new];
        m_realTimePointLayer.fillColor = [[UIColor blueColor] CGColor];
        m_realTimePointLayer.strokeColor = [[UIColor blueColor] CGColor];
        [self.layer addSublayer:m_lineShapLayer];
        [self.layer addSublayer:m_realTimePointLayer];
        self.backgroundColor = [CommonsFunc colorOfLight];// [UIColor lightGrayColor];
        self.alpha = 0.4;
        [[ServerSocket sharedSocket] addObserver:self forKeyPath:@"starGazerAckString" options:NSKeyValueObservingOptionNew context:nil];
        robotPositionOfScreen = CGPointZero;
        robotAngelOfScreen = 0;
        NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateRobotPosition:) userInfo:nil repeats:YES];
        [time fire];
        self.canEdit = NO;
        labelsArray = [NSMutableArray new];
        return self;
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"starGazerAckString"]) {
        NSString *newString  = [change objectForKey:@"new"];
        STModel *model = [STModel stmodelWithString:newString]; //解析string
        if (model) {
            robotAngelOfScreen = model.modelAngel + 90;
            robotPositionOfScreen = [FloydAlgorithm changeCood: CGPointMake(model.modelX, model.modelY)];
        }
    }
}

- (void)updateRobotPosition :(NSTimer *)time {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:robotPositionOfScreen radius:10 startAngle:0.0 endAngle:2 * M_PI clockwise:0];
    [path moveToPoint:robotPositionOfScreen];
    int l1 = 25*cosf(robotAngelOfScreen/180*M_PI);
    int l2 = 25*sinf(robotAngelOfScreen/180*M_PI);
    [path addLineToPoint:CGPointMake(robotPositionOfScreen.x + l1, robotPositionOfScreen.y + l2)];
    m_realTimePointLayer.path = path.CGPath;
}

#pragma mark - draw views
/**
 *  @param graph
 *  @param arr
 *  @param angels 角度信息
 */
- (void)drawLineAndPoints :(mGraph *)graph withPointsArray:(NSArray *)positions withTailAngel:(vexAngels *)angels {
    /*****test***/
    m_pointPositionsArray = [NSMutableArray arrayWithArray:positions];
    [self updateRobotPosition:nil];
    tmpGraph = graph;
    vexsAngels = angels;
    
    canEdit =  YES;//test
    
    // change to screen points
    for (int i = 0 ; i<m_pointPositionsArray.count; i++) {
        CGPoint old = [[m_pointPositionsArray objectAtIndex:i] CGPointValue];
        CGPoint new = [FloydAlgorithm changeCood:old];
        [m_pointPositionsArray replaceObjectAtIndex:i withObject:[NSValue valueWithCGPoint:new]];
    }
    
    [self updataPath];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!canEdit) [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    NSUInteger index = [m_pointPositionsArray indexOfObjectPassingTest:^BOOL(NSValue *obj2, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint obj = [obj2 CGPointValue];
        if ((fabs(obj.x - touchPoint.x) + fabs(obj.y - touchPoint.y)) < 40) {
            return YES;
        }
        return NO;
    }];
    if (index != NSNotFound) {
        [m_pointPositionsArray replaceObjectAtIndex:index withObject:[NSValue valueWithCGPoint:touchPoint]];
        [self updataPath];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!canEdit) [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    NSUInteger index = [m_pointPositionsArray indexOfObjectPassingTest:^BOOL(NSValue *obj2, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint obj = [obj2 CGPointValue];
        if ((fabs(obj.x - touchPoint.x) + fabs(obj.y - touchPoint.y)) < 40) {
            return YES;
        }
        return NO;
    }];
    if (index != NSNotFound) {
        [m_pointPositionsArray replaceObjectAtIndex:index withObject:[NSValue valueWithCGPoint:touchPoint]];
        [self updataPath];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!canEdit) [super touchesBegan:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!canEdit) [super touchesBegan:touches withEvent:event];
}

- (void) updataPath {
    [m_bezierPath removeAllPoints];
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[UILabel class]]) {
            [view removeFromSuperview];
        }
    }
    
    int i,j;
    for (i = 0; i < tmpGraph->numVertexes; i++) {
        for (j = i+1; j < tmpGraph->numVertexes; j++) {
            int weight = tmpGraph->weightAndAngels[i][j].weight;
            float angel = tmpGraph->weightAndAngels[i][j].angel;
            if (weight != INTMAX && weight != 0) {
                CGPoint ptI = [[m_pointPositionsArray objectAtIndex:i] CGPointValue];
                CGPoint ptJ = [[m_pointPositionsArray objectAtIndex:j] CGPointValue];
                UIBezierPath *path = [UIBezierPath new];
                [path moveToPoint:ptI];
                [path addLineToPoint:ptJ];
                [m_bezierPath appendPath:path];
                
                UILabel *numL = [[UILabel alloc] initWithFrame:CGRectMake(ptI.x/2+ptJ.x/2, ptI.y/2 + ptJ.y/2, 50, 10)];
                numL.font = [UIFont systemFontOfSize:10];
                numL.text = [NSString stringWithFormat:@"%d,%.0f",weight,angel];
                [self addSubview:numL];
                numL.backgroundColor = [UIColor lightGrayColor];
                [labelsArray addObject:numL];
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
        [labelsArray addObject:numL];
        
        float angel =((*vexsAngels)[i] / 180) * M_PI;
        
        UIBezierPath *path = [UIBezierPath new];//画tail箭头
        path.lineWidth = 3.0;
        [path moveToPoint:position];
        [path addLineToPoint:CGPointMake(position.x + 20*cosf(angel), position.y + 20*sinf(angel))];
        [m_bezierPath appendPath:path];
    }
    
    m_lineShapLayer.path = m_bezierPath.CGPath;
}

- (void)setCanEdit:(BOOL)bol {
    canEdit = bol;
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
