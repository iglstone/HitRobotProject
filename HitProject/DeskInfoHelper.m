//
//  DeskInfoHelper.m
//  HitProject
//
//  Created by 郭龙 on 16/1/4.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "DeskInfoHelper.h"
#import "CommonsFunc.h"
#define DESKMODELSDIC     @"DESKMODELSDIC_KEY"    //MODELSdic key
#define DESKMODELSSONGDIC @"DESKMODELSSONGDIC_KEY"//MODELSdic key

@implementation DeskInfoHelper

#pragma mark -
- (void) default {
    if ([CommonsFunc isFirstLaunch]) {
        [self defaultDeskArray];
        [self defaultSongsArray];
    }
}

- (void) defaultDeskArray {
    NSMutableArray <DeskInfoModel *> *modlesArr = [NSMutableArray new];
    for (int i = 0; i < 60; i++) {
        DeskInfoModel *model = [DeskInfoModel new];
        model.p_deskNum = [NSString stringWithFormat:@"%d桌",(i+1)];
        [modlesArr addObject:model];
    }
    [self setDeskModelsToUserdefault:[NSArray arrayWithArray:modlesArr] isSong:NO];
}

- (void)defaultSongsArray {
    NSArray *musics = @[@"铃儿响叮当",
                        @"生日歌",
                        @"熊出没",
                        @"恭喜发财",
                        @"My Soul",
                        @"The Truth That U Leave",
                        @"Not going anyway",
                        @"Annie's Wonderland",
                        @"Kiss The Rain",
                        @"卡农",
                        @"红豆",
                        @"滴答",
                        @"飘雪",
                        @"Angel",
                        @"Whatever will be",
                        @"The Show",
                        @"Black Black Heart",
                        @"Only Love",
                        @"Right Now Right Here",
                        @"See You Again"
                        ];
    NSMutableArray <DeskInfoModel *> *modlesArr = [NSMutableArray new];
    for (int i = 0; i < 40; i++) {
        DeskInfoModel *model = [DeskInfoModel new];
        if (i < musics.count) {
            model.p_deskNum = musics[i];//[NSString stringWithFormat:@"%d桌",(i+1)];
        }else
            model.p_deskNum = [NSString stringWithFormat:@"歌曲%d",(i+1)];
        [modlesArr addObject:model];
    }
    [self setDeskModelsToUserdefault:[NSArray arrayWithArray:modlesArr] isSong:YES];
}

- (void) changeDeskModelByTag :(int)deskNum name:(NSString *)name isSong:(BOOL)issong{
    NSArray <DeskInfoModel *> *arr = [self getDeskModelsFromUserdefault :issong];
    if (deskNum > arr.count) {
        NSLog(@"beyound the array count");
        return;
    }
    DeskInfoModel *model = arr[deskNum-1];
    if (issong) {
        model.p_deskNum = name;
    }else
        model.p_deskNum = [name hasSuffix:@"桌"] ? name : [NSString stringWithFormat:@"%@桌",name];
    [self setDeskModelsToUserdefault:arr isSong:issong];
}

- (NSArray <NSString *> *)getDeskNamesFromUserdefaultByTag:(int) deskNum isSong:(BOOL)issong{
    NSArray <DeskInfoModel *> *arr = [self getDeskModelsFromUserdefault :issong];
    NSMutableArray <NSString *> *namesArr = [NSMutableArray new];
    for (int i = 0; i < deskNum; i++) {
        DeskInfoModel *model = arr[i];
        [namesArr addObject:model.p_deskNum];
    }
    return [NSArray arrayWithArray:namesArr];
}

#pragma mark - array interface
- (void)setDeskModelsToUserdefault:(NSArray<DeskInfoModel *> *)deskModelsArray isSong:(BOOL)isSong{
    if (!deskModelsArray) {
        return;
    }
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:deskModelsArray];
    if (isSong) {
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:DESKMODELSSONGDIC];
    }else
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:DESKMODELSDIC];
}

- (NSArray <DeskInfoModel *>*)getDeskModelsFromUserdefault:(BOOL)isSong{
    NSData *data = [NSData new];
    if(isSong) {
        data = [[NSUserDefaults standardUserDefaults] objectForKey:DESKMODELSSONGDIC];
    }else
        data = [[NSUserDefaults standardUserDefaults] objectForKey:DESKMODELSDIC];
    NSArray <DeskInfoModel *> *arr = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return arr;
}


@end

