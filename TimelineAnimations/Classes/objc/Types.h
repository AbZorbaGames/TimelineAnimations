//
//  Types.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 23/02/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

//#ifndef Types_h
//#define Types_h

@import Foundation;

@class TimelineAnimation;

// Types

/** The time representation for TimelineAnimation. */
typedef double RelativeTime;

/** Block used for onStart, onUpdate and time notifications. */
typedef void (^TimelineAnimationVoidBlock)(void);

typedef TimelineAnimationVoidBlock TimelineAnimationOnStartBlock;
typedef TimelineAnimationVoidBlock TimelineAnimationNotifyBlock;
typedef TimelineAnimationVoidBlock TimelineAnimationOnUpdateBlock;

/** Block used for error reporting instead of exceptions. */
typedef void (^TimelineAnimationErrorReportingBlock)(TimelineAnimation *const _Nonnull animation,
                                                     NSError *const _Nonnull error);

/** The error domain of the framework. */
FOUNDATION_EXTERN NSErrorDomain const TimelineAnimationsErrorDomain;

/** The error codes of the framework. */
typedef NS_ENUM(NSInteger, TimelineAnimationsErrorDomainCode) {
    /** This error occurs when a mutation is attempted on an already started TimelineAnimation. */
    TimelineAnimationsErrorDomainCodeImmutbaleTimelineAnimation,
    /** This error occurs when a trying to associate audio or a time notification to an empty TimelineAnimation. */
    TimelineAnimationsErrorDomainCodeEmptyTimelineAnimation,
    /** This error occurs when a -play message is sent to a cleared TimelineAnimation. */
    TimelineAnimationsErrorDomainCodeClearedTimelineAnimation,
    /** This error occurs when trying to play an non finished (that is already playing) TimelineAnimation. */
    TimelineAnimationsErrorDomainCodeOngoingTimelineAnimation,
    /** This error occurs when registering for a time notification after the `.endTime` of the TimelineAnimation. */
    TimelineAnimationsErrorDomainCodeTimeNotificationOutOfBounds,
    /** This error occurs when adding the number of blocks passed to the method does not correspond with the animations provided */
    TimelineAnimationsErrorDomainCodeInvalidNumberOfBlocks,
    /** This error occurs when adding an animation that directly conflicts with an existing animation, that is already present, in the TimelineAnimation. */
    TimelineAnimationsErrorDomainCodeConflictingAnimations,
    /** This error occurs when playing (or repeating) an animation and any of its layers is not part of a layer hierarchy. */
    TimelineAnimationsErrorDomainCodeOutOfHierarchyException,
    /** This error occurs when adding bare animations to a GroupTimelineAnimation. */
    TimelineAnimationsErrorDomainCodeUnsupportedMesasge,
    /** This error occurs when features of TimelineAnimations are not implemented yet ^_^. */
    TimelineAnimationsErrorDomainCodeMethodNotImplementedYet

};

/** The error key containing the TimelineAnimation. */
FOUNDATION_EXTERN NSErrorUserInfoKey const TimelineAnimationReferenceKey;
/** The error key containing the summarry of the TimelineAnimation. */
FOUNDATION_EXTERN NSErrorUserInfoKey const TimelineAnimationSummaryKey;

/** Block used for completion */
typedef void (^TimelineAnimationBoolBlock)(BOOL result);

typedef TimelineAnimationBoolBlock TimelineAnimationCompletionBlock;

/** Empty block that does nothing. */
static const _Nonnull TimelineAnimationOnStartBlock TimelineAnimationOnStartBlockNull = ^{};
/** Empty block that does nothing. */
static const _Nonnull TimelineAnimationCompletionBlock TimelineAnimationCompletionBlockNull = ^(BOOL copmeleted){};

/** The repeat iteration type for repeating animations. */
typedef uint64_t TimelineAnimationRepeatIteration;

/**
 @param result a Boolean indicating the result of the animation.
 @param iteration the repeat iteration
 @param stop a reference to a Boolean value. The block can set the value to `YES` to stop
 further repeats of the TimelineAnimations. If a block stops further repeats, that
 block continues to run until it’s finished. The `stop` argument is an out-only
 argument. You should only ever set this Boolean to `YES` within the block.
 */
typedef void (^RepeatCompletionBlock)(BOOL result, TimelineAnimationRepeatIteration iteration, BOOL * _Nonnull stop);

typedef void (^RepeatOnStartBlock)(TimelineAnimationRepeatIteration iteration);

/** The repeat count type for repeating animations. */
typedef uint64_t TimelineAnimationRepeatCount NS_REFINED_FOR_SWIFT;// __attribute__((swift_wrapper(enum)))// NS_REFINED_FOR_SWIFT;
/** This will cause a repeating TimelineAnimation to repeat forever. */
static const TimelineAnimationRepeatCount TimelineAnimationRepeatCountInfinite NS_REFINED_FOR_SWIFT = UINT64_MAX;

static const NSTimeInterval TimelineAnimationMillisecond = (NSTimeInterval)0.001;

/// one frame is 16ms on 60fps devices.
static const NSTimeInterval TimelineAnimationOneFrame = (NSTimeInterval)0.016;

//#endif /* Types_h */
