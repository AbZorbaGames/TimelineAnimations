//
//  TimelineEntity.m
//  TimelineAnimations
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

#import "TimelineEntity.h"
#import "AnimationsKeyPath.h"
#import <sys/types.h>
#import <sys/sysctl.h>
#import "CAPropertyAnimation+Reverse.h"
#import "CABasicAnimation+Reverse.h"
#import "CAKeyframeAnimation+Reverse.h"
#import "CALayer+TimelineAnimation.h"

#ifndef guard
#define guard(cond) if ((cond)) {} 
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

@property (nonatomic, copy) BoolBlock _Nullable completion;
@property (nonatomic, copy) VoidBlock _Nullable onStart;

@property (nonatomic, readwrite) BOOL cleared;

@property (nonatomic, copy) NSString *actualAnimationKey;

- (instancetype)init NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithLayer:(__kindof CALayer *)layer
                    animation:(__kindof CAPropertyAnimation *)animation
                 animationKey:(NSString *)key
                    beginTime:(RelativeTime)beginTime
                      onStart:(nullable VoidBlock)onStart
                   onComplete:(nullable BoolBlock)completion
            timelineAnimation:(TimelineAnimation *)timelineAnimation NS_DESIGNATED_INITIALIZER;
@end

@interface TimelineEntity (CoreAnimationDelegate)
- (void)_callOnStartIfNeeded;
- (void)_callCompletionIfNeededWithResult:(BOOL)result;
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
                      onStart:(nullable VoidBlock)onStart
                   onComplete:(nullable BoolBlock)completion
            timelineAnimation:(TimelineAnimation *)timelineAnimation {

    NSString *key        = [NSString stringWithFormat:@"timelineEntity.animationKey.%@", animation.keyPath];
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
                      onStart:(nullable VoidBlock)onStart
                   onComplete:(nullable BoolBlock)completion
            timelineAnimation:(TimelineAnimation *)timelineAnimation {
    NSParameterAssert(layer);
    NSParameterAssert(animation);
    NSParameterAssert(key);
    NSParameterAssert(timelineAnimation);

    self = [super init];
    if (self) {
        _layer               = layer;
        _animation           = animation.copy;
        _animationKey        = key.copy;
        _actualAnimationKey  = key.copy;
        _speed               = 1;
        _onStart             = [onStart copy];
        _completion          = [completion copy];
        _timelineAnimation   = timelineAnimation;

        _animation.beginTime = beginTime;

        _initialAnimation    = _animation.copy;
        _initialAnimationKey = key.copy;
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

    NSString *keyPath = _animation.keyPath;

    // values used for reset
    id value = [slayer valueForKeyPath:keyPath];
    if ([_animation isKindOfClass:[CABasicAnimation class]]) {
        CABasicAnimation *basicAnimation = _animation;
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
    return _animation.beginTime;
}

- (void)setBeginTime:(RelativeTime)beginTime {
    _initialAnimation.beginTime =
    _animation.beginTime        = beginTime;
}

- (RelativeTime)endTime {
    return (RelativeTime)(_animation.beginTime + _animation.duration);
}

- (NSTimeInterval)duration {
    return (NSTimeInterval)(_animation.duration);
}

- (void)setSpeed:(float)speed {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { return; };

    if (speed < 0) {
        speed = 0;
    }
    // speeds are equal
    if (fabsf(speed - _speed) < 0.001 &&
        fabsf(speed - slayer.speed) < 0.001) {
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

#pragma mark - Equality

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isKindOfClass:self.class]) {
        return NO;
    }

    TimelineEntity *other = (TimelineEntity *)object;
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
    return [NSString stringWithFormat:@"<%@ %p: "
            "key = \"%@\"; "
            "keyPath = \"%@\"; "
            "beginTime = \"%.3lf\"; "
            "endTime = \"%.3lf\"; "
            "duration = \"%.3lf\"; "
            "finished = %@; "
            "paused = %@; "
            "cleared = %@; "
            "onStart = %@; "
            "completion = %@; "
            "timeline = [%p::%@]; "
            "layer = %@;"
            ">",
            NSStringFromClass(self.class),
            self,
            _animationKey,
            _animation.keyPath,
            self.beginTime,
            self.endTime,
            self.duration,
            @(self.finished),
            @(self.paused),
            @(self.cleared),
            @(_onStart != nil),
            @(_completion != nil),
            stimeline,
            stimeline.name,
            self.layer
            ];
}

@end

#pragma mark - Core Animation Delegate

@implementation TimelineEntity (CoreAnimationDelegate)

- (void)animationDidStart:(CAAnimation *)anim {
    [self _callOnStartIfNeeded];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self _callCompletionIfNeededWithResult:flag];
}

- (void)_callOnStartIfNeeded {
    if (_onStart) {
        _onStart();
    }
}

- (void)_callCompletionIfNeededWithResult:(BOOL)result {
    _animation.delegate = nil;
    _finished           = YES;
    if (_completion && !_cleared) {
        _completion(result);
    }
}

@end

@implementation TimelineEntity (Control)

- (void)playOnStart:(VoidBlock)callerOnStart
         onComplete:(BoolBlock)callerCompletion
     setModelValues:(BOOL)setsModelVaules {

    NSParameterAssert(callerOnStart);
    NSParameterAssert(callerCompletion);

    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { return; };

    if (self.isPaused) {
        [self resume];
        return;
    }

    VoidBlock userOnStart = [_onStart copy];
    BoolBlock userCompletion = [_completion copy];

    __weak typeof(self) welf = self;
    self.onStart = ^{
        __strong typeof(welf) strelf = welf;
        guard (strelf != nil) else { return; }
        guard (strelf.cleared == NO) else { return; }

        if (callerOnStart) {
            callerOnStart();
        }

        if (userOnStart) {
            userOnStart();
        }

        strelf.onStart = userOnStart;
    };

    self.completion = ^(BOOL result){
        __strong typeof(welf) strelf = welf;
        guard (strelf != nil) else { return; }
        guard (strelf.cleared == NO) else { return; }

        if (userCompletion) {
            userCompletion(result);
        }

        if (callerCompletion) {
            callerCompletion(result);
        }

        strelf.completion = userCompletion;
    };

    _animation.delegate = self;
    CFTimeInterval gap = _animation.duration * _progress;
    _animation.beginTime += CACurrentMediaTime();
    NSString *key = [NSString stringWithFormat:@"timelineEntity.animationKey<%@>.%lf", _animation.keyPath, _initialAnimation.beginTime];
    _actualAnimationKey = [key copy];
    [_animation setValue:_animationKey forKey:_actualAnimationKey];
    if (setsModelVaules) {
        [self _updateModelValues];
    }
    self.speed = _speed;
    slayer.beginTime     -= gap;
    _animation.beginTime -= gap;
    [slayer addAnimation:_animation forKey:_actualAnimationKey];
    slayer.timelineAnimation = _timelineAnimation;

    _animation.delegate = nil;

}

- (void)pause {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { return; };

    if (self.isPaused) {
        return;
    }


    _paused = YES;

    CFTimeInterval pausedTime = [slayer convertTime:CACurrentMediaTime() fromLayer:nil];
    slayer.speed = 0.0;
    slayer.timeOffset = pausedTime;
}

- (void)resume {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { return; };

    if (!self.isPaused) {
        return;
    }

    CFTimeInterval pausedTime     = slayer.timeOffset;
    slayer.speed                  = _speed;
    slayer.timeOffset             = 0.0;
    slayer.beginTime              = 0.0;
    CFTimeInterval timeSincePause = [slayer convertTime:CACurrentMediaTime()
                                              fromLayer:nil] - pausedTime;
    slayer.beginTime              = timeSincePause;

    _paused = NO;
}

- (void)clear {
    __strong typeof(_layer) slayer = _layer;

    _cleared = YES;
    _animation.delegate = nil;
    _initialAnimation.delegate = nil;
    //    [_layer removeAllAnimations]; // over-reacting
    [slayer removeAnimationForKey:_actualAnimationKey];
    slayer.speed = 1.0;
    slayer.timeOffset = 0.0;
    slayer.timelineAnimation = nil;
    slayer = nil;

    _onStart = nil;
    _completion = nil;
}

- (void)reset {
    guard (_layer != nil) else { return; };
    [self _restoreInitialValues];
}

- (void)_restoreInitialValues {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { return; };

    self.animationKey     = _initialAnimationKey;
    self.animation        = _initialAnimation;
    NSString *keyPath = _animation.keyPath;
    [slayer setValue:_initialValue forKeyPath:keyPath];
}

- (void)_updateModelValues {
    __strong typeof(_layer) slayer = _layer;
    guard (slayer != nil) else { return; };
    
    if (![_animation isKindOfClass:[CABasicAnimation class]]) {
        return;
    }

    __kindof CABasicAnimation *basicAnimation   = (__kindof CABasicAnimation *)_animation;
    NSString *keyPath                  = basicAnimation.keyPath;
    basicAnimation.fillMode            = kCAFillModeBackwards;
    basicAnimation.removedOnCompletion = YES;
    id to                              = basicAnimation.toValue;
    basicAnimation.toValue             = nil;
    if (basicAnimation.fromValue == nil) {
        basicAnimation.fromValue       = [slayer valueForKeyPath:keyPath];
    }
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [slayer setValue:to forKeyPath:keyPath];
    [CATransaction commit];
}

@end

@implementation TimelineEntity (Copying)

-(instancetype)initWithTimelineEntity:(TimelineEntity *)timelineEntity {
    return [self initWithLayer:timelineEntity.layer
                     animation:timelineEntity.animation
                  animationKey:timelineEntity.animationKey
                     beginTime:timelineEntity.initialAnimation.beginTime
                       onStart:timelineEntity.onStart
                    onComplete:timelineEntity.completion
             timelineAnimation:timelineEntity.timelineAnimation];
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

    // if I begin before the other, or the other begins before I end
    if ( ((self.beginTime > other.beginTime) && (self.beginTime < other.endTime)) ||
        ((other.beginTime > self.beginTime) && (other.beginTime < self.endTime)) ) {
        return YES; // conflict
    }

    return NO;
}
@end

@implementation TimelineEntity (Duration)

- (instancetype)copyWithDuration:(NSTimeInterval)newDuration
           shouldAdjustBeginTime:(BOOL)adjust
             usingTotalBeginTime:(RelativeTime)totalBeginTime {

    NSTimeInterval oldDuration = self.duration;
    NSTimeInterval factor      = newDuration / oldDuration;

    __kindof CAPropertyAnimation *animation = self.animation.copy;
    animation.duration  = self.duration * factor;


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
    return entity;
}

@end
