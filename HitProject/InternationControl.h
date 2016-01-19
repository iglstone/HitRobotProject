//
//  InternationControl.h
//  HitProject
//
//  Created by 郭龙 on 16/1/19.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface InternationControl : NSObject
+(NSBundle *)bundle;//获取当前资源文件

+(NSString *)userLanguage;//获取应用当前语言

+(void)setUserlanguage:(NSString *)language;//设置当前语言 ：语言版本(中文zh-Hans,英文en)
@end
