//
//  STModel.h
//  HitProject
//
//  Created by 郭龙 on 16/5/11.
//  Copyright © 2016年 郭龙. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STModel : NSObject

@property (nonatomic) int moedleId ;
@property (nonatomic) float modelAngel ;
@property (nonatomic) float modelX ;
@property (nonatomic) float modelY ;
@property (nonatomic) float modelZ ;

+ (STModel *)stmodelWithString:(NSString *)string ;

@end