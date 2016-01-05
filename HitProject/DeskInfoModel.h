//
//  DeskInfoModel.h
//  HitProject
//
//  Created by 郭龙 on 15/12/25.
//  Copyright © 2015年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DeskInfoModel : NSObject <NSCoding>
//NSArray *arr = @[@"桌号",@"信号",@"备注",@"其他"];
@property (nonatomic) NSString *p_deskNum;
@property (nonatomic) NSString *p_sign;
@property (nonatomic) NSString *p_info;
@property (nonatomic) NSString *p_other;
@end
