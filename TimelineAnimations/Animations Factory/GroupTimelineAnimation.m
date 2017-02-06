//
//  GroupTimelineAnimation.m
//  TimelineAnimations
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

#import "GroupTimelineAnimation.h"
#import "TimelineAnimationProtected.h"
#import "GroupTimelineEntity.h"
#import "TimelineEntity.h"
#import "BlankLayer.h"
#import "ProgressMonitorLayer.h"

#ifndef guard
#define guard(cond) if ((cond)) {}
#endif

@interface GroupTimelineAnimation ()
@property (nonatomic, strong) TimelineAnimation *helperTimeline;
@property (nonatomic, strong) NSMutableSet<GroupTimelineEntity *> *unfinishedEntities;
@property (nonatomic, strong) NSMutableSet<GroupTimelineEntity *> *timelinesEntities;
@property (nonatomic, strong, readonly) NSArray<GroupTimelineEntity *> *sortedEntities;

@property (nonatomic, strong, readonly) NSArray<__kindof TimelineAnimation *> *timelineAnimations;
@end

@implementation GroupTimelineAnimation

#pragma mark - Initializers

- (instancetype)init {
    return [self initWithTimelines:nil];
}

- (instancetype)initWithStart:(VoidBlock)onStart
                       update:(VoidBlock)onUpdate
                   completion:(BoolBlock)completion {
    self = [self initWithTimelines:nil];
    if (self) {
        self.onStart    = onStart;
        self.onUpdate   = onUpdate;
        self.completion = completion;
    }
    return self;
}

- (instancetype)initWithTimelines:(nullable NSSet<__kindof TimelineAnimation *> *)timelines {
    self = [super initWithStart:nil update:nil completion:nil];
    if (self) {
        _timelinesEntities = [NSMutableSet set];
        if (timelines) {
            for (TimelineAnimation *timeline in timelines) {
                GroupTimelineEntity *groupTimelineEntity = [GroupTimelineEntity groupTimelineEntityWithTimeline:timeline];
                [_timelinesEntities addObject:groupTimelineEntity];
            }
        }
        _unfinishedEntities = [NSMutableSet set];
        _helperTimeline = [TimelineAnimation timelineAnimation];
        _helperTimeline.name = @"GroupTimelineAnimation.helperTimelineAnimation";
        _speed = 1;
    }
    return self;
}

+ (instancetype)groupTimelineAnimation {
    return [[GroupTimelineAnimation alloc] initWithTimelines:nil];
}

+ (instancetype)groupTimelineAnimationWithCompletion:(BoolBlock)completion {
    return [[GroupTimelineAnimation alloc] initWithStart:nil update:nil completion:completion];
}

+ (instancetype)groupTimelineAnimationOnStart:(VoidBlock)onStart completion:(BoolBlock)completion {
    return [[GroupTimelineAnimation alloc] initWithStart:onStart update:nil completion:completion];
}

- (void)dealloc {
    _unfinishedEntities = nil;
    _timelinesEntities = nil;
    [_helperTimeline clear];
    _helperTimeline = nil;
    [self.animations removeAllObjects];
    self.originate = nil;
    self.parent = nil;
}


#pragma mark - Properties

- (BOOL)isEmpty {
    return (_timelinesEntities.count == 0);
}

- (NSTimeInterval)duration {
    return self.endTime - self.beginTime;
}

- (TimelineAnimation *)lastTimeline {
    __block TimelineAnimation *res = nil;
    __block RelativeTime maxTime = 0;
    for (GroupTimelineEntity *entity in _timelinesEntities) {
        RelativeTime endTime = entity.timeline.endTime;
        if (endTime >= maxTime) {
            maxTime = endTime;
            res = entity.timeline;
        }
    };
    return res;
}

- (RelativeTime)beginTime {
    return self.sortedEntities.firstObject.timeline.beginTime;
}

- (void)delay:(NSTimeInterval)delay {
    if (self.hasStarted) {
        [self raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }

    for (GroupTimelineEntity *entity in _timelinesEntities) {
        entity.timeline.beginTime += delay;
    };
}

- (RelativeTime)endTime {
    __block RelativeTime maxTime = 0;
    for (GroupTimelineEntity *entity in _timelinesEntities) {
        RelativeTime endTime = entity.timeline.endTime;
        if (endTime > maxTime) {
            maxTime = endTime;
        }
    };
    return maxTime;
}

- (void)setSpeed:(float)speed {
    if (speed < 0) {
        speed = 0;
    }
    float changePercentage = speed / _speed;
    guard (changePercentage != 1.0) else { return; }
    
    _speed = speed;
    for (GroupTimelineEntity *entity in _timelinesEntities) {
        entity.timeline.speed *= changePercentage;
    };
}

#pragma mark - Entities

- (NSArray<__kindof TimelineAnimation *> *)timelineAnimations {
    return [self.sortedEntities valueForKeyPath:@"timeline"];
}

- (NSArray<GroupTimelineEntity *> *)sortedEntities {
    NSSortDescriptor *sortUsingBeginTime = [NSSortDescriptor sortDescriptorWithKey:@"timeline.beginTime" ascending:YES];
    NSArray<NSSortDescriptor *> *descriptors = @[sortUsingBeginTime];
    NSArray<GroupTimelineEntity *> *sortedEntities = [_timelinesEntities sortedArrayUsingDescriptors:descriptors];
    return sortedEntities;
}

- (nullable __kindof TimelineAnimation *)timelineAnimationSimilarToTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation {
    if (![self containsTimelineAnimation:timelineAnimation]) {
        return nil;
    }

    __block __kindof TimelineAnimation *tl = nil;
    [_timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity *_Nonnull entity, BOOL *_Nonnull stop) {
        if ([entity.timeline isEqual:timelineAnimation]) {
            tl = entity.timeline;
            *stop = YES;
        }
    }];
    return tl;
}


#pragma mark - 

- (void)prepareForReplay {
    _repeat.onStartCalled = NO;
    _repeat.iteration = 0;
    for (GroupTimelineEntity *entity in _timelinesEntities) {
        [entity.timeline prepareForReplay];
    };
}

- (void)callOnComplete:(BOOL)result {
    if (_unfinishedEntities.count != 0) {
        return;
    }

    self.finished = YES;
    self.started = NO;

    // repeat
    if (_repeat.isRepeating) {
        BOOL hasMoreIterations = (_repeat.iteration < _repeat.count) || (_repeat.count == TimelineAnimationRepeatCountInfinite);
        if (hasMoreIterations) {
            if (self.repeatCompletion) {
                // inform the user that an iteration completet
                // also ask him if he wants to stop
                BOOL shouldStop = NO;
                self.repeatCompletion(result, _repeat.iteration, &shouldStop);
                if (shouldStop)
                    hasMoreIterations = NO;
            }

            if (_repeat.iteration == NSUIntegerMax)
                _repeat.iteration = 0;
            _repeat.iteration++;

            if (hasMoreIterations) {
                if (_timelinesEntities.count != 0) {
                    __weak typeof(self) welf = self;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        __strong typeof(self) strelf = welf;
                        if (strelf.isCleared) { return; }
                        [strelf _replay];
                    });
                    return;
                }
            }
        }
    }

    if (self.completion) {
        self.completion(result);
    }
}

#pragma mark - Unsupported methods

- (void)setSetsModelValues:(BOOL)setsModelValues {
    [self raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

- (void)setOnUpdate:(VoidBlock)onUpdate {
    return;
}

- (void)raiseImmutableGroupTimelineExceptionWithSelector:(SEL)sel {
    [[NSException exceptionWithName:ImmutableTimelineAnimationException
                             reason:[NSString stringWithFormat:@"Tried to modify a GroupTimelineAnimation while the animation has started"]
                           userInfo:nil] raise];
}

- (void)raiseUnsupportedMessageExceptionWithSelector:(SEL)sel {
    [[NSException exceptionWithName:TimelineAnimationUnsupportedMessageException
                             reason:[NSString stringWithFormat:@"GroupTimelineAnimation does not respond to -%@. Use a TimelineAnimation instead.", NSStringFromSelector(sel)]
                           userInfo:nil] raise];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(setSetsModelValues:)) {
        return NO;
    }
    return [super respondsToSelector:aSelector];
}

@end

@implementation GroupTimelineAnimation (Populate)

#pragma mark - Overrides

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(CALayer *)layer
          onComplete:(BoolBlock)complete {
    [self raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(CALayer *)layer
           withDelay:(NSTimeInterval)delay
          onComplete:(BoolBlock)complete {
    [self raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(CALayer *)layer
                 atTime:(NSTimeInterval)time
             onComplete:(BoolBlock)complete {
    [self raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(CALayer *)layer
                 atTime:(NSTimeInterval)time
                onStart:(nullable VoidBlock)start
             onComplete:(nullable BoolBlock)complete {
    [self raiseUnsupportedMessageExceptionWithSelector:_cmd];
}


#pragma mark - Group

- (void)addTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation {
    [self addTimelineAnimation:timelineAnimation withDelay:0.0];
}

- (void)addTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation
                   withDelay:(NSTimeInterval)delay {
    NSParameterAssert(timelineAnimation);
    if (self.hasStarted) {
        [self raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }
    if (timelineAnimation == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Tried to add a 'nil' TimelineAnimation to a %@", NSStringFromClass(self.class)];
        return;
    }

    timelineAnimation = timelineAnimation.copy;

    TimelineAnimation *lastTimeline = [self lastTimeline];
    timelineAnimation.beginTime += lastTimeline.endTime + delay;
    GroupTimelineEntity *groupTimelineEntity = [GroupTimelineEntity groupTimelineEntityWithTimeline:timelineAnimation];
    [_timelinesEntities addObject:groupTimelineEntity];
}

- (void)removeTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation {
    if (self.hasStarted) {
        [self raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }
    if ([self containsTimelineAnimation:timelineAnimation]) {
        GroupTimelineEntity *gte = [GroupTimelineEntity groupTimelineEntityWithTimeline:timelineAnimation];
        [_timelinesEntities removeObject:gte];
    }
}

- (void)insertTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation
                         atTime:(RelativeTime)time {
    NSParameterAssert(timelineAnimation);
    if (self.hasStarted) {
        [self raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }
    if (timelineAnimation == nil) {
        [NSException raise:NSInvalidArgumentException format:@"Tried to add a 'nil' TimelineAnimation to a %@", NSStringFromClass(self.class)];
        return;
    }

    timelineAnimation = timelineAnimation.copy;

    timelineAnimation.beginTime = time;
    GroupTimelineEntity *groupTimelineEntity = [GroupTimelineEntity groupTimelineEntityWithTimeline:timelineAnimation];
    [_timelinesEntities addObject:groupTimelineEntity];
    groupTimelineEntity.timeline.parent = self;
}


- (BOOL)containsTimelineAnimation:(nullable __kindof TimelineAnimation *)timelineAnimation {
    if (timelineAnimation == nil) {
        return NO;
    }

    __kindof TimelineAnimation *timeline = timelineAnimation;
    GroupTimelineEntity *gte = [GroupTimelineEntity groupTimelineEntityWithTimeline:timeline];
    GroupTimelineEntity *res = [_timelinesEntities member:gte];
    return (res != nil);
}


@end

#pragma mark - Control

@implementation GroupTimelineAnimation (Control)

- (void)__setupTimeNotifications {
    if (self.name != nil) {
        self.helperTimeline.name = [NSString stringWithFormat:@"%@>>%@", self.name, self.helperTimeline.name];
    }
    [self.helperTimeline insertBlankAnimationAtTime:0.0
                                            onStart:nil
                                         onComplete:nil
                                       withDuration:self.duration];
    [self insertTimelineAnimation:self.helperTimeline atTime:0.0];
    [self _setupTimeNotifications];
}

- (void)_setupProgressMonitoring {
    self.progressLayer = [ProgressMonitorLayer layer];
    __weak typeof(self) welf = self;
    self.progressLayer.progressBlock = ^(float progress) {
        __strong typeof(self) strelf = welf;
        strelf.progress = progress;
    };

    __kindof CALayer *layer = _timelinesEntities.anyObject.timeline.animations.firstObject.layer;
    [layer addSublayer:self.progressLayer];

    CABasicAnimation *anim   = [CABasicAnimation animationWithKeyPath:@"progress"];
    anim.duration            = self.duration;
    anim.fromValue           = @(0.0);
    anim.toValue             = @(1.0);
    [self.progressLayer addAnimation:anim forKey:@"progress"];
}

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


    if (self.isEmpty) {
        if (self.onStart) {
            self.onStart();
        }
        if (self.completion) {
            self.completion(NO);
        }
        return;
    }

    [self __setupTimeNotifications];
    [self _setupProgressNotifications];

    self.started = YES;
    self.onStartCalled = NO;

    _unfinishedEntities = _timelinesEntities.mutableCopy;

    NSArray<GroupTimelineEntity *> *sortedEntities = self.sortedEntities;
    NSMutableArray<GroupTimelineEntity *> *reversedEntities = [NSMutableArray array];
    NSMutableArray<GroupTimelineEntity *> *normalEntities   = [NSMutableArray arrayWithCapacity:sortedEntities.count];

    for (GroupTimelineEntity *entity in sortedEntities) {
        // this does not work well if -delay or some other operation that changes the animations occurs
        __strong TimelineAnimation *originate = entity.timeline.originate;
        if (entity.timeline.reversed && [self containsTimelineAnimation:originate]) {
            [reversedEntities addObject:entity];
        } else {
            [normalEntities addObject:entity];
        }
    };

    for (GroupTimelineEntity *entity in normalEntities) {
        [entity playOnStart:^{
            [self callOnStart];
        }        onComplete:^(BOOL result) {
            [self.unfinishedEntities removeObject:entity];
            [self callOnComplete:result];
        }];
    };

    for (GroupTimelineEntity *entity in reversedEntities) {
        __strong TimelineAnimation *originate = entity.timeline.originate;
        __kindof TimelineAnimation *tl = [self timelineAnimationSimilarToTimelineAnimation:originate];

        [entity playAfterReverse:tl
                         onStart:^{
                             [self callOnStart];
                         } onComplete:^(BOOL result) {
                    [self.unfinishedEntities removeObject:entity];
                    [self callOnComplete:result];
                }];
    };

    self.paused = NO;
}

- (void)resume {
    if (!self.isPaused) {
        return;
    }
    NSMutableSet<CALayer *> *resumedLayers = [NSMutableSet set];
    NSArray<GroupTimelineEntity *> *sortedEntities = self.sortedEntities;
    for (GroupTimelineEntity *groupEntity in sortedEntities) {
        for (TimelineEntity *entity in groupEntity.timeline.animations) {
            if ([resumedLayers member:entity.layer])
                return;
            [entity resume];
            [resumedLayers addObject:entity.layer];
        }
    }
    self.paused = NO;
}

- (void)pause {
    self.paused = YES;
    NSMutableSet<CALayer *> *pausedLayers = [NSMutableSet set];
    NSArray<GroupTimelineEntity *> *sortedEntities = self.sortedEntities;
    for (GroupTimelineEntity *groupEntity in sortedEntities) {
        for (TimelineEntity *entity in groupEntity.timeline.animations) {
            if ([pausedLayers member:entity.layer])
                return;
            [entity pause];
            [pausedLayers addObject:entity.layer];
        }
    }
}

- (void)clear {
    for (GroupTimelineEntity *entity in _timelinesEntities) {
        [entity clear];
    }

    for (GroupTimelineEntity *entity in _unfinishedEntities) {
        [entity clear];
    }

    [_timelinesEntities removeAllObjects];
    [_unfinishedEntities removeAllObjects];

    self.paused = NO;
    self.started = NO;
    self.cleared = YES;

    self.onStart = nil;
    self.completion = nil;
    self.onUpdate = nil;
}

- (void)reset {
    if (self.hasStarted) {
        [self raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }

    NSArray<GroupTimelineEntity *> *sortedEntities = self.sortedEntities;
    for (GroupTimelineEntity *entity in sortedEntities) {
        [entity reset];
    }

    self.paused = NO;
    self.started = NO;
    self.onStartCalled = NO;
    self.finished = NO;
}

- (instancetype)timelineWithDuration:(NSTimeInterval)duration {
    GroupTimelineAnimation *const updatedTimeline = [self copy];
    if ([updatedTimeline respondsToSelector:@selector(setSetsModelValues:)]) {
        updatedTimeline.setsModelValues = self.setsModelValues;
    }
    guard (duration != self.duration) else {
        return updatedTimeline;
    }

    NSArray<GroupTimelineEntity *> *const sortedEntities = self.sortedEntities.copy;
    NSMutableArray<GroupTimelineEntity *> *const updatedEntities = [NSMutableArray arrayWithCapacity:sortedEntities.count];
    const NSTimeInterval newTimelineDuration = duration;
    const NSTimeInterval oldTimelineDuration = self.duration;
    for (GroupTimelineEntity *const entity in sortedEntities) {
        // adjust if the entity's .beginTime is not the same as the timeline's .beginTime
        BOOL adjust = fabs((double)(entity.timeline.beginTime - self.beginTime)) > 0.001;
        NSTimeInterval newDuration = newTimelineDuration * entity.timeline.duration / oldTimelineDuration;
        GroupTimelineEntity *const updatedEntity = [entity copyWithDuration:newDuration
                                                      shouldAdjustBeginTime:adjust
                                                        usingTotalBeginTime:self.beginTime];
        [updatedEntities addObject:updatedEntity];
    };


    NSMutableSet<GroupTimelineEntity *> *timelineEntities = [NSMutableSet setWithArray:updatedEntities];
    [timelineEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        entity.timeline.parent = updatedTimeline;
    }];
    updatedTimeline.timelinesEntities = timelineEntities;
    updatedTimeline.originate = self;
    updatedTimeline.duration = newTimelineDuration;
    return updatedTimeline;
}

@end

@implementation GroupTimelineAnimation (Reverse)

- (instancetype)reversed {
    return [self reversedWithDuration:self.duration];
}

- (instancetype)reversedWithDuration:(NSTimeInterval)duration {
    NSArray<GroupTimelineEntity *> *const sortedEntities = self.sortedEntities.copy;
    NSMutableArray<GroupTimelineEntity *> *const reversedEntities = [NSMutableArray arrayWithCapacity:sortedEntities.count];
    const NSTimeInterval groupTimelineDuration = duration;

    for (GroupTimelineEntity *const entity in sortedEntities) {
        // reverse time
        GroupTimelineEntity *const reversedTimelineEntity = [entity reversedCopyWithDuration:groupTimelineDuration];
        [reversedEntities addObject:reversedTimelineEntity];
    }

    GroupTimelineAnimation *const reversed = [self copy];
    NSMutableSet<GroupTimelineEntity *> *const timelineEntities = [NSMutableSet setWithArray:reversedEntities];
    [timelineEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        entity.timeline.parent = reversed;
    }];
    reversed.timelinesEntities = timelineEntities;
    reversed.name = [reversed.name stringByAppendingPathExtension:@"reversed"];
    reversed.originate = self;
    return reversed;
}

@end

@implementation GroupTimelineAnimation (Notify)

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

    __kindof CALayer *layer = _timelinesEntities.anyObject.timeline.animations.firstObject.layer;
    [layer addSublayer:blankLayer];
    [self.blankLayers addObject:blankLayer];

    [self.helperTimeline insertAnimation:blankAnimation
                                forLayer:blankLayer
                                  atTime:time
                                 onStart:start
                              onComplete:complete];
}

@end

#pragma mark - NSCopying

@implementation GroupTimelineAnimation (Copying)

- (id)copyWithZone:(NSZone *)zone {
    GroupTimelineAnimation *copy = [[GroupTimelineAnimation alloc] initWithTimelines:nil];

    copy.timelinesEntities = [[NSMutableSet alloc] initWithSet:_timelinesEntities copyItems:YES];
    [copy.timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        entity.timeline.parent = copy;
    }];

    copy.paused             = self.paused;
    copy.finished           = self.finished;

    copy.speed              = _speed;

    copy.beginTime          = self.beginTime;
    copy.repeatCount        = self.repeatCount;
    copy.repeatCompletion   = self.repeatCompletion;

    copy.name               = self.name.copy;
    copy.userInfo           = self.userInfo.copy;

    copy.completion         = self.completion;
    copy.onStart            = self.onStart;
    copy.onUpdate           = self.onUpdate;

    copy.helperTimeline     = self.helperTimeline.copy;
    copy.helperTimeline.name = @"GroupTimelineAnimation.helperTimelineAnimation";

    copy.reversed         = self.reversed;
    copy.originate        = self.originate;

    copy.muteAssociatedSounds = self.muteAssociatedSounds;

    copy.progressNotificationAssociations = self.progressNotificationAssociations.mutableCopy;
    copy.timeNotificationAssociations     = self.timeNotificationAssociations.mutableCopy;

    return copy;
}

@end

@implementation GroupTimelineAnimation (Debug)

- (NSString *)description {
    return [NSString stringWithFormat:
            @"<<%@: %p> "
                    "name:\"%@\" "
                    "beginTime:\"%lf\" "
                    "endTime:\"%lf\" "
                    "duration:\"%lf\" "
                    "userInfo:%@>",
            NSStringFromClass(self.class),
            self,
            self.name,
            self.beginTime,
            self.endTime,
            self.duration,
            self.userInfo];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:
            @"<<%@: %p> "
                    "name:\"%@\" "
                    "beginTime:\"%lf\" "
                    "endTime:\"%lf\" "
                    "duration:\"%lf\" "
                    "userInfo:%@ "
                    "animations: %@",
            NSStringFromClass(self.class),
            self,
            self.name,
            self.beginTime,
            self.endTime,
            self.duration,
            self.userInfo,
            self.sortedEntities.debugDescription];
}

@end

