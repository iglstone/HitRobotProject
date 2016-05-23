//
//  SenderMessage.h
//  HitProject
//
//  Created by 郭龙 on 15/11/6.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface HitControl : NSObject

@property (nonatomic, strong) ServerSocket *server;

+ (instancetype) sharedControl;

- (void)startListen ;

- (void)stopAll ;

- (void)stopListen ;

- (void)sendCheckSigalWithSocket:(AsyncSocket *)sock ;

- (void)mealMode ;

- (void)controlMode ;

- (void)forward ;

- (void)backward ;

- (void)turnLeft ;

- (void)turnRight ;

- (void)stopMove;

- (void)voiceUp ;

- (void)voiceDown ;

- (void)speed:(NSInteger)dang ;

- (void)singSong:(NSInteger)numeber ;

- (void)deskNumber:(NSInteger)numeber ;

- (void)deskNumber:(NSInteger)numeber turn:(int)turn;

- (void)cancelSendMeal ;

- (void)backToOrigin ;

- (void)loopRun ;

- (void)songMode:(NSInteger)numeber ;

- (void)stopSingSong ;

//参数是转换过来的实际坐标
- (void) sendTouchPointToRobot: (CGPoint) touchPoint ;

//path route
- (void) sendPathToRobot:(NSInteger)index ofRealPosition:(NSArray *)positionArr ofDeskNum:(NSArray *)deskArr ;

@end
