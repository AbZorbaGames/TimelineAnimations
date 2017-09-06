/*!
 *  @file TimelineAnimationDescription.h
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 23/05/2017.
 *  @copyright 2016-2017 AbZorba Games. All rights reserved.
 */

@import Foundation;
@import QuartzCore;
#import "Types.h"

NS_ASSUME_NONNULL_BEGIN

/*!
 *  @public
 *  @class TimelineAnimationDescription
 *  @brief A class.
 *  @details Some details.
 */
@interface TimelineAnimationDescription : NSObject

@property (nonatomic, copy, readonly) __kindof CAPropertyAnimation *animation;
@property (nonatomic, weak, readonly, nullable) __kindof CALayer *layer;
@property (nonatomic, copy, readonly) TimelineAnimationOnStartBlock onStart;
@property (nonatomic, copy, readonly) TimelineAnimationCompletionBlock completion;

+ (instancetype)descriptionWithAnimation:(__kindof CAPropertyAnimation *)animation
                                forLayer:(__kindof CALayer *)layer
                                 onStart:(TimelineAnimationOnStartBlock)onStart
                              completion:(TimelineAnimationCompletionBlock)completion;
@end

NS_ASSUME_NONNULL_END
