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

@interface GroupTimelineAnimation ()
@property (nonatomic, strong) NSMutableSet<GroupTimelineEntity *> *unfinishedEntities;
@property (nonatomic, strong) NSMutableSet<GroupTimelineEntity *> *timelinesEntities;
@property (nonatomic, strong, readonly) NSArray<GroupTimelineEntity *> *sortedEntities;
@end

@implementation GroupTimelineAnimation

#pragma mark - Initializers

- (instancetype)init {
    return [self initWithTimelines:nil];
}

-(instancetype)initWithStart:(VoidBlock)onStart
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
            [timelines enumerateObjectsUsingBlock:^(__kindof TimelineAnimation * _Nonnull timeline, BOOL * _Nonnull stop) {
                GroupTimelineEntity *groupTimelineEntity = [GroupTimelineEntity groupTimelineEntityWithTimeline:timeline];
                [_timelinesEntities addObject:groupTimelineEntity];
            }];
        }
        _unfinishedEntities = [NSMutableSet set];
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

#pragma mark - Overrides

- (NSArray<__kindof TimelineAnimation *> *)timelineAnimations {
    return [self.sortedEntities valueForKeyPath:@"timeline"];
}

- (void)addTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation {
    [self addTimelineAnimation:timelineAnimation withDelay:0];
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
    timelineAnimation.beginTime = lastTimeline.endTime + delay;
    GroupTimelineEntity *groupTimelineEntity = [GroupTimelineEntity groupTimelineEntityWithTimeline:timelineAnimation];
    [_timelinesEntities addObject:groupTimelineEntity];
}

- (BOOL)containsTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation {
    GroupTimelineEntity *gte = [GroupTimelineEntity groupTimelineEntityWithTimeline:timelineAnimation];
    GroupTimelineEntity *res = [_timelinesEntities member:gte];
    return (res != nil);
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
                         atTime:(NSTimeInterval)time {
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
}

#pragma mark - Properties

- (NSTimeInterval)duration {
    return self.endTime - self.beginTime;
}

- (TimelineAnimation *)lastTimeline {
    __block TimelineAnimation *res = nil;
    __block NSTimeInterval maxTime = 0;
    [_timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        NSTimeInterval endTime = entity.timeline.endTime;
        if (endTime >= maxTime) {
            maxTime = endTime;
            res = entity.timeline;
        }
    }];
    return res;
}

- (NSTimeInterval)beginTime {
    return self.sortedEntities.firstObject.timeline.beginTime;
}

- (void)delay:(NSTimeInterval)delay {
    if (self.hasStarted) {
        [self raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }

    if (delay <= 0)
        return;
    [_timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        entity.timeline.beginTime += delay;
    }];
}

- (NSTimeInterval)endTime {
    __block NSTimeInterval maxTime = 0;
    [_timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        NSTimeInterval endTime = entity.timeline.endTime;
        if (endTime > maxTime) {
            maxTime = endTime;
        }
    }];
    return maxTime;
}

- (void)setSpeed:(float)speed {
    if (speed < 0)
        speed = 0;
    float changePercentage = speed / _speed;
    _speed = speed;
    [_timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        entity.timeline.speed *= changePercentage;
    }];
}

- (NSArray<GroupTimelineEntity *> *)sortedEntities {
    NSSortDescriptor *sortUsingBeginTime = [NSSortDescriptor sortDescriptorWithKey:@"timeline.beginTime" ascending:YES];
    NSArray<NSSortDescriptor *> *descriptors = @[sortUsingBeginTime];
    NSArray<GroupTimelineEntity *> *sortedEntities = [_timelinesEntities sortedArrayUsingDescriptors:descriptors];
    return sortedEntities;
}

- (void)callOnComplete:(BOOL)result {
    if (_unfinishedEntities.count != 0) {
        return;
    }

    self.finished = YES;
    self.started = NO;

    // repeat
    if (_repeat.isRepeating) {
        BOOL hasMoreIterations = _repeat.iteration < _repeat.count;
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
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self _replay];
                });
                return;
            }
        }
    }

    if (self.completion)
        self.completion(result);
}

#pragma mark - Play methods

- (void)play {
    if (self.isPaused) {
        [self resume];
        return;
    }

    self.started = YES;
    self.onStartCalled = NO;
    _unfinishedEntities = _timelinesEntities.mutableCopy;

    [self.sortedEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        [entity playOnStart:^{
            [self callOnStart];
        } onComplete:^(BOOL result) {
            [self.unfinishedEntities removeObject:entity];
            [self callOnComplete:result];
        }];
    }];
    self.paused = NO;
}

- (void)resume {
    if (!self.isPaused) {
        return;
    }
    NSMutableSet<CALayer *> *resumedLayers = [NSMutableSet set];
    [self.sortedEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull groupEntity, NSUInteger idx, BOOL * _Nonnull stop) {
        [groupEntity.timeline.animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([resumedLayers member:entity.layer])
                return;
            [entity resume];
            [resumedLayers addObject:entity.layer];
        }];
    }];
    self.paused = NO;
}

- (void)pause {
    self.paused = YES;
    NSMutableSet<CALayer *> *pausedLayers = [NSMutableSet set];
    [self.sortedEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull groupEntity, NSUInteger idx, BOOL * _Nonnull stop) {
        [groupEntity.timeline.animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([pausedLayers member:entity.layer])
                return;
            [entity pause];
            [pausedLayers addObject:entity.layer];
        }];
    }];
}

- (void)clear {
    [_timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        [entity clear];
    }];
    self.paused = NO;
    self.started = NO;
}

- (void)reset {
    if (self.hasStarted) {
        [self raiseImmutableGroupTimelineExceptionWithSelector:_cmd];
        return;
    }

    [self.sortedEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        [entity reset];
    }];
    self.paused = NO;
    self.started = NO;
    self.onStartCalled = NO;
    self.finished = NO;
}

- (instancetype)reversed {
    return [self reversedWithDuration:self.duration];
}

- (instancetype)reversedWithDuration:(NSTimeInterval)duration {
    NSArray<GroupTimelineEntity *> *sortedEntities = self.sortedEntities.copy;
    NSMutableArray<GroupTimelineEntity *> *reversedEntities = [NSMutableArray arrayWithCapacity:sortedEntities.count];
    NSTimeInterval groupTimelineDuration = duration;
    [sortedEntities enumerateObjectsWithOptions:(NSEnumerationReverse)
                                     usingBlock:^(GroupTimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
                                         // reverse time
                                         GroupTimelineEntity *reversedTimelineEntity = [entity reversedCopyWithDuration:groupTimelineDuration];
                                         [reversedEntities addObject:reversedTimelineEntity];
                                     }];

    GroupTimelineAnimation *reversed = [self copy];
    reversed.timelinesEntities = [NSMutableSet setWithArray:reversedEntities];
    reversed.name = [reversed.name stringByAppendingPathExtension:@"reversed"];
    return reversed;
}

- (void)prepareForReplay {
    _repeat.onStartCalled = NO;
    _repeat.iteration = 0;
    [_timelinesEntities enumerateObjectsUsingBlock:^(GroupTimelineEntity * _Nonnull entity, BOOL * _Nonnull stop) {
        [entity.timeline prepareForReplay];
    }];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    GroupTimelineAnimation *copy = [[GroupTimelineAnimation alloc] initWithTimelines:nil];

    copy.timelinesEntities = [[NSMutableSet alloc] initWithSet:_timelinesEntities copyItems:YES];

    copy.started            = self.started;
    copy.paused             = self.paused;
    copy.finished           = self.finished;

    copy.speed              = _speed;

    copy.beginTime          = self.beginTime;
    copy.repeatCount        = self.repeatCount;
    copy.repeatCompletion   = self.repeatCompletion;

    copy.name               = self.name;
    copy.userInfo           = self.userInfo;

    copy.completion         = self.completion;
    copy.onStart            = self.onStart;
    copy.onUpdate           = self.onUpdate;


    return copy;
}


#pragma mark - Unsupported methods

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(CALayer *)layer
          onComplete:(nullable BoolBlock)complete {
    [self raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(CALayer *)layer
           withDelay:(CGFloat)delay
          onComplete:(nullable BoolBlock)complete {
    [self raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(CALayer *)layer
                 atTime:(CGFloat)time
             onComplete:(nullable BoolBlock)complete {
    [self raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(CALayer *)layer
                 atTime:(CGFloat)time
                onStart:(nullable VoidBlock)start
             onComplete:(nullable BoolBlock)complete {
    [self raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

-(void)setSetsModelValues:(BOOL)setsModelValues {
    [self raiseUnsupportedMessageExceptionWithSelector:_cmd];
}

- (void)setOnUpdate:(VoidBlock)onUpdate {
    return;
}

- (void)raiseImmutableGroupTimelineExceptionWithSelector:(SEL)sel {
    [[NSException exceptionWithName:@"ImmutableGroupTimeline"
                             reason:[NSString stringWithFormat:@"Tried to modify a GroupTimelineAnimation while the animation has started"]
                           userInfo:nil] raise];
}

- (void)raiseUnsupportedMessageExceptionWithSelector:(SEL)sel {
    [[NSException exceptionWithName:@"UnsupportedMessage"
                             reason:[NSString stringWithFormat:@"GroupTimelieAnimation does not respond to -%@. Use a TimelineAnimation instead.", NSStringFromSelector(sel)]
                           userInfo:nil] raise];
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if (aSelector == @selector(setSetsModelValues:)) {
        return NO;
    }
    return [super respondsToSelector:aSelector];
}


@end
