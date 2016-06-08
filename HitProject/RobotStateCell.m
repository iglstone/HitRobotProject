//
//  RobotStateCell.m
//  HitProject
//
//  Created by 郭龙 on 16/4/19.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "RobotStateCell.h"

@implementation RobotStateCell

- (void )configRobotState :(ConnectModel*)model {
    if (!model) {
        NSLog(@"RobotStateModel is nil");
        return;
    }
    if (self) {
        _labelName.text = [NSString stringWithFormat:@"机器人%@:", model.robotName == nil ? @"1" : model.robotName];
        _labelPower.text = [NSString stringWithFormat:@"剩余电量： %@", model.robotPower == nil ? @"50%" : model.robotPower];
        _labelSpeed.text = [NSString stringWithFormat:@"当前速度： %@ m/s", model.robotSpeed == nil ? @"0.2" : model.robotSpeed];
        _labelVoice.text = [NSString stringWithFormat:@"当前音量： %@", model.robotVoice == nil ? @"50" : model.robotVoice];
    }else {
        NSLog(@"..RobotStateCell is nil");
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        //name of robot
        _labelName = [[UILabel alloc] initWithFrame:CGRectMake(0,0,280,20)];
        _labelName.backgroundColor = [UIColor clearColor];
        _labelName.text = @"机器人小蓝：";
        if (![CommonsFunc isDeviceIpad]) {
            _labelName.font = [UIFont systemFontOfSize:15];
        }
        [self addSubview:_labelName];
        [_labelName mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
            make.left.equalTo(self.contentView);
        }];
        
        //power
        _labelPower = [UILabel new];
        _labelPower.text = @"剩余电量： 50%";
        _labelPower.textColor = [UIColor darkGrayColor];
        if (![CommonsFunc isDeviceIpad]) {
            _labelPower.font = [UIFont systemFontOfSize:14];
        }
        [self addSubview:_labelPower];
        [_labelPower mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_labelName).offset(20);
            make.top.equalTo(_labelName.mas_bottom).offset(20);//后期电量不显示
            make.right.equalTo(self);
        }];
        
        //speed
        _labelSpeed = [UILabel new];
        _labelSpeed.text = @"当前速度： 0.3 m/s";
        if (![CommonsFunc isDeviceIpad]) {
            _labelSpeed.font = [UIFont systemFontOfSize:14];
        }
        _labelSpeed.textColor = [UIColor darkGrayColor];
        [self addSubview:_labelSpeed];
        [_labelSpeed mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_labelPower);
            make.top.equalTo(_labelPower.mas_bottom).offset(20);
        }];
        
        //voice
        _labelVoice = [UILabel new];
        _labelVoice.text = @"当前音量： 50";
        if (![CommonsFunc isDeviceIpad]) {
            _labelVoice.font = [UIFont systemFontOfSize:14];
        }
        _labelVoice.textColor = [UIColor darkGrayColor];
        [self addSubview:_labelVoice];
        [_labelVoice mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_labelSpeed);
            make.top.equalTo(_labelSpeed.mas_bottom).offset(20);
        }];
        
    }
    return self;
}

@end
