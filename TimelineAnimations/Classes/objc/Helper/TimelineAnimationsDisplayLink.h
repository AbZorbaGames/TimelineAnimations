/*!
 *  @file TimelineAnimationsDisplayLink.h
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 18/10/2016.
 *  @copyright   Copyright © 2016-2017 Abzorba Games. All rights reserved.
 */

@import QuartzCore;

NS_ASSUME_NONNULL_BEGIN

typedef void (^TimelineAnimationsDisplayLinkBlock)(CFTimeInterval timestamp);
/*!
 *  @public
 *  @class DisplayLink
 *  @brief A class.
 *  @details Some details.
 */
@interface TimelineAnimationsDisplayLink : NSObject

/*!
 @public
 @brief Creates a DisplayLink with the given block
 @details the block is called 60 per second by default
 */
+ (instancetype)displayLinkWithBlock:(TimelineAnimationsDisplayLinkBlock)block;

+ (instancetype)displayLinkPreferredFramesPerSecond:(NSInteger)preferredFramesPerSecond
                                              block:(TimelineAnimationsDisplayLinkBlock)block;

// see CADisplayLik .frameInterval and .preferredFramesPerSecond
@property (nonatomic, readonly) NSInteger preferredFramesPerSecond;

// setting this property is like calling -resume or -pause 
@property (nonatomic, readwrite, getter=isPaused) BOOL paused;

- (void)resume;
- (void)pause;

// always call -stop
- (void)stop;

@end

NS_ASSUME_NONNULL_END
