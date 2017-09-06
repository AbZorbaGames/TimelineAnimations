/*!
 *  @file TimelineAudioAssociation_Internal.h
 *  @brief TimelineAnimations
 *
 *  Created by @author Georges Boumis
 *  @date 30/08/2017.
 *  @copyright 2016-2017 AbZorba Games. All rights reserved. 
 */

NS_ASSUME_NONNULL_BEGIN

@class TimelineAnimation;

@interface TimelineAudioAssociation (Internal)

@property (nonatomic, readonly) BOOL isOnStart;
@property (nonatomic, readonly) BOOL isOnCompletion;
@property (nonatomic, readonly) BOOL isOnMiddle;
@property (nonatomic, readonly) BOOL isTimeBased;

- (RelativeTime)timeInTimelineAnimation:(__kindof TimelineAnimation *)timeline;

@end


NS_ASSUME_NONNULL_END
