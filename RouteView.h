//
//  RouteView.h
//  TourRobot
//  Created by 郭龙 on 16/5/18.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteHeader.h"
@interface RouteView : UIView

//dataSource
@property (nonatomic) NSMutableArray *m_pointPositionsArray;

- (void)drawLineAndPoints :(mGraph *)graph withTailAngel:(vexAngels *)angels ;

@end
