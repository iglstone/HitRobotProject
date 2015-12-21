//
//  meViewTableCellModel.m
//  MaiYou
//
//  Created by iOS on 15/5/23.
//  Copyright (c) 2015年 iOS. All rights reserved.
//

#import "ConnectStatesCell.h"

@implementation ConnectModel
@synthesize hostIp;
@synthesize port;
@synthesize status;
@synthesize socket;
@synthesize isCheck;
@synthesize robotName;

- (instancetype)init {
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}
@end

@interface ConnectStatesCell(){
    
}
@end

@implementation ConnectStatesCell
@synthesize hostIpLabel;
@synthesize statusLabel;
@synthesize portLabel;
@synthesize checkImg;
@synthesize isChecked;

- (void)configModel :(ConnectModel *)model {
    hostIpLabel.text = model.robotName;
    portLabel.text = [NSString stringWithFormat:@"%ld",(long)model.port];
    statusLabel.text = model.status;
    [self setIsChecked:model.isCheck];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        isChecked = NO;
        
        checkImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkbox1_unchecked.png"]];
        [self.contentView addSubview:checkImg];
        [checkImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.contentView);
            make.left.equalTo(self.contentView);
        }];
        
        hostIpLabel= [[UILabel alloc]init];
        hostIpLabel.text = @"192.168.100.100";
        [CommonsFunc com_custumLabel:hostIpLabel fontSize:12 color:[UIColor darkGrayColor] numberOfLines:1 alignment:NSTextAlignmentLeft];
        [self.contentView addSubview:hostIpLabel];
        [hostIpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(checkImg.mas_right).offset(5);
            make.centerY.equalTo(checkImg);
            make.width.mas_equalTo(@100);
        }];
        
        statusLabel = [UILabel new];
        statusLabel.text = @"未连接";
        [self.contentView addSubview:statusLabel];
        [CommonsFunc com_custumLabel:statusLabel fontSize:12 color:[UIColor darkGrayColor] numberOfLines:1 alignment:NSTextAlignmentCenter];
        [statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(hostIpLabel);
            make.right.equalTo(self.contentView).offset(-20);
        }];
        
        portLabel = [UILabel new];
        NSInteger listen = LISTEN_PORT;
        portLabel.text = [NSString stringWithFormat:@"%ld",(long)listen];
        [self.contentView addSubview:portLabel];
        [CommonsFunc com_custumLabel:portLabel fontSize:12 color:[UIColor darkGrayColor] numberOfLines:1 alignment:NSTextAlignmentCenter];
        [portLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(statusLabel);
            make.centerX.equalTo (self.contentView);
        }];
        
        self.backgroundColor= [UIColor lightGrayColor];
    }
    
    return self;
}

- (void)setIsChecked:(BOOL)check{
    if (check == YES) {
        isChecked = YES;
        [checkImg setImage:[UIImage imageNamed:@"checkbox1_checked.png"]];
    }else {
        isChecked = NO;
        [checkImg setImage:[UIImage imageNamed:@"checkbox1_unchecked.png"]];
    }
}

@end