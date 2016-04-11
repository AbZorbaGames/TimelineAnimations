//
//  TimelineAnimationProtected.h
//  TimelineAnimations
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

@interface TimelineAnimation () {
    @protected
    float _speed;
    
    struct {
        NSUInteger count;
        NSUInteger iteration;
        BOOL isRepeating;
        BOOL onStartCalled;
    } _repeat;
}
@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (nonatomic, assign, getter=hasStarted) BOOL started;
@property (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, readwrite, strong) NSMutableArray<TimelineEntity *> *__nullable animations;
@property (nonatomic, assign) NSUInteger repeatCounter;
@property (nonatomic, assign, getter=wasOnStartCalled) BOOL onStartCalled;

- (void)reset;
- (void)prepareForReplay;
- (void)_replay;
- (void)callOnStart;
- (void)callOnComplete:(BOOL)result;

- (nonnull instancetype)reversedWithDuration:(NSTimeInterval)duration;

@end

