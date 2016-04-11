//
//  TimelineAnimationTests.m
//  TimelineAnimationTests
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

@import XCTest;
#import "TimelineAnimations.h"
@import UIKit;

#define weakify(var) __weak typeof(var) AHKWeak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
_Pragma("clang diagnostic pop")

@interface TimelineAnimationTests : XCTestCase
@property (nonatomic, strong) TimelineAnimation *timeline;
@property (nonatomic, strong) UIView *view;
@end

@implementation TimelineAnimationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    _timeline = [[TimelineAnimation alloc] init];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
    [_timeline clear];
    _timeline = nil;
}


#pragma mark - Tests

- (void)testCreation {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
    XCTAssertNotNil(_timeline);
    XCTAssertNil(_timeline.onStart);
    XCTAssertNil(_timeline.onUpdate);
    XCTAssertNil(_timeline.completion);
}

- (void)testBlocks {
    _timeline.completion = ^(BOOL res) {

    };
    XCTAssertNotNil(_timeline.completion);
    _timeline.onUpdate = ^{

    };
    XCTAssertNotNil(_timeline.onUpdate);
    _timeline.onStart = ^{

    };
    XCTAssertNotNil(_timeline.onStart);
}

//- (void)testPerformanceExample {
//    // This is an example of a performance test case.
//    [self measureBlock:^{
//        // Put the code you want to measure the time of here.
//    }];
//}

@end
