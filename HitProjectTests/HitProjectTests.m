//
//  HitProjectTests.m
//  HitProjectTests
//
//  Created by 郭龙 on 15/10/29.
//  Copyright (c) 2015年 郭龙. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "StarGazerProtocol.h"

@interface HitProjectTests : XCTestCase{
    StarGazerProtocol *stPro;
}

@end

@implementation HitProjectTests

- (void)setUp {
    [super setUp];
    stPro = [StarGazerProtocol sharedStarGazerProtocol];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)test1StarGazer{
    
}

- (void)testExample {
    // This is an example of a functional test case.
    
    NSString *st = [stPro composeDownLoadStringOfMode:StarGazerModeControl data:@"abcdef"];
    
    XCTAssert(@"1234", @"st.... : %@", st);// if expression is false, will out put to console
    XCTAssertNotNil(st, @"st is nil");
    XCTAssert(YES, @"Pass");
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
