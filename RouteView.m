//
//  RouteView.m
//  TourRobot
//
//  Created by 郭龙 on 16/5/18.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "RouteView.h"
#import "STModel.h"
#import "EditGraphModelAndCell.h"
#import "FloydAlgorithm.h"

#define POSITIONOFFSET 30 //整体地图相对于背景的偏移
#define ROUTEOFFSET    30 //路径相对于整体地图的偏移，，0，0 点不是在地图的最坐下角
#define THRSHHOLDCIRCLE 20

@interface RouteView (){
    UIBezierPath *m_bezierPath ;         // globel line and point path
    CAShapeLayer *m_lineShapLayer ;      // show globel and point path
    CAShapeLayer *m_realTimePointLayer ; // robot dispalay on screen realtime
    CAShapeLayer *m_pathLayer;
    
    CGPoint robotPositionOfScreen ;
    float robotAngelOfScreen ;
    
    mGraph *tmpGraph;
    vexAngels *vexsAngels;
    vexsPre2DTabel *vesxPreTabel;
    
    NSMutableArray *labelsArray;
    NSMutableArray *m_screenPositionsArray;
    
    CAShapeLayer *touchPointLayer;
    
    NSInteger selectedIndex;
    
    STModel *tmpGazerModel;
    NSMutableArray *pathArr ;
    NSArray *graphModelsArray;
    
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
        m_lineShapLayer.hidden = YES;
        [self.layer addSublayer:m_lineShapLayer];
        
        m_realTimePointLayer = [CAShapeLayer new];
        m_realTimePointLayer.fillColor = [[UIColor blueColor] CGColor];
        m_realTimePointLayer.strokeColor = [[UIColor blueColor] CGColor];
        [self.layer addSublayer:m_realTimePointLayer];
        
        m_pathLayer = [[CAShapeLayer alloc] init];
        m_pathLayer.strokeColor = [UIColor blueColor].CGColor;
        [self.layer addSublayer:m_pathLayer];
        
        self.backgroundColor = [UIColor clearColor];// [UIColor lightGrayColor];
        [[ServerSocket sharedSocket] addObserver:self forKeyPath:@"starGazerAckString" options:NSKeyValueObservingOptionNew context:nil];
        
        robotPositionOfScreen = CGPointZero;
        robotAngelOfScreen = 0;
        NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(updateRobotPosition:) userInfo:nil repeats:YES];
        [time fire];
        
        NSTimer *time2 = [NSTimer scheduledTimerWithTimeInterval:0.8 target:self selector:@selector(sendPositonToRobot:) userInfo:nil repeats:YES];
        [time2 fire];
        
        labelsArray = [NSMutableArray new];
        
        //点击出红点
        touchPointLayer = [CAShapeLayer new];
        touchPointLayer.fillColor = [UIColor redColor].CGColor;
        touchPointLayer.strokeColor = [UIColor orangeColor].CGColor;
        [self.layer addSublayer:touchPointLayer];
        CGPoint pt = CGPointMake(100, 100);
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pt radius:10 startAngle:0 endAngle:2*M_PI clockwise:YES];
        touchPointLayer.path = path.CGPath;
        
        tmpGazerModel = nil;
        pathArr = [NSMutableArray new];
        graphModelsArray = [[DataCenter sharedDataCenter] getGraphModlesArr];
        
        return self;
    }
    return self;
}

#pragma mark - actions

- (void)updateRobotPosition :(NSTimer *)time {
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:robotPositionOfScreen radius:10 startAngle:0.0 endAngle:2 * M_PI clockwise:0];
    [path moveToPoint:robotPositionOfScreen];
    int l1 = 25*cosf(robotAngelOfScreen/180*M_PI);
    int l2 = 25*sinf(robotAngelOfScreen/180*M_PI);
    [path addLineToPoint:CGPointMake(robotPositionOfScreen.x + l1, robotPositionOfScreen.y + l2)];
    m_realTimePointLayer.path = path.CGPath;
}

//judge the robot has come to the position
// only used when touch end and search the path, because pathArr will be the nil until then.
- (void)sendPositonToRobot:(NSTimer *)time{
    if (pathArr.count == 0) {
        NSLog(@"hasnot search the path or reach the final position");
        return;
    }
    
    NSString *vexAngs = [pathArr objectAtIndex:0];//get first object
    NSArray *arr = [vexAngs componentsSeparatedByString:@","];
    NSInteger pointIndex = [[arr objectAtIndex:0] integerValue];
    NSInteger angel = [[arr objectAtIndex:1] integerValue];
    EditGraphModel *tmpGraphModel = [graphModelsArray objectAtIndex:pointIndex];
    NSString *xys = tmpGraphModel.ptXYS;
    CGPoint realPt = CGPointFromString(xys);
    
    //send to robot every time.
    [[HitControl sharedControl] sendTouchPointToRobot:realPt];
    
    if ((fabs( tmpGazerModel.modelX - realPt.x) < THRSHHOLDCIRCLE ) && (fabs(tmpGazerModel.modelY - realPt.y) < THRSHHOLDCIRCLE)) {
        NSLog(@"now in cicle next angel");
        if (fabs( angel - tmpGazerModel.modelAngel) < 5) {
            NSLog(@"oooo :position right");
            [pathArr removeObjectAtIndex:0];//remove the fisrt position in arr
        }
    }
    
}

#pragma mark - draw views
/**
 *  @param graph
 *  @param arr
 *  @param angels 角度信息
 */
- (void)drawLineAndPoints :(mGraph *)graph withPointsArray:(NSArray *)positions withTailAngel:(vexAngels *)angels vexsTabel:(vexsPre2DTabel *)table {
    /*****test***/
    [self updateRobotPosition:nil];
    
    //存下来，后面有需要
    tmpGraph = graph;
    vexsAngels = angels;
    vesxPreTabel = table;
    
    m_screenPositionsArray =[NSMutableArray arrayWithArray:[self changeToScreenCood:positions]];
    
    [self updataPath];
}


#pragma mark - delegata

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"starGazerAckString"]) {
        NSString *newString  = [change objectForKey:@"new"];
        tmpGazerModel = [STModel stmodelWithString:newString]; //解析string
        if (tmpGazerModel) {
            robotAngelOfScreen = tmpGazerModel.modelAngel + 90;
            robotPositionOfScreen = [FloydAlgorithm changeCood: CGPointMake(tmpGazerModel.modelX, tmpGazerModel.modelY)];
        }
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (canEdit){
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        NSUInteger index = [m_screenPositionsArray indexOfObjectPassingTest:^BOOL(NSString *obj2, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint obj = CGPointFromString(obj2);
            if ((fabs(obj.x - touchPoint.x) + fabs(obj.y - touchPoint.y)) < 40) {
                return YES;
            }
            return NO;
        }];
        selectedIndex = index;
        if (index != NSNotFound) {
            [m_screenPositionsArray replaceObjectAtIndex:index withObject:NSStringFromCGPoint(touchPoint)];
            [self updataPath];
        }
    } else {
        [super touchesBegan:touches withEvent:event];
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (canEdit){
        UITouch *touch = [touches anyObject];
        CGPoint touchPoint = [touch locationInView:self];
        NSUInteger index = [m_screenPositionsArray indexOfObjectPassingTest:^BOOL(NSString *obj2, NSUInteger idx, BOOL * _Nonnull stop) {
            CGPoint obj = CGPointFromString(obj2);
            if ((fabs(obj.x - touchPoint.x) + fabs(obj.y - touchPoint.y)) < 40) {
                return YES;
            }
            return NO;
        }];
        selectedIndex = index;
        if (index != NSNotFound) {
            [m_screenPositionsArray replaceObjectAtIndex:index withObject:NSStringFromCGPoint(touchPoint)];
            [self updataPath];
        }
    } else
        [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *tou = [touches anyObject];
    if (canEdit) {
        CGPoint touchPoint = [[touches anyObject] locationInView:self];
        if (selectedIndex != NSNotFound) {
            [m_screenPositionsArray replaceObjectAtIndex:selectedIndex withObject:NSStringFromCGPoint(touchPoint)];
            CGPoint real = [FloydAlgorithm changeCoodToRealPosition:touchPoint];
            NSLog(@"touch:%ld toRealPositon:%@",selectedIndex, NSStringFromCGPoint(real));
        }
        [self updataPath];
    }else {
        CGPoint pt = [tou locationInView:self];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:pt radius:10 startAngle:0 endAngle:2*M_PI clockwise:YES];
        touchPointLayer.path = path.CGPath;
        CGPoint realPosition = [FloydAlgorithm changeCoodToRealPosition:pt];
        [[HitControl sharedControl] sendTouchPointToRobot:realPosition];
        
        [self drawRobotPositonByScreenPositionStart:robotPositionOfScreen end:pt];
    }
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
                CGPoint ptI = CGPointFromString([m_screenPositionsArray objectAtIndex:i]);
                CGPoint ptJ = CGPointFromString([m_screenPositionsArray objectAtIndex:j]);
                UIBezierPath *path = [UIBezierPath new];
                [path moveToPoint:ptI];
                [path addLineToPoint:ptJ];
                [m_bezierPath appendPath:path];
                
                UILabel *numL = [[UILabel alloc] initWithFrame:CGRectMake(ptI.x/2+ptJ.x/2, ptI.y/2 + ptJ.y/2, 50, 10)];
                numL.font = [UIFont systemFontOfSize:10];
                CGPoint II = [FloydAlgorithm changeCoodToRealPosition:ptI];
                CGPoint JJ = [FloydAlgorithm changeCoodToRealPosition:ptJ];
                float xx = JJ.x - II.x;
                float yy = JJ.y - II.y;
                float dist = sqrtf(xx * xx + yy * yy);
                numL.text = [NSString stringWithFormat:@"%d,%.0f",(int)dist,angel];
                [self addSubview:numL];
                numL.backgroundColor = [UIColor lightGrayColor];
                
                [labelsArray addObject:numL];
            }
        }
    }
    
    for (int i = 0; i  < m_screenPositionsArray.count; i++ ) {
        CGPoint position = CGPointFromString([m_screenPositionsArray objectAtIndex:i] );
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

#pragma mark - private mathod

- (void) drawRobotPositonByScreenPositionStart:(CGPoint)start end:(CGPoint )end {
    CGPoint startR = [FloydAlgorithm changeCoodToRealPosition:start];
    CGPoint endR = [FloydAlgorithm changeCoodToRealPosition:end];
    int firstIndex = (int)[self findNearestIndexByRealPosition:startR];
    int lastIndex = (int)[self findNearestIndexByRealPosition:endR];
    
    NSString *pathSting = [FloydAlgorithm findShortestPath:tmpGraph from:firstIndex to:lastIndex pointsTabel:vesxPreTabel robotAngels:vexsAngels];
    NSArray *arr = [pathSting componentsSeparatedByString:@"->"];
    
    UIBezierPath *bezier = [UIBezierPath new];
    for (int i = 0; i < arr.count; i++) {
        NSString *indexAndAngel = [arr objectAtIndex:i];
        NSArray *ptArr = [indexAndAngel componentsSeparatedByString:@","];
        int index = (int)[[ptArr objectAtIndex:0] integerValue];
        CGPoint pt = CGPointFromString( [m_screenPositionsArray objectAtIndex:index] );
        
        if (i == 0) {
            [bezier moveToPoint:pt];
        }else{
            [bezier addLineToPoint:pt];
            [bezier moveToPoint:pt];
        }
    }
    m_pathLayer.path = bezier.CGPath;
    NSLog(@"Path__:%@", pathSting);
    [self processingPath:pathSting];

}

//pathString:3,0->0,-90->1,70, 将pathstring切换成数组
- (void)processingPath : (NSString *)pathString {
    if (pathString.length == 0) {
        NSLog(@"pathString length is zero, wrong");
    }
    NSArray *arr = [pathString componentsSeparatedByString:@"->"];
    pathArr = [NSMutableArray arrayWithArray:arr];
    
}


- (NSInteger) findNearestIndexByScreenPosition : (CGPoint) screen_original {
    CGPoint scPt = [FloydAlgorithm changeCoodToRealPosition:screen_original];
    return [self findNearestIndexByScreenPosition:scPt];
}

- (NSInteger) findNearestIndexByRealPosition : (CGPoint) real_original {
    NSArray *realsArr = [[DataCenter sharedDataCenter] getRealPositionsArr];
    float maxDis = INTMAX;
    NSInteger nearestIndex = 0;
    for (int i = 0; i < realsArr.count; i++) {
        CGPoint pt = CGPointFromString( [realsArr objectAtIndex: i] );
        float disX = real_original.x - pt.x;
        float disY = real_original.y - pt.y;
        float dis  = sqrtf(disX * disX + disY * disY);
        if (maxDis > dis) {
            maxDis = dis;
            nearestIndex = i;
        }
    }
    return nearestIndex;
}

- (void)setCanEdit:(BOOL)bol {
    canEdit = bol;
    
    if (canEdit) {
        m_lineShapLayer.hidden = NO;
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                view.hidden = NO;
            }
        }
    }else {
        m_lineShapLayer.hidden = YES;
        for (UIView *view in self.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                view.hidden = YES;
            }
        }
    }
    
}

- (NSArray *)changeToScreenCood:(NSArray *)arr {
    NSMutableArray *mut = [NSMutableArray new];
    for (int i = 0 ; i< arr.count; i++) {
        CGPoint old = CGPointFromString([arr objectAtIndex:i]); // [[m_pointPositionsArray objectAtIndex:i] CGPointValue];
        CGPoint new = [FloydAlgorithm changeCood:old];
        [mut insertObject:NSStringFromCGPoint(new) atIndex:i];
    }
    return mut;
}

- (NSArray *)changeToRealCood:(NSArray *)arr {
    NSMutableArray *mut = [NSMutableArray new];
    for (int i = 0 ; i< arr.count; i++) {
        CGPoint old = CGPointFromString(arr[i]); // [[m_pointPositionsArray objectAtIndex:i] CGPointValue];
        CGPoint new = [FloydAlgorithm changeCoodToRealPosition:old];
        [mut insertObject:NSStringFromCGPoint(new) atIndex:i];
    }
    return mut;
}

- (void)saveRoute {
    [[DataCenter sharedDataCenter] setRealPoisitonsOfArr:[self changeToRealCood:m_screenPositionsArray]];
}

#pragma mark - unuse
//根据角度信息来的**************更新信息 nouser
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

@end
