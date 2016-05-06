//
//  meViewTableCellModel.h
//  MaiYou
//
//  Created by iOS on 15/5/23.
//  Copyright (c) 2015年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface ConnectModel : NSObject

@property (nonatomic) NSInteger port;
@property (nonatomic) NSString *hostIp;
@property (nonatomic) NSString *robotName;
@property (nonatomic) NSString *status;
@property (nonatomic) AsyncSocket *socket;
@property (nonatomic) BOOL isCheck;

@property (nonatomic) NSString *robotPower;//50%
@property (nonatomic) NSString *robotSpeed;//0.3
@property (nonatomic) NSString *robotVoice;//50

@property (nonatomic) NSString *robotTemPower;//27.2v
@property (nonatomic) NSInteger times;//累加次数
@property (nonatomic) NSMutableArray *multPowerArray;//电量数组

@end

@interface ConnectStatesCell : UITableViewCell

@property (nonatomic) UILabel * hostIpLabel;
@property (nonatomic) UILabel * statusLabel;
@property (nonatomic) UILabel * portLabel;
@property (nonatomic) UIImageView *checkImg;
@property (nonatomic) BOOL isChecked;

- (void)configModel :(ConnectModel *)model ;

@end

