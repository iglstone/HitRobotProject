//
//  RouteView.h
//  TourRobot
//  Created by 郭龙 on 16/5/18.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteHeader.h"
#import "DataCenter.h"
@interface RouteView : UIView

@property (nonatomic) BOOL canEdit;

- (void)drawLineAndPoints :(mGraph *)graph withPointsArray:(NSArray *)positions withTailAngel:(vexAngels *)angels vexsTabel:(vexsPre2DTabel *)table ;
//- (void) drawLineAndPoints :(mGraph *)graph withPointsArray:(NSArray *)positions withTailAngel:(vexAngels *)angels ;
- (void) setCanEdit:(BOOL) bol ;//default NO
- (void) saveRoute;
@end
