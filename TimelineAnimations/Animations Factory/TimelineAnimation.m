//
//  TimelineAnimation.m
//  Baccarat
//
//  Created by Abzorba Games on 14/09/2015.
//  Copyright (c) 2015-2016 Abzorba Games. All rights reserved.
//

#import "TimelineAnimation.h"
#import "TimelineEntity.h"
#import "TimelineAnimationProtected.h"
#import "ProgressMonitorLayer.h"
#import "KeyValueBlockObservation.h"
#import "BlankLayer.h"
#import "TimelineAudio.h"
#import "TimelineAudioAssociation.h"
#import "TimelineAudioAssociationProtected.h"
#import "NotifyBlockInfo.h"

#ifndef guard
#define guard(cond) if ((cond)) {}
#endif

TimelineAnimationExceptionName ImmutableTimelineAnimationException = @"ImmutableTimelineAnimation";
TimelineAnimationExceptionName EmptyTimelineAnimationException = @"EmptyTimeline";
TimelineAnimationExceptionName ClearedTimelineAnimationException = @"ClearedTimelineAnimation";
TimelineAnimationExceptionName OngoingTimelineAnimationException = @"OngoingTimelineAnimation";
TimelineAnimationExceptionName TimelineAnimationTimeNotificationOutOfBoundsException = @"TimelineAnimationTimeNotificationOutOfBounds";
TimelineAnimationExceptionName TimelineAnimationMethodNotImplementedYetException = @"MethodNotImplementedYet";
TimelineAnimationExceptionName TimelineAnimationUnsupportedMessageException = @"UnsupportedMessage";
TimelineAnimationExceptionName TimelineAnimationConflictingAnimationsException = @"ConflictingAnimations";

@interface TimelineAnimation ()

@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CFTimeInterval lastTimestamp;
@property (nonatomic, strong) NSMutableSet<TimelineEntity *> *unfinishedEntities;

@property (nonatomic, assign) ObservationID progressObservationID;

@end

@implementation TimelineAnimation

@synthesize progress=_progress;
@synthesize duration=_duration;

#pragma mark - Initializers

- (instancetype)initWithStart:(nullable VoidBlock)onStart
                       update:(nullable VoidBlock)onUpdate
                   completion:(nullable BoolBlock)completion {
    self = [super init];
    if (self) {
        _onStart       = onStart;
        self.onUpdate  = onUpdate;
        _completion    = completion;

        _animations    = [NSMutableArray array];
        _blankLayers   = [NSMutableArray array];

        _progressNotificationAssociations = [ProgressNotificationAssociations dictionary];
        _timeNotificationAssociations     = [NotificationAssociations dictionary];

        _lastTimestamp = -1;
        _paused        = NO;
        _speed         = 1;
		_progress      = 0;
    }
    return self;
}

- (instancetype)init {
    return [self initWithStart:nil update:nil completion:nil];
}

- (instancetype)initWithStart:(nullable VoidBlock)onStart {
    return [self initWithStart:onStart update:nil completion:nil];
}

- (instancetype)initWithUpdate:(nullable VoidBlock)onUpdate {
    return [self initWithStart:nil update:onUpdate completion:nil];
}

- (instancetype)initWithCompletion:(BoolBlock)completion {
    return [self initWithStart:nil update:nil completion:completion];
}


- (instancetype)initWithStart:(nullable VoidBlock)onStart
                       update:(nullable VoidBlock)onUpdate {
    return [self initWithStart:onStart update:onUpdate completion:nil];
}

- (instancetype)initWithStart:(nullable VoidBlock)onStart
                   completion:(nullable BoolBlock)completion {
    return [self initWithStart:onStart update:nil completion:completion];
}

- (instancetype)initWithUpdate:(nullable VoidBlock)onUpdate
                    completion:(nullable BoolBlock)completion {
    return [self initWithStart:nil update:onUpdate completion:completion];
}

+ (TimelineAnimation *)timelineAnimationWithCompletion:(BoolBlock)completion {
    return [[TimelineAnimation alloc] initWithCompletion:completion];
}

+ (TimelineAnimation *)timelineAnimation {
    return [[TimelineAnimation alloc] initWithStart:nil update:nil completion:nil];
}

+ (TimelineAnimation *)timelineAnimationOnStart:(VoidBlock)onStart completion:(BoolBlock)completion {
    return [[TimelineAnimation alloc] initWithStart:onStart update:nil completion:completion];
}

- (void)dealloc {
    [self _cleanUp];
    _blankLayers = nil;
    _animations = nil;
    _originate = nil;
    _parent = nil;
}

#pragma mark - On Update Methods -

- (void)setOnUpdate:(VoidBlock)onUpdate {
    if (onUpdate == nil) {
        [self removeDisplayLink];
        _onUpdate = nil;
        return;
    }
    _onUpdate = onUpdate;
    // Create the display link
    [self createDisplayLink];
}

#pragma mark - Display Link Methods -

- (void)createDisplayLink {
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkTick:)];
}

- (void)removeDisplayLink {
    [self.displayLink invalidate];
    self.displayLink = nil;
}

- (void)startDisplayLinkIfNeeded {
    if (self.displayLink) {
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)displayLinkTick:(CADisplayLink *)displayLink {
    __unused CFTimeInterval elapsedTime = displayLink.timestamp  - self.lastTimestamp;
    self.lastTimestamp = displayLink.timestamp;

    if (_onUpdate != nil) {
        _onUpdate();
    }
}

#pragma mark - Adding Animation Methods -

- (TimelineEntity *)lastEntity {
    __block TimelineEntity *res = nil;
    __block RelativeTime maxTime = 0;
    for (TimelineEntity *entity in _animations) {
        RelativeTime endTime = entity.endTime;
        if (endTime >= maxTime) {
            maxTime = endTime;
            res = entity;
        }
    };
    return res;
}

- (void)_raise {

}

- (void)addTimelineEntity:(TimelineEntity *)timelineEntity {
    {   // check if already in
        BOOL alreadyIn = [_animations containsObject:timelineEntity];
        guard (!alreadyIn) else {
            NSIndexSet *indexes = [_animations indexesOfObjectsPassingTest:^BOOL(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
                BOOL result = [entity isEqual:timelineEntity];
                *stop = result;
                return result;
            }];
            // raise conflict
            TimelineEntity *entity = _animations[indexes.firstIndex];
            [self raiseConflictingAnimationExceptionBetweenEntity:entity
                                                        andEntity:timelineEntity];
            return;
        }
    }

    {   // check if conflicting
        NSIndexSet *indexes = [_animations indexesOfObjectsPassingTest:^BOOL(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
            BOOL result = [entity conflictingWith:timelineEntity];
            *stop = result;
            return result;
        }];
        BOOL conflicting = (indexes.count != 0);
        guard (!conflicting) else {
            // raise conflict
            TimelineEntity *entity = _animations[indexes.firstIndex];
            [self raiseConflictingAnimationExceptionBetweenEntity:entity
                                                        andEntity:timelineEntity];
            return;
        }
    }

    // add the timeline entity
    [_animations addObject:timelineEntity];
}

#pragma mark - Animation Control Methods -

- (void)callOnStart {
    if (self.wasOnStartCalled) {
        return;
    }

    if (_repeat.isRepeating && _repeat.onStartCalled) {
        return;
    }

    if (_onStart) {
        _onStart();
    }
    _onStartCalled = YES;
    _repeat.onStartCalled = YES;
}

- (void)callOnComplete:(BOOL)result {
    if (_unfinishedEntities.count != 0) {
        return;
    }

    self.finished = YES;
    self.started = NO;

    // repeat
    if (_repeat.isRepeating) {
        BOOL hasMoreIterations = (BOOL)(_repeat.iteration < _repeat.count) || (_repeat.count == TimelineAnimationRepeatCountInfinite);
        if (hasMoreIterations) {
            if (_repeatCompletion) {
                // inform the user that an iteration completet
                // also ask him if he wants to stop
                BOOL shouldStop = NO;
                _repeatCompletion(result, _repeat.iteration, &shouldStop);
                if (shouldStop) {
                    hasMoreIterations = NO;
                }
            }

            [self removeDisplayLink];
            if (_repeat.iteration == NSUIntegerMax) {
                _repeat.iteration = 0;
            }
            _repeat.iteration++;

            if (hasMoreIterations) {
                if (_animations.count != 0) {
                    __weak typeof(self) welf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong typeof(self) strelf = welf;
                        if (strelf == nil) { return; }
                        if (strelf.isCleared) { return; }
                        [strelf _replay];
                    });
                    return;
                }
            }
        }
    }

    if (_completion) {
        _completion(result);
    }
    [self removeDisplayLink];
}

- (void)setRepeatCount:(TimelineAnimationRepeatCount)repeatCount {
    if (self.hasStarted) {
        [self raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }

    _repeatCount = repeatCount;
    _repeat.count = (NSUInteger)repeatCount;
    _repeat.iteration = 0;
    _repeat.isRepeating = (repeatCount != 0);
}

- (void)reset {
    if (self.hasStarted) {
        [self raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }
    // prepare for replay
    for (TimelineEntity *entity in _animations) {
        [entity reset];
    };
    _onStartCalled = NO;
    self.finished = NO;
}

- (void)_replay {
    [self reset];
    [self play];
}

- (void)prepareForReplay {
    _repeat.onStartCalled = NO;
    _repeat.iteration = 0;
}

#pragma mark - Properties

- (RelativeTime)beginTime {
    RelativeTime begin = [_animations sortedArrayUsingComparator:^NSComparisonResult(TimelineEntity *t1, TimelineEntity *t2) {
        return [@(t1.beginTime) compare:@(t2.beginTime)];
    }].firstObject.beginTime;
    return begin;
}

- (void)setBeginTime:(RelativeTime)beginTime {
    RelativeTime currentMinBeginTime = self.beginTime;
    [self delay:beginTime - currentMinBeginTime];
}

- (RelativeTime)endTime {
    RelativeTime endTime = [_animations sortedArrayUsingComparator:^NSComparisonResult(TimelineEntity *t1, TimelineEntity *t2) {
        return [@(t1.endTime) compare:@(t2.endTime)];
    }].lastObject.endTime;
    return endTime;
}

- (void)setCompletion:(BoolBlock)completion {
    if (self.hasStarted) {
        [self raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }
    _completion = completion;
}

- (void)setSpeed:(float)speed {
    if (speed < 0)
        speed = 0;
    _speed = speed;
    for (TimelineEntity *entity in _animations) {
        entity.speed = speed;
    }
}

- (void)setStarted:(BOOL)started {
    [self willChangeValueForKey:@"started"];
    _started = started;
    [self didChangeValueForKey:@"started"];
}

- (void)setPaused:(BOOL)paused {
    [self willChangeValueForKey:@"paused"];
    _paused = paused;
    [self didChangeValueForKey:@"paused"];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"finished"];
    _finished = finished;
    [self didChangeValueForKey:@"finished"];

    if (finished == YES) {
        [self _onFinish];
    }
}

- (BOOL)isEmpty {
    return (_animations.count == 0);
}

- (void)_onFinish {
    [self _cleanUp];
}

- (void)_cleanUp {
    if (self.progressObservationID) {
        [[KeyValueBlockObservation observatory] removeObservationBlocksOfObject:self
                                                                 forKeyPath:@"progress"
                                                              observationID:self.progressObservationID
                                                                    context:NULL];
    }

    [_progressLayer removeAllAnimations];
    [_progressLayer removeFromSuperlayer];
    _progressLayer = nil;

    [_blankLayers enumerateObjectsUsingBlock:^(BlankLayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }];
    _blankLayers = [NSMutableArray array];
}

#pragma mark - Exceptions

- (void)raiseConflictingAnimationExceptionBetweenEntity:(TimelineEntity *)entity1
                                              andEntity:(TimelineEntity *)entity2 {
    
    NSString *const reason = [NSString stringWithFormat:
                              @"Tried to add an animation to the "
                              "timeline that conflicts with another "
                              "animation that is already present.\n"
                              "%@\n"
                              "%@",
                              [entity1 debugDescription],
                              [entity2 debugDescription]];

#ifdef DEBUG
    [[NSException exceptionWithName:TimelineAnimationConflictingAnimationsException
                             reason:reason
                           userInfo:nil] raise];
#else
    // in RELEASE mode just log the stack trace.
    NSArray<NSString *> *const symbols = [NSThread callStackSymbols];
    NSString *const desc = @"Follows the stack trace:";
    NSUInteger totalLength = ((NSNumber *)[symbols valueForKeyPath:@"@sum.length"]).unsignedIntegerValue;
    NSMutableString *const string = [NSMutableString stringWithCapacity:totalLength + reason.length + desc.length];
    [string appendFormat:@"%@\n%@", reason, desc];

    [symbols enumerateObjectsUsingBlock:^(NSString * _Nonnull symbol, NSUInteger idx, BOOL * _Nonnull stop) {
        [string appendFormat:@"\n%@", symbol];
    }];
    // always track, always use NSLog
    NSLog(@"%@", [string copy]);
#endif /* DEBUG */
}

- (void)raiseImmutableTimelineExceptionWithSelector:(SEL)sel {
    [[NSException exceptionWithName:ImmutableTimelineAnimationException
                             reason:[NSString stringWithFormat:
                                     @"Tried to modify a TimelineAnimation "
                                     "while the animation has started in "
                                     "selector %@",
                                     NSStringFromSelector(sel)]
                           userInfo:nil] raise];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:self.class]) {
        return NO;
    }

    TimelineAnimation *other = (TimelineAnimation *)object;
    BOOL same = [other.animations isEqualToArray:_animations];
    return same;
}

#pragma mark - Debug

- (NSString *)description {
    return [NSString stringWithFormat:
            @"<<%@: %p> "
            "name =\"%@\"; "
            "beginTime = \"%.3lf\"; "
            "endTime = \"%.3lf\"; "
            "duration = \"%.3lf\"; "
            "userInfo = %@;>",
            NSStringFromClass(self.class),
            (void *)self,
            _name,
            self.beginTime,
            self.endTime,
            self.duration,
            _userInfo];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:
			@"<<%@: %p> "
			"name = \"%@\"; "
			"beginTime = \"%.3lf\"; "
			"endTime = \"%.3lf\"; "
			"duration = \"%.3lf\"; "
			"userInfo = %@; "
            "animations = %@; "
            "timeNotifications = %@; "
            "progressNotifications = %@;"
            ">",
			NSStringFromClass(self.class),
			(void *)self,
			_name,
			self.beginTime,
			self.endTime,
			self.duration,
			_userInfo,
            _animations.debugDescription,
            _timeNotificationAssociations.allKeys,
            _progressNotificationAssociations.allKeys];
}


#pragma mark - Progress

- (void)setProgress:(float)progress {
    [self willChangeValueForKey:@"progress"];
    _progress = progress;
    [self didChangeValueForKey:@"progress"];
}


- (void)_setupProgressMonitoring {
    _progressLayer = [ProgressMonitorLayer layer];
    __weak typeof(self) welf = self;
    _progressLayer.progressBlock = ^(float progress) {
        __strong typeof(self) strelf = welf;
        strelf.progress = progress;
    };

    [_animations.firstObject.layer addSublayer:(CALayer *)_progressLayer];

    CABasicAnimation *anim   = [CABasicAnimation animationWithKeyPath:@"progress"];
    anim.duration            = self.duration;
    anim.fromValue           = @(0.0);
    anim.toValue             = @(1.0);
    [_progressLayer addAnimation:anim forKey:@"progress"];
}

- (void)_setupProgressNotifications {
    // avoid heavy implementation if no progress observer are registered
    if (_progressNotificationAssociations.count == 0) { return; }

    [self _setupProgressMonitoring];


    NSMutableSet<ProgressNumber *> *unfinished = [NSMutableSet setWithArray:_progressNotificationAssociations.allKeys];
    __weak typeof(self) welf = self;
    self.progressObservationID = [[KeyValueBlockObservation observatory] addObservationBlock:^(NSString * _Nonnull keypath, TimelineAnimation  * _Nonnull timeline, NSDictionary * _Nonnull change, void * _Nullable context) {
                __strong typeof(self) strelf = welf;
                if (strelf == nil) { return; }
                if (unfinished.count == 0) { return; } // already finished

                float progress = ((ProgressNumber *)change[NSKeyValueChangeNewKey]).floatValue;

                NSMutableSet<ProgressNumber *> *finished = [NSMutableSet set];
                [unfinished enumerateObjectsUsingBlock:^(ProgressNumber * _Nonnull progressNumber, BOOL * _Nonnull stop) {
                    float progressKey = progressNumber.floatValue;
                    if (progress >= progressKey) {
                        ((NotifyBlock)_progressNotificationAssociations[progressNumber])(); // mind fuck, provided it to you by georges boumis :)
                        [finished addObject:progressNumber]; // mark this progress number as finished
                    }
                }];
                [unfinished minusSet:finished];
            }
                                                                                      object:self
                                                                                  forKeyPath:@"progress"
                                                                                     options:NSKeyValueObservingOptionNew
                                                                                     context:NULL];
}

#pragma mark - Time Notifications

- (void)_setupTimeNotifications {
    if (_timeNotificationAssociations.count == 0) { return; }

    [_timeNotificationAssociations enumerateKeysAndObjectsUsingBlock:^(RelativeTimeNumber  *_Nonnull key, NotifyBlockInfo *_Nonnull info, BOOL * _Nonnull stop) {
        RelativeTime time = key.doubleValue;
        __weak typeof(self) welf = self;
        [self insertBlankAnimationAtTime:time
                                 onStart:^{
                                     __strong typeof(self) strelf = welf;
                                     if (strelf == nil) { return; }
                                     [info call:strelf.muteAssociatedSounds];
                                 } onComplete:nil
                            withDuration:0.001];
    }];
}

- (void)insertBlankAnimationAtTime:(RelativeTime)time
                           onStart:(nullable VoidBlock)start
                        onComplete:(nullable BoolBlock)complete
                      withDuration:(NSTimeInterval)duration {
    if (self.isEmpty) {
        return;
    }


    BlankLayer *blankLayer = [BlankLayer layer];
    CABasicAnimation *blankAnimation = [CABasicAnimation animationWithKeyPath:@"blank"];
    blankAnimation.duration = duration;

    [_animations.firstObject.layer addSublayer:blankLayer];
    [_blankLayers addObject:blankLayer];

    [self insertAnimation:blankAnimation
                 forLayer:blankLayer
                   atTime:time
                  onStart:start
               onComplete:complete];
}

@end

#pragma mark - Populate

@implementation TimelineAnimation (Populate)

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time {
    [self insertAnimation:animation forLayer:layer atTime:time onStart:nil onComplete:nil];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
                onStart:(VoidBlock)start {
    NSParameterAssert(start);
    [self insertAnimation:animation forLayer:layer atTime:time onStart:start onComplete:nil];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
             onComplete:(BoolBlock)complete {
    NSParameterAssert(complete);
    [self insertAnimation:animation forLayer:layer atTime:time onStart:nil onComplete:complete];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)anim
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
                onStart:(nullable VoidBlock)start
             onComplete:(nullable BoolBlock)complete  {

    NSParameterAssert(anim);
    NSParameterAssert(layer);
    
    if (self.hasStarted) {
        [self raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }
    if (anim == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Tried to add a 'nil' animation to a %@", NSStringFromClass(self.class)];
        return;
    }
    if (layer == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Tried to add an animation with a 'nil' layer to a %@", NSStringFromClass(self.class)];
        return;
    }

    __kindof CAPropertyAnimation *animation = anim.copy;

    TimelineEntity *tlEntity = [[TimelineEntity alloc] initWithLayer:layer
                                                           animation:animation
                                                           beginTime:time
                                                             onStart:start
                                                          onComplete:complete
                                                   timelineAnimation:self];

    if (tlEntity.endTime > self.duration) {
        _duration = tlEntity.endTime - self.beginTime;
    }

    [self addTimelineEntity:tlEntity];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)anim
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
             onStart:(nullable VoidBlock)onStart
          onComplete:(nullable BoolBlock)complete {
    NSParameterAssert(anim);
    NSParameterAssert(layer);

    if (self.hasStarted) {
        [self raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }
    if (anim == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Tried to add a 'nil' animation to a %@", NSStringFromClass(self.class)];
        return;
    }
    if (layer == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Tried to add an animation with a 'nil' layer to a %@", NSStringFromClass(self.class)];
        return;
    }

    __kindof CAPropertyAnimation *animation = anim.copy;

    CFTimeInterval beginTime = 0.0;
    TimelineEntity *lastEntity = [self lastEntity];
    if (lastEntity) {
        beginTime = lastEntity.endTime + delay;
    } else if (delay >= 0.0) {
        beginTime = delay;
    }

    TimelineEntity *tlEntity = [[TimelineEntity alloc] initWithLayer:layer
                                                           animation:animation
                                                           beginTime:beginTime
                                                             onStart:onStart
                                                          onComplete:complete
                                                   timelineAnimation:self];

    if (tlEntity.endTime > self.duration) {
        _duration = tlEntity.endTime - self.beginTime;
    }

    [self addTimelineEntity:tlEntity];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
             onStart:(VoidBlock)onStart {
    NSParameterAssert(onStart);
    [self addAnimation:animation forLayer:layer withDelay:delay onStart:onStart onComplete:nil];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
          onComplete:( BoolBlock)complete {
    NSParameterAssert(complete);
    [self addAnimation:animation forLayer:layer withDelay:delay onStart:nil onComplete:complete];

}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay {
    [self addAnimation:animation forLayer:layer withDelay:delay onStart:nil onComplete:nil];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(VoidBlock)onStart
          onComplete:(BoolBlock)complete {
    NSParameterAssert(onStart);
    NSParameterAssert(complete);
    [self addAnimation:animation forLayer:layer withDelay:0.0 onStart:onStart onComplete:complete];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
          onComplete:(BoolBlock)complete {
    NSParameterAssert(complete);
    [self addAnimation:animation forLayer:layer withDelay:0.0 onStart:nil onComplete:complete];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(VoidBlock)onStart {
    NSParameterAssert(onStart);
    [self addAnimation:animation forLayer:layer withDelay:0.0 onStart:onStart onComplete:nil];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation forLayer:(__kindof CALayer *)layer {
    [self addAnimation:animation forLayer:layer withDelay:0.0 onStart: nil onComplete:nil];
}

@end

#pragma mark - Control

@implementation TimelineAnimation (Control)

- (void)play {
    if (self.isPaused) {
        [self resume];
        return;
    }

    if (self.hasStarted) {
        [NSException raise:OngoingTimelineAnimationException
                    format:@"You tried to play an non paused or finished %@.", NSStringFromClass(self.class)];
        return;
    }

    if (self.isCleared) {
        [NSException raise:ClearedTimelineAnimationException
                    format:@"You tried to play a cleared %@.", NSStringFromClass(self.class)];
        return;
    }


    self.paused = NO;

    if (self.isEmpty) {
        if (_onStart) {
            _onStart();
        }
        if (_completion) {
            _completion(NO);
        }
        return;
    }

    [self _setupTimeNotifications];
    [self _setupProgressNotifications];

    self.started = YES;

    _unfinishedEntities = [NSMutableSet setWithArray:_animations];
    NSArray<TimelineEntity *> *sortedEntities = [_animations sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"beginTime" ascending:YES]]];
    for (TimelineEntity *entity in sortedEntities) {
        entity.speed = _speed;
        [entity playOnStart:^{
            [self callOnStart];
        } onComplete:^(BOOL result) {
            [self.unfinishedEntities removeObject:entity];
            [self callOnComplete:result];
        } setModelValues:self.setsModelValues];
    };
    [self startDisplayLinkIfNeeded];
}

- (void)replay {
    if (self.hasStarted) {
        return;
    }
    __weak typeof(self) welf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strelf = welf;
        if (strelf.isCleared) { return; }
        [strelf prepareForReplay];
        [strelf _replay];
    });
}

- (void)resume {
    if (!self.isPaused) {
        return;
    }

    for (TimelineEntity *entity in _animations) {
        [entity resume];
    };
    self.paused = NO;
    [self startDisplayLinkIfNeeded];
}

- (void)pause {
    if (!self.hasStarted) {
        return;
    }

    self.paused = YES;
    for (TimelineEntity *entity in _animations) {
        [entity pause];
    };
    [self removeDisplayLink];
}

- (void)clear {
    for (TimelineEntity *entity in _animations) {
        [entity clear];
    };

    [_animations removeAllObjects];

    self.paused  = NO;
    self.started = NO;
    self.cleared = YES;

    self.onStart = nil;
    self.completion = nil;
    self.onUpdate = nil;

    _progress = 0.0;
}

- (void)delay:(NSTimeInterval)delay {
    if (self.hasStarted) {
        [self raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }
    guard (delay != 0.0) else { return; }

    for (TimelineEntity *entity in _animations) {
        entity.beginTime += delay;
    };

    {   // calculate notification time changes
        NotificationAssociations *const updatedAssociations = [NotificationAssociations dictionaryWithCapacity:_timeNotificationAssociations.count];
        [_timeNotificationAssociations enumerateKeysAndObjectsUsingBlock:^(RelativeTimeNumber * _Nonnull key, NotifyBlockInfo  *_Nonnull info, BOOL * _Nonnull stop) {
            RelativeTimeNumber *const newKey = @(key.doubleValue + delay);
            updatedAssociations[newKey] = info;
        }];
        _timeNotificationAssociations = updatedAssociations;
    }
}

- (instancetype)timelineWithDuration:(NSTimeInterval)duration {
    TimelineAnimation *const updatedTimeline = [self copy];
    if ([updatedTimeline respondsToSelector:@selector(setSetsModelValues:)]) {
        updatedTimeline.setsModelValues = self.setsModelValues;
    }
    guard (duration != self.duration) else {
        return updatedTimeline;
    }

    NSArray<TimelineEntity *> *const entities = _animations.copy;
    NSMutableArray<TimelineEntity *> *const updatedEntities = [NSMutableArray arrayWithCapacity:entities.count];
    const NSTimeInterval newTimelineDuration = duration;
    const NSTimeInterval oldTimelineDuration = self.duration;
    for (TimelineEntity *const entity in entities) {
        // adjust if the entity's .beginTime is not the same as the timeline's .beginTime
        const BOOL adjust = fabs((double)(entity.beginTime - self.beginTime)) > 0.001;
        NSTimeInterval newDuration = newTimelineDuration * entity.duration / oldTimelineDuration;
        TimelineEntity *const updatedEntity = [entity copyWithDuration:newDuration
                                                 shouldAdjustBeginTime:adjust
                                                   usingTotalBeginTime:self.beginTime];
        [updatedEntities addObject:updatedEntity];
    };

    updatedTimeline.animations = updatedEntities;
    [updatedEntities enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        entity.timelineAnimation = updatedTimeline;
    }];

    for (TimelineEntity *const entity in entities) {
        entity.timelineAnimation = updatedTimeline;
    }

    updatedTimeline.originate = self;
    updatedTimeline.duration = newTimelineDuration;

    {   // calculate notification time changes
        if (_timeNotificationAssociations.count > 0) {
            const double factor = duration / self.duration;
            NotificationAssociations *const updatedAssociations = [NotificationAssociations dictionaryWithCapacity:_timeNotificationAssociations.count];
            [_timeNotificationAssociations enumerateKeysAndObjectsUsingBlock:^(RelativeTimeNumber * _Nonnull key, NotifyBlockInfo *_Nonnull info, BOOL * _Nonnull stop) {
                RelativeTimeNumber *const newKey = @(key.doubleValue * factor);
                updatedAssociations[newKey] = info;
            }];
            updatedTimeline.timeNotificationAssociations = updatedAssociations;
        }
    }

    return updatedTimeline;
}

@end

#pragma mark - Reverse

@implementation TimelineAnimation (Reverse)

- (instancetype)reversed {
    return [self reversedWithDuration:self.duration];
}

- (instancetype)reversedWithDuration:(NSTimeInterval)duration {
    NSArray<TimelineEntity *> *sortedEntities = _animations.copy;
    NSMutableArray<TimelineEntity *> *reversedEntities = [NSMutableArray arrayWithCapacity:sortedEntities.count];
    NSTimeInterval timelineDuration = duration;
    for (TimelineEntity *entity in sortedEntities) {
        // reverse time
        TimelineEntity *reversedTimelineEntity = [entity reversedCopy];
        RelativeTime endTime = reversedTimelineEntity.endTime;
        reversedTimelineEntity.beginTime = timelineDuration - endTime;
        [reversedEntities addObject:reversedTimelineEntity];
    };

    [reversedEntities sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"beginTime" ascending:YES]]];

    TimelineAnimation *reversed = [self copy];
    [reversedEntities enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        entity.timelineAnimation = reversed;
    }];
    if (self.setsModelValues) {
        reversed.setsModelValues = YES;
    }
    reversed.animations = reversedEntities;
    reversed.name = [reversed.name stringByAppendingPathExtension:@"reversed"];
    reversed.reversed = YES;
    reversed.originate = self;
    return reversed;
}

@end

#pragma mark - Progress

@implementation TimelineAnimation (Progress)

- (void)playFromProgress:(float)progress catchUpIn:(NSTimeInterval)intervalToCatchUp {
    [[NSException exceptionWithName:TimelineAnimationMethodNotImplementedYetException
                             reason:[NSString stringWithFormat:
                                     @"The functionality provided by selector "
                                     "\"%@\" is not yet implemented ",
                                     NSStringFromSelector(_cmd)]
                           userInfo:nil] raise];
}


- (void)playFromProgress:(float)progress {
    if (self.hasStarted) {
        [self raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }

    if (progress < 0.0) {
        progress = 0.0;
    }
    if (progress > 1.0) {
        progress = 1.0;
    }

    NSTimeInterval duration = self.duration;
    RelativeTime beginTime  = self.beginTime;

    NSTimeInterval diff = duration * progress;
    RelativeTime newBeginTime = beginTime - diff;
    self.beginTime = newBeginTime;
    
    [self play];
}

@end

#pragma mark - Notify

@implementation TimelineAnimation (Notify)

- (void)notifyAtProgress:(float)progress
              usingBlock:(NotifyBlock)block {
    if (self.hasStarted) {
        [NSException raise:OngoingTimelineAnimationException
                    format:@"You tried to associate audio with an ongoing %@.", NSStringFromClass(self.class)];
        return;
    }
    ProgressNumber *progressKey = @(progress);
    _progressNotificationAssociations[progressKey] = [block copy];
}

- (void)notifyAtTime:(RelativeTime)time
          usingBlock:(NotifyBlock)block {
    if (self.hasStarted) {
        [NSException raise:OngoingTimelineAnimationException
                    format:@"You tried to associate audio with an ongoing %@.", NSStringFromClass(self.class)];
        return;
    }

    if (time < (RelativeTime)0.0) {
        [NSException raise:TimelineAnimationTimeNotificationOutOfBoundsException
                    format:@"Tried to add a time notification in %@, before its beginTime.", NSStringFromClass(self.class)];
        return;
    }
    if (self.isEmpty) {
        [NSException raise:EmptyTimelineAnimationException
                    format:@"Tried to add a time notification in an empty %@.", NSStringFromClass(self.class)];
        return;
    }
    if (time >= self.endTime) {
        [NSException raise:TimelineAnimationTimeNotificationOutOfBoundsException
                    format:@"Tried to add a time notification in %@, after its endTime.", NSStringFromClass(self.class)];
        return;
    }

    RelativeTimeNumber *timeKey = @(time);
    NotifyBlockInfo *info = [NotifyBlockInfo infoWithBlock:block
                                       isSoundNotification:NO];
    info.previous = _timeNotificationAssociations[timeKey];
    _timeNotificationAssociations[timeKey] = info;
}

- (void)addBlankAnimationWithDuration:(NSTimeInterval)duration {
    [self addBlankAnimationWithDuration:duration
                                onStart:nil
                             onComplete:nil];
}


- (void)addBlankAnimationWithDuration:(NSTimeInterval)duration
                              onStart:(VoidBlock)start {
    [self addBlankAnimationWithDuration:duration
                                onStart:start
                             onComplete:nil];
}

- (void)addBlankAnimationWithDuration:(NSTimeInterval)duration
                           onComplete:(BoolBlock)complete {
    [self addBlankAnimationWithDuration:duration
                                onStart:nil
                             onComplete:complete];
}

- (void)addBlankAnimationWithDuration:(NSTimeInterval)duration
                              onStart:(nullable VoidBlock)start
                           onComplete:(nullable BoolBlock)complete {
    if (self.isEmpty)
        return;

    BlankLayer *blankLayer = [BlankLayer layer];
    CABasicAnimation *blankAnimation = [CABasicAnimation animationWithKeyPath:@"blank"];
    blankAnimation.duration = duration;

    [_animations.firstObject.layer addSublayer:blankLayer];
    [_blankLayers addObject:blankLayer];

    [self addAnimation:blankAnimation
              forLayer:blankLayer
               onStart:start
            onComplete:complete];
}



- (void)insertBlankAnimationAtTime:(RelativeTime)time
                      withDuration:(NSTimeInterval)duration {
    [self insertBlankAnimationAtTime:time
                             onStart:nil
                          onComplete:nil
                        withDuration:duration];
}

- (void)insertBlankAnimationAtTime:(RelativeTime)time
                           onStart:(VoidBlock)start
                      withDuration:(NSTimeInterval)duration {
    [self insertBlankAnimationAtTime:time
                             onStart:start
                          onComplete:nil
                        withDuration:duration];
}

- (void)insertBlankAnimationAtTime:(RelativeTime)time
                        onComplete:(BoolBlock)complete
                      withDuration:(NSTimeInterval)duration {
    [self insertBlankAnimationAtTime:time
                             onStart:nil
                          onComplete:complete
                        withDuration:duration];
}

@end

#pragma mark - Audio

@implementation TimelineAnimation (Audio)

- (void)associateAudio:(id<TimelineAudio>)audio
  usingTimeAssociation:(TimelineAudioAssociation *)association {
    RelativeTime time = [association timeInTimelineAnimation:self];
    if (time < (RelativeTime)0.0) {
        [NSException raise:TimelineAnimationTimeNotificationOutOfBoundsException
                    format:@"Tried to add a time notification in %@, before its beginTime.", NSStringFromClass(self.class)];
        return;
    }
    if (self.isEmpty) {
        [NSException raise:EmptyTimelineAnimationException
                    format:@"Tried to add a time notification in an empty %@.", NSStringFromClass(self.class)];
        return;
    }
    if (time >= self.endTime) {
        [NSException raise:TimelineAnimationTimeNotificationOutOfBoundsException
                    format:@"Tried to add a time notification in %@, after its endTime.", NSStringFromClass(self.class)];
        return;
    }

    if (self.hasStarted) {
        [NSException raise:OngoingTimelineAnimationException
                    format:@"You tried to associate audio with an ongoing %@.", NSStringFromClass(self.class)];
        return;
    }

    RelativeTimeNumber *timeKey = @(time);
    NotifyBlock block = ^{
        [audio play];
    };
    NotifyBlockInfo *info = [NotifyBlockInfo infoWithBlock:block
            isSoundNotification:YES];
    info.sound = audio; // for debug purposes, used only in -description
    info.previous = _timeNotificationAssociations[timeKey];
    _timeNotificationAssociations[timeKey] = info;
}

- (void)disassociateAllAudio {
    if (self.hasStarted) {
        [NSException raise:OngoingTimelineAnimationException
                    format:@"You tried to associate audio with an ongoing %@.", NSStringFromClass(self.class)];
        return;
    }
    [self _removeTimeNotificationAssociationsPassingTest:^BOOL(RelativeTimeNumber *number, NotifyBlockInfo *info, BOOL *stop) {
        return info.isSoundNotification;
    }];
}

- (void)disassociateAudio:(id<TimelineAudio>)audio {
    if (self.hasStarted) {
        [NSException raise:OngoingTimelineAnimationException
                    format:@"You tried to associate audio with an ongoing %@.", NSStringFromClass(self.class)];
        return;
    }
    [self _removeTimeNotificationAssociationsPassingTest:^BOOL(RelativeTimeNumber *number, NotifyBlockInfo *info, BOOL *stop) {
        return info.sound == audio;
    }];
}

- (void)_removeTimeNotificationAssociationsPassingTest:(BOOL (^)(RelativeTimeNumber *, NotifyBlockInfo *, BOOL *stop))test {
    guard (_timeNotificationAssociations.count) else { return; }

    NotificationAssociations *workingCopy = _timeNotificationAssociations.mutableCopy;
    NSSet<RelativeTimeNumber *> *keysToRemove =  [_timeNotificationAssociations keysOfEntriesPassingTest:test];
    guard (keysToRemove.count) else { return; }
    [workingCopy removeObjectsForKeys:keysToRemove.allObjects];
    _timeNotificationAssociations = workingCopy;
}

- (void)disassociateAudioAtTimeAssociation:(TimelineAudioAssociation *)association {
    if (self.hasStarted) {
        [NSException raise:OngoingTimelineAnimationException
                    format:@"You tried to associate audio with an ongoing %@.", NSStringFromClass(self.class)];
        return;
    }
    RelativeTime time = [association timeInTimelineAnimation:self];
    RelativeTimeNumber *timeKey = @(time);
    _timeNotificationAssociations[timeKey] = nil;
}

@end

#pragma mark - NSCopying

@implementation TimelineAnimation (Copying)

- (instancetype)initWithTimelineAnimation:(__kindof TimelineAnimation *)timeline {
    self = [self initWithStart:timeline.onStart
                        update:timeline.onUpdate
                    completion:timeline.completion];
    if (self) {
        _animations       = [[NSMutableArray alloc] initWithArray:timeline.animations
                                                        copyItems:YES];
        
        [_animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
            entity.timelineAnimation = self;
        }];

        _lastTimestamp    = timeline.lastTimestamp;

        _paused           = timeline.paused;
        _finished         = timeline.finished;

        _speed            = timeline.speed;

        self.beginTime    = timeline.beginTime;
        _duration         = timeline.duration;
        self.repeatCount  = timeline.repeatCount;
        _repeatCompletion = timeline.repeatCompletion;
        _setsModelValues  = timeline.setsModelValues;

        _name             = timeline.name.copy;
        _userInfo         = timeline.userInfo.copy;

        _completion       = [timeline.completion copy];
        _onStart          = [timeline.onStart copy];
        _onUpdate         = [timeline.onUpdate copy];

        _progress         = timeline.progress;

        _reversed         = timeline.reversed;
        _originate        = timeline.originate;

        _muteAssociatedSounds = timeline.muteAssociatedSounds;

        _progressNotificationAssociations = timeline.progressNotificationAssociations.mutableCopy;
        _timeNotificationAssociations     = timeline.timeNotificationAssociations.mutableCopy;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[TimelineAnimation alloc] initWithTimelineAnimation:self];
}

@end

