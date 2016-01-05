//
//  DeskInfoHelper.m
//  HitProject
//
//  Created by 郭龙 on 16/1/4.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "DeskInfoHelper.h"
#import "CommonsFunc.h"
#define DESKNAMESARRAY  @"DESKNAMEARRAY_KEY"//namearray key
#define DESKNAMESDIC    @"DESKNAMEDIC_KEY"  //namedic key
#define DESKMODELSARRAY @"DESKMODELS_KEY"   //modelsarray key
#define DESKMODELSDIC   @"DESKMODELSDIC_KEY"//MODELSdic key

@implementation DeskInfoHelper

#pragma mark -
- (void)defaultArray {
    if ([CommonsFunc isFirstLaunch]) {
        NSMutableArray <DeskInfoModel *> *modlesArr = [NSMutableArray new];
        for (int i = 0; i < 100; i++) {
            DeskInfoModel *model = [DeskInfoModel new];
            model.p_deskNum = [NSString stringWithFormat:@"%d 桌",(i+1)];
            [modlesArr addObject:model];
        }
        [self setDeskModelsToUserdefault:[NSArray arrayWithArray:modlesArr]];
    }
}

- (void) changeDeskModelByTag :(int)deskNum name:(NSString *)name{
    NSArray <DeskInfoModel *> *arr = [self getDeskModelsFromUserdefault];
    if (deskNum >= arr.count) {
        NSLog(@"beyound the array count");
        return;
    }
    DeskInfoModel *model = arr[deskNum-1];
    model.p_deskNum = name;
    [self setDeskModelsToUserdefault:arr];
}

- (NSArray <NSString *> *)getDeskNamesFromUserdefaultByTag:(int) deskNum {
    NSArray <DeskInfoModel *> *arr = [self getDeskModelsFromUserdefault];
    NSMutableArray <NSString *> *namesArr = [NSMutableArray new];
    for (int i = 0; i < deskNum; i++) {
        DeskInfoModel *model = arr[i];
        [namesArr addObject:model.p_deskNum];
    }
    return [NSArray arrayWithArray:namesArr];
}

#pragma mark - array interface
- (void)setDeskModelsToUserdefault:(NSArray<DeskInfoModel *> *)deskModelsArray {
    if (!deskModelsArray) {
        return;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deskModelsArray];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:DESKMODELSDIC];
}

- (NSArray <DeskInfoModel *>*)getDeskModelsFromUserdefault {
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:DESKMODELSDIC];
    NSArray <DeskInfoModel *> *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return arr;
}


@end

