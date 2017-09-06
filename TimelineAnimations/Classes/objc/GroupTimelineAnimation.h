//
//  GroupTimelineAnimation.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 18/02/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

#import "TimelineAnimation.h"

NS_ASSUME_NONNULL_BEGIN

/**
 @public
 A sequence of `TimelineAnimation`s.

 @discussion A GroupTimelineAnimation permits you to combine multiple 
 `TimelineAnimation`s to create even more complex animations and scenarios.
 */
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
 @discussion Creates an GroupTimelineAnimation with all animations inserted at time 0
 @param animations an array of timelines.
 */
+ (instancetype)together:(NSArray<__kindof TimelineAnimation *> *)animations;

/**
 @discussion Creates an GroupTimelineAnimation with animations added one after the after
 @param animations an array of timelines.
 */
+ (instancetype)sequentially:(NSArray<__kindof TimelineAnimation *> *)animations;

/**
 @discussion Creates an empty GroupTimelineAnimation, with a completion block.
 */
+ (instancetype)groupTimelineAnimationWithCompletion:(TimelineAnimationCompletionBlock)completion;

/**
 @discussion Creates an empty GroupTimelineAnimation, with a completion and start block.
 */
+ (instancetype)groupTimelineAnimationOnStart:(TimelineAnimationOnStartBlock)onStart
                                   completion:(TimelineAnimationCompletionBlock)completion;

#pragma mark - Unavailable

- (instancetype)initWithCompletion:(nullable TimelineAnimationCompletionBlock)completion NS_UNAVAILABLE;
- (instancetype)initWithStart:(nullable TimelineAnimationOnStartBlock)onStart NS_UNAVAILABLE;
- (instancetype)initWithUpdate:(nullable TimelineAnimationOnUpdateBlock)onUpdate
      preferredFramesPerSecond:(NSInteger)preferredFramesPerSecond NS_UNAVAILABLE;
- (instancetype)initWithStart:(nullable TimelineAnimationOnStartBlock)onStart
                       update:(nullable TimelineAnimationOnUpdateBlock)onUpdate NS_UNAVAILABLE;
- (instancetype)initWithStart:(nullable TimelineAnimationOnStartBlock)onStart
                   completion:(nullable TimelineAnimationCompletionBlock)completion NS_UNAVAILABLE;
+ (instancetype)timelineAnimationWithCompletion:(TimelineAnimationCompletionBlock)completion  NS_UNAVAILABLE;
+ (instancetype)timelineAnimation NS_UNAVAILABLE;
+ (instancetype)timelineAnimationOnStart:(TimelineAnimationOnStartBlock)onStart
                              completion:(TimelineAnimationCompletionBlock)completion NS_UNAVAILABLE;
- (void)stopUpdates NS_UNAVAILABLE;

@end

@interface GroupTimelineAnimation (Populate)

/**
 Appends a TimelineAnimation at the end of the group.
 
 @param timelineAnimation the timeline to append.
 */
- (void)addTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation;

/**
 Appends a TimelineAnimation at the end of the group, after a `delay`.
 
 @param timelineAnimation the timeline to append.
 @param delay the delay to apply to the animation
 */
- (void)addTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation
                   withDelay:(NSTimeInterval)delay;

/**
 Inserts a TimelineAnimation at the specified
 
 @param timelineAnimation the timeline to insert.
 @param time the time to add the animation
 */
- (void)insertTimelineAnimation:(__kindof TimelineAnimation *)timelineAnimation
                         atTime:(RelativeTime)time;

/**
 Append an array of timelines in the end of the group, after a `delay`.
 @param animations the animations to insert
 @param delay the delay to apply to the animations
 */
- (void)addTimelineAnimations:(NSArray<__kindof TimelineAnimation *> *)animations
                    withDelay:(NSTimeInterval)delay;

/**
 Insert an set of timelines at the specified time.
 
 @param animations the animations to insert
 @param time the time to add the animation
 */
- (void)insertTimelineAnimations:(NSArray<__kindof TimelineAnimation *> *)animations
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


// The methods below are UNAVAILABLE in GroupTimelineAnimation
#pragma mark - Unavailable

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer NS_UNAVAILABLE;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(TimelineAnimationOnStartBlock)onStart NS_UNAVAILABLE;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
          onComplete:(TimelineAnimationCompletionBlock)complete NS_UNAVAILABLE;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(TimelineAnimationOnStartBlock)onStart
          onComplete:(TimelineAnimationCompletionBlock)complete NS_UNAVAILABLE;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay NS_UNAVAILABLE;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
             onStart:(TimelineAnimationOnStartBlock)onStart NS_UNAVAILABLE;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
          onComplete:(TimelineAnimationCompletionBlock)complete NS_UNAVAILABLE;

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
             onStart:(nullable TimelineAnimationOnStartBlock)onStart
          onComplete:(nullable TimelineAnimationCompletionBlock)complete NS_UNAVAILABLE;

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time NS_UNAVAILABLE;

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
                onStart:(TimelineAnimationOnStartBlock)start NS_UNAVAILABLE;

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
             onComplete:(TimelineAnimationCompletionBlock)complete NS_UNAVAILABLE;

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
                onStart:(nullable TimelineAnimationOnStartBlock)start
             onComplete:(nullable TimelineAnimationCompletionBlock)complete NS_UNAVAILABLE;

- (void)insertAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
                forLayer:(__kindof CALayer *)layer
                  atTime:(RelativeTime)time NS_UNAVAILABLE;

- (void)addAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
             forLayer:(__kindof CALayer *)layer
            withDelay:(NSTimeInterval)delay NS_UNAVAILABLE;

- (void)addAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
             forLayer:(__kindof CALayer *)layer
            withDelay:(NSTimeInterval)delay
        onStartBlocks:(nullable NSArray<TimelineAnimationOnStartBlock> *)onStartBlocks
     completionBlocks:(nullable NSArray<TimelineAnimationCompletionBlock> *)completionBlocks NS_UNAVAILABLE;

- (void)insertAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
                forLayer:(__kindof CALayer *)layer
                  atTime:(RelativeTime)time
           onStartBlocks:(nullable NSArray<TimelineAnimationOnStartBlock> *)onStartBlocks
        completionBlocks:(nullable NSArray<TimelineAnimationCompletionBlock> *)completionBlocks NS_UNAVAILABLE;

- (NSArray<__kindof CAPropertyAnimation *> *)animationsBeginingAtTime:(RelativeTime)time NS_UNAVAILABLE;
- (NSArray<__kindof CAPropertyAnimation *> *)animationsOngoingAtTime:(RelativeTime)time NS_UNAVAILABLE;

@property (nonatomic, readonly, strong) NSArray<TimelineAnimationDescription *> *animationDescriptions NS_UNAVAILABLE;
- (void)combineAnimationDescriptions:(NSArray<TimelineAnimationDescription *> *)animationDescriptions NS_UNAVAILABLE;
@end

@interface GroupTimelineAnimation (Debug)

- (NSSet<__kindof TimelineAnimation *> *)timelineAnimationsBeginingAtTime:(RelativeTime)time;

- (NSSet<__kindof TimelineAnimation *> *)timelineAnimationsOngoingAtTime:(RelativeTime)time;
@end

NS_ASSUME_NONNULL_END

