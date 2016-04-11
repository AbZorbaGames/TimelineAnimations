//
//  AnimationsFactory.h
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
                                duration:(CGFloat)duration
                                delegate:(id)delegate
                          timingFunction:(ECustomTimingFunction)timingFunction;


+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                                 toValue:(id)toValue
                                duration:(CGFloat)duration
                                delegate:(id)delegate
                          timingFunction:(ECustomTimingFunction)timingFunction;

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
                                duration:(CGFloat)duration
                          timingFunction:(ECustomTimingFunction)timingFunction;

+ (CABasicAnimation *)animateWithKeyPath:(NSString *)keyPath
                                 toValue:(id)toValue
                                duration:(CGFloat)duration
                          timingFunction:(ECustomTimingFunction)timingFunction;


/**
 * Creates a new CAAnimationGroup with the duration.
 *
 * @param animations        An array of animations properties to be included in the group.
 * @param duration          The basic duration of the object.
 *
 * @returns A new instance of CAAnimationGroup with the passed duration.
 *
 */
+ (CAAnimationGroup *)animationGroupWithAnimations:(NSArray *)animations
                                       andDuration:(CGFloat)duration;


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
                                             duration:(CGFloat)duration
                                               values:(NSArray *)values
                                             keyTimes:(nullable NSArray *)keyTimes
                                       timingFunction:(ECustomTimingFunction)timingFunction;

+ (CABasicAnimation *)fadeWithDuration:(CGFloat)duration
                             fromValue:(CGFloat)fromValue
                               toValue:(CGFloat)toValue
                        timingFunction:(ECustomTimingFunction)timingFunction;

+ (CABasicAnimation *)fadeInWithDuration:(CGFloat)duration
                          timingFunction:(ECustomTimingFunction)timingFunction;

+ (CABasicAnimation *)fadeOutWithDuration:(CGFloat)duration
                           timingFunction:(ECustomTimingFunction)timingFunction;

+ (CAKeyframeAnimation *)scaleWithBounceDuration:(CGFloat)duration
                                       fromValue:(CGFloat)fromValue
                                         toValue:(CGFloat)toValue
                                         byValue:(CGFloat)byValue
                                  timingFunction:(ECustomTimingFunction)timingFunction;

@end

NS_ASSUME_NONNULL_END
