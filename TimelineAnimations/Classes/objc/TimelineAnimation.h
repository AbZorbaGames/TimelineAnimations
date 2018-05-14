//
//  TimelineAnimation.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 14/09/2015.
//  Copyright (c) 2015-2017 Abzorba Games. All rights reserved.
//

@import Foundation;
@import UIKit;

@class TimelineAudioAssociation, TimelineAnimationDescription;
@protocol TimelineAudio;

#import "Types.h"

NS_ASSUME_NONNULL_BEGIN

typedef NSExceptionName const TimelineAnimationExceptionName;

// Exceptions

/** Thrown when a mutation is attempted on an already started TimelineAnimation. */
FOUNDATION_EXTERN TimelineAnimationExceptionName ImmutableTimelineAnimationException;
/** Thrown when a trying to associate audio or a time notification to an empty TimelineAnimation. */
FOUNDATION_EXTERN TimelineAnimationExceptionName EmptyTimelineAnimationException;
/** Thrown when a -play message is sent to a cleared TimelineAnimation. */
FOUNDATION_EXTERN TimelineAnimationExceptionName ClearedTimelineAnimationException;
/** Thrown when trying to play an non finished (that is already playing) TimelineAnimation. */
FOUNDATION_EXTERN TimelineAnimationExceptionName OngoingTimelineAnimationException;
/** Thrown when registering for a time notification after the `.endTime` of the TimelineAnimation. */
FOUNDATION_EXTERN TimelineAnimationExceptionName TimelineAnimationTimeNotificationOutOfBoundsException;
/** Thrown when adding bare animations to a GroupTimelineAnimation. */
FOUNDATION_EXTERN TimelineAnimationExceptionName TimelineAnimationUnsupportedMessageException;
/** Thrown when adding an animation that directly conflicts with an existing animation, that is already present, in the TimelineAnimation. */
FOUNDATION_EXTERN TimelineAnimationExceptionName TimelineAnimationConflictingAnimationsException;
/** Thrown when adding the number of blocks passed to the method does not correspond with the animations provided */
FOUNDATION_EXTERN TimelineAnimationExceptionName TimelineAnimationInvalidNumberOfBlocksException;
/** Thrown when features of TimelineAnimations are not implemented yet ^_^. */
FOUNDATION_EXTERN TimelineAnimationExceptionName TimelineAnimationMethodNotImplementedYetException;
/** Thrown when playing (or repeating) an animation and any of its layers is not part of a layer hierarchy. */
FOUNDATION_EXTERN TimelineAnimationExceptionName TimelineAnimationElementsNotInHierarchyException;

/**
 @public 
 A declarative sequence of CAAnimations.
 
 @discussion TimelineAnimation is a timed collection of CAPropertyAnimations.
 It permits you to declare in sequence the animations you want to perform in a 
 declarative way. It provides you with fine control over the start and 
 completion of the whole timeline, as well as the start and completion of each
 animation in a block oriented way.
 This way you can create complex animations and play, replay, or event change 
 the speed.
 
 You can create complex repeating animations, or animations based on 
 CADisplayLink.

 TimelineAnimation can notify you at a time during the animation other than its
 start or its comletion.

 You can also be notified based on the total progress of the timeline.

 TimelineAnimation permits you to associate audio to be played along with it.
 */
@interface TimelineAnimation : NSObject

/** The block that is called when the TimelineAnimation is based on a DisplayLink */
@property (nonatomic, copy, nullable) TimelineAnimationOnUpdateBlock onUpdate;
@property (nonatomic, assign) NSInteger preferredFramesPerSecond;

/** 
 The block that is called when the TimelineAnimation finishes.
 @note Do not set it to `nil`, use -removeCompletionBlocks instead.
 */
@property (nonatomic, copy, nullable) TimelineAnimationCompletionBlock completion;


/** 
 The block that is called when the first animation of the TimelineAnimation starts.
 @note Do not set it to `nil`, use -removeCompletionBlocks instead.
 */
@property (nonatomic, copy, nullable) TimelineAnimationOnStartBlock onStart;

/** The total duration in seconds of the TimelineAnimation */
@property (nonatomic, readonly) NSTimeInterval duration;
/** The beginning time of the first animation */
@property (nonatomic, assign) RelativeTime beginTime;
/** The end time of the timeline */
@property (nonatomic, assign, readonly) RelativeTime endTime;

/** 
 The number of repeats to perform
 @note A `repeatCount` of `1` is equivalent to calling `-play`.
 */
@property (nonatomic, assign) TimelineAnimationRepeatCount repeatCount NS_REFINED_FOR_SWIFT;
/** A block that is called when an iteration begins */
@property (nonatomic, copy, nullable) RepeatOnStartBlock repeatOnStart;
/** A block that is called after each iteration */
@property (nonatomic, copy, nullable) RepeatCompletionBlock repeatCompletion;

/**
 Indicates if the timeline automatically, creates a backward animation
 (.fillMode = kCAFillModeBackwards), setting the model values on the beggining
 of the animation (when -play is called).
 @discussion This setting sets the layer properties to the final values of each
 animation and performs the animation in backward, from the current layer property.

 @note Works only on animations that are subclasses of CABasicAnimation.
 */
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
 TimelineAnimation with a DisplayLink.
 @param completion an optional block to be called when the animation completes.
 */
- (instancetype)initWithStart:(nullable TimelineAnimationOnStartBlock)onStart
                   completion:(nullable TimelineAnimationCompletionBlock)completion NS_DESIGNATED_INITIALIZER;

/** Convenience constructor. */
- (instancetype)initWithCompletion:(nullable TimelineAnimationCompletionBlock)completion;

/** Convenience constructor. */
- (instancetype)initWithStart:(nullable TimelineAnimationOnStartBlock)onStart;

/** Convenience constructor. */
- (instancetype)initWithUpdate:(TimelineAnimationOnUpdateBlock)onUpdate
      preferredFramesPerSecond:(NSInteger)preferredFramesPerSecond;

/** Convenience constructor. */
+ (instancetype)timelineAnimationWithCompletion:(TimelineAnimationCompletionBlock)completion;

/** Convenience constructor. */
+ (instancetype)timelineAnimation;

/** Convenience constructor. */
+ (instancetype)timelineAnimationOnStart:(TimelineAnimationOnStartBlock)onStart
                              completion:(TimelineAnimationCompletionBlock)completion;

/** A flag indicating whether the receiver is a reversed derivation */
@property (nonatomic, readonly, getter=isReversed) BOOL reversed;

/** The TimelineAnimation from which the receiver was derived */
@property (nonatomic, weak, readonly) __kindof TimelineAnimation * __nullable originate;

/** The parent of the TimelineAnimation if contained in a group. */
@property (nonatomic, weak, readonly) __kindof TimelineAnimation * __nullable parent;

/** A flag indicating whether the `TimelineAnimation` has any animations. */
@property (nonatomic, readonly, getter=isEmpty) BOOL empty;

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
            forLayer:(__kindof CALayer *)layer NS_REFINED_FOR_SWIFT;

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
             onStart:(TimelineAnimationOnStartBlock)onStart NS_REFINED_FOR_SWIFT;

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
          onComplete:(TimelineAnimationCompletionBlock)complete NS_REFINED_FOR_SWIFT;

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
             onStart:(TimelineAnimationOnStartBlock)onStart
          onComplete:(TimelineAnimationCompletionBlock)complete NS_REFINED_FOR_SWIFT;

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
           withDelay:(NSTimeInterval)delay NS_REFINED_FOR_SWIFT;

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
             onStart:(TimelineAnimationOnStartBlock)onStart NS_REFINED_FOR_SWIFT;

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
          onComplete:(TimelineAnimationCompletionBlock)complete NS_REFINED_FOR_SWIFT;

/**
 Appends an animation at the end of the timeline, after a delay.

 @param animation a property animation describing the animation to be applied on the layer
 @param layer the layer whose property is to be animated in the TimelineAnimation
 @param delay the delay, must be > 0.0, in seconds
 @param onStart an optional block to be called on the beginning of the animation
 @param complete an optional block to be called when the animation completes

 @throws NSInvalidArgumentException if either `layer` on `animation` are `nil`.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
             onStart:(nullable TimelineAnimationOnStartBlock)onStart
          onComplete:(nullable TimelineAnimationCompletionBlock)complete NS_REFINED_FOR_SWIFT;

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
                 atTime:(RelativeTime)time NS_REFINED_FOR_SWIFT;

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
                onStart:(TimelineAnimationOnStartBlock)start NS_REFINED_FOR_SWIFT;

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
             onComplete:(TimelineAnimationCompletionBlock)complete NS_REFINED_FOR_SWIFT;


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
                onStart:(nullable TimelineAnimationOnStartBlock)start
             onComplete:(nullable TimelineAnimationCompletionBlock)complete NS_REFINED_FOR_SWIFT;


/**
 Convenience method
 
 @throws NSInvalidArgumentException if either `layer` on `animations` are `nil`.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 */
- (void)insertAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
                forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time NS_REFINED_FOR_SWIFT;


/**
 Inserts an array of animations in the TimelineAnimation for the provided layer
 at the given time. Each animation can have different durations.
 
 @param animations the animation to insert in the timeline
 @param layer the layer whose property is to be animated in the TimelineAnimation
 @param time the time, in the TimelineAnimation's relative time (seconds), to insert the animations
 @param onStartBlocks an array with blocks to associated with each animation. If not `nil`, `onStartBlocks` should be a 1:1 mapping with `animations`. Use `TimelineAnimationOnStartBlockNull` when no `onStartBlock` is needed.
 @param completionBlocks an array with blocks to associated with each animation. If not `nil`, `completionBolcks` should be a 1:1 mapping with `animations`. Use `TimelineAnimationCompletionBlockNull` when no `completionBlock` is needed.
 
 
 @throws NSInvalidArgumentException if either `layer` on `animations` are `nil`.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 @throws TimelineAnimationInvalidNumberOfBlocksException when the number of `onStartBlocks` or `completionBlocks` is not a 1:1 mapping with `animations`.
 */
- (void)insertAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
                forLayer:(__kindof CALayer *)layer
                  atTime:(RelativeTime)time
           onStartBlocks:(nullable NSArray<TimelineAnimationOnStartBlock> *)onStartBlocks
        completionBlocks:(nullable NSArray<TimelineAnimationCompletionBlock> *)completionBlocks NS_REFINED_FOR_SWIFT;


/**
 Convenience method
 
 @throws NSInvalidArgumentException if either `layer` on `animations` are `nil`.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 @throws TimelineAnimationInvalidNumberOfBlocksException when the number of `onStartBlocks` or `completionBlocks` is not a 1:1 mapping with `animations`.
 */
- (void)addAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
             forLayer:(__kindof CALayer *)layer
            withDelay:(NSTimeInterval)delay NS_REFINED_FOR_SWIFT;

/**
 Appends all animations at the end of the timeline, after a delay. All 
 animations will be appendend at the same time.
 
 @param animations the animation to insert in the timeline
 @param layer the layer whose property is to be animated in the TimelineAnimation
 the delay, must be > 0.0, in seconds
 @param delay the delay in seconds. if delay < 0 then the timeline animation
 @param onStartBlocks an array with blocks to associated with each animation. If not `nil`, `onStartBlocks` should be a 1:1 mapping with `animations`. Use `TimelineAnimationOnStartBlockNull` when no `onStartBlock` is needed.
 @param completionBlocks an array with blocks to associated with each animation. If not `nil`, `completionBolcks` should be a 1:1 mapping with `animations`. Use `TimelineAnimationCompletionBlockNull` when no `completionBlock` is needed.
 
 @throws NSInvalidArgumentException if either `layer` on `animations` are `nil`.
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the animation is conflicting with existing animations in the timeline.
 @throws TimelineAnimationInvalidNumberOfBlocksException when the number of `onStartBlocks` or `completionBlocks` is not a 1:1 mapping with `animations`.
 */
- (void)addAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
             forLayer:(__kindof CALayer *)layer
            withDelay:(NSTimeInterval)delay
        onStartBlocks:(nullable NSArray<TimelineAnimationOnStartBlock> *)onStartBlocks
     completionBlocks:(nullable NSArray<TimelineAnimationCompletionBlock> *)completionBlocks NS_REFINED_FOR_SWIFT;

/**
 Inserts the animations of the TimelineAnimation provided with the animations of
 the receiver.
 
 @param timeline the timeline with whom animations to merge in the receiver
 
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws TimelineAnimationConflictingAnimationsException if the mergin timeline contains conflicting animations.
 */
- (void)merge:(TimelineAnimation *)timeline;

@end

#pragma mark - Control Blocks 

@interface TimelineAnimation (ControlBlocks)

- (void)removeOnStartBlocks;
- (void)removeCompletionBlocks;

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
 @discussion Stops a TimelineAnimation that uses a display link/onUpdate block.
 If you call this method on another TimelineAnimation it throws
 */
- (void)stopUpdates;



/**
 Delays all the animations of the timeline by a delay
 @param delay the delay in seconds. if delay < 0 then the timeline animation
 starts at an advanced state.
 */
- (void)delay:(const NSTimeInterval)delay;

/**
 @discussion Creates a TimelineAnimation with the requested duration. The
 resulted TimelineAnimation has scaled propertionally its animation to match the
 requested duration.
 @param duration the new duration in seconds.
 @return a new TimelineAnimation with the requested duration.
 */
- (instancetype)timelineWithDuration:(const NSTimeInterval)duration;

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
 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 */
- (void)notifyAtTime:(RelativeTime)time
          usingBlock:(TimelineAnimationNotifyBlock)block NS_REFINED_FOR_SWIFT;


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

 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 */
- (void)notifyAtProgress:(float)progress
              usingBlock:(TimelineAnimationNotifyBlock)block NS_REFINED_FOR_SWIFT;

@end

@interface TimelineAnimation (Audio)

/**
 Associates an audio to the provided TimelineAudioAssociation.

 @param audio the audio to be associated with the timeline.
 @param association the association describing at which point to associate the audio in the timeline.

 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 @throws EmptyTimelineAnimationException if the receiver is empty.
 */
- (void)associateAudio:(id<TimelineAudio>)audio
  usingTimeAssociation:(TimelineAudioAssociation *)association NS_REFINED_FOR_SWIFT;

/**
 Removes **all** audio at association.

 @discussion This method is best effort. If the association is not exactly the same
 it does not guarantee to remove the associated audio.

 @param association the time association whose audio is to be disassociated.

 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 */
- (void)disassociateAudioAtTimeAssociation:(TimelineAudioAssociation *)association NS_REFINED_FOR_SWIFT;

/**
 Removes audio provided audio.

 @discussion TimelineAnimation searches with strict pointer comparison the audio to be
 removed. This is method is best effort, it does not guarantee to remove the audio.

 @param audio the audio to be disassociated.

 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 */
- (void)disassociateAudio:(id<TimelineAudio>)audio NS_REFINED_FOR_SWIFT;

/**
 Removes all audio associations.

 @discussion This method guarantees that all audio will be disassociated from the timeline.

 @throws ImmutableTimelineAnimationException if called on an ongoing timeline.
 */
- (void)disassociateAllAudio;




/**
 Returns the audios beginning at a given time, if any.
 
 @param time begining time of audio
 @return an array containing any sounds beginning a the specified time, if there
 is no audio associated then the array is empty.
 @throws OngoingTimelineAnimationException as time in not relevant anymore. after -play time is invalidated.
 */
- (NSArray<id<TimelineAudio>> *)associatedAudioBeginingAtTime:(RelativeTime)time;

/**
 Returns the audios ongoing at a given time, if any.
 
 @param time time at which an audio is ongoing (started and not finished yet)
 @return an array containing any sounds ongoing a the specified time, if there 
 is no audio associated then the array is empty.
 @throws OngoingTimelineAnimationException as time in not relevant anymore. after -play time is invalidated.
 */
- (NSArray<id<TimelineAudio>> *)associatedOngoingAtTime:(RelativeTime)time;

/**
 Returns the audios associated with the timeline.
 
 @return an array containing any sounds associated with this timeline.
 */
@property (nonatomic, strong, readonly) NSArray<id<TimelineAudio>> *associatedAudios;

@end

@interface TimelineAnimation (Copying) <NSCopying>
@end

@interface TimelineAnimation (Debug)

@property (nonatomic, readonly) NSString *summary;
- (NSArray<__kindof CAPropertyAnimation *> *)animationsBeginingAtTime:(RelativeTime)time;
- (NSArray<__kindof CAPropertyAnimation *> *)animationsOngoingAtTime:(RelativeTime)time;

@property (nonatomic, readonly, strong) NSArray<__kindof CAPropertyAnimation *> *allPropertyAnimations;

@end

@interface TimelineAnimation (Plumbing)

@property (nonatomic, readonly, strong) NSArray<TimelineAnimationDescription *> *animationDescriptions;
- (void)combineAnimationDescriptions:(NSArray<TimelineAnimationDescription *> *)animationDescriptions;

@end

@interface TimelineAnimation (ErrorReporting)

@property (nonatomic, class, copy) TimelineAnimationErrorReportingBlock errorReporting;

@end

NS_ASSUME_NONNULL_END
