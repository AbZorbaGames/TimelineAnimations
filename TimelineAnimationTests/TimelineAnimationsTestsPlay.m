//
//  TimelineAnimationsTestsPlay.m
//  TimelineAnimations
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

@interface TimelineAnimationsTestsPlay : XCTestCase
@property (nonatomic, strong) TimelineAnimation *timeline;
@property (nonatomic, strong) UIView *view;
@end

@implementation TimelineAnimationsTestsPlay

- (void)setUp {
    [super setUp];
    _timeline = [[TimelineAnimation alloc] init];
    _view = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)tearDown {
    [super tearDown];
    [_timeline clear];
    _timeline = nil;
    _view = nil;
}

- (void)testPlayEmpty {
    weakify(self);
    _timeline.onStart = ^{
        strongify(self);
        XCTAssert(true);
    };
    _timeline.completion = ^(BOOL res) {
        strongify(self);
        XCTAssertFalse(res);
    };
    [_timeline play];
}

@end
