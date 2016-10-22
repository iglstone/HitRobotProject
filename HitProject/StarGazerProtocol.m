//
//  StarGazerProtocol.m
//  HitProject
//
//  Created by 郭龙 on 16/7/25.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import "StarGazerProtocol.h"
#import "ServerSocket.h"

@interface StarGazerProtocol()
{
    //NSString *downLoadToStarString;
}

@end

@implementation StarGazerProtocol

+ (instancetype )sharedStarGazerProtocol
{
    static StarGazerProtocol *sharedStarGazer = nil;
    static dispatch_once_t pridicate;
    dispatch_once(&pridicate, ^{
        sharedStarGazer = [[StarGazerProtocol alloc] init];
    });
    return sharedStarGazer;
}

- (instancetype )init
{
    self  = [super init];
    if (self) {
        [[ServerSocket sharedSocket] addObserver:self forKeyPath:@"starGazerUpLoadString" options:NSKeyValueObservingOptionNew context:nil];
        
        return self;
    }
    return nil;
}

//接收下位机代码
- (void )observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"starGazerUpLoadString"]) {
        NSString *newString  = [change objectForKey:@"new"];
        NSLog(@"new string:%@", newString);
        
        NSString *subCmdMode = [newString substringWithRange:NSMakeRange(4, 1)];
        NSString *subData = [newString substringWithRange:NSMakeRange(5, newString.length - 7)];
        NSLog(@"subCmdMode: %@; subData: %@", subCmdMode, subData);
        
        const char *cmdC = [subCmdMode UTF8String];
        char cmd = cmdC[0];
        
        if (cmd == '2')
        {
            NSLog(@"请求回复");
        }
        else if (cmd == '1')
        {
            NSLog(@"状态回复");
        }
        else
        {
            NSLog(@"紧急事件回复,cmd: %c",cmd);
        }
        
        /*
        tmpGazerModel = [STModel stmodelWithString:newString]; //解析string
        if (tmpGazerModel) {
            robotAngelOfScreen = tmpGazerModel.modelAngel + 90;
            robotPositionOfScreen = [FloydAlgorithm changeCood: CGPointMake(tmpGazerModel.modelX, tmpGazerModel.modelY)];
        }
        */
    }
}

//数据结合成协议转发到机器人下位机, have unit test.
- (NSString *) composeDownLoadStringOfMode:(StarGazerMode)mode data:(NSString *)dataString
{
    
    NSString *st = [NSString stringWithFormat:@"%01hhu%@",mode, dataString];
    short nlen = st.length + 6;//add a xor and nlen self
    
    NSString *st2 = [NSString stringWithFormat:@"%02hd%@",nlen, st];
    
    char result = [self xorSum:st2];
    
    /*
    const char *ch = [st2 UTF8String];
    int i;
    char result;
    for (result = ch[0], i = 1; i < st2.length; i++)
    {
        result^=ch[i];//Xor
    }
    NSLog(@"result = %x",result);
    */
    
    NSString *st3 = [NSString stringWithFormat:@"##%@%c$", st2, result];
    return st3;
    
}

- (char )xorSum:(NSString *)stringToChar
{
    const char *ch = [stringToChar UTF8String];
    int i;
    char result;
    for (result = ch[0], i = 1; i < stringToChar.length; i++)
    {
        result^=ch[i];//Xor
    }
    NSLog(@"XOR of String: %@ result = %c", stringToChar ,result);
    
    return result;
}


/*
- (void) sendMessage:(NSString *)string Mode:(StarGazerMode)mode
{
    NSString *sendS = [self composeDownLoadStringOfMode:mode data:string];
    NSArray *debugsArray = @[@"控制命令", @"配置StarGazer" ,@"路径下发命令", @"其他命令"];
    NSString *debugString = [debugsArray objectAtIndex:(mode-1)];
    
    [[ServerSocket  sharedSocket] sendMessage:sendS debugstring:debugString];
}
*/

@end
