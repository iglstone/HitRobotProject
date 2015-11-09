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

- (void)configModel :(ConnectModel *)model {
    hostIpLabel.text = model.hostIp;
    portLabel.text = [NSString stringWithFormat:@"%ld",(long)model.port];
    statusLabel.text = model.status;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        hostIpLabel= [[UILabel alloc]init];
        hostIpLabel.text = @"192.168.100.100";
        hostIpLabel.backgroundColor = [UIColor redColor];
        [CommonsFunc com_custumLabel:hostIpLabel fontSize:12 color:[UIColor darkGrayColor] numberOfLines:1 alignment:NSTextAlignmentLeft];
        [self.contentView addSubview:hostIpLabel];
        [hostIpLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10);
            make.centerY.equalTo(self.contentView);
            make.width.mas_equalTo(@100);
        }];
        
        statusLabel = [UILabel new];
        statusLabel.text = @"disconnected";
        [self.contentView addSubview:statusLabel];
        [CommonsFunc com_custumLabel:statusLabel fontSize:12 color:[UIColor darkGrayColor] numberOfLines:1 alignment:NSTextAlignmentCenter];
        [statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(hostIpLabel);
            make.right.equalTo(self.contentView).offset(-20);
        }];
        
        portLabel = [UILabel new];
        portLabel.text = @"1234";
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

@end