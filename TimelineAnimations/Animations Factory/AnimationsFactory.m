//
//  AnimationsFactory.m
//
//  Created by AbZorba Games on 07/09/2015.
//  Copyright (c) 2015-2016 AbZorba Games. All rights reserved.
//

#import "AnimationsFactory.h"
#import "AnimationsKeyPath.h"

@implementation AnimationsFactory

+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                               fromValue:(nullable id)fromValue
                                 toValue:(nullable id)toValue
                                duration:(CGFloat)duration
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

+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                                 toValue:(id)toValue
                                duration:(CGFloat)duration
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

+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                               fromValue:(nullable id)fromValue
                                 toValue:(nullable id)toValue
                                duration:(CGFloat)duration
                          timingFunction:(ECustomTimingFunction)timingFunction {

    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = keyPath;
    animation.fromValue = fromValue;
    animation.toValue = toValue;
    animation.duration = duration;
    animation.timingFunction = [EasingTimingHandler functionWithType:timingFunction];

    return animation;
}

+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                                 toValue:(id)toValue
                                duration:(CGFloat)duration
                          timingFunction:(ECustomTimingFunction)timingFunction {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = keyPath;
    animation.toValue = toValue;
    animation.duration = duration;
    animation.timingFunction = [EasingTimingHandler functionWithType:timingFunction];

    return animation;
}

+ (CAAnimationGroup *)animationGroupWithAnimations:(NSArray *)animations andDuration:(CGFloat)duration {
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = duration;
    animationGroup.animations = animations;
    return animationGroup;
}

+ (CAKeyframeAnimation *)keyframeAnimationWithKeyPath:(NSString *)keyPath
                                             duration:(CGFloat)duration
                                               values:(NSArray *)values
                                             keyTimes:(nullable NSArray *)keyTimes
                                       timingFunction:(ECustomTimingFunction)timingFunction {

    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.duration = duration;
    animation.keyPath = keyPath;
    animation.values = values;
    if (keyTimes) animation.keyTimes = keyTimes;
    animation.timingFunction = [EasingTimingHandler functionWithType:timingFunction];

    return animation;
}

+ (CABasicAnimation *)fadeWithDuration:(CGFloat)duration
                             fromValue:(CGFloat)fromValue
                               toValue:(CGFloat)toValue
                        timingFunction:(ECustomTimingFunction)timingFunction {

    CABasicAnimation *animation = [[self class] animateWithKeyPath:kAnimationKeyPathOpacity
                                                         fromValue:@(fromValue)
                                                           toValue:@(toValue)
                                                          duration:duration
                                                    timingFunction:timingFunction];

    return animation;
}


+ (CABasicAnimation *)fadeInWithDuration:(CGFloat)duration
                          timingFunction:(ECustomTimingFunction)timingFunction {

    CABasicAnimation *animation = [[self class] animateWithKeyPath:kAnimationKeyPathOpacity
                                                         fromValue:@(0.0)
                                                           toValue:@(1.0)
                                                          duration:duration
                                                    timingFunction:timingFunction];

    return animation;
}


+ (CABasicAnimation *)fadeOutWithDuration:(CGFloat)duration
                           timingFunction:(ECustomTimingFunction)timingFunction {

    CABasicAnimation *animation = [[self class] animateWithKeyPath:kAnimationKeyPathOpacity
                                                         fromValue:nil // current layer's state
                                                           toValue:@(0.0)
                                                          duration:duration
                                                    timingFunction:timingFunction];

    return animation;
}

+ (CABasicAnimation *)scaleWithDuration:(CGFloat)duration
                              fromValue:(CGFloat)fromValue
                                toValue:(CGFloat)toValue
                         timingFunction:(ECustomTimingFunction)timingFunction {

    CABasicAnimation *animation = [[self class] animateWithKeyPath:kAnimationKeyPathScale
                                                         fromValue:@(fromValue)
                                                           toValue:@(toValue)
                                                          duration:duration
                                                    timingFunction:timingFunction];

    return animation;

}

+ (CAKeyframeAnimation *)scaleWithBounceDuration:(CGFloat)duration
                                       fromValue:(CGFloat)fromValue
                                         toValue:(CGFloat)toValue
                                         byValue:(CGFloat)byValue
                                  timingFunction:(ECustomTimingFunction)timingFunction {

    CAKeyframeAnimation *animation = [[self class] keyframeAnimationWithKeyPath:kAnimationKeyPathScale
                                                                       duration:duration
                                                                         values:@[@(fromValue), @(byValue), @(toValue)]
                                                                       keyTimes:nil
                                                                 timingFunction:timingFunction];
    return animation;
}

+ (CAKeyframeAnimation *)bouncePositionWithDuration:(CGFloat)duration
                                     targetPosition:(CGPoint)position
                                       bounceOffset:(CGFloat)bounceOffset {
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:kAnimationKeyPathPosition];
    bounceAnimation.duration    = duration;
    //    bounceAnimation.values      = @[[NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(label.frame), CGRectGetMidY(label.frame))],
    //                                    [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(label.frame) + offsetX, CGRectGetMidY(label.frame) - maxOffsetY)],
    //                                    [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(label.frame) + offsetX, CGRectGetMidY(label.frame))],
    //                                    [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(label.frame) + offsetX, CGRectGetMidY(label.frame) - minOffsetY)],
    //                                    [NSValue valueWithCGPoint:CGPointMake(CGRectGetMidX(label.frame) + offsetX, CGRectGetMidY(label.frame))]
    //                                    ];

    return bounceAnimation;
}

@end
