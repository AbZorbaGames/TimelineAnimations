/*!
 *  @file CAKeyframeAnimation+SpecialEasing.m
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 01/03/2016.
 *  @copyright Copyright © 2016-2017 Abzorba Games. All rights reserved.
 */

#import "CAKeyframeAnimation+SpecialEasing.h"
#import "AnimationsKeyPath.h"
@import UIKit;
@import QuartzCore;
@import Foundation;

#if !defined(DefaultKeyframeCount)

// The larger this number, the smoother the animation
#define DefaultKeyframeCount 60

#endif

@implementation CAKeyframeAnimation (SpecialEasing)

+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                                from:(id)fromValue
                                  to:(id)toValue
                       keyframeCount:(size_t)keyframeCount {
    //TODO
//    NSMutableArray *const values = [NSMutableArray arrayWithCapacity:keyframeCount];
//
//    CGFloat t = 0.0;
//    const CGFloat dt = (CGFloat)(1.0 / (keyframeCount - 1));
//    for(size_t frame = 0; frame < keyframeCount; ++frame, t += dt) {
//        const CGFloat value = fromValue + function(t) * (toValue - fromValue);
//        [values addObject:@((float)value)];
//    }
//
//    CAKeyframeAnimation *const animation = [CAKeyframeAnimation animationWithKeyPath:path];
//    animation.values = [values copy];
//    return animation;
    return nil;
}

+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                           fromValue:(CGFloat)fromValue
                             toValue:(CGFloat)toValue
                       keyframeCount:(size_t)keyframeCount {
    NSMutableArray<NSNumber *> *const values = [NSMutableArray arrayWithCapacity:keyframeCount];

    CGFloat t = 0.0;
    const CGFloat dt = (CGFloat)(1.0 / (keyframeCount - 1));
    const CGFloat diff = (toValue - fromValue);
    for(size_t frame = 0; frame < keyframeCount; ++frame, t += dt) {
        const CGFloat value = fromValue + function(t) * diff;
        [values addObject:@((float)value)];
    }

    CAKeyframeAnimation *const animation = [CAKeyframeAnimation animationWithKeyPath:path];
    animation.values = [values copy];
    return animation;
}

+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                           fromValue:(CGFloat)fromValue
                             toValue:(CGFloat)toValue {
    return [self animationWithKeyPath:path
                             function:function
                            fromValue:fromValue
                              toValue:toValue
                        keyframeCount:DefaultKeyframeCount];
}

+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                           fromPoint:(CGPoint)fromPoint
                             toPoint:(CGPoint)toPoint
                       keyframeCount:(size_t)keyframeCount {
    NSMutableArray<NSValue *> *const values = [NSMutableArray arrayWithCapacity:keyframeCount];

    CGFloat t = 0.0;
    const CGFloat dt = (CGFloat)(1.0 / (keyframeCount - 1));
    for (size_t frame = 0; frame < keyframeCount; ++frame, t += dt) {
        const CGFloat x = fromPoint.x + function(t) * (toPoint.x - fromPoint.x);
        const CGFloat y = fromPoint.y + function(t) * (toPoint.y - fromPoint.y);
#if TARGET_OS_IPHONE
        [values addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
#else
        [values addObject:[NSValue valueWithPoint:NSMakePoint(x, y)]];
#endif
    }

    CAKeyframeAnimation *const animation = [CAKeyframeAnimation animationWithKeyPath:path];
    animation.values = [values copy];
    return animation;
}

+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                           fromPoint:(CGPoint)fromPoint
                             toPoint:(CGPoint)toPoint {
    return [self animationWithKeyPath:path
                             function:function
                            fromPoint:fromPoint
                              toPoint:toPoint
                        keyframeCount:DefaultKeyframeCount];
}

+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                            fromSize:(CGSize)fromSize
                              toSize:(CGSize)toSize
                       keyframeCount:(size_t)keyframeCount {
    NSMutableArray<NSValue *> *const values = [NSMutableArray arrayWithCapacity:keyframeCount];

    CGFloat t = 0.0;
    const CGFloat dt = (CGFloat)(1.0 / (keyframeCount - 1));
    for(size_t frame = 0; frame < keyframeCount; ++frame, t += dt) {
        const CGFloat w = fromSize.width + function(t) * (toSize.width - fromSize.width);
        const CGFloat h = fromSize.height + function(t) * (toSize.height - fromSize.height);
#if TARGET_OS_IPHONE
        [values addObject:[NSValue valueWithCGSize:CGSizeMake(w, h)]];
#else
        [values addObject:[NSValue valueWithSize:NSMakeSize(w, h)]];
#endif
    }

    CAKeyframeAnimation *const animation = [CAKeyframeAnimation animationWithKeyPath:path];
    animation.values = [values copy];
    return animation;
}

+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                            fromSize:(CGSize)fromSize
                              toSize:(CGSize)toSize {
    return [self animationWithKeyPath:path
                             function:function
                             fromSize:fromSize
                               toSize:toSize
                        keyframeCount:DefaultKeyframeCount];
}

+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                       fromTransform:(CGAffineTransform)fromTransform
                         toTransform:(CGAffineTransform)toTransform
                       keyframeCount:(size_t)keyframeCount {
    NSMutableArray<NSValue *> *const values = [NSMutableArray arrayWithCapacity:keyframeCount];

    const CGPoint fromTranslation = CGPointMake(fromTransform.tx, fromTransform.ty);
    const CGPoint toTranslation = CGPointMake(toTransform.tx, toTransform.ty);

    const CGFloat fromScale = (CGFloat)(hypot(fromTransform.a, fromTransform.c));
    const CGFloat toScale = (CGFloat)(hypot(toTransform.a, toTransform.c));

    const CGFloat fromRotation = (CGFloat)(atan2(fromTransform.c, fromTransform.a));
    const CGFloat toRotation = (CGFloat)(atan2(toTransform.c, toTransform.a));

    CGFloat deltaRotation = toRotation - fromRotation;

    if (deltaRotation < -M_PI) {
        deltaRotation += (2 * M_PI);
    }
    else if (deltaRotation > M_PI) {
        deltaRotation -= (2 * M_PI);
    }
    
    

    CGFloat t = 0.0;
    const CGFloat dt = (CGFloat)(1.0 / (keyframeCount - 1));
    for (size_t frame = 0; frame < keyframeCount; ++frame, t += dt) {
        const CGFloat interp = function(t);
        const CGFloat scale = fromScale + interp * (toScale - fromScale);
        const CGFloat rotate = fromRotation + interp * deltaRotation;
        
        const CGFloat translateX = fromTranslation.x + interp * (toTranslation.x - fromTranslation.x);
        const CGFloat translateY = fromTranslation.y + interp * (toTranslation.y - fromTranslation.y);

        const CGAffineTransform affineTransform = CGAffineTransformMake(scale * cos(rotate), -scale * sin(rotate),
                                                                        scale * sin(rotate), scale * cos(rotate),
                                                                        translateX, translateY);

        const CATransform3D transform = CATransform3DMakeAffineTransform(affineTransform);

        [values addObject:[NSValue valueWithCATransform3D:transform]];
    }

    CAKeyframeAnimation *const animation = [CAKeyframeAnimation animationWithKeyPath:path];
    animation.values = [values copy];
    return animation;
}

+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                       fromTransform:(CGAffineTransform)fromTransform
                         toTransform:(CGAffineTransform)toTransform
{
    return [self animationWithKeyPath:path
                             function:function
                        fromTransform:fromTransform
                          toTransform:toTransform
                        keyframeCount:DefaultKeyframeCount];
}

@end
