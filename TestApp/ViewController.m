//
//  ViewController.m
//  TestApp
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

#import "ViewController.h"
#import "TimelineAnimations.h"
@import UIKit;

#define weakify(var) __weak typeof(var) AHKWeak_##var = var;

#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = AHKWeak_##var; \
_Pragma("clang diagnostic pop")

#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

#define PerformTest(sel) \
{ \
[self setUp]; \
SuppressPerformSelectorLeakWarning([self performSelector:sel]); \
}

#define diameter 100
#define testsDelay 1

@interface ViewController ()
@property (nonatomic, strong) TimelineAnimation *timeline;
@property (nonatomic, strong) TimelineAnimation *tl1;
@property (nonatomic, strong) TimelineAnimation *tl2;
@property (nonatomic, strong) TimelineAnimation *tl3;
@property (nonatomic, strong) UIView *testView;
@property (nonatomic, strong) UIView *tv1;
@property (nonatomic, strong) UIView *tv2;
@property (nonatomic, strong) UIView *tv3;
@property (nonatomic, strong) NSMutableArray<NSString *> *tests;
@property (nonatomic, strong) GroupTimelineAnimation *groupTimeline;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tests = [NSMutableArray arrayWithObjects:
//              NSStringFromSelector(@selector(testEmpty)),
//              NSStringFromSelector(@selector(testPlay)),
//              NSStringFromSelector(@selector(testPause)),
//              NSStringFromSelector(@selector(testUpdate)),
//              NSStringFromSelector(@selector(testGroupPlay)),
//              NSStringFromSelector(@selector(testGroupPause)),
//              NSStringFromSelector(@selector(testGroupInsert)),
//              NSStringFromSelector(@selector(testSetModelValues)),
//              NSStringFromSelector(@selector(testSpeed)),
//              NSStringFromSelector(@selector(testReset)),
//              NSStringFromSelector(@selector(testReset2)),
//              NSStringFromSelector(@selector(testRepeatCount)),
//              NSStringFromSelector(@selector(testRepeatCountStop)),
//              NSStringFromSelector(@selector(testRepeatCountStopInfinity)),
//              NSStringFromSelector(@selector(testGroupRepeatCount)),
//              NSStringFromSelector(@selector(testGroupRepeatInfinityCount)),
//              NSStringFromSelector(@selector(testGroupRepeatReplayCount)),
//              NSStringFromSelector(@selector(testReverseSimple)),
//              NSStringFromSelector(@selector(testReverseLessSimple)),
//              NSStringFromSelector(@selector(testReverseGroup)),
//              NSStringFromSelector(@selector(testReverseGroupRepeatCount)),
//              NSStringFromSelector(@selector(testGroupComposition)),
              NSStringFromSelector(@selector(testGroupCompositionWithReverse)),

              nil];
    [self performNextTest];
}

- (void)performNextTest {
    NSString *string = _tests.firstObject;
    if (string) {
        [_tests removeObjectAtIndex:0];
        SEL sel = NSSelectorFromString(string);
        PerformTest(sel)
    }
}


#pragma mark - set up/tear down

- (UIView *)roundedView {
    UIView *testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, diameter, diameter)];
    testView.backgroundColor    = [UIColor redColor];
    testView.layer.cornerRadius = diameter * .5;
    testView.layer.borderWidth  = 4;
    testView.layer.borderColor  = [UIColor blackColor].CGColor;
    testView.layer.anchorPoint  = CGPointZero;
    testView.layer.position     = CGPointZero;
    return testView;
}

- (void)setUp {
    _timeline = [[TimelineAnimation alloc] init];
    _groupTimeline = [[GroupTimelineAnimation alloc] init];
    _testView = [self roundedView];
    [self.view addSubview:_testView];
}

- (void)tearDown {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(testsDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_groupTimeline clear];
        [_timeline clear];
        [_tl1 clear];
        [_tl2 clear];
        [_tl3 clear];

        [_testView removeFromSuperview];
        [_tv1 removeFromSuperview];
        [_tv2 removeFromSuperview];
        [_tv3 removeFromSuperview];

        _groupTimeline = nil;
        _timeline      = _tl1 = _tl2 = _tl3 = nil;
        _testView      = _tv1 = _tv2 = _tv3 = nil;

        [self performNextTest];
    });
}

#pragma mark - TimelineAnimation Tests

- (void)testEmpty {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self)
    _timeline.completion = ^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
        [self tearDown];
    };

    [_timeline play];
}

- (void)testPlay {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    CABasicAnimation *ba = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionY
                                                         toValue:@(CGRectGetHeight(self.view.bounds)-diameter)
                                                        duration:1
                                                  timingFunction:(ECustomTimingFunctionLinear)];
    _timeline.setsModelValues = YES;
    weakify(self)
    _timeline.completion = ^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
        [self tearDown];
    };
    _timeline.onStart = ^{
        strongify(self)
        NSAssert(true, @"");
    };
    [_timeline insertAnimation:ba
                      forLayer:_testView.layer
                        atTime:1
                    onComplete:nil];
    [_timeline play];
}

- (void)testPause {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    CABasicAnimation *ba = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionY
                                                         toValue:@(CGRectGetHeight(self.view.bounds)-diameter)
                                                        duration:3
                                                  timingFunction:(ECustomTimingFunctionLinear)];
    _timeline.setsModelValues = YES;
    weakify(self)
    _timeline.completion = ^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
        [self tearDown];
    };
    _timeline.onStart = ^{
        strongify(self)
        NSAssert(true, @"");
    };
    [_timeline insertAnimation:ba
                      forLayer:_testView.layer
                        atTime:.5
                    onComplete:nil];
    [_timeline play];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_timeline pause];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_timeline play];
        });
    });
}

- (void)testUpdate {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self)
    _timeline.completion = ^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
        [self tearDown];
    };


    CABasicAnimation *move = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionY
                                                           toValue:@(255)
                                                          duration:2.08
                                                    timingFunction:(ECustomTimingFunctionLinear)];
    _timeline.setsModelValues = YES;
    [_timeline insertAnimation:move
                      forLayer:_testView.layer
                        atTime:0
                    onComplete:nil];

    __block UIColor *red = [UIColor redColor];
    __block NSUInteger i = 0;
    _timeline.onUpdate = ^{
        strongify(self)
        NSAssert(true, @"");
        red = [red colorWithAlphaComponent:(double)(128-++i)/128.0];
        self.testView.layer.backgroundColor = red.CGColor;
    };

    [_timeline play];
}

#pragma mark - GroupTimelineAnimation tests

- (void)testGroupPlay {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self)
    _testView.layer.opacity = .5;
    _testView.layer.position = CGPointMake(0, CGRectGetMidY(self.view.bounds));

    CABasicAnimation *opacity = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathOpacity
                                                            fromValue:@1
                                                              toValue:nil
                                                             duration:.5
                                                       timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *yTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionY
                                                               fromValue:@0
                                                                 toValue:nil
                                                                duration:.25
                                                          timingFunction:(ECustomTimingFunctionLinear)];

    opacity.fillMode =
    yTranslate.fillMode = kCAFillModeBackwards;

    // opacity and y translation
    _tl1 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL res) {
        strongify(self)
        NSLog(@"tl1 completed");
        NSAssert(true, @"");
    }];
    _tl1.onStart = ^{
        strongify(self)
        NSLog(@"tl1 started");
        NSAssert(true, @"");
    };
    [_tl1 insertAnimation:opacity
                 forLayer:_testView.layer
                   atTime:0
                  onStart:^{
                      NSLog(@"tl1___1 started");
                  }
               onComplete:^(BOOL result) {
                   NSLog(@"tl1___1 comlpeted");
               }];
    [_tl1 insertAnimation:yTranslate
                 forLayer:_testView.layer
                   atTime:.25
                  onStart:^{
                      NSLog(@"tl1___2 started");
                  }
               onComplete:^(BOOL result) {
                   NSLog(@"tl1___2 completed");
               }];
    _tl1.name = @"1 yTranslate + opacity";

    CABasicAnimation *scaleX = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathScaleX
                                                           fromValue:@1
                                                             toValue:nil
                                                            duration:.5
                                                      timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *xTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionX
                                                               fromValue:@0
                                                                 toValue:nil
                                                                duration:.5
                                                          timingFunction:(ECustomTimingFunctionLinear)];
    scaleX.fillMode = kCAFillModeBackwards;
    xTranslate.fillMode = kCAFillModeBackwards;

    // x-scale and x translation
    _tl2 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self)
        NSLog(@"tl2 completed");
        NSAssert(true, @"");
    }];

    _tl2.onStart = ^{
        strongify(self)
        NSLog(@"tl2 started");
        self.testView.layer.transform = CATransform3DMakeScale(1.5, 1, 1);
        self.testView.layer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    };

    [_tl2 insertAnimation:xTranslate
                 forLayer:_testView.layer
                   atTime:0
                  onStart:^{
                      NSLog(@"tl2___1 started");
                  }
               onComplete:^(BOOL result) {
                   NSLog(@"tl2___1 completed");
               }];
    [_tl2 insertAnimation:scaleX
                 forLayer:_testView.layer
                   atTime:0.25
                  onStart:^{
                      NSLog(@"tl2___2 started");
                  }
               onComplete:^(BOOL result) {
                   NSLog(@"tl2___2 completed");
               }];
    _tl2.name = @"2 xTranslate + scaleX";


    CABasicAnimation *pos = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPosition
                                                        fromValue:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))]
                                                          toValue:nil
                                                         duration:1
                                                   timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *unscaleX = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathScaleX
                                                             fromValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1, 1)]
                                                               toValue:nil
                                                              duration:1
                                                        timingFunction:(ECustomTimingFunctionLinear)];



    // reset to initial
    _tl3 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self)
        NSLog(@"tl3 completed");
        NSAssert(true, @"");
    }];

    _tl3.onStart = ^{
        strongify(self)
        NSLog(@"tl3 started");
        self.testView.layer.position = CGPointZero;
    };

    [_tl3 insertAnimation:pos
                 forLayer:_testView.layer
                   atTime:0
                  onStart:^{
                      NSLog(@"tl3___1 started");
                  }
               onComplete:^(BOOL result) {
                   NSLog(@"tl3___1 completed");
               }];

    [_tl3 addAnimation:unscaleX
              forLayer:_testView.layer
             withDelay:1
               onStart:^{
                   strongify(self)
                   NSLog(@"tl3___2 started");
                   self.testView.layer.transform = CATransform3DIdentity;
               } onComplete:^(BOOL result) {
                   NSLog(@"tl3___2 completed");
               }];
    _tl3.name = @"3 reset position + reset scale";



    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline addTimelineAnimation:_tl2 withDelay:1];
    [_groupTimeline addTimelineAnimation:_tl3 withDelay:1];
    _groupTimeline.onStart = ^{
        strongify(self)
        NSAssert(true, @"");
        NSLog(@"group started");
    };
    _groupTimeline.completion = ^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
        NSLog(@"group completed");
        [self tearDown];
    };
    NSAssert([_groupTimeline containsTimelineAnimation:_tl1], @"error");
    [_groupTimeline play];
}

- (void)testGroupPause {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self)
    _testView.layer.opacity = .5;
    _testView.layer.position = CGPointMake(0, CGRectGetMidY(self.view.bounds));

    CABasicAnimation *opacity = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathOpacity
                                                            fromValue:@1
                                                              toValue:nil
                                                             duration:.5
                                                       timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *yTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionY
                                                               fromValue:@0
                                                                 toValue:nil
                                                                duration:.5
                                                          timingFunction:(ECustomTimingFunctionLinear)];

    opacity.fillMode =
    yTranslate.fillMode = kCAFillModeBackwards;

    // opacity and y translation
    _tl1 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
    }];
    [_tl1 insertAnimation:opacity
                 forLayer:_testView.layer
                   atTime:0
               onComplete:nil];
    [_tl1 insertAnimation:yTranslate
                 forLayer:_testView.layer
                   atTime:0
               onComplete:nil];
    _tl1.name = @"opacity + yTranslate";


    CABasicAnimation *opacityFull = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathOpacity
                                                                fromValue:@.5
                                                                  toValue:nil
                                                                 duration:.5
                                                           timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *scaleX = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathScaleX
                                                           fromValue:@1
                                                             toValue:nil
                                                            duration:.5
                                                      timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *xTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionX
                                                               fromValue:@0
                                                                 toValue:nil
                                                                duration:.5
                                                          timingFunction:(ECustomTimingFunctionLinear)];
    opacityFull.fillMode = kCAFillModeBackwards;
    scaleX.fillMode = kCAFillModeBackwards;
    xTranslate.fillMode = kCAFillModeBackwards;

    // x-scale and x translation
    _tl2 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self)
        NSAssert(true, @"");
    }];

    _tl2.onStart = ^{
        strongify(self)
        self.testView.layer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    };

    [_tl2 insertAnimation:xTranslate
                 forLayer:_testView.layer
                   atTime:0
               onComplete:nil];
    [_tl2 insertAnimation:scaleX
                 forLayer:_testView.layer
                   atTime:.5
                  onStart:^{
                      self.testView.layer.transform = CATransform3DMakeScale(1.5, 1, 1);
                  }
               onComplete:nil];
    _tl2.name = @"xTranslate + scaleX";


    CABasicAnimation *pos = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPosition
                                                        fromValue:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))]
                                                          toValue:nil
                                                         duration:1
                                                   timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *unscaleX = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathScaleX
                                                             fromValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1, 1)]
                                                               toValue:nil
                                                              duration:1
                                                        timingFunction:(ECustomTimingFunctionLinear)];


    // reset to initial
    _tl3 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self)
        NSAssert(true, @"");
    }];

    _tl3.onStart = ^{
        strongify(self)
        self.testView.layer.position = CGPointZero;
    };

    [_tl3 insertAnimation:pos
                 forLayer:_testView.layer
                   atTime:0
               onComplete:nil];

    [_tl3 addAnimation:unscaleX
              forLayer:_testView.layer
             withDelay:1
               onStart:^{
                   strongify(self)
                   self.testView.layer.transform = CATransform3DIdentity;
               } onComplete:nil];
    [_tl3 insertAnimation:opacityFull
                 forLayer:_testView.layer
                   atTime:2
                  onStart:^{
                      strongify(self);
                      self.testView.layer.opacity = 1;
                  } onComplete:nil];
    _tl3.name = @"reset position + scaleX + opacity";


    _groupTimeline.name = @"group tl name";
    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline addTimelineAnimation:_tl2];
    [_groupTimeline addTimelineAnimation:_tl3];
    _groupTimeline.completion = ^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
        [self tearDown];
    };
    NSAssert([_groupTimeline containsTimelineAnimation:_tl1]==YES, @"error");
    [_groupTimeline play];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [_groupTimeline pause];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_groupTimeline resume];
        });
    });
}

- (void)testGroupInsert {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self)
    _testView.layer.opacity = .5;
    _testView.layer.position = CGPointMake(0, CGRectGetMidY(self.view.bounds));

    CABasicAnimation *opacity = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathOpacity
                                                            fromValue:@1
                                                              toValue:nil
                                                             duration:.5
                                                       timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *yTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionY
                                                               fromValue:@0
                                                                 toValue:nil
                                                                duration:.5
                                                          timingFunction:(ECustomTimingFunctionLinear)];

    opacity.fillMode =
    yTranslate.fillMode = kCAFillModeBackwards;

    // opacity and y translation
    _tl1 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
    }];
    [_tl1 insertAnimation:opacity
                 forLayer:_testView.layer
                   atTime:0
               onComplete:nil];
    [_tl1 insertAnimation:yTranslate
                 forLayer:_testView.layer
                   atTime:0
               onComplete:nil];


    // reset to initial
    _tl3 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self)
        NSAssert(true, @"");
    }];


    CABasicAnimation *opacityFull = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathOpacity
                                                                fromValue:@.5
                                                                  toValue:nil
                                                                 duration:.5
                                                           timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *scaleX = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathScaleX
                                                           fromValue:@1
                                                             toValue:nil
                                                            duration:.5
                                                      timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *xTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionX
                                                               fromValue:@0
                                                                 toValue:nil
                                                                duration:.5
                                                          timingFunction:(ECustomTimingFunctionLinear)];
    opacityFull.fillMode = kCAFillModeBackwards;
    scaleX.fillMode = kCAFillModeBackwards;
    xTranslate.fillMode = kCAFillModeBackwards;

    // x-scale and x translation
    _tl2 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self)
        NSAssert(true, @"");
    }];

    _tl2.onStart = ^{
        strongify(self)
        self.testView.layer.transform = CATransform3DMakeScale(1.5, 1, 1);
        self.testView.layer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    };

    [_tl2 insertAnimation:xTranslate
                 forLayer:_testView.layer
                   atTime:0
               onComplete:nil];
    [_tl2 insertAnimation:scaleX
                 forLayer:_testView.layer
                   atTime:0
               onComplete:nil];


    CABasicAnimation *pos = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPosition
                                                        fromValue:[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds))]
                                                          toValue:nil
                                                         duration:.5
                                                   timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *unscaleX = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathScaleX
                                                             fromValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1, 1)]
                                                               toValue:nil
                                                              duration:.5
                                                        timingFunction:(ECustomTimingFunctionLinear)];

    _tl3.onStart = ^{
        strongify(self)
        self.testView.layer.position = CGPointZero;
    };

    [_tl3 insertAnimation:pos
                 forLayer:_testView.layer
                   atTime:0
               onComplete:nil];

    [_tl3 addAnimation:unscaleX
              forLayer:_testView.layer
             withDelay:1
               onStart:^{
                   strongify(self)
                   self.testView.layer.transform = CATransform3DIdentity;
               } onComplete:nil];


    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline insertTimelineAnimation:_tl2
                                     atTime:2];
    [_groupTimeline insertTimelineAnimation:_tl3
                                     atTime:1];
    _groupTimeline.completion = ^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
        [self tearDown];
    };
    NSAssert([_groupTimeline containsTimelineAnimation:_tl1], @"error");
    [_groupTimeline play];
}

- (void)testSetModelValues {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    CABasicAnimation *ba = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionY
                                                       fromValue:@100
                                                         toValue:@(CGRectGetHeight(self.view.bounds)-diameter)
                                                        duration:1
                                                  timingFunction:(ECustomTimingFunctionLinear)];


    _timeline.setsModelValues = YES;
    weakify(self)
    _timeline.completion = ^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
        [self.testView.layer removeAllAnimations];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self tearDown];
        });
    };
    _timeline.onStart = ^{
        strongify(self)
        NSAssert(true, @"");
    };
    [_timeline insertAnimation:ba
                      forLayer:_testView.layer
                        atTime:1
                    onComplete:nil];
    [_timeline play];
}

- (void)testSpeed {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    _testView.hidden = YES;
    _tv1 = [self roundedView];
    _tv2 = [self roundedView];
    _tv3 = [self roundedView];
    _tv2.backgroundColor = [UIColor greenColor];
    _tv3.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_tv1];
    [self.view addSubview:_tv2];
    [self.view addSubview:_tv3];
    _tv2.layer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    _tv3.layer.position = CGPointMake(CGRectGetMaxX(self.view.bounds), CGRectGetMidY(self.view.bounds));

    weakify(self)
    _tv1.layer.opacity = .5;
    _tv1.layer.position = CGPointMake(0, CGRectGetMidY(self.view.bounds));

    CABasicAnimation *opacity = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathOpacity
                                                            fromValue:@1
                                                              toValue:nil
                                                             duration:.5
                                                       timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *yTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionY
                                                               fromValue:@0
                                                                 toValue:nil
                                                                duration:.5
                                                          timingFunction:(ECustomTimingFunctionLinear)];

    opacity.fillMode =
    yTranslate.fillMode = kCAFillModeBackwards;

    // opacity and y translation
    _tl1 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL res) {
        strongify(self)
        NSLog(@"tl1 completed");
        NSAssert(true, @"");
    }];
    _tl1.onStart = ^{
        strongify(self)
        NSLog(@"tl1 started");
        NSAssert(true, @"");
    };
    _tl1.speed = .5;
    [_tl1 insertAnimation:opacity
                 forLayer:_tv1.layer
                   atTime:0
                  onStart:^{
                      NSLog(@"tl1___1 started");
                  }
               onComplete:nil];
    [_tl1 insertAnimation:yTranslate
                 forLayer:_tv1.layer
                   atTime:0
                  onStart:^{
                      NSLog(@"tl1___2 started");
                  }
               onComplete:nil];


    CABasicAnimation *scaleX = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathScaleX
                                                           fromValue:@1
                                                             toValue:nil
                                                            duration:.5
                                                      timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *xTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionX
                                                               fromValue:@0
                                                                 toValue:nil
                                                                duration:.5
                                                          timingFunction:(ECustomTimingFunctionLinear)];
    scaleX.fillMode = kCAFillModeBackwards;
    xTranslate.fillMode = kCAFillModeBackwards;

    // x-scale and x translation
    _tl2 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self)
        NSLog(@"tl2 completed");
        NSAssert(true, @"");
    }];

    _tl2.onStart = ^{
        strongify(self)
        NSLog(@"tl2 started");
        self.testView.layer.transform = CATransform3DMakeScale(1.5, 1, 1);
        self.testView.layer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    };

    [_tl2 insertAnimation:xTranslate
                 forLayer:_tv2.layer
                   atTime:0
                  onStart:^{
                      NSLog(@"tl2___2 started");
                  }
               onComplete:nil];
    [_tl2 insertAnimation:scaleX
                 forLayer:_tv2.layer
                   atTime:0
                  onStart:^{
                      NSLog(@"tl2___3 started");
                  }
               onComplete:nil];


    NSValue *finalPosition = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds)-diameter,
                                                                   CGRectGetMidY(self.view.bounds))];
    CABasicAnimation *pos = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPosition
                                                        fromValue:finalPosition
                                                          toValue:nil
                                                         duration:1
                                                   timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *unscaleX = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathScaleX
                                                             fromValue:[NSValue valueWithCATransform3D:CATransform3DMakeScale(1.5, 1, 1)]
                                                               toValue:nil
                                                              duration:1
                                                        timingFunction:(ECustomTimingFunctionLinear)];



    _tv3.layer.transform = CATransform3DMakeScale(1.5, 1, 1);
    // reset to initial
    _tl3 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self)
        NSLog(@"tl3 completed");
        NSAssert(true, @"");
    }];

    _tl3.onStart = ^{
        strongify(self)
        NSLog(@"tl3 started");
        self.tv3.layer.position = CGPointZero;
    };

    [_tl3 insertAnimation:pos
                 forLayer:_tv3.layer
                   atTime:0
                  onStart:^{
                      NSLog(@"tl3___1 started");
                  }
               onComplete:nil];

    [_tl3 addAnimation:unscaleX
              forLayer:_tv3.layer
             withDelay:1
               onStart:^{
                   strongify(self)
                   NSLog(@"tl3___2 started");
                   self.tv3.layer.transform = CATransform3DIdentity;
               } onComplete:nil];


    _tl3.speed = 3;
    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline addTimelineAnimation:_tl2];
    [_groupTimeline addTimelineAnimation:_tl3 withDelay:1];
    _groupTimeline.onStart = ^{
        strongify(self)
        NSAssert(true, @"");
        NSLog(@"group started");
    };
    _groupTimeline.completion = ^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
        NSLog(@"group completed");
        [self tearDown];
    };
    NSAssert([_groupTimeline containsTimelineAnimation:_tl1], @"error");

    _groupTimeline.speed = .5;
    [_groupTimeline play];
}

#pragma mark - Reset/Replay tests

- (void)testReset {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    CABasicAnimation *ba = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionY
                                                         toValue:@(CGRectGetHeight(self.view.bounds)-diameter)
                                                        duration:1
                                                  timingFunction:(ECustomTimingFunctionLinear)];
    _timeline.setsModelValues = YES;
    weakify(self)
    _timeline.completion = ^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
        weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            strongify(self)
            weakify(self)
            self.timeline.completion = ^(BOOL res) {
                strongify(self);
                [self tearDown];
            };
            [self.timeline replay];
        });
    };
    _timeline.onStart = ^{
        strongify(self)
        NSAssert(true, @"");
    };
    [_timeline insertAnimation:ba
                      forLayer:_testView.layer
                        atTime:1
                    onComplete:nil];
    [_timeline play];
}

- (void)testReset2 {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    _testView.hidden = YES;
    _tv1 = [self roundedView];
    _tv2 = [self roundedView];
    _tv3 = [self roundedView];
    _tv2.backgroundColor = [UIColor greenColor];
    _tv3.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_tv1];
    [self.view addSubview:_tv2];
    [self.view addSubview:_tv3];
    _tv2.layer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    _tv3.layer.position = CGPointMake(CGRectGetMaxX(self.view.bounds)-diameter, CGRectGetMidY(self.view.bounds));

    weakify(self)
    _tv1.layer.opacity = .5;
    _tv1.layer.position = CGPointMake(0, CGRectGetMidY(self.view.bounds));

    CABasicAnimation *opacity = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathOpacity
                                                            fromValue:@1
                                                              toValue:nil
                                                             duration:.5
                                                       timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *yTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionY
                                                               fromValue:@0
                                                                 toValue:nil
                                                                duration:.5
                                                          timingFunction:(ECustomTimingFunctionLinear)];

    opacity.fillMode =
    yTranslate.fillMode = kCAFillModeBackwards;

    // opacity and y translation
    _tl1 = [TimelineAnimation timelineAnimation];
    _tl1.speed = .5;
    [_tl1 insertAnimation:opacity
                 forLayer:_tv1.layer
                   atTime:0
               onComplete:nil];
    [_tl1 insertAnimation:yTranslate
                 forLayer:_tv1.layer
                   atTime:0
               onComplete:nil];
    _tl1.name = @"opacity + yTranslate @ speed:.5";


    CABasicAnimation *scaleX = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathScaleX
                                                           fromValue:@1
                                                             toValue:nil
                                                            duration:.5
                                                      timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *xTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionX
                                                               fromValue:@0
                                                                 toValue:nil
                                                                duration:.5
                                                          timingFunction:(ECustomTimingFunctionLinear)];
    scaleX.fillMode = kCAFillModeBackwards;
    xTranslate.fillMode = kCAFillModeBackwards;

    // x-scale and x translation
    _tl2 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self)
        NSAssert(true, @"");
    }];

    _tl2.onStart = ^{
        strongify(self)
        self.tv2.layer.transform = CATransform3DMakeScale(1.5, 1, 1);
        self.tv2.layer.position = CGPointMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds));
    };

    [_tl2 insertAnimation:xTranslate
                 forLayer:_tv2.layer
                   atTime:0
               onComplete:nil];
    [_tl2 insertAnimation:scaleX
                 forLayer:_tv2.layer
                   atTime:0
               onComplete:nil];
    _tl2.name = @"xTranslate + scaleX @ speed:1";


    NSValue *finalPosition = [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds)-diameter,
                                                                   CGRectGetMidY(self.view.bounds))];
    CABasicAnimation *pos = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPosition
                                                        fromValue:finalPosition
                                                          toValue:nil
                                                         duration:1
                                                   timingFunction:(ECustomTimingFunctionLinear)];
    CABasicAnimation *unscaleX = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathScaleX
                                                             fromValue:@1.5
                                                               toValue:nil
                                                              duration:1
                                                        timingFunction:(ECustomTimingFunctionLinear)];



    _tv3.layer.transform = CATransform3DMakeScale(1.5, 1, 1);
    // reset to initial
    _tl3 = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self)
        NSAssert(true, @"");
    }];

    _tl3.onStart = ^{
        strongify(self)
        self.tv3.layer.position = CGPointMake(0, 50);
    };

    [_tl3 insertAnimation:pos
                 forLayer:_tv3.layer
                   atTime:0
               onComplete:nil];

    [_tl3 addAnimation:unscaleX
              forLayer:_tv3.layer
             withDelay:1
               onStart:^{
                   strongify(self)
                   self.tv3.layer.transform = CATransform3DIdentity;
               } onComplete:nil];
    _tl3.speed = 2;
    _tl3.name = @"pos + unscaleX @ speed:3";



    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline addTimelineAnimation:_tl2];
    [_groupTimeline addTimelineAnimation:_tl3];
    _groupTimeline.onStart = ^{
        strongify(self)
        NSAssert(true, @"");
        NSLog(@"group started");
    };

    _groupTimeline.completion = ^(BOOL res) {
        strongify(self)
        NSAssert(true, @"");
        NSLog(@"group completed");
        weakify(self)
        dispatch_async(dispatch_get_main_queue(), ^{
            strongify(self)
            weakify(self)
            self.tv1.layer.opacity = .5;
            self.tv1.layer.position = CGPointMake(0, CGRectGetMidY(self.view.bounds));
            self.groupTimeline.onStart = ^{
                strongify(self)
                NSAssert(true, @"");
                NSLog(@"group:reset started");
            };
            self.groupTimeline.completion = ^(BOOL result){
                strongify(self)
                NSLog(@"group:reset completed");
                [self tearDown];
            };

            [self.groupTimeline replay];
            self.groupTimeline.speed = 1;
            self.tv1.layer.opacity = .5;
            self.tv1.layer.position = CGPointMake(0, CGRectGetMidY(self.view.bounds));
        });
    };
    NSAssert([_groupTimeline containsTimelineAnimation:_tl1], @"error");

    _groupTimeline.speed = .5;
    [_groupTimeline play];
}

#pragma mark - Repeat tests

- (void)testRepeatCount {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self)
    _timeline = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self);
        NSLog(@"timeline completed");
        [self tearDown];
    }];
    _timeline.onStart = ^{
        NSLog(@"timeline started");
    };

    NSArray<NSValue *> *values = @[
                                   [NSValue valueWithCGPoint:CGPointZero],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - diameter)],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMaxY(self.view.bounds) - diameter)],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMinY(self.view.bounds))],
                                   [NSValue valueWithCGPoint:CGPointZero],
                                   ];
    NSArray<NSNumber *> *keyTimes = @[
                                      @0,
                                      @.25,
                                      @.5,
                                      @.75,
                                      @1];

    CAKeyframeAnimation *circleAround = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPosition
                                                                               duration:2
                                                                                 values:values
                                                                               keyTimes:keyTimes
                                                                         timingFunction:(ECustomTimingFunctionLinear)];
    [_timeline addAnimation:circleAround
                   forLayer:_testView.layer];


    _timeline.repeatCompletion = ^(BOOL result, NSUInteger iteration, BOOL *stop) {
        NSLog(@"%@_iteration: %ld", NSStringFromSelector(_cmd), iteration);
    };


    _timeline.repeatCount = 2;
    [_timeline play];
}

- (void)testRepeatCountStop {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self)
    _timeline = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self);
        NSLog(@"timeline completed");
        [self tearDown];
    }];
    _timeline.onStart = ^{
        NSLog(@"timeline started");
    };

    NSArray<NSValue *> *values = @[
                                   [NSValue valueWithCGPoint:CGPointZero],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - diameter)],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMaxY(self.view.bounds) - diameter)],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMinY(self.view.bounds))],
                                   [NSValue valueWithCGPoint:CGPointZero],
                                   ];
    NSArray<NSNumber *> *keyTimes = @[
                                      @0,
                                      @.25,
                                      @.5,
                                      @.75,
                                      @1];

    CAKeyframeAnimation *circleAround = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPosition
                                                                               duration:2
                                                                                 values:values
                                                                               keyTimes:keyTimes
                                                                         timingFunction:(ECustomTimingFunctionLinear)];
    [_timeline addAnimation:circleAround
                   forLayer:_testView.layer];


    _timeline.repeatCompletion = ^(BOOL result, NSUInteger iteration, BOOL *stop) {
        NSLog(@"%@_iteration: %ld", NSStringFromSelector(_cmd), iteration);
        if (iteration == 1)
            *stop = YES;
    };


    _timeline.repeatCount = 2;
    [_timeline play];
}


- (void)testRepeatCountStopInfinity {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self)
    _timeline = [TimelineAnimation timelineAnimationWithCompletion:^(BOOL result) {
        strongify(self);
        NSLog(@"timeline completed");
        [self tearDown];
    }];
    _timeline.onStart = ^{
        NSLog(@"timeline started");
    };

    NSArray<NSValue *> *values = @[
                                   [NSValue valueWithCGPoint:CGPointZero],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - diameter)],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMaxY(self.view.bounds) - diameter)],
                                   [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMinY(self.view.bounds))],
                                   [NSValue valueWithCGPoint:CGPointZero],
                                   ];
    NSArray<NSNumber *> *keyTimes = @[
                                      @0,
                                      @.25,
                                      @.5,
                                      @.75,
                                      @1];

    CAKeyframeAnimation *circleAround = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPosition
                                                                               duration:2
                                                                                 values:values
                                                                               keyTimes:keyTimes
                                                                         timingFunction:(ECustomTimingFunctionLinear)];
    [_timeline addAnimation:circleAround
                   forLayer:_testView.layer];


    _timeline.repeatCompletion = ^(BOOL result, NSUInteger iteration, BOOL *stop) {
        NSLog(@"%@_iteration: %ld", NSStringFromSelector(_cmd), iteration);
        if (iteration == 3)
            *stop = YES;
    };


    _timeline.repeatCount = -1;
    [_timeline play];
}


- (void)testGroupRepeatCount {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    _testView.hidden = YES;
    _tv1 = [self roundedView];
    _tv2 = [self roundedView];
    _tv3 = [self roundedView];
    _tv2.backgroundColor = [UIColor greenColor];
    _tv3.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_tv1];
    [self.view addSubview:_tv2];
    [self.view addSubview:_tv3];

    _tl1 = [TimelineAnimation timelineAnimation];
    _tl2 = [TimelineAnimation timelineAnimation];
    _tl3 = [TimelineAnimation timelineAnimation];

    NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithArray:@[
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMinY(self.view.bounds))],
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         ]];
    NSArray<NSNumber *> *keyTimes = @[
                                      @0,
                                      @.25,
                                      @.5,
                                      @.75,
                                      @1];

    CAKeyframeAnimation *circleAround = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPosition
                                                                               duration:1
                                                                                 values:values.copy
                                                                               keyTimes:keyTimes
                                                                         timingFunction:(ECustomTimingFunctionLinear)];
    _tv1.layer.position = values.firstObject.CGPointValue;
    [_tl1 addAnimation:circleAround
              forLayer:_tv1.layer];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    _tv2.layer.position = values[0].CGPointValue;


    [_tl2 addAnimation:circleAround
              forLayer:_tv2.layer];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    circleAround.values = values;
    _tv3.layer.position = values[0].CGPointValue;
    [_tl3 addAnimation:circleAround
              forLayer:_tv3.layer];

    _tl1.name = @"red";
    _tl2.name = @"green";
    _tl3.name = @"blue";

    _groupTimeline = [GroupTimelineAnimation groupTimelineAnimation];
    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline addTimelineAnimation:_tl2];
    [_groupTimeline addTimelineAnimation:_tl3];

    _groupTimeline.onStart = ^{
        NSLog(@"group started");
    };

    weakify(self);
    _groupTimeline.completion = ^(BOOL result) {
        strongify(self);
        NSLog(@"group completed");
        [self tearDown];
    };
    _groupTimeline.repeatCompletion = ^(BOOL result, NSUInteger iteration, BOOL *stop) {
        NSLog(@"%@_iteration: %ld", NSStringFromSelector(_cmd), iteration);

    };

    _groupTimeline.repeatCount = 2;
    [_groupTimeline play];
}

- (void)testGroupRepeatInfinityCount {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    _testView.hidden = YES;
    _tv1 = [self roundedView];
    _tv2 = [self roundedView];
    _tv3 = [self roundedView];
    _tv2.backgroundColor = [UIColor greenColor];
    _tv3.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_tv1];
    [self.view addSubview:_tv2];
    [self.view addSubview:_tv3];

    _tl1 = [TimelineAnimation timelineAnimation];
    _tl2 = [TimelineAnimation timelineAnimation];
    _tl3 = [TimelineAnimation timelineAnimation];

    NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithArray:@[
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMinY(self.view.bounds))],
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         ]];
    NSArray<NSNumber *> *keyTimes = @[
                                      @0,
                                      @.25,
                                      @.5,
                                      @.75,
                                      @1];

    CAKeyframeAnimation *circleAround = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPosition
                                                                               duration:1
                                                                                 values:values.copy
                                                                               keyTimes:keyTimes
                                                                         timingFunction:(ECustomTimingFunctionLinear)];
    _tv1.layer.position = values.firstObject.CGPointValue;
    [_tl1 addAnimation:circleAround
              forLayer:_tv1.layer];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    _tv2.layer.position = values[0].CGPointValue;


    [_tl2 addAnimation:circleAround
              forLayer:_tv2.layer];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    circleAround.values = values;
    _tv3.layer.position = values[0].CGPointValue;
    [_tl3 addAnimation:circleAround
              forLayer:_tv3.layer];

    _tl1.name = @"red";
    _tl2.name = @"green";
    _tl3.name = @"blue";
    
    _groupTimeline = [GroupTimelineAnimation groupTimelineAnimation];
    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline addTimelineAnimation:_tl2];
    [_groupTimeline addTimelineAnimation:_tl3];
    
    _groupTimeline.onStart = ^{
        NSLog(@"group started");
    };
    
    weakify(self);
    _groupTimeline.completion = ^(BOOL result) {
        strongify(self);
        NSLog(@"group completed");
        [self tearDown];
    };
    _groupTimeline.repeatCompletion = ^(BOOL result, NSUInteger iteration, BOOL *stop) {
        NSLog(@"%@_iteration: %ld", NSStringFromSelector(_cmd), iteration);
        if (iteration == 3)
            *stop = YES;
    };
    
    _groupTimeline.repeatCount = -1;
    [_groupTimeline play];
}

- (void)testGroupRepeatReplayCount {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    _testView.hidden = YES;
    _tv1 = [self roundedView];
    _tv2 = [self roundedView];
    _tv3 = [self roundedView];
    _tv2.backgroundColor = [UIColor greenColor];
    _tv3.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_tv1];
    [self.view addSubview:_tv2];
    [self.view addSubview:_tv3];

    _tl1 = [TimelineAnimation timelineAnimation];
    _tl2 = [TimelineAnimation timelineAnimation];
    _tl3 = [TimelineAnimation timelineAnimation];

    NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithArray:@[
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMinY(self.view.bounds))],
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         ]];
    NSArray<NSNumber *> *keyTimes = @[
                                      @0,
                                      @.25,
                                      @.5,
                                      @.75,
                                      @1];

    CAKeyframeAnimation *circleAround = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPosition
                                                                               duration:1
                                                                                 values:values.copy
                                                                               keyTimes:keyTimes
                                                                         timingFunction:(ECustomTimingFunctionLinear)];
    _tv1.layer.position = values.firstObject.CGPointValue;
    [_tl1 addAnimation:circleAround
              forLayer:_tv1.layer];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    _tv2.layer.position = values[0].CGPointValue;


    [_tl2 addAnimation:circleAround
              forLayer:_tv2.layer];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    circleAround.values = values;
    _tv3.layer.position = values[0].CGPointValue;
    [_tl3 addAnimation:circleAround
              forLayer:_tv3.layer];

    _tl1.name = @"red";
    _tl2.name = @"green";
    _tl3.name = @"blue";

    _groupTimeline = [GroupTimelineAnimation groupTimelineAnimation];
    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline addTimelineAnimation:_tl2];
    [_groupTimeline addTimelineAnimation:_tl3];

    _groupTimeline.onStart = ^{
        NSLog(@"group started");
    };

    weakify(self);
    _groupTimeline.completion = ^(BOOL result) {
        strongify(self);
        NSLog(@"group completed");
        weakify(self);
        dispatch_async(dispatch_get_main_queue(), ^{
            strongify(self);
            weakify(self);
            self.groupTimeline.completion = ^(BOOL res) {
                strongify(self);
                NSLog(@"group#replay completed");
                [self tearDown];
            };
            [self.groupTimeline replay];
        });
    };
    _groupTimeline.repeatCompletion = ^(BOOL result, NSUInteger iteration, BOOL *stop) {
        NSLog(@"%@_iteration: %ld", NSStringFromSelector(_cmd), iteration);
    };

    _groupTimeline.repeatCount = 2;
    [_groupTimeline play];
}



#pragma mark - Reverse tests

- (void)testReverseSimple {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self);

    _timeline.onStart = ^{
        NSLog(@"timeline started");
    };

    _timeline.completion = ^(BOOL result) {
        strongify(self);
        NSLog(@"timeline completed");
        TimelineAnimation *reverse = [self.timeline reversed];
        reverse.completion = ^(BOOL result) {
            NSLog(@"timeline:reversed completed");
            [self tearDown];
        };
        [reverse play];

    };

    NSNumber *midX = @(CGRectGetMidX(self.view.bounds));

    CABasicAnimation *xTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionX
                                                               fromValue:@0
                                                                 toValue:midX
                                                                duration:1
                                                          timingFunction:(ECustomTimingFunctionLinear)];
    [_timeline insertAnimation:xTranslate forLayer:_testView.layer atTime:0];
    [_testView.layer setValue:midX forKeyPath:kAnimationKeyPathPositionX];
    [_timeline play];
}

- (void)testReverseLessSimple {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self);

    _timeline.setsModelValues = YES;
    _timeline.onStart = ^{
        NSLog(@"timeline started");
    };

    _timeline.completion = ^(BOOL result) {
        strongify(self);
        NSLog(@"timeline completed");
        TimelineAnimation *reverse = [self.timeline reversed];
        reverse.completion = ^(BOOL result) {
            NSLog(@"timeline:reversed completed");
            [self tearDown];
        };
        [reverse play];

    };

    NSNumber *midX = @(CGRectGetMidX(self.view.bounds));

    CABasicAnimation *xTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionX
                                                               fromValue:@0
                                                                 toValue:midX
                                                                duration:1
                                                          timingFunction:(ECustomTimingFunctionLinear)];

    NSNumber *midY = @(CGRectGetMidY(self.view.bounds));
    CABasicAnimation *yTranslate = [AnimationsFactory animateWithKeyPath:kAnimationKeyPathPositionY
                                                               fromValue:@0
                                                                 toValue:midY
                                                                duration:1
                                                          timingFunction:(ECustomTimingFunctionLinear)];

    [_timeline insertAnimation:xTranslate forLayer:_testView.layer atTime:0];
    [_timeline addAnimation:yTranslate forLayer:_testView.layer];

    _timeline.name = @"less.simple";
    [_timeline play];
}


- (void)testReverseGroup {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    _testView.hidden = YES;
    _tv1 = [self roundedView];
    _tv2 = [self roundedView];
    _tv3 = [self roundedView];
    _tv2.backgroundColor = [UIColor greenColor];
    _tv3.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_tv1];
    [self.view addSubview:_tv2];
    [self.view addSubview:_tv3];

    _tl1 = [TimelineAnimation timelineAnimation];
    _tl2 = [TimelineAnimation timelineAnimation];
    _tl3 = [TimelineAnimation timelineAnimation];

    NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithArray:@[
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMinY(self.view.bounds))],
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         ]];
    NSArray<NSNumber *> *keyTimes = @[
                                      @0,
                                      @.25,
                                      @.5,
                                      @.75,
                                      @1];

    CAKeyframeAnimation *circleAround = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPosition
                                                                               duration:1
                                                                                 values:values.copy
                                                                               keyTimes:keyTimes
                                                                         timingFunction:(ECustomTimingFunctionLinear)];
    _tv1.layer.position = values.firstObject.CGPointValue;
    [_tl1 addAnimation:circleAround
              forLayer:_tv1.layer];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    _tv2.layer.position = values[0].CGPointValue;


    [_tl2 addAnimation:circleAround
              forLayer:_tv2.layer];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    circleAround.values = values;
    _tv3.layer.position = values[0].CGPointValue;
    [_tl3 addAnimation:circleAround
              forLayer:_tv3.layer];

    _tl1.name = @"red";
    _tl2.name = @"green";
    _tl3.name = @"blue";

    _groupTimeline = [GroupTimelineAnimation groupTimelineAnimation];
    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline addTimelineAnimation:_tl2];
    [_groupTimeline addTimelineAnimation:_tl3];

    _groupTimeline.name = @"helicopter";

    _groupTimeline.onStart = ^{
        NSLog(@"group started");
    };

    weakify(self);
    _groupTimeline.completion = ^(BOOL result) {
        strongify(self);
        NSLog(@"group completed");
        TimelineAnimation *reverse = [self.groupTimeline reversed];
        reverse.speed = 2;
        reverse.completion = ^(BOOL result) {
            NSLog(@"timeline:reversed completed");
            [self tearDown];
        };
        [reverse play];
    };

    [_groupTimeline play];
}

- (void)testReverseGroupRepeatCount {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    _testView.hidden = YES;
    _tv1 = [self roundedView];
    _tv2 = [self roundedView];
    _tv3 = [self roundedView];
    _tv2.backgroundColor = [UIColor greenColor];
    _tv3.backgroundColor = [UIColor blueColor];
    [self.view addSubview:_tv1];
    [self.view addSubview:_tv2];
    [self.view addSubview:_tv3];

    _tl1 = [TimelineAnimation timelineAnimation];
    _tl2 = [TimelineAnimation timelineAnimation];
    _tl3 = [TimelineAnimation timelineAnimation];

    NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithArray:@[
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMinY(self.view.bounds))],
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         ]];
    NSArray<NSNumber *> *keyTimes = @[
                                      @0,
                                      @.25,
                                      @.5,
                                      @.75,
                                      @1];

    CAKeyframeAnimation *circleAround = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPosition
                                                                               duration:1
                                                                                 values:values.copy
                                                                               keyTimes:keyTimes
                                                                         timingFunction:(ECustomTimingFunctionLinear)];
    _tv1.layer.position = values.firstObject.CGPointValue;
    [_tl1 addAnimation:circleAround
              forLayer:_tv1.layer];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    _tv2.layer.position = values[0].CGPointValue;


    [_tl2 addAnimation:circleAround
              forLayer:_tv2.layer];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    circleAround.values = values;
    _tv3.layer.position = values[0].CGPointValue;
    [_tl3 addAnimation:circleAround
              forLayer:_tv3.layer];

    _tl1.name = @"red";
    _tl2.name = @"green";
    _tl3.name = @"blue";

    _groupTimeline = [GroupTimelineAnimation groupTimelineAnimation];
    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline addTimelineAnimation:_tl2];
    [_groupTimeline addTimelineAnimation:_tl3];

    _groupTimeline.name = @"helicopter";

    _groupTimeline.onStart = ^{
        NSLog(@"group started");
    };

    weakify(self);
    _groupTimeline.completion = ^(BOOL result) {
        strongify(self);
        NSLog(@"group completed");
        TimelineAnimation *reverse = [self.groupTimeline reversed];
        reverse.speed = 2;
        reverse.onStart = ^{
            NSLog(@"group#reversed started");
        };
        reverse.completion = ^(BOOL result) {
            NSLog(@"group#reversed completed");
            [self tearDown];
        };
        [reverse play];
    };

    _groupTimeline.repeatCount = 1;
    [_groupTimeline play];
}

#pragma mark - Group composition 

- (void)testGroupComposition {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self);


    _testView.hidden = YES;
    _tv1 = [self roundedView];
    _tv2 = [self roundedView];
    _tv3 = [self roundedView];
    UIView *centerViewVertical   = [self roundedView];
    UIView *centerViewHorizontal = [self roundedView];
    _tv2.backgroundColor = [UIColor greenColor];
    _tv3.backgroundColor = [UIColor blueColor];
    centerViewVertical.backgroundColor   = [UIColor brownColor];
    centerViewHorizontal.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:_tv1];
    [self.view addSubview:_tv2];
    [self.view addSubview:_tv3];
    [self.view addSubview:centerViewVertical];
    [self.view addSubview:centerViewHorizontal];

    centerViewVertical.layer.position   = CGPointMake(CGRectGetMidX(self.view.bounds) - diameter, CGRectGetMidY(self.view.bounds) - diameter * 2);
    centerViewHorizontal.layer.position = CGPointMake(CGRectGetMidX(self.view.bounds) - diameter, CGRectGetMidY(self.view.bounds) + diameter);

    GroupTimelineAnimation *whole = [GroupTimelineAnimation groupTimelineAnimation];
    whole.onStart = ^{
        NSLog(@"whole.group started");
    };
    weakify(whole);
    whole.completion = ^(BOOL result) {
        strongify(whole);
        NSLog(@"whole.group completed");
        whole.completion = ^(BOOL result) {
            NSLog(@"whole.group completed");
            [centerViewVertical removeFromSuperview];
            [centerViewHorizontal removeFromSuperview];
            [self tearDown];
        };
        [whole replay];
    };

    GroupTimelineAnimation *centerViewsTimelines = [GroupTimelineAnimation groupTimelineAnimationOnStart:^{
        NSLog(@"  center.group started");
    } completion:^(BOOL result) {
        NSLog(@"  center.group completed");
    }];
    TimelineAnimation *centerTimelineVertical = [TimelineAnimation timelineAnimationOnStart:^{
        NSLog(@"    center.group.vertical started");
    } completion:^(BOOL result) {
        NSLog(@"    center.group.vertical completed");
    }];
    TimelineAnimation *centerTimelineHorizontal = [TimelineAnimation timelineAnimationOnStart:^{
        NSLog(@"    center.group.horizontal started");
    } completion:^(BOOL result) {
        NSLog(@"    center.group.horizontal started");
    }];

    _tl1 = [TimelineAnimation timelineAnimationOnStart:^{
        NSLog(@"    clockwise.group.red started");
    } completion:^(BOOL result) {
        NSLog(@"    clockwise.group.red completed");
    }];
    _tl2 = [TimelineAnimation timelineAnimationOnStart:^{
        NSLog(@"    clockwise.group.green started");
    } completion:^(BOOL result) {
        NSLog(@"    clockwise.group.green completed");
    }];
    _tl3 = [TimelineAnimation timelineAnimationOnStart:^{
        NSLog(@"    clockwise.group.blue started");
    } completion:^(BOOL result) {
        NSLog(@"    clockwise.group.bleu completed");
    }];

    NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithArray:@[
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMinY(self.view.bounds))],
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         ]];
    NSArray<NSNumber *> *keyTimes = @[
                                      @0,
                                      @.25,
                                      @.5,
                                      @.75,
                                      @1];

    CAKeyframeAnimation *circleAround = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPosition
                                                                               duration:1
                                                                                 values:values.copy
                                                                               keyTimes:keyTimes
                                                                         timingFunction:(ECustomTimingFunctionLinear)];
    _tv1.layer.position = values.firstObject.CGPointValue;
    [_tl1 addAnimation:circleAround
              forLayer:_tv1.layer
               onStart:^{
                   strongify(self);
                   NSLog(@"      %@_1 started", self.tl1.name);
               } onComplete:^(BOOL result) {
                   strongify(self);
                   NSLog(@"      %@_1 completed", self.tl1.name);
               }];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    _tv2.layer.position = values[0].CGPointValue;


    [_tl2 addAnimation:circleAround
              forLayer:_tv2.layer
               onStart:^{
                   strongify(self);
                   NSLog(@"      %@_1 started", self.tl2.name);
               } onComplete:^(BOOL result) {
                   strongify(self);
                   NSLog(@"      %@_1 completed", self.tl2.name);
               }];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    circleAround.values = values;
    _tv3.layer.position = values[0].CGPointValue;
    [_tl3 addAnimation:circleAround
              forLayer:_tv3.layer
               onStart:^{
                   strongify(self);
                   NSLog(@"      %@_1 started", self.tl3.name);
               } onComplete:^(BOOL result) {
                   strongify(self);
                   NSLog(@"      %@_1 completed", self.tl3.name);
               }];

    _tl1.name = @"clockwise.group.red";
    _tl2.name = @"clockwise.group.green";
    _tl3.name = @"clockwise.group.blue";
    centerTimelineHorizontal.name = @"center.group.horizontal";
    centerTimelineVertical.name   = @"center.group.vertical";

    _groupTimeline = [GroupTimelineAnimation groupTimelineAnimation];
    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline addTimelineAnimation:_tl2];
    [_groupTimeline addTimelineAnimation:_tl3];

    _groupTimeline.onStart = ^{
        NSLog(@"  clockwise.group started");
    };

    _groupTimeline.completion = ^(BOOL result) {
        NSLog(@"  clockwise.group completed");
    };

    CAKeyframeAnimation *verticalOscillation = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPositionY
                                                                                      duration:1
                                                                                        values:@[
                                                                                                 @(CGRectGetMidY(self.view.bounds) - diameter * 2),
                                                                                                 @(CGRectGetMidY(self.view.bounds)),
                                                                                                 @(CGRectGetMidY(self.view.bounds) - diameter * 2)
                                                                                                 ]
                                                                                      keyTimes:@[
                                                                                                 @0,
                                                                                                 @.5,
                                                                                                 @1
                                                                                                 ]
                                                                                timingFunction:(ECustomTimingFunctionLinear)];
    CAKeyframeAnimation *horizontalOscillation = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPositionX
                                                                                        duration:1
                                                                                          values:@[
                                                                                                   @(CGRectGetMidX(self.view.bounds) - diameter),
                                                                                                   @(CGRectGetMidX(self.view.bounds)),
                                                                                                   @(CGRectGetMidX(self.view.bounds) - diameter)
                                                                                                   ]
                                                                                        keyTimes:@[
                                                                                                   @0,
                                                                                                   @.5,
                                                                                                   @1
                                                                                                   ]
                                                                                  timingFunction:(ECustomTimingFunctionLinear)];

    [centerTimelineHorizontal insertAnimation:horizontalOscillation
                                     forLayer:centerViewHorizontal.layer
                                       atTime:0
                                      onStart:^{
                                          NSLog(@"      %@_1 started", centerTimelineHorizontal.name);
                                      } onComplete:^(BOOL result) {
                                          NSLog(@"      %@_1 completed", centerTimelineHorizontal.name);
                                      }];


    [centerTimelineVertical insertAnimation:verticalOscillation
                                   forLayer:centerViewVertical.layer
                                     atTime:0
                                    onStart:^{
                                        NSLog(@"      %@_1 started", centerTimelineVertical.name);
                                    } onComplete:^(BOOL result) {
                                        NSLog(@"      %@_1 completed", centerTimelineVertical.name);
                                    }];

    [centerViewsTimelines insertTimelineAnimation:centerTimelineHorizontal
                                           atTime:0];
    [centerViewsTimelines insertTimelineAnimation:centerTimelineVertical
                                           atTime:0];

    _groupTimeline.name = @"clockwise.group";
    centerViewsTimelines.name = @"center.group";

    centerViewsTimelines.repeatCount = 2;

    [whole addTimelineAnimation:_groupTimeline];
    [whole insertTimelineAnimation:centerViewsTimelines
                            atTime:0];
    [whole play];
}

- (void)testGroupCompositionWithReverse {
    NSLog(@"## %@", NSStringFromSelector(_cmd));
    weakify(self);


    _testView.hidden = YES;
    _tv1 = [self roundedView];
    _tv2 = [self roundedView];
    _tv3 = [self roundedView];
    UIView *centerViewVertical   = [self roundedView];
    UIView *centerViewHorizontal = [self roundedView];
    _tv2.backgroundColor = [UIColor greenColor];
    _tv3.backgroundColor = [UIColor blueColor];
    centerViewVertical.backgroundColor   = [UIColor brownColor];
    centerViewHorizontal.backgroundColor = [UIColor purpleColor];
    [self.view addSubview:_tv1];
    [self.view addSubview:_tv2];
    [self.view addSubview:_tv3];
    [self.view addSubview:centerViewVertical];
    [self.view addSubview:centerViewHorizontal];

    centerViewVertical.layer.position   = CGPointMake(CGRectGetMidX(self.view.bounds) - diameter, CGRectGetMidY(self.view.bounds) - diameter * 2);
    centerViewHorizontal.layer.position = CGPointMake(CGRectGetMidX(self.view.bounds) - diameter, CGRectGetMidY(self.view.bounds) + diameter);

    GroupTimelineAnimation *whole = [GroupTimelineAnimation groupTimelineAnimation];
    whole.name = @"whole.group";
    whole.onStart = ^{
        NSLog(@"whole.group started");
    };
    weakify(whole);
    whole.completion = ^(BOOL result) {
        strongify(whole);
        NSLog(@"whole.group completed");
        GroupTimelineAnimation *reverse = [whole reversed];
        reverse.completion = ^(BOOL result) {
            NSLog(@"whole.group completed");
            whole.completion = ^(BOOL result) {
                NSLog(@"whole.group completed");

                [centerViewVertical removeFromSuperview];
                [centerViewHorizontal removeFromSuperview];
                [self tearDown];
            };
            [whole replay];
        };
        dispatch_async(dispatch_get_main_queue(), ^{
            [reverse play];
        });
    };

    GroupTimelineAnimation *centerViewsTimelines = [GroupTimelineAnimation groupTimelineAnimationOnStart:^{
        NSLog(@"  center.group started");
    } completion:^(BOOL result) {
        NSLog(@"  center.group completed");
    }];
    TimelineAnimation *centerTimelineVertical = [TimelineAnimation timelineAnimationOnStart:^{
        NSLog(@"    center.group.vertical started");
    } completion:^(BOOL result) {
        NSLog(@"    center.group.vertical completed");
    }];
    TimelineAnimation *centerTimelineHorizontal = [TimelineAnimation timelineAnimationOnStart:^{
        NSLog(@"    center.group.horizontal started");
    } completion:^(BOOL result) {
        NSLog(@"    center.group.horizontal started");
    }];

    _tl1 = [TimelineAnimation timelineAnimationOnStart:^{
        NSLog(@"    clockwise.group.red started");
    } completion:^(BOOL result) {
        NSLog(@"    clockwise.group.red completed");
    }];
    _tl2 = [TimelineAnimation timelineAnimationOnStart:^{
        NSLog(@"    clockwise.group.green started");
    } completion:^(BOOL result) {
        NSLog(@"    clockwise.group.green completed");
    }];
    _tl3 = [TimelineAnimation timelineAnimationOnStart:^{
        NSLog(@"    clockwise.group.blue started");
    } completion:^(BOOL result) {
        NSLog(@"    clockwise.group.bleu completed");
    }];

    NSMutableArray<NSValue *> *values = [NSMutableArray arrayWithArray:@[
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMinX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMaxY(self.view.bounds) - diameter)],
                                                                         [NSValue valueWithCGPoint:CGPointMake(CGRectGetMaxX(self.view.bounds) - diameter, CGRectGetMinY(self.view.bounds))],
                                                                         [NSValue valueWithCGPoint:CGPointZero],
                                                                         ]];
    NSArray<NSNumber *> *keyTimes = @[
                                      @0,
                                      @.25,
                                      @.5,
                                      @.75,
                                      @1];

    CAKeyframeAnimation *circleAround = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPosition
                                                                               duration:1
                                                                                 values:values.copy
                                                                               keyTimes:keyTimes
                                                                         timingFunction:(ECustomTimingFunctionLinear)];
    _tv1.layer.position = values.firstObject.CGPointValue;
    [_tl1 addAnimation:circleAround
              forLayer:_tv1.layer
               onStart:^{
                   strongify(self);
                   NSLog(@"      %@_1 started", self.tl1.name);
               } onComplete:^(BOOL result) {
                   strongify(self);
                   NSLog(@"      %@_1 completed", self.tl1.name);
               }];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    _tv2.layer.position = values[0].CGPointValue;


    [_tl2 addAnimation:circleAround
              forLayer:_tv2.layer
               onStart:^{
                   strongify(self);
                   NSLog(@"      %@_1 started", self.tl2.name);
               } onComplete:^(BOOL result) {
                   strongify(self);
                   NSLog(@"      %@_1 completed", self.tl2.name);
               }];

    [values removeObjectAtIndex:0];
    [values addObject:values.firstObject];
    circleAround.values = values.copy;
    circleAround.values = values;
    _tv3.layer.position = values[0].CGPointValue;
    [_tl3 addAnimation:circleAround
              forLayer:_tv3.layer
               onStart:^{
                   strongify(self);
                   NSLog(@"      %@_1 started", self.tl3.name);
               } onComplete:^(BOOL result) {
                   strongify(self);
                   NSLog(@"      %@_1 completed", self.tl3.name);
               }];

    _tl1.name = @"clockwise.group.red";
    _tl2.name = @"clockwise.group.green";
    _tl3.name = @"clockwise.group.blue";
    centerTimelineHorizontal.name = @"center.group.horizontal";
    centerTimelineVertical.name   = @"center.group.vertical";

    _groupTimeline = [GroupTimelineAnimation groupTimelineAnimation];
    [_groupTimeline addTimelineAnimation:_tl1];
    [_groupTimeline addTimelineAnimation:_tl2];
    [_groupTimeline addTimelineAnimation:_tl3];

    _groupTimeline.onStart = ^{
        NSLog(@"  clockwise.group started");
    };

    _groupTimeline.completion = ^(BOOL result) {
        NSLog(@"  clockwise.group completed");
    };

    CAKeyframeAnimation *verticalOscillation = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPositionY
                                                                                      duration:1
                                                                                        values:@[
                                                                                                 @(CGRectGetMidY(self.view.bounds) - diameter * 2),
                                                                                                 @(CGRectGetMidY(self.view.bounds)),
                                                                                                 @(CGRectGetMidY(self.view.bounds) - diameter * 2)
                                                                                                 ]
                                                                                      keyTimes:@[
                                                                                                 @0,
                                                                                                 @.5,
                                                                                                 @1
                                                                                                 ]
                                                                                timingFunction:(ECustomTimingFunctionLinear)];
    CAKeyframeAnimation *horizontalOscillation = [AnimationsFactory keyframeAnimationWithKeyPath:kAnimationKeyPathPositionX
                                                                                        duration:1
                                                                                          values:@[
                                                                                                   @(CGRectGetMidX(self.view.bounds) - diameter),
                                                                                                   @(CGRectGetMidX(self.view.bounds)),
                                                                                                   @(CGRectGetMidX(self.view.bounds) - diameter)
                                                                                                   ]
                                                                                        keyTimes:@[
                                                                                                   @0,
                                                                                                   @.5,
                                                                                                   @1
                                                                                                   ]
                                                                                  timingFunction:(ECustomTimingFunctionLinear)];

    [centerTimelineHorizontal insertAnimation:horizontalOscillation
                                     forLayer:centerViewHorizontal.layer
                                       atTime:0
                                      onStart:^{
                                          NSLog(@"      %@_1 started", centerTimelineHorizontal.name);
                                      } onComplete:^(BOOL result) {
                                          NSLog(@"      %@_1 completed", centerTimelineHorizontal.name);
                                      }];


    [centerTimelineVertical insertAnimation:verticalOscillation
                                   forLayer:centerViewVertical.layer
                                     atTime:0
                                    onStart:^{
                                        NSLog(@"      %@_1 started", centerTimelineVertical.name);
                                    } onComplete:^(BOOL result) {
                                        NSLog(@"      %@_1 completed", centerTimelineVertical.name);
                                    }];

    [centerViewsTimelines insertTimelineAnimation:centerTimelineHorizontal
                                           atTime:0];
    [centerViewsTimelines insertTimelineAnimation:centerTimelineVertical
                                           atTime:0];

    _groupTimeline.name = @"clockwise.group";
    centerViewsTimelines.name = @"center.group";

    centerViewsTimelines.repeatCount = 2;

    [whole addTimelineAnimation:_groupTimeline];
    [whole insertTimelineAnimation:centerViewsTimelines
                            atTime:0];
    [whole play];
}

@end
