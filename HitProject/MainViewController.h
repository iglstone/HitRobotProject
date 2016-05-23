//
//  MainViewController.h
//  HitProject
//
//  Created by 郭龙 on 15/11/9.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerSocket.h"

typedef NS_ENUM(NSInteger, MESSAGEMODE) {
    MESSAGEMODE_SEND = 0,
    MESSAGEMODE_RECV = 1
};

@interface MainViewController : UITabBarController {

}

@property (nonatomic, strong) NSMutableArray *m_modelsArray;//连接上的 models
@property (nonatomic, strong) UIView         *rightsideContainer;
@property (nonatomic, strong) UILabel        *p_debugLabel;

//mode :0 send
//mode :1 recv
- (void)setDebugLabelText:(NSString *)string mode:(MESSAGEMODE)mode;

-(void) hideTabelAndDebugLabel ;
-(void) showTabelAndDebugLabel ;
@end
