//
//  CommonsFunc.h
//  MaiYou
//
//  Created by iOS on 15/5/17.
//  Copyright (c) 2015年 iOS. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CommonsFunc : NSObject

+ (UIImage *)imagePinch:(UIImage *)img width:(int)width height:(int)height ;

//十六进制转nsstring
+(NSString *)stringFromHexString:(NSString *)hexString;
+(NSString *)stringToHexString:(int)number;

+(BOOL)isDeviceIpad;
/**
 *  判断程序整个生命周期都只执行一次
 *  @return yes 表示是第一次运行，no 不是第一次执行。
 */
+ (BOOL)isFirstLaunch ;

//获得系统背景色
+(UIColor *)colorOfSystemBackground;
+(UIColor *)colorOfLight;
+(UIColor *)colorOfMiddle;
+(UIColor *)colorOfDark;
+(NSString*)getIPAddressByHostName:(NSString*)strHostName;

//+(void)GetJsonWithUrl:(NSString *)url parameters:(id)parameter success:(void(^)(id responseObjec))succes faild:(void (^)(AFHTTPRequestOperation *operation))faildd;
////post 也是带token的
//+ (void)postJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success fail:(void (^)( AFHTTPRequestOperation *operation))fail; //参数是void (^)(id responseObject)，所以上面传的时候也必须是这种类型的
////put
//+(void)PutJsonWithUrl:(NSString *)url parameters:(id)parameter success:(void(^)(id responseObjec))succes fail:(void (^)(AFHTTPRequestOperation *operation))fail;
////delete
//+(void)DeleteJsonWithUrl:(NSString *)url parameters:(id)parameter success:(void(^)(id responseObjec))succes fail:(void (^)(AFHTTPRequestOperation *operation))fail;


////是否有token
//+(BOOL)hasToken;
////获得本地token
//+(NSString *)getLocalToken;
////删除本地和缓存token
//+(void)deleteLocalToken;
////存储token到本地
//+(void)saveLocalToken:(NSString *)token;

+(void)com_custumLabel:(UILabel *)label fontSize:(NSInteger)font color:(UIColor *)color numberOfLines:(NSInteger)lines alignment:(NSTextAlignment )alignment;

+(void)com_custumLabel:(UILabel *)label parentView:(UIView *)parentView  text:(NSString *)text fontSize:(NSInteger)font color:(UIColor *)color numberOfLines:(NSInteger)lines textAlignment:(NSTextAlignment )alignment ;//mas_constrant:(void(^)(MASConstraintMaker *))block;

+(void)com_custumButton:(UIButton *)btn parentView:(UIView *)parentView text:(NSString *)text backgroundColor:(UIColor *)backgroundColor  textColor:(UIColor *)textColor textFontSize:(NSInteger)font target:(id)target select:(SEL)action ;// mas_constrant:(void(^)(MASConstraintMaker *))block;
+(void)com_customVerButton:(UIButton *)btn title:(NSString *)title titleFont:(NSInteger)fontsize image:(NSString *)imageName btnSize:(CGSize)btnSize titleTopToImg:(NSInteger)gap;

////使用blend改变图片颜色
//+ (UIImage *)imageWithTintColor:(UIColor *)tintColor uimage:(UIImage *)image;
////把头像按比例缩放到固定大小  heightAndWidth: 200(头像) 240（小图） 400（大图）
//+(UIImage *)scaleSmallImage:(UIImage *)image toScale:(float)scaleSize baseHeight:(NSInteger)heightAndWidth;
////把头像从中间截取一部分  大图用的骑牛 压缩系数为 0.6 就不需要截取了
//+(UIImage *)cutSmallImage:(UIImage *)image baseHeight:(NSInteger)baseLength;
////解决图像拍照时旋转九十度的问题
//+ (UIImage*)rotateImage:(UIImage *)image;
//
////toast
//+(void) makeToastCenter:(NSString *)description duration:(NSInteger)duration;
//+(void) makeToastBottom:(NSString *)description duration:(NSInteger)duration;
//+(void) makeToastTop:(NSString *)description duration:(NSInteger)duration;
//
////把unix时间戳变成 2014-05-15的时间
//+(NSString *)changeDateFromUnixToString:(NSInteger)unixDate;
//+(NSString *)changeDateFromUnixToSecendsString:(NSInteger)unixDate;//转换到秒
////把unix时间戳变成nsdate
//+(NSDate *)changeDateFromUnixToNSDate:(NSInteger)unixDate;
////把unix时间戳变成“几分钟前，几天前。。“
//+(NSString *)changeDateFromUnixToTimeAgo:(NSInteger)unixDate;
////有nsdate到 几分钟前，几小时前
//+(NSString *)changeNsdateToTimeAgo:(NSDate*) compareDate;
//
//+(NSString *)changeSexNumToString:(NSString *)sexNum;//0 1 2 保密，男，女
////输入一个生日字符串，生成一个年龄字符串  带 “XX 岁”
//+(NSString *)getAgeFromBirthDayString:(NSString *)birthdayString;
//
////由生日计算星座：输入格式 1988-07-11 string/nsdate
//+(NSString *)getXingzuo:(id)date;
//
////根据电话号码来找到姓名
//+(NSString *)findNameByPhone:(NSString *)phoen;
//
////设置线的frame和color,，线宽是frame的height,然后当成ImageView来操作。。当然可以直接对Image操作
//+(UIImageView *)lineImageViewInitWithFrame:(CGRect)frameRect color:(UIColor *)color2;
//
////把dic中的字典转换成字符串
//+(NSString *)changeArrayToString:(NSString *)key nsdic:(NSDictionary *)dic;
//
////使用第三方库导致NSLog打印数组NSArray或字典NSDictionary时出现\U开头乱码的解决办法
//+(void)logDiction:(NSDictionary *)dic;
//
//+ (BOOL)IS_IOS8 ;
//
//+(BOOL) checkNotificationState;
//
@end
