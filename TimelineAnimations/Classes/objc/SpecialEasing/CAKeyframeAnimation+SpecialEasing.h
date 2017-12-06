/*!
 *  @file CAKeyframeAnimation+SpecialEasing.h
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 01/03/2016.
 *  @copyright Copyright © 2016-2017 Abzorba Games. All rights reserved.
 */

@import QuartzCore;
#include "TimelineAnimationSpecialTimingFunction.h"
#import "AnimationsKeyPath.h"

@interface CAKeyframeAnimation (SpecialEasing)

/// Factory method to create a keyframe animation for animating a scalar value
+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                           fromValue:(CGFloat)fromValue
                             toValue:(CGFloat)toValue
                       keyframeCount:(size_t)keyframeCount NS_REFINED_FOR_SWIFT;

/// Factory method to create a keyframe animation for animating a scalar value,
/// with keyFrameCount set to 60
+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                           fromValue:(CGFloat)fromValue
                             toValue:(CGFloat)toValue NS_REFINED_FOR_SWIFT;

/// Factory method to create a keyframe animation for animating between two points
+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                           fromPoint:(CGPoint)fromPoint
                             toPoint:(CGPoint)toPoint
                       keyframeCount:(size_t)keyframeCount NS_REFINED_FOR_SWIFT;

/// Factory method to create a keyframe animation for animating between two points,
/// with keyFrameCount set to 60
+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                           fromPoint:(CGPoint)fromValue
                             toPoint:(CGPoint)toValue NS_REFINED_FOR_SWIFT;

/// Factory method to create a keyframe animation for animating between two sizes
+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                            fromSize:(CGSize)fromSize
                              toSize:(CGSize)toSize
                       keyframeCount:(size_t)keyframeCount NS_REFINED_FOR_SWIFT;

/// Factory method to create a keyframe animation for animating between two sizes,
/// with keyFrameCount set to 60
+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                            fromSize:(CGSize)fromValue
                              toSize:(CGSize)toValue NS_REFINED_FOR_SWIFT;

/// Factory method to create a keyframe animation for animating between two affine transforms.
/// The provinstancetypeed transforms must not have any shearing factors, and must have uniform scale.
/// The keyframe values are instances of NSValue wrapping a CATransform3D.
+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                       fromTransform:(CGAffineTransform)fromTransform
                         toTransform:(CGAffineTransform)toTransform
                       keyframeCount:(size_t)keyframeCount NS_REFINED_FOR_SWIFT;

/// Factory method to create a keyframe animation for animating between two affine transforms,
/// with keyFrameCount set to 60.
/// The provinstancetypeed transforms must not have any shearing factors, and must have uniform scale.
/// The keyframe values are instances of NSValue wrapping a CATransform3D.
+ (instancetype)animationWithKeyPath:(AnimationKeyPath)path
                            function:(TimelineAnimationSpecialTimingFunction)function
                       fromTransform:(CGAffineTransform)fromTransform
                         toTransform:(CGAffineTransform)toTransform NS_REFINED_FOR_SWIFT;

@end
