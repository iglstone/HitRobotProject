//
//  DeskInfoHelper.h
//  HitProject
//
//  Created by 郭龙 on 16/1/4.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeskInfoModel.h"

@interface DeskInfoHelper : NSObject

/**
 *  初始化100个桌号到内存，最先调用。
 */
- (void)defaultArray ;

/**
 *  根据tag改变deskNum的name
 *  @param deskNum 第几桌，桌的tag
 *  @param name    桌的名字
 */
- (void) changeDeskModelByTag :(int)deskNum name:(NSString *)name;

/**
 *  获得到指定桌号数的名称。
 *  @param tag
 *  @return
 */
- (NSArray <NSString *> *)getDeskNamesFromUserdefaultByTag:(int) tag ;

/**
 *  将deskNameArray存储到userinfo
 *  @param array
 */
- (void) setDeskModelsToUserdefault:(NSArray <DeskInfoModel *>*)deskModelsArray;

/**
 *  从userdefault 获取key
 *  @return
 */
- (NSArray <DeskInfoModel *>*) getDeskModelsFromUserdefault;

@end
