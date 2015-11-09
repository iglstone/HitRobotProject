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
@property (nonatomic) NSString *status;
@property (nonatomic) AsyncSocket *socket;

@end

@interface ConnectStatesCell : UITableViewCell

@property (nonatomic) UILabel * hostIpLabel;
@property (nonatomic) UILabel * statusLabel;
@property (nonatomic) UILabel * portLabel;

- (void)configModel :(ConnectModel *)model ;

@end

