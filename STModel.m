//
//  STModel.m
//  HitProject
//
//  Created by 郭龙 on 16/5/11.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "STModel.h"
@implementation STModel
- (instancetype)init{
    self = [super init];
    return self;
}

+ (STModel *)stmodelWithString:(NSString *)string {
    STModel *model = [STModel new];
    
    if ( ![string hasPrefix:@"~^"] || ![string hasSuffix:@"`"]) {
        NSLog(@"err protocol");
        return nil;
    }
    if ([string isEqualToString:@"~*DeadZone"]) {
        NSLog(@"~*DeadZone");
        return nil;
    }
    if ([STModel getCount:string ofsubString:@"|"] == 4) {
        NSArray *strings = [string componentsSeparatedByString:@"|"];
        
        NSString *modelStrins = strings[0];
        NSArray *idsStrings = [modelStrins componentsSeparatedByString:@"^"];
        NSString *iDFirstLetter = [idsStrings[1] substringToIndex:1];
        if ([iDFirstLetter isEqualToString:@"F"]) {
            NSLog(@"map-building Mode");
        }
        if ([iDFirstLetter isEqualToString:@"I"]) {
            //            NSLog(@"Map");
        }
        if ([iDFirstLetter isEqualToString:@"Z"]) {
            NSLog(@"Height Calvulation Mode");
        }
        
        NSString *idString = [idsStrings[1] substringFromIndex:1];
        int modelId = (int) [idString integerValue];
        float modelAngel = [strings[1] floatValue];
        float modelX = [strings[2] floatValue];
        float modelY = [strings[3] floatValue];
        float modelZ = [[strings[4] substringWithRange:NSMakeRange(0, ((NSString *)strings[4]).length -1)] floatValue];
        
        model.moedleId = modelId;
        model.modelAngel = modelAngel;
        model.modelX = modelX;
        model.modelY = modelY;
        model.modelZ = modelZ;
        return model;
    }
    
    if ([STModel getCount:string ofsubString:@"|"] == 3) {
        NSArray *strings = [string componentsSeparatedByString:@"|"];
        
        NSString *angels = strings[0];
        NSArray *angelsString = [angels componentsSeparatedByString:@"^"];
        NSString *iDFirstLetter = [angelsString[1] substringToIndex:1];
        if ([iDFirstLetter isEqualToString:@"F"]) {
            NSLog(@"map-building Mode");
        }
        if ([iDFirstLetter isEqualToString:@"I"]) {
            //            NSLog(@"Map");
        }
        if ([iDFirstLetter isEqualToString:@"Z"]) {
            NSLog(@"Height Calvulation Mode");
        }
        
        NSString *angelString = [angelsString[1] substringFromIndex:1];
        float modelAngel = [angelString floatValue];
        float modelX = [strings[1] floatValue];
        float modelY = [strings[2] floatValue];
        NSInteger modelId = [[strings[3] substringWithRange:NSMakeRange(0, ((NSString *)strings[3]).length -1)] integerValue];
        
        model.moedleId = (int)modelId;
        model.modelAngel = modelAngel;
        model.modelX = modelX;
        model.modelY = modelY;
        model.modelZ = 0.0;
        return model;
    }
    return nil;
}

+ (NSInteger)getCount:(NSString *)string ofsubString:(NSString *)subString {
    if (subString.length != 1) {
        NSLog(@"sub string length is to long");
        return 0;
    }
    int k = 0;
    for (int i = 0; i < string.length; i++) {
        NSString *t = [string substringWithRange:NSMakeRange(i, 1)];
        if ([t isEqualToString:subString]) {
            k++;
        }
    }
    return k;

}

@end
