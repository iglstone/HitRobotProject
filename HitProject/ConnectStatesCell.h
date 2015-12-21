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

@end

@interface ConnectStatesCell : UITableViewCell

@property (nonatomic) UILabel * hostIpLabel;
@property (nonatomic) UILabel * statusLabel;
@property (nonatomic) UILabel * portLabel;
@property (nonatomic) UIImageView *checkImg;
@property (nonatomic) BOOL isChecked;

- (void)configModel :(ConnectModel *)model ;

@end

