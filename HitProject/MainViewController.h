//
//  MainViewController.h
//  HitProject
//
//  Created by 郭龙 on 15/11/9.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ServerSocket.h"

@interface MainViewController : UITabBarController {
    ServerSocket *server;
}

@property (nonatomic, strong) UIView *views;
@property (nonatomic, strong) UILabel *m_debugLabel;
@property (nonatomic, strong) NSMutableArray *m_selecedModelsArray;
@property (nonatomic, strong) NSMutableArray *m_modelsArray;

@property (assign) NSInteger tmpTest;
@property (copy, nonatomic) NSString *tmpTest1;
@property (strong, nonatomic) NSString *tmpTest2;

//red blue both
//@property (nonatomic, strong) NSString *selectedNames;

//mode :0 send
//mode :1 recv
- (void)setDebugLabelText:(NSString *)string mode:(int)mode;
@end
