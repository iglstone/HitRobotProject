//
//  EditGraphModelAndCell.h
//  HitProject
//
//  Created by 郭龙 on 16/5/24.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EditGraphModel : NSObject

@property (nonatomic) NSInteger ptIndexI;
@property (nonatomic) NSString *ptXYS;
@property (nonatomic) NSString *ptAngelS;
@property (nonatomic) NSString *ptJointsS;
@property (nonatomic) NSString *ptJointAngelsS;

@end

@interface EditGraphCell : UITableViewCell
@property (nonatomic) UILabel *pointIndexL;
@property (nonatomic) UITextField *pointXYT;            // seprate by ‘,’
@property (nonatomic) UITextField *pointAngelT;
@property (nonatomic) UITextField *pointJointsT;        //must bigger, seprate by ','
@property (nonatomic) UITextField *pointJointAngelsT;   // seprate by ‘,’

- (void) initCellWithModel :(EditGraphModel *)model ;

@end
