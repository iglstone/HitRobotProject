//
//  RobotStateCell.h
//  HitProject
//
//  Created by 郭龙 on 16/4/19.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ConnectStatesCell.h"

//ConnectModel替代
//@interface RobotStateModel : NSObject
//@property (nonatomic) NSString *robotName;//小蓝
//@property (nonatomic) NSString *robotPower;//50%
//@property (nonatomic) NSString *robotSpeed;//0.3
//@property (nonatomic) NSString *robotVoice;//50
//@end

@interface RobotStateCell : UITableViewCell

@property (nonatomic) UILabel *labelName;
@property (nonatomic) UILabel *labelPower;
@property (nonatomic) UILabel *labelSpeed;
@property (nonatomic) UILabel *labelVoice;

/**
 *  config model
 *  @param model: model args
 */
- (void )configRobotState :(ConnectModel*)model;
@end
