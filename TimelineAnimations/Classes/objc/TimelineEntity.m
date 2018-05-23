//
//  TimelineEntity.m
//  TimelineAnimations
//
//  Created by Georges Boumis on 18/02/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

#import "TimelineEntity.h"
#import "AnimationsKeyPath.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import "CAPropertyAnimation+Reverse.h"
#import "CABasicAnimation+Reverse.h"
#import "CAKeyframeAnimation+Reverse.h"
#import "CALayer+TimelineAnimation.h"
#import "CAPropertyAnimation+TimelineEntity.h"
#import "PrivateTypes.h"
#import "TimelineAnimation.h"

#ifdef DEBUG
#define _raise(e) ([TimelineEntity _raiseEmptyTimelineAnimationException])
#else
#define _raise(e) {}
#endif

#pragma mark - TimelineObject Implementation -

@interface TimelineEntity () <CAAnimationDelegate>
@property (nonatomic, weak) __kindof CALayer *layer;
@property (nonatomic, copy) __kindof CAPropertyAnimation *animation;
@property (nonatomic, copy) NSString *animationKey;
// reset values
@property (nonatomic, copy) __kindof CAPropertyAnimation *initialAnimation;
@property (nonatomic, copy) id initialValue;
@property (nonatomic, copy) id initialAnimationKey;

@property (nonatomic, copy, nullable) TimelineAnimationCompletionBlock completion;
@property (nonatomic, copy, nullable) TimelineAnimationOnStartBlock onStart;

@property (nonatomic, readwrite) BOOL cleared;

@property (nonatomic, copy) NSString *actualAnimationKey;

@property (nonatomic, readwrite) BOOL resetBeginTimeOnNextIteration;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithLayer:(__kindof CALayer *)layer
                    animation:(__kindof CAPropertyAnimation *)animation
                 animationKey:(NSString *)key
                    beginTime:(RelativeTime)beginTime
                      onStart:(nullable TimelineAnimationOnStartBlock)onStart
                   onComplete:(nullable TimelineAnimationCompletionBlock)completion
            timelineAnimation:(TimelineAnimation *)timelineAnimation NS_DESIGNATED_INITIALIZER;

#define NO_RETURN __attribute__ ((noreturn))
+ (void)_raiseEmptyTimelineAnimationException NO_RETURN;
#undef NO_RETURN
@end

@interface TimelineEntity (CoreAnimationDelegate)
- (void)_callOnStartIfNeeded;
- (void)_callCompletionIfNeededHasGracefullyFinished:(BOOL)result;
@end


@implementation TimelineEntity

#pragma mark - Initializer

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithLayer:(__kindof CALayer *)layer
                    animation:(__kindof CAPropertyAnimation *)animation
                    beginTime:(RelativeTime)beginTime
                      onStart:(nullable TimelineAnimationOnStartBlock)onStart
                   onComplete:(nullable TimelineAnimationCompletionBlock)completion
            timelineAnimation:(TimelineAnimation *)timelineAnimation {
    
    NSString *key = [NSString stringWithFormat:@"timelineEntity.animationKey.%@", animation.keyPath];
    return [self initWithLayer:layer
                     animation:animation
                  animationKey:key
                     beginTime:beginTime
                       onStart:onStart
                    onComplete:completion
             timelineAnimation:timelineAnimation];
}

- (instancetype)initWithLayer:(__kindof CALayer *)layer
                    animation:(__kindof CAPropertyAnimation *)animation
                 animationKey:(NSString *)key
                    beginTime:(RelativeTime)beginTime
                      onStart:(nullable TimelineAnimationOnStartBlock)onStart
                   onComplete:(nullable TimelineAnimationCompletionBlock)completion
            timelineAnimation:(TimelineAnimation *)timelineAnimation {
    
    NSParameterAssert(layer != nil);
    NSParameterAssert(animation != nil);
    NSParameterAssert(key != nil);
    NSParameterAssert(timelineAnimation != nil);
    
    if (animation.isSpecial) {
        NSParameterAssert(animation.isConsistent == YES);
        guard (animation.isConsistent) else {
            [NSException raise:NSInvalidArgumentException
                        format:@"TimelineAnimations: The animation provided has both '.repeatCount' and '.repeatDuration' which results in undefined behaviour. animation: %@.", animation];
            return nil;
        }
    }
    
    if (![animation isKindOfClass:[CAPropertyAnimation class]]) {
        [NSException raise:NSInvalidArgumentException
                    format:@"TimelineAnimations: The animation provided is not a subclass of 'CAPropertyAnimation'. animation: %@.", animation];
        return nil;
    }
    
    self = [super init];
    if (self) {
        _layer               = layer;
        _animation           = animation.copy;
        _animationKey        = key.copy;
        _actualAnimationKey  = key.copy;
        _speed               = 1.0f;
        _onStart             = [onStart copy];
        _completion          = [completion copy];
        _timelineAnimation   = timelineAnimation;
        
        _animation.beginTime = Round(beginTime);
        _animation.duration  = Round(_animation.duration);
        
        _initialAnimation    = _animation.copy;
        _initialAnimationKey = key.copy;

        _restoresValues = YES;
        [self _storeInitialValues];
    }
    return self;
}

- (void)dealloc {
    _layer = nil;
    _onStart = nil;
    _completion = nil;
    _timelineAnimation = nil;
}

#pragma mark - Private

- (void)_storeInitialValues {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { return; };
    
    NSString *const keyPath = _animation.keyPath;
    
    // values used for reset
    id value = [slayer valueForKeyPath:keyPath];
    if ([_animation isKindOfClass:[CABasicAnimation class]]) {
        CABasicAnimation *const basicAnimation = _animation;
        id fromValue = basicAnimation.fromValue;
        if (fromValue) {
            value = fromValue;
        }
    }
    if ([value respondsToSelector:@selector(copy)]) {
        value = [value copy];
    }
    _initialValue = value;
}

#pragma mark - Properties

- (RelativeTime)beginTime {
    const RelativeTime beginTime = (RelativeTime)_animation.beginTime;
    return Round(beginTime);
}

- (void)setBeginTime:(RelativeTime)beginTime {
    _initialAnimation.beginTime =
    _animation.beginTime        = (RelativeTime)Round(beginTime);
}

- (RelativeTime)endTime {
    const RelativeTime endTime = ((RelativeTime)_animation.beginTime) + ((RelativeTime)self.duration);
    return Round(endTime);
}

- (NSTimeInterval)duration {
    const NSTimeInterval duration = _animation.realDuration;
    return duration;
}

- (void)setSpeed:(float)speed {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { _raise(EmptyTimelineAnimationException); return; };
    
    if (speed < 0.0f) {
        speed = 0.0f;
    }
    // speeds are equal
    if (fabsf(speed - _speed) < TimelineAnimationMillisecond &&
        fabsf(speed - slayer.speed) < TimelineAnimationMillisecond) {
        return;
    }
    
    slayer.timeOffset = [slayer convertTime:CACurrentMediaTime()
                                  fromLayer:slayer];
    slayer.beginTime  = CACurrentMediaTime();
    slayer.speed      = speed;
    _speed = speed;
}

- (void)setProgress:(float)progress {
    _progress = progress;
}

- (void)setTimelineAnimation:(TimelineAnimation *)timelineAnimation {
    NSParameterAssert(timelineAnimation != nil);
    _timelineAnimation = timelineAnimation;
}

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }
    
    if (![object isKindOfClass:[TimelineEntity class]]) {
        return NO;
    }
    
    TimelineEntity *const other = (TimelineEntity *)object;
    if (other.layer != _layer) {
        return NO;
    }
    
    if (![other.animationKey isEqualToString:_animationKey]) {
        return NO;
    }
    
    if (![other.animation.keyPath isEqualToString:_animation.keyPath]) {
        return NO;
    }
    
    if (other.beginTime != self.beginTime) {
        return NO;
    }
    
    return YES;
}

#pragma mark -

- (NSString *)debugDescription {
    __strong typeof(_timelineAnimation) stimeline = self.timelineAnimation;
    
    NSString *values = @"<no-values-description>";
    if ([_animation isKindOfClass:[CAKeyframeAnimation class]]) {
        __kindof CAKeyframeAnimation *const keyframe = (__kindof CAKeyframeAnimation *)_animation;
        values = [NSString stringWithFormat:@"[keytimes = %@; values = %@]",
                  keyframe.keyTimes,
                  keyframe.values];
    }
    if ([_animation isKindOfClass:[CABasicAnimation class]]) {
        __kindof CABasicAnimation *const basic = (__kindof CABasicAnimation *)_animation;
        values = [NSString stringWithFormat:@"[from = %@; to = %@]",
                  basic.fromValue,
                  basic.toValue];
    }
    
    return [NSString stringWithFormat:@"<%@ %p: "
            "key = \"%@\"; "
            "keyPath = \"%@\"; "
            "beginTime = \"%.3lf\"; "
            "endTime = \"%.3lf\"; "
            "duration = \"%.3lf\"; "
            "values = %@; "
            "finished = %@; "
            "paused = %@; "
            "cleared = %@; "
            "type = %@; "
            "onStart = %@; "
            "completion = %@; "
            "timeline = [%@(%p)::\"%@\"]; "
            "layer = %@;"
            ">",
            NSStringFromClass(self.class),
            self,
            _animationKey,
            _animation.keyPath,
            self.beginTime,
            self.endTime,
            self.duration,
            values,
            @(self.finished).stringValue,
            @(self.paused).stringValue,
            @(self.cleared).stringValue,
            NSStringFromClass(_animation.class),
            @(_onStart != nil),
            @(_completion != nil),
            NSStringFromClass(stimeline.class),
            stimeline,
            stimeline.name,
            self.layer
            ];
}

#pragma mark - Exceptions

+ (void)_raiseEmptyTimelineAnimationException {
    @throw [NSException exceptionWithName:EmptyTimelineAnimationException
                                   reason:@""
                                 userInfo:nil];
}

@end

#pragma mark - Core Animation Delegate

@implementation TimelineEntity (CoreAnimationDelegate)

- (void)animationDidStart:(CAAnimation *)anim {
    [self _callOnStartIfNeeded];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)gracefullyFinished {
    [self _callCompletionIfNeededHasGracefullyFinished:gracefullyFinished];
    if (self.resetBeginTimeOnNextIteration) {
        _layer.beginTime = _initialAnimation.beginTime;
        self.resetBeginTimeOnNextIteration = NO;
    }
}

- (void)_callOnStartIfNeeded {
    if (_onStart != nil) {
        _onStart();
    }
    _started = YES;
}

- (void)_callCompletionIfNeededHasGracefullyFinished:(BOOL)gracefullyFinished {
    const BOOL started = _started;
    _animation.delegate = nil;
    _started = NO;
    _finished = YES;
    if (_completion != nil) {
        const BOOL hasNoLayer = (_layer == nil);
        const BOOL res = hasNoLayer
        ? YES
        : (_cleared
           ? NO
           : (_paused
              ? YES
              : (started ? gracefullyFinished : YES))
           );
        _completion(res);
    }
}

@end

@implementation TimelineEntity (Control)

- (void)playWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
                    onStart:(TimelineAnimationOnStartBlock)callerOnStart
                 onComplete:(TimelineAnimationCompletionBlock)callerCompletion
                repeatCount:(TimelineAnimationRepeatCount)repeatCount
             setModelValues:(BOOL)setsModelValues {
    
    NSParameterAssert(callerOnStart != nil);
    NSParameterAssert(callerCompletion != nil);
    
    __strong typeof(_layer) slayer = _layer;
    NSAssert(slayer, @"TimelineAnimations: The layer of the entity is `nil`. Something's wrong. Check it out. entity description follows: %@", self);
    guard (slayer != nil) else { return; };
    
    if (self.isPaused) {
        [self resumeWithCurrentTime:currentTime
                        repeatCount:repeatCount];
        return;
    }

    [self _prepareCallbacksOnStart:callerOnStart onComplete:callerCompletion];
    [self _scheduleWithCurrentTime:currentTime setsModelValues:setsModelValues];
}

- (void)_prepareCallbacksOnStart:(TimelineAnimationOnStartBlock)callerOnStart
                      onComplete:(TimelineAnimationCompletionBlock)callerCompletion {

    {   // hack for completion
        TimelineAnimationOnStartBlock userOnStart = [_onStart copy];

        __weak typeof(self) welf = self;
        self.onStart = ^{
            __strong typeof(welf) strelf = welf;
            guard (strelf != nil) else { _raise(EmptyTimelineAnimationException); return; }
            guard (strelf.cleared == NO) else { _raise(EmptyTimelineAnimationException); return; }

            if (callerOnStart != nil) {
                callerOnStart();
            }

            if (userOnStart != nil) {
                userOnStart();
            }

            strelf.onStart = userOnStart;
        };
    }

    {   // hack for completion
        TimelineAnimationCompletionBlock userCompletion = [_completion copy];

        __weak typeof(self) welf = self;
        self.completion = ^(BOOL result){
            __strong typeof(welf) strelf = welf;
            guard (strelf != nil) else { _raise(EmptyTimelineAnimationException); return; }
            guard (strelf.cleared == NO) else { _raise(EmptyTimelineAnimationException); return; }

            if (userCompletion != nil) {
                userCompletion(result);
            }

            if (callerCompletion != nil) {
                callerCompletion(result);
            }

            strelf.completion = userCompletion;
        };
    }
}

- (void)_scheduleWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
                 setsModelValues:(BOOL)setsModelValues {
    __strong typeof(_layer) slayer = _layer;
    NSAssert(slayer, @"TimelineAnimations: The layer of the entity is `nil`. Something's wrong. Check it out. entity description follows: %@", self);
    guard (slayer != nil) else { return; };

    _animation.delegate = self;
    const CFTimeInterval gap = _animation.duration * (CFTimeInterval)_progress;
    _animation.beginTime += (RelativeTime)currentTime();
    NSString *const key = [[NSString alloc] initWithFormat:@"timelineEntity.animationKey<%@>.%.3lf", _animation.keyPath, _initialAnimation.beginTime];
    _actualAnimationKey = [key copy];
    //    [_animation setValue:_actualAnimationKey forKey:_animationKey];
    if (setsModelValues) {
        [self _updateAnimationForSetModelValues];
    }
    self.speed = _speed;
    slayer.beginTime     -= gap;
    _animation.beginTime -= gap;
    [slayer addAnimation:_animation forKey:_actualAnimationKey];
    slayer.timelineAnimation = _timelineAnimation;

    _animation.delegate = nil;
}

- (void)pauseWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { _raise(EmptyTimelineAnimationException); return; };
    
    if (self.isPaused) {
        return;
    }
    
    _paused = YES;
    
    const CFTimeInterval pausedTime = [slayer convertTime:currentTime()
                                                fromLayer:nil];
    slayer.speed = 0.0f;
    slayer.timeOffset = pausedTime;
}

- (void)resumeWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
                  repeatCount:(TimelineAnimationRepeatCount)repeatCount {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { _raise(EmptyTimelineAnimationException); return; };
    guard (self.isPaused) else { return; }

    const CFTimeInterval pausedTime = slayer.timeOffset;
    slayer.speed                    = _speed;
    slayer.timeOffset               = (CFTimeInterval)0.0;
    slayer.beginTime                = (CFTimeInterval)0.0;
    const CFTimeInterval timeSincePause = [slayer convertTime:currentTime()
                                                    fromLayer:nil] - pausedTime;
    slayer.beginTime = timeSincePause;

    // if associated timelines are indefenitely repeating then do not set a
    // deffered .beginTime
    if (repeatCount == TimelineAnimationRepeatCountInfinite) {
        self.resetBeginTimeOnNextIteration = YES;
    }

    _paused = NO;
}

- (void)clear {
    __strong typeof(_layer) slayer = _layer;
    
    _cleared = YES;
    _paused = NO;
    _animation.delegate = nil;
    _initialAnimation.delegate = nil;
    
    _onStart = nil;
    _completion = nil;
    
    guard (slayer != nil) else {
        return;
    }
    
    [slayer removeAnimationForKey:_actualAnimationKey];
    slayer.timelineAnimation = nil;
    
    if (slayer.speed != 1.0f) {
        slayer.speed = 1.0f;
    }
    if (slayer.timeOffset != (CFTimeInterval)0.0) {
        slayer.timeOffset = (CFTimeInterval)0.0;
    }
    if (slayer.repeatCount != 0.0f) {
        slayer.repeatCount = 0.0f;
    }
    if (slayer.repeatDuration != (CFTimeInterval)0.0) {
        slayer.repeatDuration = (CFTimeInterval)0.0;
    }
    if (slayer.duration != INFINITY) {
        slayer.duration = INFINITY;
    }
    if (slayer.autoreverses != NO) {
        slayer.autoreverses = NO;
    }
    if (![slayer.fillMode isEqualToString:kCAFillModeRemoved]) {
        slayer.fillMode = kCAFillModeRemoved;
    }
    if (slayer.beginTime != (CFTimeInterval)0.0) {
        slayer.beginTime = (CFTimeInterval)0.0;
    }
    slayer = nil;
}

- (void)resetWithRepeatCount:(TimelineAnimationRepeatCount)repeatCount {
    self.animationKey = _initialAnimationKey;
    self.animation    = _initialAnimation;

    if ((repeatCount == (TimelineAnimationRepeatCount)0LL) || self.restoresValues) {
        [self _restoreInitialValues];
    }
}

- (void)_restoreInitialValues {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { _raise(EmptyTimelineAnimationException); return; };
    
    NSString *const keyPath = _animation.keyPath;
    [slayer setValue:_initialValue forKeyPath:keyPath];
}

- (id)_updateAnimationForSetModelValues {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { _raise(EmptyTimelineAnimationException); return nil; };
    if ([_animation isKindOfClass:[CABasicAnimation class]]) {
        return [self __updateAnimation_basicAnimation];
    }
    if ([_animation isKindOfClass:[CAKeyframeAnimation class]]) {
        return [self __updateAnimation_keyframeAnimation];
    }
    return nil;
}

- (id)__updateAnimation_keyframeAnimation {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { _raise(EmptyTimelineAnimationException); return nil; };
    
    __kindof CAKeyframeAnimation *const keyframeAnimation   = (__kindof CAKeyframeAnimation *)_animation;
    keyframeAnimation.fillMode            = kCAFillModeBackwards;
    keyframeAnimation.removedOnCompletion = YES;
    id to                                 = keyframeAnimation.values.lastObject;
    [self _updateModelValues:to];
    return to;
}

- (id)__updateAnimation_basicAnimation {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { _raise(EmptyTimelineAnimationException); return nil; };
    
    __kindof CABasicAnimation *const basicAnimation   = (__kindof CABasicAnimation *)_animation;
    NSString *const keyPath            = basicAnimation.keyPath;
    basicAnimation.fillMode            = kCAFillModeBackwards;
    basicAnimation.removedOnCompletion = YES;
    id to                              = basicAnimation.toValue;
    basicAnimation.toValue             = nil;
    if (basicAnimation.fromValue == nil) {
        basicAnimation.fromValue       = [slayer valueForKeyPath:keyPath];
    }
    [self _updateModelValues:to];
    return to;
}

- (void)_updateModelValues:(id)to {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { _raise(EmptyTimelineAnimationException); return; };
    guard ([_animation isKindOfClass:[CAPropertyAnimation class]]) else { _raise(EmptyTimelineAnimationException); return;  }
    
    __kindof CAPropertyAnimation *const basicAnimation   = (__kindof CAPropertyAnimation *)_animation;
    NSString *const keyPath = basicAnimation.keyPath;
    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [slayer setValue:to forKeyPath:keyPath];
    [CATransaction commit];
}

@end

@implementation TimelineEntity (Copying)

-(instancetype)initWithTimelineEntity:(TimelineEntity *)timelineEntity {
    TimelineEntity *const entity =
    [self initWithLayer:timelineEntity.layer
              animation:timelineEntity.animation
           animationKey:timelineEntity.animationKey
              beginTime:timelineEntity.initialAnimation.beginTime
                onStart:timelineEntity.onStart
             onComplete:timelineEntity.completion
      timelineAnimation:timelineEntity.timelineAnimation];
    entity.restoresValues = self.restoresValues;
    return entity;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[TimelineEntity alloc] initWithTimelineEntity:self];
}

@end

@implementation TimelineEntity (Reverse)


- (instancetype)reversedCopy {
    TimelineEntity *reversedCopy = [[TimelineEntity alloc] initWithLayer:_layer
                                                               animation:[_initialAnimation reversedAnimation]
                                                            animationKey:_animationKey
                                                               beginTime:_initialAnimation.beginTime
                                                                 onStart:_onStart
                                                              onComplete:_completion
                                                       timelineAnimation:_timelineAnimation];
    reversedCopy.restoresValues = self.restoresValues;
    return reversedCopy;
}

@end

@implementation TimelineEntity (Conflicts)

- (BOOL)conflictingWith:(TimelineEntity *)other {
    if (other.layer != _layer) {
        return NO;
    }
    
    if (![other.animationKey isEqualToString:_animationKey]) {
        return NO;
    }
    
    if (![other.animation.keyPath isEqualToString:_animation.keyPath]) {
        return NO;
    }
    
    // at this instant we have:
    // - same layer
    // - same animation key
    // - same keypath
    
    // there is snag you see…,
    // due to bad planning float comparison sucks, so we transform everything
    // in milliseconds and treat them as integers
    const int64_t selfBeginTime = (int64_t)(self.beginTime * (RelativeTime)1000.0); // make it ms
    const int64_t selfEndTime = (int64_t)(self.endTime * (RelativeTime)1000.0); // make it ms
    
    int64_t otherBeginTime = (int64_t)(other.beginTime * (RelativeTime)1000.0); // make it ms
    int64_t otherEndTime = (int64_t)(other.endTime * (RelativeTime)1000.0); // make it ms
    
    // if I begin before the other ends, |or| the other begins before I end! - boumis the painter
    if ( ((selfBeginTime > otherBeginTime) && (selfBeginTime < otherEndTime)) ||
        ((otherBeginTime > selfBeginTime) && (otherBeginTime < selfEndTime)) ) {
        return YES; // conflict
    }
    
    return NO;
}

@end

@implementation TimelineEntity (Duration)

- (instancetype)copyWithDuration:(NSTimeInterval)newDuration
           shouldAdjustBeginTime:(BOOL)adjust
             usingTotalBeginTime:(RelativeTime)totalBeginTime {
    
    const NSTimeInterval oldDuration = self.duration;
    const NSTimeInterval factor      = newDuration / oldDuration;
    
    __kindof CAPropertyAnimation *const animation = (__kindof CAPropertyAnimation *)self.animation.copy;
    const NSTimeInterval newAnimationDuration = (NSTimeInterval) (((NSTimeInterval)animation.duration) * factor);
    animation.duration  = newAnimationDuration;
    
    TimelineEntity *entity = [[TimelineEntity alloc] initWithLayer:_layer
                                                         animation:animation
                                                      animationKey:_animationKey
                                                         beginTime:_initialAnimation.beginTime
                                                           onStart:_onStart
                                                        onComplete:_completion
                                                 timelineAnimation:_timelineAnimation];
    if (adjust) {
        entity.beginTime = totalBeginTime + ((self.beginTime - totalBeginTime) * factor);
    }
    if (newAnimationDuration < TimelineAnimationMillisecond) {
        entity.beginTime = MAX(entity.beginTime - TimelineAnimationMillisecond, (RelativeTime)0);
        entity.animation.duration = TimelineAnimationMillisecond; // 1ms
    }
    else {
        entity.animation.duration = (CFTimeInterval)Round(entity.animation.duration);
    }
    entity.restoresValues = self.restoresValues;
    return entity;
}

@end
