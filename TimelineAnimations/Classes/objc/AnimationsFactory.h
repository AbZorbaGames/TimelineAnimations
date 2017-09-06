//
//  TimelineAnimations.h
//  TimelineAnimations
//
//  Created by AbZorba Games on 07/09/2015.
//  Copyright (c) 2015-2016 AbZorba Games. All rights reserved.
//

@import UIKit;
#import "EasingTimingHandler.h"

NS_ASSUME_NONNULL_BEGIN

@interface AnimationsFactory : NSObject

#pragma mark - Generic Methods -

/**
 * Creates a new CABasicAnimation with the passed parameters
 *
 * @param keyPath           The key-path describing the property to be animated.
 * @param fromValue         Defines the value the receiver uses to start interpolation.
 * @param toValue           Defines the value the receiver uses to end interpolation.
 * @param duration          The basic duration of the object.
 * @param delegate          The delegate of the animation. CAAnimationDelegate
 * @param timingFunction    A timing function defining the pacing of the animation. Accepted values can be found on ECustomTimingFunction
 *
 * @returns A new instance of CABasicAnimation with the key path set to keyPath.
 *
 */
+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                               fromValue:(nullable id)fromValue
                                 toValue:(nullable id)toValue
                                duration:(CFTimeInterval)duration
                                delegate:(nullable id)delegate
                          timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;

+ (CABasicAnimation *)moveFromValue:(nullable NSValue *)fromValue
                            toValue:(nullable NSValue *)toValue
                           duration:(CFTimeInterval)duration
                           delegate:(nullable id)delegate
                     timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;


+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                                 toValue:(id)toValue
                                duration:(CFTimeInterval)duration
                                delegate:(nullable id)delegate
                          timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;

+ (CABasicAnimation *)moveToValue:(nullable NSValue *)toValue
                         duration:(CFTimeInterval)duration
                         delegate:(nullable id)delegate
                   timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;

/**
 * Creates a new CABasicAnimation with the passed parameters.
 *
 * @param keyPath           The key-path describing the property to be animated.
 * @param fromValue         Defines the value the receiver uses to start interpolation.
 * @param toValue           Defines the value the receiver uses to end interpolation.
 * @param duration          The basic duration of the object.
 *
 * @returns A new instance of CABasicAnimation with the key path set to keyPath.
 *
 */
+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                               fromValue:(nullable id)fromValue
                                 toValue:(nullable id)toValue
                                duration:(CFTimeInterval)duration
                          timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;

+ (CABasicAnimation *)moveFromValue:(nullable NSValue *)fromValue
                            toValue:(nullable NSValue *)toValue
                           duration:(CFTimeInterval)duration
                     timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;

+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                                 toValue:(id)toValue
                                duration:(CFTimeInterval)duration
                          timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;

+ (CABasicAnimation *)moveToValue:(nullable NSValue *)toValue
                         duration:(CFTimeInterval)duration
                   timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;


/**
 * Creates a new CAAnimationGroup with the duration.
 *
 * @param animations        An array of animations properties to be included in the group.
 * @param duration          The basic duration of the object.
 *
 * @returns A new instance of CAAnimationGroup with the passed duration.
 *
 */
+ (CAAnimationGroup *)animationGroupWithAnimations:(NSArray<__kindof CAAnimation *> *)animations
                                          duration:(CFTimeInterval)duration;


/**
 * Creates a new CAKeyframeAnimation with the passed parameters.
 *
 * @param keyPath           The key-path describing the property to be animated.
 * @param duration          The basic duration of the object.
 * @param values            An array of objects that specify the keyframe values to use for the animation.
 * @param keyTimes          An optional array of NSNumber objects that define the time at which to apply a given keyframe segment.
 *
 * @returns A new instance of CAKeyframeAnimation with the key path set to keyPath.
 *
 */
+ (CAKeyframeAnimation *)keyframeAnimationWithKeyPath:(NSString *)keyPath
                                             duration:(CFTimeInterval)duration
                                               values:(NSArray<id> *)values
                                             keyTimes:(nullable NSArray<NSNumber *> *)keyTimes
                                       timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;

+ (CABasicAnimation *)fadeWithDuration:(CFTimeInterval)duration
                             fromValue:(CGFloat)fromValue
                               toValue:(CGFloat)toValue
                        timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;

+ (CABasicAnimation *)fadeInWithDuration:(CFTimeInterval)duration
                          timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;

+ (CABasicAnimation *)fadeOutWithDuration:(CFTimeInterval)duration
                           timingFunction:(ECustomTimingFunction)timingFunction NS_REFINED_FOR_SWIFT;

+ (CAKeyframeAnimation *)scaleWithBounceDuration:(CFTimeInterval)duration
                                       fromValue:(CGFloat)fromValue
                                         toValue:(CGFloat)toValue
                                         byValue:(CGFloat)byValue
                                  timingFunction:(ECustomTimingFunction)timingFunction;

@end

NS_ASSUME_NONNULL_END
