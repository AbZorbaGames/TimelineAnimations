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


@interface TimelineAnimation ()
@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, strong) CADisplayLink *displayLink;
@property (nonatomic, assign) CFTimeInterval lastTimestamp;
@property (nonatomic, strong) NSMutableSet<TimelineEntity *> *unfinishedEntities;
@end

@implementation TimelineAnimation

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

        _lastTimestamp = -1;
        _paused        = NO;
        _speed         = 1;
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

- (void)startDisplayLink {
    if (self.displayLink) {
        [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
}

- (void)displayLinkTick:(CADisplayLink *)sender {
    __unused CGFloat elapsedTime = self.displayLink.timestamp  - self.lastTimestamp;
    self.lastTimestamp = self.displayLink.timestamp;

    if (_onUpdate != nil) {
        _onUpdate();
    }
}

#pragma mark - Adding Animation Methods -

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(CGFloat)time {
    [self insertAnimation:animation forLayer:layer atTime:time onComplete:nil];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(CGFloat)time
                onStart:(nullable VoidBlock)start {
    [self insertAnimation:animation forLayer:layer atTime:time onStart:start onComplete:nil];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(CGFloat)time
             onComplete:(nullable BoolBlock)complete {
    [self insertAnimation:animation
                 forLayer:layer
                   atTime:time
                  onStart:nil
               onComplete:complete];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)anim
               forLayer:(__kindof CALayer *)layer
                 atTime:(CGFloat)time
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

    NSString *key = [NSString stringWithFormat:@"animation.%@", animation.keyPath];
    TimelineEntity *tlEntity = [[TimelineEntity alloc] initWithLayer:layer
                                                           animation:animation
                                                        animationKey:key
                                                        beginTime:time
                                                             onStart:start
                                                          onComplete:complete];

    if (tlEntity.endTime > self.duration) {
        self.duration = tlEntity.endTime;
    }

    [self addTimelineEntity:tlEntity];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)anim
            forLayer:(__kindof CALayer *)layer
           withDelay:(CGFloat)delay
             onStart:(nullable VoidBlock)onStart
          onComplete:(BoolBlock)complete {
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

    CFTimeInterval beginTime = 0;
    TimelineEntity *lastEntity = [self lastEntity];
    if (lastEntity) {
        beginTime = lastEntity.endTime + delay;
    } else if (delay >= 0) {
        beginTime = delay;
    }

    NSString *key = [NSString stringWithFormat:@"animation.%@", animation.keyPath];
    TimelineEntity *tlEntity = [[TimelineEntity alloc] initWithLayer:layer
                                                           animation:animation
                                                        animationKey:key
                                                           beginTime:beginTime
                                                             onStart:onStart
                                                          onComplete:complete];

    if (tlEntity.endTime > self.duration) {
        self.duration = tlEntity.endTime;
    }

    [self addTimelineEntity:tlEntity];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)anim
            forLayer:(__kindof CALayer *)layer
           withDelay:(CGFloat)delay
             onStart:(nullable VoidBlock)onStart {
    [self addAnimation:anim forLayer:layer onStart:onStart onComplete:nil];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(CGFloat)delay
          onComplete:(nullable BoolBlock)complete {
    [self addAnimation:animation
              forLayer:layer
             withDelay:delay
               onStart:nil
            onComplete:complete];

}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation forLayer:(__kindof CALayer *)layer withDelay:(CGFloat)delay {
    [self addAnimation:animation forLayer:layer withDelay:delay onStart:nil onComplete:nil];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(nullable VoidBlock)onStart
          onComplete:(nullable BoolBlock)complete {
    [self addAnimation:animation forLayer:layer withDelay:0 onStart:onStart onComplete:complete];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
          onComplete:(nullable BoolBlock)complete {
    [self addAnimation:animation forLayer:layer withDelay:0 onStart:nil onComplete:complete];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation forLayer:(__kindof CALayer *)layer onStart:(VoidBlock)onStart {
    [self addAnimation:animation forLayer:layer onStart:onStart onComplete:nil];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation forLayer:(__kindof CALayer *)layer {
    [self addAnimation:animation forLayer:layer onComplete:nil];
}


- (TimelineEntity *)lastEntity {
    __block TimelineEntity *res = nil;
    __block NSTimeInterval maxTime = 0;
    [_animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        NSTimeInterval endTime = entity.endTime;
        if (endTime >= maxTime) {
            maxTime = endTime;
            res = entity;
        }
    }];
    return res;
}




- (void)addTimelineEntity:(TimelineEntity *)timelineEntity {
    if (![_animations containsObject:timelineEntity]) {
        [_animations addObject:timelineEntity];
        [_animations sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"beginTime" ascending:YES]]];
    }
}

#pragma mark - Animation Control Methods -

- (void)play {
    if (self.isPaused) {
        [self resume];
        return;
    }

    _paused = NO;
    if (_animations.count == 0) {
        if (_onStart)
            _onStart();
        if (_completion)
            _completion(NO);
        return;
    }

    _started = YES;
    _unfinishedEntities = [NSMutableSet setWithArray:_animations];
    NSArray<TimelineEntity *> *sortedEntities = _animations;
    [sortedEntities enumerateObjectsUsingBlock:^(TimelineEntity *entity, NSUInteger idx, BOOL *stop) {
        entity.speed = _speed;
        [entity playOnStart:^{
            [self callOnStart];
        } onComplete:^(BOOL result) {
            [self.unfinishedEntities removeObject:entity];
            [self callOnComplete:result];
        } setModelValues:self.setsModelValues];
    }];
    [self startDisplayLink];
}

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

    _finished = YES;
    _started = NO;

    // repeat
    if (_repeat.isRepeating) {
        BOOL hasMoreIterations = _repeat.iteration < _repeat.count;
        if (hasMoreIterations) {
            if (_repeatCompletion) {
                // inform the user that an iteration completet
                // also ask him if he wants to stop
                BOOL shouldStop = NO;
                _repeatCompletion(result, _repeat.iteration, &shouldStop);
                if (shouldStop)
                    hasMoreIterations = NO;
            }

            [self removeDisplayLink];
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

    if (_completion)
        _completion(result);
    [self removeDisplayLink];
}

- (void)setRepeatCount:(NSInteger)repeatCount {
    if (self.hasStarted) {
        [self raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }

    _repeatCount = repeatCount;
    _repeat.count = repeatCount;
    _repeat.iteration = 0;
    _repeat.isRepeating = (repeatCount != 0);
}

- (void)resume {
    if (!self.isPaused) {
        return;
    }

    [_animations enumerateObjectsUsingBlock:^(TimelineEntity *entity, NSUInteger idx, BOOL *stop) {
        [entity resume];
    }];
    _paused = NO;
    [self startDisplayLink];
}

- (void)pause {
    if (!self.hasStarted) {
        return;
    }

    _paused = YES;
    [_animations enumerateObjectsUsingBlock:^(TimelineEntity *entity, NSUInteger idx, BOOL *stop) {
        [entity pause];
    }];
    [self removeDisplayLink];
}

- (void)clear {
    [_animations enumerateObjectsUsingBlock:^(TimelineEntity *entity, NSUInteger idx, BOOL * _Nonnull stop) {
        [entity clearEntity];
    }];
    [_animations removeAllObjects];
    _paused  =
    _started = NO;
}

- (void)delay:(NSTimeInterval)delay {
    if (self.hasStarted) {
        [self raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }

    if (delay <= 0)
        return;
    [_animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        entity.beginTime += delay;
    }];
}

- (void)reset {
    if (self.hasStarted) {
        [self raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }
    // prepare for replay
    [_animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        [entity reset];
    }];
    _onStartCalled = NO;
    _finished = NO;
}

- (void)_replay {
    [self reset];
    [self play];
}

- (void)replay {
    if (self.hasStarted) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self prepareForReplay];
        [self _replay];
    });
}

- (void)prepareForReplay {
    _repeat.onStartCalled = NO;
    _repeat.iteration = 0;
}

- (instancetype)reversed {
    return [self reversedWithDuration:self.duration];
}

- (instancetype)reversedWithDuration:(NSTimeInterval)duration {
    NSArray<TimelineEntity *> *sortedEntities = _animations.copy;
    NSMutableArray<TimelineEntity *> *reversedEntities = [NSMutableArray arrayWithCapacity:sortedEntities.count];
    NSTimeInterval timelineDuration = duration;
    [sortedEntities enumerateObjectsWithOptions:(NSEnumerationReverse)
                                     usingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
                                         // reverse time
                                         TimelineEntity *reversedTimelineEntity = [entity reversedCopy];
                                         NSTimeInterval endTime = reversedTimelineEntity.endTime;
                                         reversedTimelineEntity.beginTime = timelineDuration - endTime;
                                         [reversedEntities addObject:reversedTimelineEntity];
                                     }];

    [reversedEntities sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"beginTime" ascending:YES]]];

    TimelineAnimation *reversed = [self copy];
    if ([reversed respondsToSelector:@selector(setSetsModelValues:)])
        reversed.setsModelValues = YES;
    reversed.animations = reversedEntities;
    reversed.name = [reversed.name stringByAppendingPathExtension:@"reversed"];
    return reversed;
}

#pragma mark - Properties

- (NSTimeInterval)beginTime {
    return _animations.firstObject.beginTime;
}

- (void)setBeginTime:(NSTimeInterval)beginTime {
    NSTimeInterval currentMinBeginTime = self.beginTime;
    [self delay:beginTime - currentMinBeginTime];
}

- (NSTimeInterval)endTime {
    return self.beginTime + self.duration;
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
    [_animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        entity.speed = speed;
    }];
}

#pragma mark - Exceptions

- (void)raiseImmutableTimelineExceptionWithSelector:(SEL)sel {
    [[NSException exceptionWithName:@"ImmutableTimeline"
                             reason:[NSString stringWithFormat:@"Tried to modify a TimelineAnimation while the animation has started"]
                           userInfo:nil] raise];
}

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object)
        return YES;

    if (![object isKindOfClass:self.class])
        return NO;

    if (self == object)
        return YES;

    if (![object isKindOfClass:self.class])
        return NO;

    TimelineAnimation *other = (TimelineAnimation *)object;
    BOOL same = [other.animations isEqualToArray:_animations];
    return same;
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone {
    TimelineAnimation *copy = [[TimelineAnimation alloc] initWithStart:_onStart update:_onUpdate completion:_completion];

    copy.animations         = [[NSMutableArray alloc] initWithArray:_animations copyItems:YES];
    copy.lastTimestamp      = _lastTimestamp;

    copy.started            = _started;
    copy.paused             = _paused;
    copy.finished           = _finished;

    copy.speed              = _speed;

    copy.beginTime          = self.beginTime;
    copy.duration           = self.duration;
    copy.repeatCount        = _repeatCount;
    copy.repeatCompletion   = _repeatCompletion;
    copy.setsModelValues    = _setsModelValues;

    copy.name               = _name;
    copy.userInfo           = _userInfo;

    copy.completion         = _completion;
    copy.onStart            = _onStart;
    copy.onUpdate           = _onUpdate;

    return copy;
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<<%@: %p> name:\"%@\" beginTime:\"%lf\" endTime:\"%lf\" duration:\"%lf\" userInfo:%@>", NSStringFromClass(self.class), self, _name, self.beginTime, self.endTime, self.duration, _userInfo];
}

@end

