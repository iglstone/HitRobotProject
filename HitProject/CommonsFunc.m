//
//  CommonsFunc.m
//  MaiYou
//
//  Created by iOS on 15/5/17.
//  Copyright (c) 2015年 iOS. All rights reserved.
//

#import "CommonsFunc.h"
#include <netinet/in.h>  //定义数据结构sockaddr_in
#include <sys/socket.h>  //提供socket函数及数据结构
#import <arpa/inet.h>
#import <netdb.h>
// positions

#define UD [NSUserDefaults standardUserDefaults]

@implementation CommonsFunc

+ (UIImage *)imagePinch:(UIImage *)img width:(int)width height:(int)height {
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), NO ,0.0);
    CGRect imageRect = CGRectMake(0, 0,width, height);
    [img drawInRect:imageRect];
    UIImage *new = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return new;
}

+(NSString *)stringFromHexString:(NSString *)hexString { //
    hexString = [hexString stringByReplacingOccurrencesOfString:@"0x" withString:@""];
    char *myBuffer = (char *)malloc((int)[hexString length] / 2 + 1);
    bzero(myBuffer, [hexString length] / 2 + 1);
    for (int i = 0; i < [hexString length] - 1; i += 2) {
        unsigned int anInt;
        NSString * hexCharStr = [hexString substringWithRange:NSMakeRange(i, 2)];
        NSScanner * scanner = [[NSScanner alloc] initWithString:hexCharStr] ;
        [scanner scanHexInt:&anInt];
        myBuffer[i / 2] = (char)anInt;
    }
    NSString *unicodeString = [NSString stringWithCString:myBuffer encoding:4];
//    NSLog(@"------字符串=======%@",unicodeString);
    return unicodeString;
}

+ (NSString *)stringToHexString:(int)number{
    NSString *hexString;
    if (number < 16) {
        hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"0%x",number]];
    }else
        hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%x",number]];
    return hexString;
}

+ (BOOL)isFirstLaunch {
    if (![UD boolForKey:@"everLaunched"]) {
        [UD setBool:YES forKey:@"everLaunched"];
        [UD setBool:YES forKey:@"firstLaunch"];
    }
    else{
        [UD setBool:NO forKey:@"firstLaunch"];
    }

    return [UD boolForKey:@"firstLaunch"];
//    if ([UD boolForKey:@"firstLaunch"]) {
//        //第一次运行,以游客登录
//        NSLog(@"firstLaunch..");
//        
//    }
}

+(BOOL)isDeviceIpad
{
    NSString* deviceType = [UIDevice currentDevice].model;
//    NSLog(@"deviceType = %@", deviceType);
    NSRange range = [deviceType rangeOfString:@"iPad"];
    return range.location != NSNotFound;
}

+(UIColor *)colorOfSystemBackground{
    UIColor *color = [UIColor colorWithHexString:@"#f3efef"];//  ecececgu
    return color;
}

+(UIColor *)colorOfLight{
    UIColor *color = [UIColor colorWithHexString:@"F8F8FF"];//  ecececgu
    return color;
}

+(UIColor *)colorOfMiddle{
    UIColor *color = [UIColor colorWithHexString:@"#999999"];//  ecececgu
    return color;
}

+(UIColor *)colorOfDark{
    UIColor *color = [UIColor colorWithHexString:@"#666666"];//  ecececgu
    return color;
}


+(NSString*)getIPAddressByHostName:(NSString*)strHostName
{
    const char* szname = [strHostName UTF8String];
    struct hostent* phot ;
    @try
    {
        phot = gethostbyname(szname);
    }
    @catch (NSException * e)
    {
        return nil;
    }
    
    struct in_addr ip_addr;
    memcpy(&ip_addr,phot->h_addr_list[0],4);///h_addr_list[0]里4个字节,每个字节8位，此处为一个数组，一个域名对应多个ip地址或者本地时一个机器有多个网卡
    
    char ip[20] = {0};
    inet_ntop(AF_INET, &ip_addr, ip, sizeof(ip));
    
    NSString* strIPAddress = [NSString stringWithUTF8String:ip];
    return strIPAddress;
}


/*
// 设置超时时间
+(void)setTimeOut:(AFHTTPRequestOperationManager *)manager{
    [CommonsFunc setTimeOutInterval:manager interval:0];
}
+(void)setTimeOutInterval:(AFHTTPRequestOperationManager *)manager interval:(NSInteger)interval{
    [manager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    if (interval == 0) {
        manager.requestSerializer.timeoutInterval = 5.0f;
    }else{
        manager.requestSerializer.timeoutInterval = interval;
    }
    [manager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
}

//从服务器GET获取,添加token的
+(void)GetJsonWithUrl:(NSString *)url parameters:(id)parameter success:(void(^)(id responseObjec))succes faild:(void(^)(AFHTTPRequestOperation *operation))faildd{
    NSLog(@"tokenCheck url:%@",url);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    //设置超时时间
    [CommonsFunc setTimeOut:manager];
    
    // set Header
    [manager.requestSerializer setValue:C_httpHeaderValue forHTTPHeaderField:C_httpHeaderKey];
    [manager.requestSerializer setValue:C_httpHeaderValue2 forHTTPHeaderField:C_httpHeaderKey2];
    
    if (![CommonsFunc getLocalToken]) {
        NSLog(@"Did not have token");
    }
    if ([CommonsFunc hasToken]) {
        [manager.requestSerializer setValue:[CommonsFunc getLocalToken] forHTTPHeaderField:C_httpHeaderKey3];//token
    }
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.responseSerializer.stringEncoding = NSUTF8StringEncoding;
    
    //遇到 500 错误需要重试 3次
//    __block int fiveHadrudTimes = 0;
//    for (__block int fiveHadrudTimes = 0; fiveHadrudTimes < 3 ; fiveHadrudTimes++) {
        [manager GET:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
            succes(responseObject);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"log error :%@",error);
            if (operation.response.statusCode == 401) {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"UnauthorizedUser" object:nil];
            }else
                faildd(operation);
        }];
}




//post 也是带token的
+ (void)postJSONWithUrl:(NSString *)urlStr parameters:(id)parameters success:(void (^)(id responseObject))success fail:(void (^)( AFHTTPRequestOperation *operation))fail //参数是void (^)(id responseObject)，所以上面传的时候也必须是这种类型的
{
    LoggerApp(4, @"url :%@  token:%@ parameters ",urlStr,parameters);

    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];

    //设置超时时间
    [CommonsFunc setTimeOut:manager];
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.responseSerializer.stringEncoding = NSUTF8StringEncoding;

    [manager.requestSerializer setValue:C_httpHeaderValue forHTTPHeaderField:C_httpHeaderKey];
    [manager.requestSerializer setValue:C_httpHeaderValue2 forHTTPHeaderField:C_httpHeaderKey2];
    if (![CommonsFunc getLocalToken]) {
        NSLog(@"Did not have token");
    }
    if ([CommonsFunc hasToken]) {
        [manager.requestSerializer setValue:[CommonsFunc getLocalToken] forHTTPHeaderField:C_httpHeaderKey3];//token
    }

    [manager POST:urlStr parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {

        success(responseObject);//调出来

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error :%@", error);
        if (operation.response.statusCode == 1001) {
//            if ([]) {
//                
//            }
        }else if (operation.response.statusCode == 401) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UnauthorizedUser" object:nil];
        }else
            fail(operation);
    }];
}

//从服务器PUT获取,添加token的
+(void)PutJsonWithUrl:(NSString *)url parameters:(id)parameter success:(void(^)(id responseObjec))succes fail:(void (^)(AFHTTPRequestOperation *operation))fail{
    NSLog(@"tokenCheck url:%@",url);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    //设置超时时间
    [CommonsFunc setTimeOut:manager];
    
    // set Header
    [manager.requestSerializer setValue:C_httpHeaderValue forHTTPHeaderField:C_httpHeaderKey];
    [manager.requestSerializer setValue:C_httpHeaderValue2 forHTTPHeaderField:C_httpHeaderKey2];
    
    if (![CommonsFunc getLocalToken]) {
        NSLog(@"Did not have token");
    }
    if ([CommonsFunc hasToken]) {
        [manager.requestSerializer setValue:[CommonsFunc getLocalToken] forHTTPHeaderField:C_httpHeaderKey3];//token
    }
    [manager.requestSerializer setValue:[CommonsFunc getLocalToken] forHTTPHeaderField:C_httpHeaderKey3];//token
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.responseSerializer.stringEncoding = NSUTF8StringEncoding;
    
    [manager PUT:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        succes(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"put Fail..，%@",error);
        if (operation.response.statusCode == 401) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UnauthorizedUser" object:nil];
        }else
            fail(operation);
    }];
}

//DELETE,添加token的
+(void)DeleteJsonWithUrl:(NSString *)url parameters:(id)parameter success:(void(^)(id responseObjec))succes fail:(void (^)(AFHTTPRequestOperation *operation))fail{
    NSLog(@"tokenCheck url:%@",url);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    // 设置返回格式
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    // 设置请求格式
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
    //设置超时时间
    [CommonsFunc setTimeOut:manager];
    
    // set Header
    [manager.requestSerializer setValue:C_httpHeaderValue forHTTPHeaderField:C_httpHeaderKey];
    [manager.requestSerializer setValue:C_httpHeaderValue2 forHTTPHeaderField:C_httpHeaderKey2];
    
    if (![CommonsFunc getLocalToken]) {
        NSLog(@"Did not have token");
    }
    if ([CommonsFunc hasToken]) {
        [manager.requestSerializer setValue:[CommonsFunc getLocalToken] forHTTPHeaderField:C_httpHeaderKey3];//token
    }
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    manager.responseSerializer.stringEncoding = NSUTF8StringEncoding;
    
    [manager DELETE:url parameters:parameter success:^(AFHTTPRequestOperation *operation, id responseObject) {
        succes(responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"delete Fail..%@",error);
        if (operation.response.statusCode == 401) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"UnauthorizedUser" object:nil];
        }else
            fail(operation);
    }];
}


+(BOOL)hasToken{//这个的作用仅仅是检测有没有被卸载过，，并不能代表其能否有本地token
    NSNumber *hasToken = (NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:C_isTokenInSskeyChain];

    if ([hasToken isEqual:[NSNull null]]){
        return NO;
    }
    return [hasToken boolValue];
}

//获取本地的token
+(NSString *)getLocalToken{
    if ([[DataCacher sharedDataCenter] getChachedDate:@"cachedToken"]) {
        return (NSString *)[[DataCacher sharedDataCenter] getChachedDate:@"cachedToken"];
    }
    
    NSString *ret = [SSKeychain passwordForService:C_passWordService account:C_passWordAccount];
    if (ret) {
        [[DataCacher sharedDataCenter] cacheData:ret key:@"cachedToken"];
        
        return ret;
    }else{
        NSLog(@" didnot have token..");
        return nil;
    }
}

//删除本地和缓存token
+(void)deleteLocalToken{
    NSString *ret = [SSKeychain passwordForService:C_passWordService account:C_passWordAccount];
    //删除内存
    if (ret) {
        [SSKeychain deletePasswordForService:C_passWordService account:C_passWordAccount];
    }
    //删除缓存
    id tk =[[DataCacher sharedDataCenter] getChachedDate:@"cachedToken"];
    if ([tk isEqual:[NSNull null]]) {//如果缓存没有，则do nothing
        
    }else{
        [[DataCacher sharedDataCenter]removeCachedData:@"cachedToken"];
    }
    //删除nsdefault中的有token标志位,不能删，退出的画已经删除过了
//    NSNumber *hasToken = [[NSUserDefaults standardUserDefaults] objectForKey:C_isTokenInSskeyChain];
//    if ([hasToken boolValue]) {
//        [[NSUserDefaults standardUserDefaults] removeObjectForKey:C_isTokenInSskeyChain];
//    }
    
    NSString *idString = [[NSUserDefaults standardUserDefaults] stringForKey:C_user_ID_key];
    if (idString) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:C_user_ID_key];
    }
}

//存储token到本地
+(void)saveLocalToken:(NSString *)token{
    NSString *ret = [SSKeychain passwordForService:C_passWordService account:C_passWordAccount];
    //删除内存
    if (ret) {
        [SSKeychain deletePasswordForService:C_passWordService account:C_passWordAccount];
    }
    //删除缓存
    id tk =[[DataCacher sharedDataCenter] getChachedDate:@"cachedToken"];
    if ([tk isEqual:[NSNull null]]) {//如果缓存没有，则do nothing
        
    }else{
        [[DataCacher sharedDataCenter]removeCachedData:@"cachedToken"];
    }
    [SSKeychain setPassword:token forService:C_passWordService account:C_passWordAccount];
    [[DataCacher sharedDataCenter] cacheData:token key:@"cachedToken"];
}
*/

+(void)com_custumLabel:(UILabel *)label fontSize:(NSInteger)font color:(UIColor *)color numberOfLines:(NSInteger)lines alignment:(NSTextAlignment )alignment{
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = lines;
    label.font = [UIFont systemFontOfSize:font];
    label.textColor = color;
    if (alignment) {
        label.textAlignment = alignment;
    }
}

+(void)com_custumLabel:(UILabel *)label parentView:(UIView *)parentView  text:(NSString *)text fontSize:(NSInteger)font color:(UIColor *)color numberOfLines:(NSInteger)lines textAlignment:(NSTextAlignment )alignment {//mas_constrant:(void(^)(MASConstraintMaker *))block{
    [parentView addSubview:label];
    label.text = text;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = lines;
    label.font = [UIFont systemFontOfSize:font];
    label.textColor = color;
    if (alignment) {
        label.textAlignment = alignment;
    }
}

+(void)com_custumButton:(UIButton *)btn parentView:(UIView *)parentView text:(NSString *)text backgroundColor:(UIColor *)backgroundColor textColor:(UIColor *)textColor textFontSize:(NSInteger)font target:(id)target select:(SEL)action {// mas_constrant:(void(^)(MASConstraintMaker *))block{
    if (parentView) {
        [parentView addSubview:btn];
    }
    [btn setTitle:text forState:UIControlStateNormal];
    [btn setTitleColor:textColor forState:UIControlStateNormal];
    btn.titleLabel.textColor = textColor;
    
    if (font != 0) {
        btn.titleLabel.font = [UIFont systemFontOfSize:font];
    }
    
    btn.backgroundColor = backgroundColor;
//    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
//        block(make);
//    }];
    [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}
//最终整合：
+(void)com_customVerButton:(UIButton *)btn title:(NSString *)title titleFont:(NSInteger)fontsize image:(NSString *)imageName btnSize:(CGSize)btnSize titleTopToImg:(NSInteger)gap{
    NSInteger BUtttonImageSize = 80;
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {//先分配足够大的空间让横着放
        make.size.mas_equalTo(CGSizeMake(80 * 2, 80 + 80)).priorityLow();
    }];
    if (imageName) {
        [btn setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    }
    if (!gap) {
        gap = 0;
    }
    if (title) {
        [btn.titleLabel setBackgroundColor:[UIColor clearColor]];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        btn.titleLabel.font = [UIFont systemFontOfSize:fontsize];
        [btn setTitle:title forState:UIControlStateNormal];
    }
    CGSize ImgeSize = btn.imageView.frame.size;
    CGSize labelSize = btn.titleLabel.frame.size;
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btn.contentVerticalAlignment = UIControlContentVerticalAlignmentTop;
    int ImgeToLeft = (BUtttonImageSize - ImgeSize.width)/2;
    int titleToleft = (BUtttonImageSize - labelSize.width)/2 - ImgeSize.width;
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(gap+ImgeSize.height, titleToleft, 0, 0)];//由于imageSize被定死了，，所以也需要根据实际情况来调
    [btn setImageEdgeInsets:UIEdgeInsetsMake(0, ImgeToLeft, 0, 0)];
    
    if (CGSizeEqualToSize(btnSize, CGSizeZero)) {
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(ImgeSize.width+5 , ImgeSize.height + labelSize.height + gap));
        }];
    }else{
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(btnSize);
        }];
    }
}


+(void)com_custumImageView:(UIImageView *)imgView parentView:(UIView *)parentView mas_constrant:(void(^)(MASConstraintMaker *))block{
    [parentView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        block(make);
    }];
}


//裁剪正方形
+ (UIImage *)croppedImage:(UIImage *)image
{
    if (image)
    {
        float min = MIN(image.size.width,image.size.height);
        CGRect rectMAX = CGRectMake((float)(image.size.width-min)/2, (float)(image.size.height-min)/2, min, min);
        
        CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rectMAX);
        
        UIGraphicsBeginImageContext(rectMAX.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, CGRectMake(0, 0, min, min), subImageRef);
        UIImage *viewImage = [UIImage imageWithCGImage:subImageRef];
        UIGraphicsEndImageContext();
        CGImageRelease(subImageRef);
        return viewImage;
    }
    
    return nil;
}


//把头像从中间截取一部分 ，缩放到 200
+(UIImage *)cutSmallImage:(UIImage *)image baseHeight:(NSInteger)baseLength
{
    UIImage *img = [CommonsFunc croppedImage:image];
    
    UIImage *finalImag = [CommonsFunc scaleSmallImage:img toScale:0 baseHeight:baseLength];
    return finalImag;
}

/*
//把头像从中间截取一部分  大图用的骑牛 压缩系数为 0.6 就不需要截取了
+(UIImage *)cutSmallImage:(UIImage *)image baseHeight:(NSInteger)baseLength
{
    NSInteger ImageWidth = image.size.width; NSInteger ImageHeigth = image.size.height;
    NSInteger theLong = ImageWidth > ImageHeigth ? ImageWidth : ImageHeigth;
    NSInteger theShort = ImageWidth > ImageHeigth ? ImageHeigth : ImageWidth;
    
    CGRect frameRect;
    CGPoint centerPoint = CGPointMake(ImageWidth/2, ImageHeigth/2);
    
    if (theShort > baseLength) {//截取
        CGSize widthAndLength = CGSizeMake(baseLength, baseLength);
        frameRect = CGRectMake(centerPoint.x - widthAndLength.width/2 , centerPoint.y - widthAndLength.height/2, baseLength, baseLength);
    }
    else if (theLong < baseLength) {
        CGSize widthAndLength = CGSizeMake(ImageWidth , ImageHeigth);
        frameRect = CGRectMake(centerPoint.x - widthAndLength.width/2 , centerPoint.y - widthAndLength.height/2, baseLength, baseLength);
    }
    else {
        if (ImageWidth > baseLength) {
            CGSize widthAndLength = CGSizeMake(baseLength, ImageHeigth);
            frameRect = CGRectMake(centerPoint.x - widthAndLength.width/2 , centerPoint.y - widthAndLength.height/2, baseLength, baseLength);
        }
        if (ImageHeigth > baseLength) {
            CGSize widthAndLength = CGSizeMake(ImageWidth, baseLength);
            frameRect = CGRectMake(centerPoint.x - widthAndLength.width/2 , centerPoint.y - widthAndLength.height/2, baseLength, baseLength);
        }
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width , image.size.height ));
    [image drawInRect:frameRect];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}
*/

//使用blend改变图片颜色
+ (UIImage *) imageWithTintColor:(UIColor *)tintColor uimage:(UIImage *)image
{
    //We want to keep alpha, set opaque to NO; Use 0.0f for scale to use the scale factor of the device’s main screen.
    UIGraphicsBeginImageContextWithOptions(image.size, NO, 0.0f);
    [tintColor setFill];
    CGRect bounds = CGRectMake(0, 0, image.size.width, image.size.height);
    UIRectFill(bounds);
    
    //Draw the tinted image in context
    [image drawInRect:bounds blendMode:kCGBlendModeDestinationIn alpha:1.0f];
    UIImage *tintedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return tintedImage;
}

//把头像按比例缩放到固定大小  heightAndWidth: 200(头像) 240（小图） 400（大图）
+(UIImage *)scaleSmallImage:(UIImage *)image toScale:(float)scaleSize baseHeight:(NSInteger)heightAndWidth
{
    if (!image) {
        return nil;
    }
    
    //按比例缩放 240 为基准
    if (image.size.width >=heightAndWidth || image.size.height >= heightAndWidth) {
        float newWidth = image.size.width > heightAndWidth ? heightAndWidth : image.size.width;
        float newHeight = image.size.height > heightAndWidth ? heightAndWidth : image.size.height;
        
        float scaleWidth = newWidth/image.size.width;
        float scaleHeight = newHeight/image.size.height;
        
        scaleSize = scaleWidth < scaleHeight ? scaleWidth : scaleHeight;//取小的，按比例缩放
        
    }else{
        scaleSize = 1.0;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


//拍照时解决旋转问题。。
+ (UIImage*)rotateImage:(UIImage *)image
{
    int kMaxResolution = 960; // Or whatever
    CGImageRef imgRef = image.CGImage;
    
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    if (width > kMaxResolution || height > kMaxResolution) {
        CGFloat ratio = width/height;
        if (ratio > 1) {
            bounds.size.width = kMaxResolution;
            bounds.size.height = bounds.size.width / ratio;
        }
        else {
            bounds.size.height = kMaxResolution;
            bounds.size.width = bounds.size.height * ratio;
        }
    }
    
    CGFloat scaleRatio = bounds.size.width / width;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imgRef), CGImageGetHeight(imgRef));
    CGFloat boundHeight;
    UIImageOrientation orient = image.imageOrientation;
    switch(orient) {
            
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(imageSize.width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(imageSize.width, imageSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, imageSize.width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, imageSize.width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(imageSize.height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
            
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}

/*
+(void) makeToastCenter:(NSString *)description duration:(NSInteger)duration{
    [[[UIApplication sharedApplication]keyWindow]makeToast:description duration:duration position:CSToastPositionCenter];
}
+(void) makeToastBottom:(NSString *)description duration:(NSInteger)duration{
    [[[UIApplication sharedApplication]keyWindow]makeToast:description duration:duration position:CSToastPositionBottom];
}
+(void) makeToastTop:(NSString *)description duration:(NSInteger)duration{
    [[[UIApplication sharedApplication]keyWindow]makeToast:description duration:duration position:CSToastPositionTop];
}

//根据电话号码来找到姓名
+(NSString *)findNameByPhone:(NSString *)phoen{
    NSString *nameString2 = [NSString new];
    AddressBook *book = [AddressBook MR_findFirst];
    NSDictionary *dic = (NSDictionary *)book.addressBook;
    NSArray *totalArray = (NSArray *)[dic objectForKey:@"info"];
    for (NSDictionary *abDic in totalArray) {
        NSString *tmpPhone = (NSString *)[abDic objectForKey:@"phone"];
        if ([tmpPhone isEqualToString:phoen]) {
            nameString2 = (NSString *)[abDic objectForKey:@"name"];
            break;
        }
    }
    return nameString2;
}

//设置线的frame和color,，线宽是frame的height,然后当成ImageView来操作。。当然可以直接对Image操作
+(UIImageView *)lineImageViewInitWithFrame:(CGRect)frameRect color:(UIColor *)color2{
    UIImageView *imageView=[[UIImageView alloc] initWithFrame:frameRect];
    UIGraphicsBeginImageContext(imageView.frame.size);
    [imageView.image drawInRect:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();//获取当前ctx
    CGContextSetLineCap(ctx, kCGLineCapRound);  //边缘样式
    CGContextSetLineWidth(ctx, frameRect.size.height);  //线宽
    CGContextSetAllowsAntialiasing(ctx, YES);
    CGContextSetStrokeColorWithColor(ctx, [color2 CGColor]);//颜色//颜色
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, frameRect.origin.x, frameRect.origin.y);  //起点坐标
    CGContextAddLineToPoint(ctx, frameRect.origin.x + frameRect.size.width, frameRect.origin.y);   //终点坐标
    CGContextStrokePath(ctx);
    imageView.image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageView;
}

//输入一个生日字符串，生成一个年龄字符串
+(NSString *)getAgeFromBirthDayString:(NSString *)birthdayString{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *birthdayDate = [dateFormatter dateFromString:birthdayString];
    
    NSTimeInterval dateDiff = [birthdayDate timeIntervalSinceNow];
    int age = - trunc(dateDiff/(60*60*24))/365;
    NSString *returnString = [NSString stringWithFormat:@"%d",age];
    return returnString;
}


//-(NSString *)getRelationName:(model){
//    NSDictionary *dic = model.relation;
//    NSNumber *level = [dic objectForKey:@"level"];
//    if ([level integerValue] == 1) {
//        sellerNameLabel.text = model.name;
//    }else if([level integerValue] == 2){
//        NSArray *arr = [dic objectForKey:@"names"];
//        if (arr.count == 1) {
//            NSString *st = [arr objectAtIndex:0];
//            sellerNameLabel.text = st;
//        }else if(arr.count > 1){
//            NSString *st = [arr objectAtIndex:0];
//            sellerNameLabel.text = [NSString stringWithFormat:@"%@ 的好友",st];
//        }
//        else if([arr isEqual:[NSNull null]]){
//            NSLog(@"现在可能已经不是好友的好友了");
//            [CommonsFunc makeToastCenter:@"现在其可能不是你好友的好友了" duration:2.0];
//        }
//    }
//}

//把unix时间戳变成 2014-05-15的时间字符串
+(NSString *)changeDateFromUnixToString:(NSInteger)unixDate{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];//YYYY-MM-dd HH:mm:ss
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    return strDate;
}

//把unix时间戳变成 2014-05-15的时间字符串
+(NSString *)changeDateFromUnixToSecendsString:(NSInteger)unixDate{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];//YYYY-MM-dd HH:mm:ss
    NSString *strDate = [dateFormatter stringFromDate:date];
    
    return strDate;
}


//把unix时间戳变成nsdate
+(NSDate *)changeDateFromUnixToNSDate:(NSInteger)unixDate{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixDate];
    return date;
}

//把unix时间戳变成“几分钟前，几天前。。“
+(NSString *)changeDateFromUnixToTimeAgo:(NSInteger)unixDate{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:unixDate];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    [dateFormatter setDateFormat:@"YYYY-MM-dd HH:mm:ss"];//YYYY-MM-dd HH:mm:ss
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSDate *date4 = [CommonsFunc getLocalFromUTC:strDate];
    NSLog(@"时间戳转日期2 %ld  = %@", (long)unixDate, date4);
    
    NSString *ret = [CommonsFunc changeNsdateToTimeAgo:date];
    
    
    //test
//    NSDate *date1 = [NSDate date];
//    NSLog(@"当前日期为:%@",date1);
//    NSTimeInterval timeStamp= [date1 timeIntervalSince1970];
//    NSLog(@"日期转换为时间戳 %@ = %f", date1, timeStamp);
//    NSDate *date3 = [NSDate dateWithTimeIntervalSince1970:timeStamp];
//    NSLog(@"时间戳转日期0 %f  = %@", timeStamp, date3);
    
//    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:unixDate];
//    NSLog(@"时间戳转日期1 %f  = %@", timeStamp, date2);
    
//    return nil;
    
    
    return ret;
}

+ (NSDate *)getLocalFromUTC:(NSString *)utc
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *ldate = [dateFormatter dateFromString:utc];
    return ldate;
}
 */

/**
 * 计算指定时间与当前的时间差
 * @param compareDate   某一指定时间
 * @return 多少(秒or分or天or月or年)+前 (比如，3天前、10分钟前)
 * 配合着下面的这个用
 * NSTimer *time = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(timeFireMethod:) userInfo:date repeats:YES];
 */
+(NSString *)changeNsdateToTimeAgo:(NSDate*) compareDate
{
    NSTimeInterval  timeInterval = [compareDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    long temp = 0;
    NSString *result;
    if (timeInterval < 60) {
        result = [NSString stringWithFormat:@"刚刚"];
    }
    else if((temp = timeInterval/60) <60){
        result = [NSString stringWithFormat:@"%ld分前",temp];
    }
    
    else if((temp = temp/60) <24){
        result = [NSString stringWithFormat:@"%ld小时前",temp];
    }
    
    else if((temp = temp/24) <30){
        result = [NSString stringWithFormat:@"%ld天前",temp];
    }
    
    else if((temp = temp/30) <12){
        result = [NSString stringWithFormat:@"%ld月前",temp];
    }
    else{
        temp = temp/12;
        result = [NSString stringWithFormat:@"%ld年前",temp];
    }
    
    return  result;
}

//由生日计算星座：输入格式 1988-07-11 string/nsdate
+(NSString *)getXingzuo:(id)date{
    //计算星座
    NSDate *inDate;
    if ([date isKindOfClass:[NSString class]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        inDate = [dateFormatter dateFromString:date];
    }else if([date isKindOfClass:[NSDate class]]){
        inDate = (NSDate *)date;
    }else{
        NSLog(@"输入日期格式不正确，请重新输入");
    }
    
    
    NSString *retStr=@"";
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"MM"];
    int monthInt=0;
    NSString *theMonth = [dateFormat stringFromDate:inDate];
    if([[theMonth substringToIndex:0] isEqualToString:@"0"]){
        monthInt = [[theMonth substringFromIndex:1] intValue];
    }else{
        monthInt = [theMonth intValue];
    }
    
    [dateFormat setDateFormat:@"dd"];
    int dayInt=0;
    NSString *theDay = [dateFormat stringFromDate:inDate];
    if([[theDay substringToIndex:0] isEqualToString:@"0"]){
        dayInt = [[theDay substringFromIndex:1] intValue];
    }else{
        dayInt = [theDay intValue];
    }
    /*
     摩羯座 12月22日------1月19日
     水瓶座 1月20日-------2月18日
     双鱼座 2月19日-------3月20日
     白羊座 3月21日-------4月19日
     金牛座 4月20日-------5月20日
     双子座 5月21日-------6月21日
     巨蟹座 6月22日-------7月22日
     狮子座 7月23日-------8月22日
     处女座 8月23日-------9月22日
     天秤座 9月23日------10月23日
     天蝎座 10月24日-----11月21日
     射手座 11月22日-----12月21日
     */
    if (monthInt == 1) {
        if (dayInt > 0 && dayInt < 20) {
            retStr=@"摩羯座";
        }
        if (dayInt > 21 &&dayInt < 31) {
            retStr=@"水瓶座";
        }
        return retStr;
    }
    if (monthInt == 2) {
        if (dayInt > 0 && dayInt < 19) {
            retStr=@"水瓶座";
        }
        if (dayInt > 20 && dayInt < 30) {
            retStr=@"双鱼座";
        }
        return retStr;
    }
    if (monthInt == 3) {
        if (dayInt > 0 && dayInt < 21) {
            retStr=@"双鱼座";
        }
        if (dayInt > 20 && dayInt < 32) {
            retStr=@"白羊座";
        }
        return retStr;
    }
    if (monthInt == 4) {
        if (dayInt > 0 && dayInt < 20) {
            retStr=@"白羊座";
        }
        if (dayInt > 19 && dayInt < 31) {
            retStr=@"金牛座";
        }
        return retStr;
    }
    if (monthInt == 5) {
        if (dayInt > 0 && dayInt < 21) {
            retStr=@"金牛座";
        }
        if (dayInt > 22 && dayInt < 32) {
            retStr=@"双子座";
        }
        return retStr;
    }
    if (monthInt == 6) {
        if (dayInt > 0 && dayInt < 22) {
            retStr=@"双子座";
        }
        if (dayInt > 21 && dayInt < 31) {
            retStr=@"巨蟹座";
        }
        return retStr;
    }
    if (monthInt == 7) {
        if (dayInt > 0 && dayInt < 23) {
            retStr=@"巨蟹座";
        }
        if (dayInt > 22 && dayInt < 32) {
            retStr=@"狮子座";
        }
        return retStr;
    }
    if (monthInt == 8) {
        if (dayInt > 0 && dayInt < 23) {
            retStr=@"狮子座";
        }
        if (dayInt > 22 && dayInt < 32) {
            retStr=@"处女座";
        }
        return retStr;
    }
    if (monthInt == 9) {
        if (dayInt > 1 && dayInt < 23) {
            retStr=@"处女座";
        }
        if (dayInt > 22 && dayInt < 31) {
            retStr=@"天平座";
        }
        return retStr;
    }
    if (monthInt == 10) {
        if (dayInt > 0 && dayInt < 24) {
            retStr=@"天平座";
        }
        if (dayInt > 23 && dayInt < 32) {
            retStr=@"天蝎座";
        }
        return retStr;
    }
    if (monthInt == 11) {
        if (dayInt > 0 && dayInt < 22) {
            retStr=@"天蝎座";
        }
        if (dayInt > 21 && dayInt < 31) {
            retStr=@"摩羯座";
        }
        return retStr;
    }
    if (monthInt == 12) {
        if (dayInt > 1 && dayInt < 22) {
            retStr=@"水瓶座";
        }
        if (dayInt > 21 && dayInt < 32) {
            retStr=@"摩羯座";
        }
        return retStr;
    }
    return  retStr;
}


//使用第三方库导致NSLog打印数组NSArray或字典NSDictionary时出现\U开头乱码的解决办法
+(void)logDiction:(NSDictionary *)dic{
    //使用第三方库导致NSLog打印数组NSArray或字典NSDictionary时出现\U开头乱码的解决办法
    NSString *tempStr1 = [[dic description] stringByReplacingOccurrencesOfString:@"\\u" withString:@"\\U"];
    NSString *tempStr2 = [tempStr1 stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    NSString *tempStr3 = [[@"\"" stringByAppendingString:tempStr2] stringByAppendingString:@"\""];
    NSData *tempData = [tempStr3 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str = [NSPropertyListSerialization propertyListWithData:tempData options:NSPropertyListImmutable format:NULL error:NULL];
    NSLog(@"logDic:%@",str);
}

//把dic中的字典转换成字符串
+(NSString *)changeArrayToString:(NSString *)key nsdic:(NSDictionary *)dic{
    if (dic == nil) {
        return @"";
    }
    NSArray * hobbyArray = [dic objectForKey:key];
    if ([hobbyArray isEqual:[NSNull null]] ) {
        return @"";
    }
    
    NSLog(@" hobbyArray %@ ",hobbyArray);
    
    NSString *hobbys = @"";
    for (NSString *hobby in hobbyArray) {
        
        hobbys = [[hobbys stringByAppendingString:@", "] stringByAppendingString:hobby];
    }
    hobbys =  hobbys.length > 1 ? [hobbys substringFromIndex:1] : @"";
    return hobbys;
}

+ (BOOL)IS_IOS8 {
    //check systemVerson of device
   UIDevice *device = [UIDevice currentDevice];
   float sysVersion = [device.systemVersion floatValue];
   if (sysVersion >= 8.0f) {
       return YES;
   }
    return NO;
 }

//+(BOOL) checkNotificationState{
//    if ([CommonsFunc IS_IOS8])
//    {
//        UIUserNotificationType types = [[UIApplication sharedApplication] currentUserNotificationSettings].types;
//        NSLog(@"========%lu,%lu -%lu",(unsigned long)(types & UIRemoteNotificationTypeAlert),(unsigned long)types,(unsigned long)[[UIApplication sharedApplication] currentUserNotificationSettings]);
//        return (types & UIRemoteNotificationTypeAlert);
//    }
//    else
//    {
//        UIRemoteNotificationType types = [[UIApplication sharedApplication] enabledRemoteNotificationTypes];
//        return (types & UIRemoteNotificationTypeAlert);
//    }
//}
//
@end
