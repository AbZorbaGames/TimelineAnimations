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
                           fromValue:(CGFloat)fromValue
                             toValue:(CGFloat)toValue
                       keyframeCount:(size_t)keyframeCount {
    
    CAKeyframeAnimation *const animation = [CAKeyframeAnimation animationWithKeyPath:path];
    animation.values = [self numberValuesFunction:function
                                             from:fromValue
                                               to:toValue
                                    keyframeCount:keyframeCount];
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


+ (NSArray<NSNumber *> *)numberValuesFunction:(TimelineAnimationSpecialTimingFunction)function
                                         from:(CGFloat)from
                                           to:(CGFloat)to
                                keyframeCount:(size_t)keyframeCount {
    
    NSMutableArray<NSNumber *> *const values = [[NSMutableArray alloc] initWithCapacity:(NSInteger)keyframeCount];
    
    double t = 0.0;
    const CGFloat dt = (CGFloat)(1.0 / (keyframeCount - 1));
    const CGFloat diff = (to - from);
    for(size_t frame = 0; frame < keyframeCount; ++frame, t += dt) {
        const CGFloat value = from + (CGFloat)function(t) * diff;
        [values addObject:@((float)value)];
    }
    return [values copy];
}





+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                           fromPoint:(CGPoint)from
                             toPoint:(CGPoint)to
                       keyframeCount:(size_t)keyframeCount {

    CAKeyframeAnimation *const animation = [CAKeyframeAnimation animationWithKeyPath:path];
    animation.values = [self pointValuesFunction:function
                                            from:from
                                              to:to
                                   keyframeCount:keyframeCount];
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

+ (NSArray<NSValue *> *)pointValuesFunction:(TimelineAnimationSpecialTimingFunction)function
                                       from:(CGPoint)from
                                         to:(CGPoint)to
                              keyframeCount:(size_t)keyframeCount {
    
    NSMutableArray<NSValue *> *const values = [[NSMutableArray alloc] initWithCapacity:(NSInteger)keyframeCount];
    
    double t = 0.0;
    const CGFloat dt = (CGFloat)(1.0 / (keyframeCount - 1));
    const CGFloat xDiff = (to.x - from.x);
    const CGFloat yDiff = (to.y - from.y);
    
    for (size_t frame = 0; frame < keyframeCount; ++frame, t += dt) {
        const CGFloat v = (CGFloat)function(t);
        const CGFloat x = from.x + v * xDiff;
        const CGFloat y = from.y + v * yDiff;
#if TARGET_OS_IPHONE
        [values addObject:[NSValue valueWithCGPoint:CGPointMake(x, y)]];
#else
        [values addObject:[NSValue valueWithPoint:NSMakePoint(x, y)]];
#endif
    }
    return [values copy];
}

+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                            fromSize:(CGSize)from
                              toSize:(CGSize)to
                       keyframeCount:(size_t)keyframeCount {
    
    CAKeyframeAnimation *const animation = [CAKeyframeAnimation animationWithKeyPath:path];
    animation.values = [self sizeValuesFunction:function
                                           from:from
                                             to:to
                                  keyframeCount:keyframeCount];
    return animation;
}

+ (NSArray<NSValue *> *)sizeValuesFunction:(TimelineAnimationSpecialTimingFunction)function
                                      from:(CGSize)from
                                        to:(CGSize)to
                             keyframeCount:(size_t)keyframeCount {
    
    NSMutableArray<NSValue *> *const values = [[NSMutableArray alloc] initWithCapacity:(NSInteger)keyframeCount];
    
    double t = 0.0;
    const CGFloat dt = (CGFloat)(1.0 / (keyframeCount - 1));
    const CGFloat wDiff = (to.width - from.width);
    const CGFloat hDiff = (to.height - from.height);
    
    for(size_t frame = 0; frame < keyframeCount; ++frame, t += dt) {
        const CGFloat v = (CGFloat)function(t);
        const CGFloat w = from.width  + v * wDiff;
        const CGFloat h = from.height + v * hDiff;
#if TARGET_OS_IPHONE
        [values addObject:[NSValue valueWithCGSize:CGSizeMake(w, h)]];
#else
        [values addObject:[NSValue valueWithSize:NSMakeSize(w, h)]];
#endif
    }

    return [values copy];
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
                       fromTransform:(CGAffineTransform)from
                         toTransform:(CGAffineTransform)to
                       keyframeCount:(size_t)keyframeCount {

    CAKeyframeAnimation *const animation = [CAKeyframeAnimation animationWithKeyPath:path];
    animation.values = [self transformValuesFunction:function
                                                from:from
                                                  to:to
                                       keyframeCount:keyframeCount];
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

+ (NSArray<NSValue *> *)transformValuesFunction:(TimelineAnimationSpecialTimingFunction)function
                                           from:(CGAffineTransform)from
                                             to:(CGAffineTransform)to
                                  keyframeCount:(size_t)keyframeCount {
    NSMutableArray<NSValue *> *const values = [[NSMutableArray alloc] initWithCapacity:(NSInteger)keyframeCount];
    
    const CGPoint fromTranslation  = CGPointMake(from.tx, from.ty);
    const CGPoint toTranslation    = CGPointMake(to.tx, to.ty);
    const CGFloat xTranslationDiff = (toTranslation.x - fromTranslation.x);
    const CGFloat yTranslationDiff = (toTranslation.y - fromTranslation.y);
    
    
    const CGFloat fromScale = (CGFloat)(hypot(from.a, from.c));
    const CGFloat toScale   = (CGFloat)(hypot(to.a, to.c));
    const CGFloat scaleDiff = (toScale - fromScale);
    
    const CGFloat fromRotation = (CGFloat)(atan2(from.c, from.a));
    const CGFloat toRotation   = (CGFloat)(atan2(to.c, to.a));
    
    CGFloat deltaRotation = toRotation - fromRotation;
    
    if (deltaRotation < -M_PI) {
        deltaRotation += (2 * M_PI);
    }
    else if (deltaRotation > M_PI) {
        deltaRotation -= (2 * M_PI);
    }
    
    
    
    double t = 0.0;
    const CGFloat dt = (CGFloat)(1.0 / (keyframeCount - 1));
    for (size_t frame = 0; frame < keyframeCount; ++frame, t += dt) {
        const CGFloat v = (CGFloat)function(t);
        const CGFloat scale = fromScale + v * scaleDiff;
        const CGFloat rotate = fromRotation + v * deltaRotation;
        
        const CGFloat translateX = fromTranslation.x + v * xTranslationDiff;
        const CGFloat translateY = fromTranslation.y + v * yTranslationDiff;
        
        const CGAffineTransform affineTransform = CGAffineTransformMake(scale * cos(rotate), -scale * sin(rotate),
                                                                        scale * sin(rotate), scale * cos(rotate),
                                                                        translateX, translateY);
        
        const CATransform3D transform = CATransform3DMakeAffineTransform(affineTransform);
        
        [values addObject:[NSValue valueWithCATransform3D:transform]];
    }
    
    return [values copy];
}


@end
