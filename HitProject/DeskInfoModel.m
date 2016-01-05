//
//  DeskInfoModel.m
//  HitProject
//
//  Created by 郭龙 on 15/12/25.
//  Copyright © 2015年 郭龙. All rights reserved.
//

#import "DeskInfoModel.h"

@implementation DeskInfoModel
@synthesize p_deskNum;
@synthesize p_info;
@synthesize p_other;
@synthesize p_sign;

- (instancetype)init {
    self = [super init];
    if (self) {
        return self;
    }
    return nil;
}

//@interface DeskInfoModel : NSObject <NSCoding>
/**
 *  序列话归档  nskeyachieve -> nsdata
 *  @param aCoder
 */
//NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deskModelsArray];
//[[NSUserDefaults standardUserDefaults] setObject:data forKey:DESKMODELSDIC];
- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:p_deskNum  forKey:@"deskNum"];
    [aCoder encodeObject:p_info     forKey:@"info"];
    [aCoder encodeObject:p_other    forKey:@"other"];
    [aCoder encodeObject:p_sign     forKey:@"sign"];
}

/**
 *  解档  nskeyedunarchieve <- nsdata
 *  @param aDecoder
 *  @return
 */
//NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:DESKMODELSDIC];
//NSArray <DeskInfoModel *> *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    self.p_deskNum = [aDecoder decodeObjectForKey:@"deskNum"];
    self.p_info    = [aDecoder decodeObjectForKey:@"info"];
    self.p_other   = [aDecoder decodeObjectForKey:@"other"];
    self.p_sign    = [aDecoder decodeObjectForKey:@"sign"];
    return self;
}

@end
