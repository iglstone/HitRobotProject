//
//  EditGraphModelAndCell.m
//  HitProject
//
//  Created by 郭龙 on 16/5/24.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "EditGraphModelAndCell.h"

@implementation EditGraphModel
//NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deskModelsArray];
//[[NSUserDefaults standardUserDefaults] setObject:data forKey:DESKMODELSDIC];
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:@(self.ptIndexI)       forKey:@"ptIndexI"];
    [aCoder encodeObject:self.ptXYS             forKey:@"ptXYS"];
    [aCoder encodeObject:self.ptAngelS          forKey:@"ptAngelS"];
    [aCoder encodeObject:self.ptJointsS         forKey:@"ptJointsS"];
    [aCoder encodeObject:self.ptJointAngelsS    forKey:@"ptJointAngelsS"];
}

/**
 *  解档  nskeyedunarchieve <- nsdata
 *  @param aDecoder
 *  @return
 */
//NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:DESKMODELSDIC];
//NSArray <DeskInfoModel *> *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self.ptIndexI       = [[aDecoder decodeObjectForKey:@"ptIndexI"] integerValue];
    self.ptXYS          = [aDecoder decodeObjectForKey:@"ptXYS"];
    self.ptAngelS       = [aDecoder decodeObjectForKey:@"ptAngelS"];
    self.ptJointsS      = [aDecoder decodeObjectForKey:@"ptJointsS"];
    self.ptJointAngelsS = [aDecoder decodeObjectForKey:@"ptJointAngelsS"];
    return self;
}


@end

@implementation EditGraphCell
#define SUBWIDTH 150
#define SUBHEIGHT 45

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _pointIndexL = [UILabel new];
        _pointIndexL.text = @"0";
        _pointIndexL.textAlignment = NSTextAlignmentCenter;
        _pointIndexL.backgroundColor = [UIColor orangeColor];
        [self.contentView addSubview:_pointIndexL];
        
        _pointXYT = [UITextField new];
        _pointXYT.placeholder = @"input x,y";
        [self.contentView addSubview:_pointXYT];
        
        _pointAngelT = [UITextField new];
        _pointAngelT.placeholder = @"input angel";
        [self.contentView addSubview:_pointAngelT];
        
        _pointJointsT = [UITextField new];
        _pointJointsT.placeholder = @"input Joints";
        [self.contentView addSubview:_pointJointsT];
        
        _pointJointAngelsT = [UITextField new];
        _pointJointAngelsT.placeholder = @"input Joints angels";
        [self.contentView addSubview:_pointJointAngelsT];
        
        [_pointIndexL mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView);
            make.size.mas_equalTo(CGSizeMake(SUBWIDTH , SUBHEIGHT));
        }];
        
        [_pointXYT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_pointIndexL.mas_right).offset(20);
            make.size.mas_equalTo(CGSizeMake(SUBWIDTH , SUBHEIGHT));
        }];
        
        [_pointAngelT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_pointXYT.mas_right).offset(20);
            make.size.mas_equalTo(CGSizeMake(SUBWIDTH , SUBHEIGHT));
        }];
        
        [_pointJointsT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_pointAngelT.mas_right).offset(20);
            make.size.mas_equalTo(CGSizeMake(SUBWIDTH , SUBHEIGHT));
        }];
        [_pointJointAngelsT mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_pointJointsT.mas_right).offset(20);
            make.size.mas_equalTo(CGSizeMake(SUBWIDTH , SUBHEIGHT));
        }];
        
        return self;
    }
    return nil;
}


- (void) initCellWithModel :(EditGraphModel *)model {
    self.pointIndexL.text = [NSString stringWithFormat:@"%ld", model.ptIndexI];
    self.pointAngelT.text = model.ptAngelS;
    CGPoint pt = CGPointFromString(model.ptXYS);
    self.pointXYT.text = [NSString stringWithFormat:@"%.0f,%.0f",pt.x, pt.y];
    self.pointJointsT.text = model.ptJointsS;
    self.pointJointAngelsT.text = model.ptJointAngelsS;
}

@end
