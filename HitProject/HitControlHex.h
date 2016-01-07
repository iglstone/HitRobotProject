//
//  HitControlHex.h
//  HitProject
//
//  Created by 郭龙 on 16/1/7.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HitControlHex : NSObject

@property (nonatomic, strong) ServerSocket *server;

+ (instancetype) sharedControl;

- (void)startListen ;

- (void)stopAll ;

- (void)stopListen ;

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

- (void)cancelSendMeal ;

- (void)backToOrigin ;

- (void)loopRun ;

- (void)songMode:(NSInteger)numeber ;

- (void)stopSingSong ;

//新加的几个
- (void)queryMessageAll ;

- (void)queryMessagePower ;

- (void)queryMessageVoice ;

- (void)queryMessageSpeed ;



@end

