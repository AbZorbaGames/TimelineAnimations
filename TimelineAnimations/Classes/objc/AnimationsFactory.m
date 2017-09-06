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

+ (CABasicAnimation *)moveFromValue:(nullable NSValue *)fromValue
                            toValue:(nullable NSValue *)toValue
                           duration:(CFTimeInterval)duration
                           delegate:(id)delegate
                     timingFunction:(ECustomTimingFunction)timingFunction {
    return [self animateWithKeyPath:kAnimationKeyPathPosition
                          fromValue:fromValue
                            toValue:toValue
                           duration:duration
                           delegate:delegate
                     timingFunction:timingFunction];
}

+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                               fromValue:(nullable id)fromValue
                                 toValue:(nullable id)toValue
                                duration:(CFTimeInterval)duration
                                delegate:(id)delegate
                          timingFunction:(ECustomTimingFunction)timingFunction {


    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = keyPath;
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.duration = duration;
    animation.timingFunction = [EasingTimingHandler functionWithType:timingFunction];

    if (delegate)
        animation.delegate = delegate;

    return animation;
}

+ (CABasicAnimation *)moveFromValue:(id)fromValue toValue:(id)toValue duration:(CFTimeInterval)duration timingFunction:(ECustomTimingFunction)timingFunction {
    return [self animateWithKeyPath:kAnimationKeyPathPosition
                          fromValue:fromValue
                            toValue:toValue
                           duration:duration
                     timingFunction:timingFunction];
}

+ (CABasicAnimation *)moveToValue:(nullable NSValue *)toValue
                         duration:(CFTimeInterval)duration
                         delegate:(nullable id)delegate
                   timingFunction:(ECustomTimingFunction)timingFunction {
    return [self animateWithKeyPath:kAnimationKeyPathPosition
                            toValue:toValue
                           duration:duration
                           delegate:delegate
                     timingFunction:timingFunction];
}

+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                                 toValue:(id)toValue
                                duration:(CFTimeInterval)duration
                                delegate:(id)delegate
                          timingFunction:(ECustomTimingFunction)timingFunction {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = keyPath;
    animation.toValue = toValue;
    animation.duration = duration;
    animation.timingFunction = [EasingTimingHandler functionWithType:timingFunction];

    if (delegate)
        animation.delegate = delegate;

    return animation;
}

+ (CABasicAnimation *)moveToValue:(nullable NSValue *)toValue
                         duration:(CFTimeInterval)duration
                   timingFunction:(ECustomTimingFunction)timingFunction {
    return [self animateWithKeyPath:kAnimationKeyPathPosition
                            toValue:toValue
                           duration:duration
                     timingFunction:timingFunction];
}

+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                               fromValue:(nullable id)fromValue
                                 toValue:(nullable id)toValue
                                duration:(CFTimeInterval)duration
                          timingFunction:(ECustomTimingFunction)timingFunction {

    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath   = keyPath;
    animation.fromValue = fromValue;
    animation.toValue   = toValue;
    animation.duration  = duration;
    animation.timingFunction = [EasingTimingHandler functionWithType:timingFunction];

    return animation;
}

+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                                 toValue:(id)toValue
                                duration:(CFTimeInterval)duration
                          timingFunction:(ECustomTimingFunction)timingFunction {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = keyPath;
    animation.toValue = toValue;
    animation.duration = duration;
    animation.timingFunction = [EasingTimingHandler functionWithType:timingFunction];

    return animation;
}

+ (CAAnimationGroup *)animationGroupWithAnimations:(NSArray *)animations duration:(CFTimeInterval)duration {
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = duration;
    animationGroup.animations = animations;
    return animationGroup;
}

+ (CAKeyframeAnimation *)keyframeAnimationWithKeyPath:(NSString *)keyPath
                                             duration:(CFTimeInterval)duration
                                               values:(NSArray *)values
                                             keyTimes:(nullable NSArray<NSNumber *> *)keyTimes
                                       timingFunction:(ECustomTimingFunction)timingFunction {

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.duration = duration;
    animation.keyPath = keyPath;
    animation.values = values;
    if (keyTimes) animation.keyTimes = keyTimes;
    animation.timingFunction = [EasingTimingHandler functionWithType:timingFunction];

    return animation;
}

+ (CABasicAnimation *)fadeWithDuration:(CFTimeInterval)duration
                             fromValue:(CGFloat)fromValue
                               toValue:(CGFloat)toValue
                        timingFunction:(ECustomTimingFunction)timingFunction {

    return [[self class] animateWithKeyPath:kAnimationKeyPathOpacity
                                  fromValue:@(fromValue)
                                    toValue:@(toValue)
                                   duration:duration
                             timingFunction:timingFunction];
}


+ (CABasicAnimation *)fadeInWithDuration:(CFTimeInterval)duration
                          timingFunction:(ECustomTimingFunction)timingFunction {
    return [[self class] fadeWithDuration:duration
                                fromValue:0
                                  toValue:1
                           timingFunction:timingFunction];
}


+ (CABasicAnimation *)fadeOutWithDuration:(CFTimeInterval)duration
                           timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT {
    return [[self class] fadeWithDuration:duration
                                fromValue:1
                                  toValue:0
                           timingFunction:timingFunction];
}

+ (CABasicAnimation *)scaleWithDuration:(CFTimeInterval)duration
                              fromValue:(CGFloat)fromValue
                                toValue:(CGFloat)toValue
                         timingFunction:(ECustomTimingFunction)timingFunction {

    return [[self class] animateWithKeyPath:kAnimationKeyPathScale
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

    return [[self class] keyframeAnimationWithKeyPath:kAnimationKeyPathScale
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
