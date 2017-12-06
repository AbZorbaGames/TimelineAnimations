//
//  AnimationsFactory.m
//  TimelineAnimations
//
//  Created by AbZorba Games on 07/09/2015.
//  Copyright (c) 2015-2016 AbZorba Games. All rights reserved.
//

#import "TimelineAnimations.h"
#import "AnimationsKeyPath.h"

@implementation AnimationsFactory

#pragma mark - Generic Methods

+ (CAPropertyAnimation *)animateWithKeyPath:(AnimationKeyPath)keyPath
                                  fromValue:(nullable id)fromValue
                                    toValue:(nullable id)toValue
                                   duration:(CFTimeInterval)duration
                                   delegate:(nullable id)delegate
                             timingFunction:(ECustomTimingFunction)timingFunction {
    
    NSParameterAssert([EasingTimingHandler isSpecialTimingFunction:timingFunction] == NO);
    
    CAPropertyAnimation *const animation = ^CAPropertyAnimation *(void) {
        if ([EasingTimingHandler isSpecialTimingFunction:timingFunction]) {
            NSAssert(false,
                     @"Use CAKeyframe+SpecialEasing extensions directly "
                     "to create animation with special timing functions.");
            return nil;
        }
        else {
            CABasicAnimation *const basic = [CABasicAnimation animationWithKeyPath:keyPath];
            basic.fromValue               = fromValue;
            basic.toValue                 = toValue;
            basic.timingFunction          = [EasingTimingHandler functionWithType:timingFunction];
            return basic;
        }
    }();
    animation.duration = duration;
    animation.delegate = delegate;
    
    return animation;
}


+ (CAPropertyAnimation *)animateWithKeyPath:(AnimationKeyPath)keyPath
                               fromValue:(nullable id)fromValue
                                 toValue:(nullable id)toValue
                                duration:(CFTimeInterval)duration
                          timingFunction:(ECustomTimingFunction)timingFunction {
    
    return [self animateWithKeyPath:keyPath
                          fromValue:fromValue
                            toValue:toValue
                           duration:duration
                           delegate:nil
                     timingFunction:timingFunction];
}


+ (CAPropertyAnimation *)animateWithKeyPath:(AnimationKeyPath)keyPath
                                 toValue:(id)toValue
                                duration:(CFTimeInterval)duration
                                delegate:(id)delegate
                          timingFunction:(ECustomTimingFunction)timingFunction {
    
    return [self animateWithKeyPath:keyPath
                          fromValue:nil
                            toValue:toValue
                           duration:duration
                           delegate:delegate
                     timingFunction:timingFunction];
}

+ (CAPropertyAnimation *)animateWithKeyPath:(AnimationKeyPath)keyPath
                                 toValue:(id)toValue
                                duration:(CFTimeInterval)duration
                          timingFunction:(ECustomTimingFunction)timingFunction {
    
    return [self animateWithKeyPath:keyPath
                          fromValue:nil
                            toValue:toValue
                           duration:duration
                           delegate:nil
                     timingFunction:timingFunction];
}

#pragma mark - Move

+ (CAPropertyAnimation *)moveFromValue:(nullable NSValue *)fromValue
                            toValue:(nullable NSValue *)toValue
                           duration:(CFTimeInterval)duration
                           delegate:(nullable id)delegate
                     timingFunction:(ECustomTimingFunction)timingFunction {
    
    return [self animateWithKeyPath:kAnimationKeyPathPosition
                          fromValue:fromValue
                            toValue:toValue
                           duration:duration
                           delegate:delegate
                     timingFunction:timingFunction];
}

+ (CAPropertyAnimation *)moveFromValue:(id)fromValue
                            toValue:(id)toValue
                           duration:(CFTimeInterval)duration
                     timingFunction:(ECustomTimingFunction)timingFunction {
    return [self animateWithKeyPath:kAnimationKeyPathPosition
                          fromValue:fromValue
                            toValue:toValue
                           duration:duration
                     timingFunction:timingFunction];
}

+ (CAPropertyAnimation *)moveToValue:(nullable NSValue *)toValue
                         duration:(CFTimeInterval)duration
                         delegate:(nullable id)delegate
                   timingFunction:(ECustomTimingFunction)timingFunction {
    
    return [self animateWithKeyPath:kAnimationKeyPathPosition
                            toValue:toValue
                           duration:duration
                           delegate:delegate
                     timingFunction:timingFunction];
}


+ (CAPropertyAnimation *)moveToValue:(nullable NSValue *)toValue
                         duration:(CFTimeInterval)duration
                   timingFunction:(ECustomTimingFunction)timingFunction {
    return [self animateWithKeyPath:kAnimationKeyPathPosition
                            toValue:toValue
                           duration:duration
                     timingFunction:timingFunction];
}


+ (CAAnimationGroup *)animationGroupWithAnimations:(NSArray *)animations duration:(CFTimeInterval)duration {
    CAAnimationGroup *const animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = duration;
    animationGroup.animations = animations;
    return animationGroup;
}

+ (CAKeyframeAnimation *)keyframeAnimationWithKeyPath:(NSString *)keyPath
                                             duration:(CFTimeInterval)duration
                                               values:(NSArray *)values
                                             keyTimes:(nullable NSArray<NSNumber *> *)keyTimes
                                       timingFunction:(ECustomTimingFunction)timingFunction {

    CAKeyframeAnimation *const animation = [CAKeyframeAnimation animation];
    animation.duration = duration;
    animation.keyPath = keyPath;
    animation.values = values;
    if (keyTimes) {
        animation.keyTimes = keyTimes;
    }
    animation.timingFunction = [EasingTimingHandler functionWithType:timingFunction];
    
    return animation;
}

#pragma mark - Fade

+ (CAPropertyAnimation *)fadeWithDuration:(CFTimeInterval)duration
                             fromValue:(CGFloat)fromValue
                               toValue:(CGFloat)toValue
                        timingFunction:(ECustomTimingFunction)timingFunction {
    
    return [self animateWithKeyPath:kAnimationKeyPathOpacity
                          fromValue:@(fromValue)
                            toValue:@(toValue)
                           duration:duration
                     timingFunction:timingFunction];
}


+ (CAPropertyAnimation *)fadeInWithDuration:(CFTimeInterval)duration
                          timingFunction:(ECustomTimingFunction)timingFunction {
    return [self fadeWithDuration:duration
                        fromValue:0
                          toValue:1
                   timingFunction:timingFunction];
}


+ (CAPropertyAnimation *)fadeOutWithDuration:(CFTimeInterval)duration
                           timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT {
    return [self fadeWithDuration:duration
                        fromValue:1
                          toValue:0
                   timingFunction:timingFunction];
}

#pragma mark - Scale & Bounce

+ (CAPropertyAnimation *)scaleWithDuration:(CFTimeInterval)duration
                              fromValue:(CGFloat)fromValue
                                toValue:(CGFloat)toValue
                         timingFunction:(ECustomTimingFunction)timingFunction {
    
    return [self animateWithKeyPath:kAnimationKeyPathScale
                          fromValue:@(fromValue)
                            toValue:@(toValue)
                           duration:duration
                     timingFunction:timingFunction];
    
}

+ (CAKeyframeAnimation *)scaleWithBounceDuration:(CFTimeInterval)duration
                                       fromValue:(CGFloat)fromValue
                                         toValue:(CGFloat)toValue
                                         byValue:(CGFloat)byValue
                                  timingFunction:(ECustomTimingFunction)timingFunction {
    
    return [self keyframeAnimationWithKeyPath:kAnimationKeyPathScale
                                     duration:duration
                                       values:@[@(fromValue), @(byValue), @(toValue)]
                                     keyTimes:nil
                               timingFunction:timingFunction];
}

//+ (CAKeyframeAnimation *)bouncePositionWithDuration:(CFTimeInterval)duration
//                                     targetPosition:(CGPoint)position
//                                       bounceOffset:(CGFloat)bounceOffset {
//    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:kAnimationKeyPathPosition];
//    bounceAnimation.duration    = duration;
//    //    bounceAnimation.values      = @[[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(label.frame), CGRectGetMidY(label.frame))],
//    //                                    [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(label.frame) + offsetX, CGRectGetMidY(label.frame) - maxOffsetY)],
//    //                                    [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(label.frame) + offsetX, CGRectGetMidY(label.frame))],
//    //                                    [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(label.frame) + offsetX, CGRectGetMidY(label.frame) - minOffsetY)],
//    //                                    [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(label.frame) + offsetX, CGRectGetMidY(label.frame))]
//    //                                    ];
//
//    return bounceAnimation;
//}

@end
