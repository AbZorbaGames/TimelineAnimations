/*!
 *  @file TimelineAnimationsDisplayLink.m
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 18/10/2016.
 *  @copyright   Copyright © 2016-2017 Abzorba Games. All rights reserved.
 */

#import "TimelineAnimationsDisplayLink.h"

@interface TimelineAnimationsDisplayLink ()
@property (nonatomic, strong) CADisplayLink *link;
@property (nonatomic, copy) TimelineAnimationsDisplayLinkBlock block;
@end

@implementation TimelineAnimationsDisplayLink

#pragma mark - Initializers

+ (instancetype)displayLinkPreferredFramesPerSecond:(NSInteger)preferredFramesPerSecond
                                              block:(TimelineAnimationsDisplayLinkBlock)block {
    return [(TimelineAnimationsDisplayLink *)[self alloc] initWithDisplayLinkBlock:block preferredFramesPerSecond:preferredFramesPerSecond];
}

+ (instancetype)displayLinkWithBlock:(TimelineAnimationsDisplayLinkBlock)block {
    return [self displayLinkPreferredFramesPerSecond:60 block:block];
}

- (instancetype)initWithDisplayLinkBlock:(TimelineAnimationsDisplayLinkBlock)block
                preferredFramesPerSecond:(NSInteger)preferredFramesPerSecond {
    self = [super init];
    if (self) {
        _block = [block copy];
        _link = [CADisplayLink displayLinkWithTarget:self selector:@selector(_loop:)];
        self.preferredFramesPerSecond = preferredFramesPerSecond;
        [self _registerForNotifications];
        [self _setupDisplayLink];
        [self _start];
    }
    return self;
}

- (void)dealloc {
    _link.paused = YES;
    [_link invalidate];
    _link = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Properties

- (NSInteger)preferredFramesPerSecond {
//    if ([iOS isAtLeast:iOS10]) {
//        return _link.preferredFramesPerSecond;
//    }
//    else {
        return 60/_link.frameInterval;
//    }
}

- (void)setPreferredFramesPerSecond:(NSInteger)preferredFramesPerSecond {
//    if ([iOS isAtLeast:iOS10]) {
//        _link.preferredFramesPerSecond = preferredFramesPerSecond;
//    }
//    else {
        _link.frameInterval = 60/preferredFramesPerSecond;
//    }
}

- (BOOL)isPaused {
    return self.link.isPaused;
}

- (void)setPaused:(BOOL)paused {
    if (paused) {
        [self _pause];
    }
    else {
        [self _resume];
    }
}

#pragma mark - Private methods control

- (void)_pause {
    self.link.paused = YES;
}

- (void)_resume {
    self.link.paused = NO;
}

- (void)_start {
    [self _resume];
}

- (void)_invalidate {
    [self _pause];
    [self.link invalidate];
    self.link = nil;
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:UIApplicationDidEnterBackgroundNotification
                object:nil];
    [nc removeObserver:self
                  name:UIApplicationWillEnterForegroundNotification
                object:nil];
}

#pragma mark - Private methods setup

- (void)_setupDisplayLink {
    [self _pause];
    [self.link addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark - Notifications

- (void)_registerForNotifications {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(_applicationDidEnterBackground:)
               name:UIApplicationDidEnterBackgroundNotification
             object:nil];
    [nc addObserver:self
           selector:@selector(_applicationWillEnterForeground:)
               name:UIApplicationWillEnterForegroundNotification
             object:nil];
}

- (void)_applicationDidEnterBackground:(NSNotification *)note {
    [self _pause];
}

- (void)_applicationWillEnterForeground:(NSNotification *)note {
    [self _resume];
}

#pragma mark - CADisplayLink loop 

- (void)_loop:(CADisplayLink *)displayLink {
    const CFTimeInterval timestamp = displayLink.timestamp;
    self.block(timestamp);
}

#pragma mark - Public methods

- (void)pause {
    [self _pause];
}

- (void)resume {
    [self _resume];
}

- (void)stop {
    [self _invalidate];
}

@end
