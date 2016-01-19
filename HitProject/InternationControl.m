//
//  InternationControl.m
//  HitProject
//
//  Created by 郭龙 on 16/1/19.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "InternationControl.h"
/**
 *  系统语言切换control
 */
@implementation InternationControl
static NSBundle *bundle = nil;

+ ( NSBundle * )bundle{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    NSString *string = [def valueForKey:@"userLanguage"];
        
    NSArray* languages = [def objectForKey:@"AppleLanguages"];
    
    NSString *current = [languages objectAtIndex:0];
    
    if (![string isEqualToString:current]) {
        
        string = current;
        
        [def setValue:current forKey:@"userLanguage"];
        
        [def synchronize];//持久化，不加的话不会保存
    }
    
    //获取文件路径
    NSString *path = [[NSBundle mainBundle] pathForResource:string ofType:@"lproj"];
    
    bundle = [NSBundle bundleWithPath:path];//生成bundle
    
    return bundle;
}

+(NSString *)userLanguage{
    
    NSString *language = [[NSUserDefaults standardUserDefaults] objectForKey:@"userLanguage"];
    
    return language;
}

+(void)setUserlanguage:(NSString *)language{
    
    NSUserDefaults *def = [NSUserDefaults standardUserDefaults];
    
    //1.第一步改变bundle的值
    NSString *path = [[NSBundle mainBundle] pathForResource:language ofType:@"lproj" ];
    
    bundle = [NSBundle bundleWithPath:path];
    
    //2.持久化
    [def setValue:language forKey:@"userLanguage"];
    
    [def synchronize];
}

//- (void)changeLanguage:(id)sender {
//    
//    NSString *lan = [InternationControl userLanguage];
//    
//    if([lan isEqualToString:@"en"]){//判断当前的语言，进行改变
//        
//        [InternationControl setUserlanguage:@"zh-Hans"];
//        
//    }else{
//        
//        [InternationControl setUserlanguage:@"en"];
//    }
//    
//    //改变完成之后发送通知，告诉其他页面修改完成，提示刷新界面
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeLanguage" object:nil];
//}
@end
