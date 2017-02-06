//
//  GroupTimelineAnimation.h
//  TimelineAnimations
//
//  Created by AbZorba Games on 18/02/2016.
//  Copyright © 2016 AbZorba Games. All rights reserved.
//

#import "TimelineAnimation.h"

NS_ASSUME_NONNULL_BEGIN

@interface GroupTimelineAnimation : TimelineAnimation

/**
 @discussion Creates a GroupTimelineAnimation with a given set of TimelineAnimations.
 @param timelines a set of timelines. The use of a set implies that the timelines provided should be unique. Adding the
 same timeline multiple times results in **undefined behaviour**.
 */
- (instancetype)initWithTimelines:(nullable NSSet<__kindof TimelineAnimation *> *)timelines NS_DESIGNATED_INITIALIZER;

/**
 @discussion Creates an empty GroupTimelineAnimation
 */
+ (instancetype)groupTimelineAnimation;

/**
 @discussion Creates an empty GroupTimelineAnimation, with a completion block.
 */
+ (instancetype)groupTimelineAnimationWithCompletion:(BoolBlock)completion;

/**
 @discussion Creates an empty GroupTimelineAnimation, with a completion and start block.
 */
+ (instancetype)groupTimelineAnimationOnStart:(VoidBlock)onStart completion:(BoolBlock)completion;

@end

@interface GroupTimelineAnimation (Populate)

/**
 @discussion Appends a TimelineAnimation at the end of the group.
 @param timelineAnimation the timeline to append.
 */
- (void)addTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation;

/**
 @discussion Appends a TimelineAnimation at the end of the group, after a `delay`.
 @param timelineAnimation the timeline to append.
 @param delay the delay to apply to the animation
 */
- (void)addTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation
                   withDelay:(NSTimeInterval)delay;

/**
 @discussion Inserts a TimelineAnimation at the specified
 @param timelineAnimation the timeline to insert.
 @param delay the delay to apply to the animation
 */
- (void)insertTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation
                         atTime:(RelativeTime)time;

/**
 @discussion Removes a TimelineAnimation. It is not guaranteed to work.
 @param timelineAnimation the timeline to remove.
 */
- (void)removeTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation;

/**
 @discussion Checks to see if the a TimelineAnimation is in the group.
 @param timelineAnimation the timeline to check.
 @returns a boolean indicating the inclusion of the timeline in the group.
 */
- (BOOL)containsTimelineAnimation:(nullable __kindof TimelineAnimation *)timelineAnimation;

@end

NS_ASSUME_NONNULL_END

