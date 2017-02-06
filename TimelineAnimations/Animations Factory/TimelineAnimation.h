//
//  TimelineAnimation.h
//  Baccarat
//
//  Created by Abzorba Games on 14/09/2015.
//  Copyright (c) 2015 Abzorba Games. All rights reserved.
//

@import Foundation;
@import UIKit;

@class TimelineAudioAssociation;
@protocol TimelineAudio;

NS_ASSUME_NONNULL_BEGIN

typedef NSExceptionName const TimelineAnimationExceptionName;

/*** Exceptions ***/
FOUNDATION_EXTERN TimelineAnimationExceptionName ImmutableTimelineAnimationException;
FOUNDATION_EXTERN TimelineAnimationExceptionName EmptyTimelineAnimationException;
FOUNDATION_EXTERN TimelineAnimationExceptionName ClearedTimelineAnimationException;
FOUNDATION_EXTERN TimelineAnimationExceptionName OngoingTimelineAnimationException;
FOUNDATION_EXTERN TimelineAnimationExceptionName TimelineAnimationTimeNotificationOutOfBoundsException;
FOUNDATION_EXTERN TimelineAnimationExceptionName TimelineAnimationMethodNotImplementedYetException;
FOUNDATION_EXTERN TimelineAnimationExceptionName TimelineAnimationUnsupportedMessageException;
FOUNDATION_EXTERN TimelineAnimationExceptionName TimelineAnimationConflictingAnimationsException;

/*** Types ***/
typedef double RelativeTime;
typedef void (^VoidBlock)(void);
typedef void (^BoolBlock)(BOOL result);
/**
   @param result a Boolean indicating the result of the animation.
   @param iteration the repeat iteration
   @param stop a reference to a Boolean value. The block can set the value to `YES` to stop
   further repeats of the TimelineAnimations. If a block stops further repeats, that
   block continues to run until it’s finished. The `stop` argument is an out-only
   argument. You should only ever set this Boolean to `YES` within the block.
   */
typedef void (^RepeatCompletionBlock)(BOOL result, NSUInteger iteration, BOOL * _Nonnull stop);
typedef VoidBlock NotifyBlock;

//typedef NS_ENUM(NSUInteger, TimelineAnimationRepeatCount) {
//    TimelineAnimationRepeatCountInfinite = NSUIntegerMax
//};


typedef NSUInteger TimelineAnimationRepeatCount __attribute__((swift_wrapper(enum)));
static const TimelineAnimationRepeatCount TimelineAnimationRepeatCountInfinite = NSUIntegerMax;

@interface TimelineAnimation : NSObject

/** The block that is called when the TimelineAnimation finishes */
@property (nonatomic, copy, nullable) BoolBlock completion;
/** The block that is called when the TimelineAnimation is based on a DisplayLink */
@property (nonatomic, copy, nullable) VoidBlock onUpdate;
/** The block that is called when the first animation of the TimelineAnimation starts */
@property (nonatomic, copy, nullable) VoidBlock onStart;

/** The total duration in seconds of the TimelineAnimation */
@property (nonatomic, readonly, assign) NSTimeInterval duration;
/** The beginning time of the first animation */
@property (nonatomic, assign) RelativeTime beginTime;
/** The end time of the timeline */
@property (nonatomic, assign, readonly) RelativeTime endTime;

/** The number of repeats to perform */
@property (nonatomic, assign) TimelineAnimationRepeatCount repeatCount;
/** A block that is called after each iteration */
@property (nonatomic, copy, nullable) RepeatCompletionBlock repeatCompletion;

@property (nonatomic, assign) BOOL setsModelValues;
/** The speed of the timeline. Defaults to 1.0
    @discussion Speeds > 1.0 make the animation go faster, speed < 1.0 make the animation go slower.
    Setting the speed to 0.0 is like calling -pause on the timeline.
    */
@property (nonatomic, assign) float speed;
/**
 The progress, ranged from 0.0 to 1.0, of an ongoing timeline.

 @discussion This property is Key-Value Observing complaint. If the timeline has never played or is cleared, then
 this property has the value of 0.0. If it's finished then the value of this property is near (but less or equal to) 1.0.
 Otherwise it indicates the progress of the timeline.
 */
@property (nonatomic, assign, readonly) float progress;

/** A flag indicating whether to mute audio associations or not.
    @discussion You can set this property any time. Setting this to 'YES', results to **avoid** playing the audio
    associations.
    */
@property (nonatomic, readwrite) BOOL muteAssociatedSounds;


/** The (user-provided) name of the timeline associated with the receiver. It has no impact on the workings
  of TimelineAnimation. */
@property (nonatomic, copy, nullable) NSString *name;
/** The user information dictionary associated with the receiver. */
@property (nonatomic, copy, nullable) NSDictionary<id, id> *userInfo;


/**
 Creates a TimelineAnimation.

 @param onStart an optional block to be called on the beginning of the animation.
 @param onUpdate an optional block to be called at each CADisplayLink iteration. Providing this block sets up the
 TimelineAnimation with a DisplayLink.
 @param completion an optional block to be called when the animation completes.
 */
- (instancetype)initWithStart:(nullable VoidBlock)onStart
                       update:(nullable VoidBlock)onUpdate
                   completion:(nullable BoolBlock)completion NS_DESIGNATED_INITIALIZER;

/** Convenience constructor. */
- (instancetype)initWithCompletion:(nullable BoolBlock)completion;

/** Convenience constructor. */
- (instancetype)initWithStart:(nullable VoidBlock)onStart;

/** Convenience constructor. */
- (instancetype)initWithUpdate:(nullable VoidBlock)onUpdate;

/** Convenience constructor. */
- (instancetype)initWithStart:(nullable VoidBlock)onStart
                       update:(nullable VoidBlock)onUpdate;

/** Convenience constructor. */
- (instancetype)initWithStart:(nullable VoidBlock)onStart
                   completion:(nullable BoolBlock)completion;

/** Convenience constructor. */
- (instancetype)initWithUpdate:(nullable VoidBlock)onUpdate
                    completion:(nullable BoolBlock)completion;

/** Convenience constructor. */
+ (TimelineAnimation *)timelineAnimationWithCompletion:(BoolBlock)completion;

/** Convenience constructor. */
+ (TimelineAnimation *)timelineAnimation;

/** Convenience constructor. */
+ (TimelineAnimation *)timelineAnimationOnStart:(VoidBlock)onStart completion:(BoolBlock)completion;

/** A flag indicating whether the receiver is a reversed derivation */
@property (nonatomic, readonly, getter=isReversed) BOOL reversed;

/** The TimelineAnimation from which the receiver was derived */
@property (nonatomic, weak, readonly) __kindof TimelineAnimation * __nullable originate;

/** The parent of the TimelineAnimation if contained in a group. */
@property (nonatomic, weak, readonly) __kindof TimelineAnimation * __nullable parent;

/** A flag indicating whether the `TimelineAnimation` has any animations. */
@property (nonatomic, assign, readonly, getter=isEmpty) BOOL empty;

@end



#pragma mark - Timeline Adding Animations Methods -

@interface TimelineAnimation (Populate)

/**
 Appends the animation at the end of the timeline.
 @see -addAnimation:forLayer:withDelay:onStart:onComplete: for usage.
 @precondition `animation` and `layer` should not be nil.
 @throws NSInvalidArgumentException if the preconditions are not met.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer;

/**
 Convenience method
 @see -addAnimation:forLayer:withDelay:onStart:onComplete: for usage.
 @precondition `animation`, `layer` and `onStart` should not be nil.
 @throws NSInvalidArgumentException if the preconditions are not met.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(VoidBlock)onStart;

/**
 Convenience method
 @see -addAnimation:forLayer:withDelay:onStart:onComplete: for usage.
 @precondition `animation`, `layer` and `complete` should not be nil.
 @throws NSInvalidArgumentException if the preconditions are not met.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
          onComplete:(BoolBlock)complete;

/**
 Convenience method
 @see -addAnimation:forLayer:withDelay:onStart:onComplete: for usage.
 @precondition `animation`, `layer`, `onStart` and `complete` should not be nil.
 @throws NSInvalidArgumentException if the preconditions are not met.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(VoidBlock)onStart
          onComplete:(BoolBlock)complete;

/**
 Appends the animation at the end of the timeline, with an optional delay value.
 @see -addAnimation:forLayer:withDelay:onStart:onComplete: for usage.
 @precondition `animation` and `layer` should not be nil.
 @throws NSInvalidArgumentException if the preconditions are not met.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay;

/**
 Convenience method
 @see -addAnimation:forLayer:withDelay:onStart:onComplete: for usage.
 @precondition `animation`, `layer` and `onStart` should not be nil.
 @throws NSInvalidArgumentException if the preconditions are not met.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
             onStart:(VoidBlock)onStart;

/**
 Convenience method
 @see -addAnimation:forLayer:withDelay:onStart:onComplete: for usage.
 @precondition `animation`, `layer` and `complete` should not be nil.
 @throws NSInvalidArgumentException if the preconditions are not met.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
          onComplete:(BoolBlock)complete;

/**
 Appends an animation at the end of the timeline, after a delay.

 @param animation a property animation describing the animation to be applied on the layer
 @param layer the layer whose property is to be animated in the TimelineAnimation
 @param delay the delay, must be > 0.0, in seconds
 @param start an optional block to be called on the beginning of the animation
 @param complete an optional block to be called when the animation completes

 @throws NSInvalidArgumentException if either `layer` on `animation` are `nil`.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
             onStart:(nullable VoidBlock)onStart
          onComplete:(nullable BoolBlock)complete;

/**
 @discussion Inserts the animation at the given time.
 @see -insertAnimation:forLayer:atTime:onStart:onComplete: for usage.
 @precondition `animation`, and `layer` should not be nil.
 @throws NSInvalidArgumentException if the preconditions are not met.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time;

/**
 @discussion Convenience method
 @see -insertAnimation:forLayer:atTime:onStart:onComplete: for usage.
 @precondition `animation`, `layer` and `onStart` should not be nil.
 @throws NSInvalidArgumentException if the preconditions are not met.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
                onStart:(VoidBlock)start;

/**
 @discussion Convenience method
 @see -insertAnimation:forLayer:atTime:onStart:onComplete: for usage.
 @precondition `animation`, `layer` and `complete` should not be nil.
 @throws NSInvalidArgumentException if the preconditions are not met.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
             onComplete:(BoolBlock)complete;


/**
 Inserts a animation in the TimelineAnimation for the provided layer at the given time. The duration is
 provided by the `animation.duration` property.

 @param animation a property animation describing the animation to be applied on the layer
 @param layer the layer whose property is to be animated in the TimelineAnimation
 @param time the time, in the TimelineAnimation's relative time (seconds), to insert the animation
 @param start an optional block to be called on the beginning of the animation
 @param complete an optional block to be called when the animation completes

 @throws NSInvalidArgumentException if either `layer` on `animation` are `nil`.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
                onStart:(nullable VoidBlock)start
             onComplete:(nullable BoolBlock)complete;

@end

#pragma mark - Timeline Control -

@interface TimelineAnimation (Control)

/**
 A flag indicating whether the `TimelineAnimation` is paused.
 @discussion This property is Key-Value Observing complaint.
 */
@property (nonatomic, readonly, assign, getter=isPaused) BOOL paused;      // KVO
/**
 A flag indicating whether the `TimelineAnimation` has started.
 @discussion This property is Key-Value Observing complaint.
 */
@property (nonatomic, readonly, assign, getter=hasStarted) BOOL started;   // KVO
/**
 A flag indicating whether the `TimelineAnimation` has finished.
 @discussion This property is Key-Value Observing complaint.
 */
@property (nonatomic, readonly, assign, getter=hasFinished) BOOL finished; // KVO
/** A flag indicating whether the `TimelineAnimation` has been cleared. */
@property (nonatomic, readonly, getter=isCleared) BOOL cleared;

/**
 Starts the timeline.
 @discussion If the timeline is empty then, the `onStart` and `completion` blocks
 are called immediately +0 happens ( '+0' means: "and nothing more.").

 @throws ClearedTimelineAnimationException if a cleared timeline is sent the -play message.
 @throws OngoingTimelineAnimationException if a non finished timeline is sent the -play message.
 */
- (void)play;

/**
 Replays the timeline.
 @precondition (soft) the timeline has already played and finished
 */
- (void)replay;

/**
 Pauses a ongoing timeline.
 @precondition (soft) the timeline should be paused
 */
- (void)pause;

/**
 Resumes a paused timeline.
 @precondition (soft) the timeline should have been started
 */
- (void)resume;

/**
 @discussion Clears the TimelineAnimation. This means it removes all animation
 from layers and clears its internal state. You cannot (re)play a cleared
 TimelineAnimation.
 */
- (void)clear;

/**
 Delays all the animations of the timeline by a delay
 @param delay the delay in seconds. if delay < 0 then the timeline animation
 starts at an advanced state.
*/
- (void)delay:(NSTimeInterval)delay;

/**
 @discussion Creates a TimelineAnimation with the requested duration. The
 resulted TimelineAnimation has scaled propertionally its animation to match the
 requested duration.
 @param duration the new duration in seconds.
 @return a new TimelineAnimation with the requested duration.
 */
- (instancetype)timelineWithDuration:(NSTimeInterval)duration;

@end


@interface TimelineAnimation (Reverse)

/**
 Creates a reversed TimelineAnimation.
 @discussion The resulted TimelineAnimation has the same duration as the receiver. The resulted animation
 starts at the end of the receiver's and goes all the way back to the beginning.
 This method sets the `.originate` property of the resulted TimelineAnimation.

 @warning
 Playing concurrently a TimelineAnimation and a reversed one results are
 *undefined*.
 @returns a new TimelineAnimation that plays in reversed order from the receiver.
 */
- (instancetype)reversed;

@end

@interface TimelineAnimation (Progress)

/**
 Plays the TimelineAnimation from an advanced state.
 @param progress the progress at which to start the animation. Values range from 0.0 to 1.0.
 */
- (void)playFromProgress:(float)progress;

@end

@interface TimelineAnimation (Notify)

/**
 Inserts a time based callback block at a given (relative) time (in seconds).
 @discussion You cannot add a time notification to an empty TimelineAnimation. Adding a time notification to a ongoing
 timeline has **no** effect. But if the timeline is replayed or copied then it **will** take effect.

 @warning Adding a time notification to an empty TimelineAnimation or after .endTime is undefined.

 @param time the time in the TimelineAnimation duration to call the block
 provided. The time should be at least 0 and less than the TimelineAnimation's
 endTime.
 @param block the block to be called. It's called only once.

 @precondition the timeline should not by empty and `time` should be less than `timeline.endTime`

 @throws TimelineAnimationTimeNotificationOutOfBoundsException if time is negative or after the `.endTime` of the receiver.
 @throws EmptyTimelineAnimationException if the receiver is empty.
 @throws OngoingTimelineAnimationException if sent to a non finished timeline.
 */
- (void)notifyAtTime:(RelativeTime)time
          usingBlock:(NotifyBlock)block;


/**
 Inserts a progress based callback block at a given progress (in %).
 @discussion As this method is *costly* the TimelineAnimation tries to not set it
 unless there are notifications related to progress. If you want a progress
 notification the overhead is *big*.
 Progress > 0.96-0.97 are *NOT* guaranteed to work.

 @warning This is costly and could result into a **performance hit**. Prefer -notifyAtTime:usingBlock:

 @param progress values range from 0.0 to 1.0. The progress of the animation at
 which point the notification block will be called. When the block is called the
 progress of the animation is *at least* the requested progress.
 @param block the block to be called. It's called only once.

 @see -notifyAtTime:usingBlock:

 @throws OngoingTimelineAnimationException if sent to a non finished timeline.
 */
- (void)notifyAtProgress:(float)progress
              usingBlock:(NotifyBlock)block;

@end

@interface TimelineAnimation (Audio)

/**
 Associates an audio to the provided TimelineAudioAssociation.

 @param audio the audio to be associated with the timeline.
 @param association the association describing at which point to associate the audio in the timeline.

 @throws OngoingTimelineAnimationException if sent to a non finished timeline.
 @throws EmptyTimelineAnimationException if the receiver is empty.
 */
- (void)associateAudio:(id<TimelineAudio>)audio
  usingTimeAssociation:(TimelineAudioAssociation *)association;

/**
 Removes **all** audio at association.

 @discussion This method is best effort. If the association is not exactly the same
 it does not guarantee to remove the associated audio.

 @param association the time association whose audio is to be disassociated.

 @throws OngoingTimelineAnimationException if sent to a non finished timeline.
 */
- (void)disassociateAudioAtTimeAssociation:(TimelineAudioAssociation *)association;

/**
 Removes audio provided audio.

 @discussion TimelineAnimation searches with strict pointer comparison the audio to be
 removed. This is method is best effort, it does not guarantee to remove the audio.

 @param audio the audio to be disassociated.

 @throws OngoingTimelineAnimationException if sent to a non finished timeline.
 */
- (void)disassociateAudio:(id<TimelineAudio>)audio;

/**
 Removes all audio associations.

 @discussion This method guarantees that all audio will be disassociated from the timeline.

 @throws OngoingTimelineAnimationException if sent to a non finished timeline.
 */
- (void)disassociateAllAudio;

@end

@interface TimelineAnimation (Copying) <NSCopying>
@end

NS_ASSUME_NONNULL_END
