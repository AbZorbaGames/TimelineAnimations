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


#define LOST 0

#pragma mark - TimelineObject Implementation -

@interface TimelineEntity () {
#if LOST
    struct {
        double currentPauseTime;
        double totalPauseTime;
        double currentChangeSpeedTime;
        double currentTimeLostResultingFromSpeedChange;
        double totalTimeLostResultingFromSpeedChange;
    } speedChanges;
#endif /* LOST */
}
@property (nonatomic, strong) __kindof CALayer *layer;
@property (nonatomic, copy) __kindof CAPropertyAnimation *animation;
@property (nonatomic, copy) NSString *animationKey;
// reset values
@property (nonatomic, copy) __kindof CAPropertyAnimation *initialAnimation;
@property (nonatomic, copy) id initialValue;
@property (nonatomic, copy) id initialAnimationKey;

@property (nonatomic, assign, getter=wasReseted) BOOL reseted;
- (instancetype)init NS_DESIGNATED_INITIALIZER;

@property (nonatomic, copy) BoolBlock userCompletion;
@property (nonatomic, copy) VoidBlock userOnStart;

@property (nonatomic, copy) BoolBlock playCompletion;
@property (nonatomic, copy) VoidBlock playOnStart;
@end


@implementation TimelineEntity

#pragma mark - Initializer

- (instancetype)init
{
    return [super init];
}

- (instancetype)initWithLayer:(__kindof CALayer *)layer
                    animation:(__kindof CAPropertyAnimation *)animation
                 animationKey:(NSString *)key
                    beginTime:(NSTimeInterval)beginTime
                      onStart:(nullable VoidBlock)onStart
                   onComplete:(nullable BoolBlock)completion {
    self = [super init];
    if (self) {
        _layer               = layer;
        _animation           = animation.copy;
        _animationKey        = key;
        _speed               = 1;
        _onStart             = [onStart copy];
        _completion          = [completion copy];

        _animation.beginTime = beginTime;

        _initialAnimation    = _animation.copy;
        _initialAnimationKey = key.copy;
        [self storeInitialValues];
    }
    return self;
}

#pragma mark - Reset

- (void)storeInitialValues {
    NSString *keyPath = _animation.keyPath;

    // values used for reset
    id value = [_layer valueForKeyPath:keyPath];
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

- (void)restoreInitialValues {
    self.animationKey     = _initialAnimationKey;
    self.animation        = _initialAnimation.copy;
    NSString *keyPath = _animation.keyPath;
    [_layer setValue:_initialValue forKeyPath:keyPath];
}

- (void)reset {
    [self restoreInitialValues];
}

- (void)clearEntity {
    _animation.delegate = nil;
    _initialAnimation.delegate = nil;
    [_layer removeAllAnimations];
}

#if LOST
- (void)updateTotalTimeLostResultingFromSpeedChange {
    double value = [_layer convertTime:CACurrentMediaTime() fromLayer:_layer] - speedChanges.currentChangeSpeedTime;
    speedChanges.currentChangeSpeedTime = value - (value * _layer.speed);
    speedChanges.totalTimeLostResultingFromSpeedChange += speedChanges.currentTimeLostResultingFromSpeedChange;
}

- (void)resetTotalTimeLostResultingFromSpeedChange {
    speedChanges.totalTimeLostResultingFromSpeedChange = 0;
}
#endif

- (void)playOnStart:(VoidBlock)onStart
         onComplete:(BoolBlock)comlete
     setModelValues:(BOOL)setsModelVaules {
    if (self.isPaused) {
        [self resume];
        return;
    }

    self.playOnStart    = onStart;
    self.playCompletion = comlete;

    self.userOnStart    = self.onStart;
    self.userCompletion = self.completion;

    __weak typeof(self) welf = self;
    self.onStart = ^{
        __strong typeof(welf) sself = welf;
        if (sself.playOnStart) {
            sself.playOnStart();
        }
        sself.onStart = sself.userOnStart;
        [sself callOnStartIfNeeded];
        sself.playOnStart = nil;
        sself.userOnStart = nil;
    };

    self.completion = ^(BOOL result){
        __strong typeof(welf) sself = welf;
        sself.completion = sself.userCompletion;
        if (sself.completion) {
            sself.completion(result);
        }
        if (sself.playCompletion) {
            sself.playCompletion(result);
        }
        sself.userCompletion = nil;
        sself.playCompletion = nil;
    };

    _animation.delegate = self;
    _animation.beginTime += CACurrentMediaTime();
    [_animation setValue:_animationKey forKey:@"key"];
    if (setsModelVaules) {
        [self updateModelValues];
    }
    self.speed = _speed;
    [_layer addAnimation:_animation forKey:_animationKey];
}

- (void)pause {
    if (self.isPaused)
        return;

    _paused = YES;

#if LOST
    [self updateTotalTimeLostResultingFromSpeedChange];
    _layer.speed = 0;
    _layer.timeOffset = [_layer convertTime:CACurrentMediaTime() fromLayer:_layer] - speedChanges.totalPauseTime - speedChanges.totalTimeLostResultingFromSpeedChange;
    speedChanges.currentPauseTime = _layer.timeOffset;
#else
    CFTimeInterval pausedTime = [_layer convertTime:CACurrentMediaTime() fromLayer:nil];
    _layer.speed = 0.0;
    _layer.timeOffset = pausedTime;
#endif /* LOST */
}

- (void)resume {
    if (!self.isPaused)
        return;

#if LOST
    _layer.speed      = _speed;
    _layer.timeOffset = 0;
    _layer.beginTime  = 0;

    [self resetTotalTimeLostResultingFromSpeedChange];

    speedChanges.totalPauseTime = [_layer convertTime:CACurrentMediaTime() fromLayer:_layer] - speedChanges.currentPauseTime;
    _layer.beginTime = speedChanges.totalPauseTime;
    self.speed = _speed;
#else
    CFTimeInterval pausedTime = _layer.timeOffset;
    _layer.speed = _speed;
    _layer.timeOffset = 0.0;
    _layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [_layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    _layer.beginTime = timeSincePause;
#endif /* LOST */
    _paused = NO;
}

- (void)updateModelValues {
    if (![_animation isKindOfClass:[CABasicAnimation class]])
        return;

    CABasicAnimation *basicAnimation   = (CABasicAnimation *)_animation;
    basicAnimation.fillMode            = kCAFillModeBackwards;
    basicAnimation.removedOnCompletion = YES;
    id to                              = basicAnimation.toValue;
    NSString *keyPath                  = basicAnimation.keyPath;
    basicAnimation.toValue             = nil;
    if (basicAnimation.fromValue == nil) {
        basicAnimation.fromValue       = [_layer valueForKeyPath:keyPath];
    }
    [_layer setValue:to forKeyPath:keyPath];
}

#pragma mark - Public

- (void)callOnStartIfNeeded {
    if (_onStart)
        _onStart();
}

- (void)callCompletionIfNeededWithResult:(BOOL)result {
    _animation.delegate = nil;
    _finished           = YES;
    if (_completion)
        _completion(result);
}


#pragma mark - Properties

- (NSTimeInterval)beginTime {
    return _animation.beginTime;
}

- (void)setBeginTime:(NSTimeInterval)beginTime {
    _initialAnimation.beginTime = 
    _animation.beginTime        = beginTime;
}

- (NSTimeInterval)endTime {
    return _animation.beginTime + _animation.duration;
}

- (void)setSpeed:(float)speed {
    if (speed < 0)
        speed = 0;
#if LOST
    [self updateTotalTimeLostResultingFromSpeedChange];
    speedChanges.currentChangeSpeedTime = [_layer convertTime:CACurrentMediaTime() fromLayer:_layer];
    _layer.timeOffset = speedChanges.currentChangeSpeedTime - speedChanges.totalPauseTime - speedChanges.totalTimeLostResultingFromSpeedChange;
    _layer.beginTime = CACurrentMediaTime();
    _layer.speed = speed;
#else
    _layer.timeOffset = [_layer convertTime:CACurrentMediaTime() fromLayer:_layer];
    _layer.beginTime  = CACurrentMediaTime();
    _layer.speed      = speed;
#endif /* LOST */
    _speed = speed;
}

#pragma mark - Core Animation Delegate 

- (void)animationDidStart:(CAAnimation *)anim {
    [self callOnStartIfNeeded];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    [self callCompletionIfNeededWithResult:flag];
}

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"<<%@: %p> animationKey:\"%@\" beginTime:\"%lf\", endTime:\"%lf\">", NSStringFromClass(self.class), self, _animationKey, self.beginTime, self.endTime];
}

#pragma mark - 

- (id)copyWithZone:(NSZone *)zone {
    TimelineEntity *copy = [[TimelineEntity alloc] initWithLayer:_layer
                                                       animation:_animation
                                                    animationKey:_animationKey
                                                       beginTime:_initialAnimation.beginTime
                                                         onStart:_onStart
                                                      onComplete:_completion];

    return copy;
}

- (instancetype)reversedCopy {
    TimelineEntity *reversedCopy = [[TimelineEntity alloc] initWithLayer:_layer
                                                               animation:[_initialAnimation reversedAnimation]
                                                            animationKey:_animationKey
                                                               beginTime:_initialAnimation.beginTime
                                                                 onStart:_onStart
                                                              onComplete:_completion];
    return reversedCopy;
}

- (BOOL)isEqual:(id)object {
    if (self == object)
        return YES;

    if (![object isKindOfClass:self.class])
        return NO;

    TimelineEntity *other = (TimelineEntity *)object;
    if (other.layer != _layer)
        return NO;

    if (![other.animationKey isEqualToString:_animationKey])
        return NO;

    if (![other.animation.keyPath isEqualToString:_animation.keyPath])
        return NO;
    return YES;
}

@end
