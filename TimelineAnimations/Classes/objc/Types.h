//
//  Types.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 23/02/2017.
//  Copyright © 2017 AbZorba Games. All rights reserved.
//

//#ifndef Types_h
//#define Types_h

// Types
typedef double RelativeTime;

/** Block used for onStart, onUpdate and time notifications. */
typedef void (^TimelineAnimationVoidBlock)(void);

typedef TimelineAnimationVoidBlock TimelineAnimationOnStartBlock;
typedef TimelineAnimationVoidBlock TimelineAnimationNotifyBlock;
typedef TimelineAnimationVoidBlock TimelineAnimationOnUpdateBlock;


/** Block used for completion */
typedef void (^TimelineAnimationBoolBlock)(BOOL result);

typedef TimelineAnimationBoolBlock TimelineAnimationCompletionBlock;


/** Empty block that does nothing. */
static const _Nonnull TimelineAnimationOnStartBlock TimelineAnimationOnStartBlockNull = ^{};
/** Empty block that does nothing. */
static const _Nonnull TimelineAnimationCompletionBlock TimelineAnimationCompletionBlockNull = ^(BOOL completion){};


/**
 @param result a Boolean indicating the result of the animation.
 @param iteration the repeat iteration
 @param stop a reference to a Boolean value. The block can set the value to `YES` to stop
 further repeats of the TimelineAnimations. If a block stops further repeats, that
 block continues to run until it’s finished. The `stop` argument is an out-only
 argument. You should only ever set this Boolean to `YES` within the block.
 */
typedef void (^RepeatCompletionBlock)(BOOL result, NSUInteger iteration, BOOL * _Nonnull stop);

typedef void (^RepeatOnStartBlock)(NSUInteger iteration);

/** The repeat count type for repeating animations. */
typedef NSUInteger TimelineAnimationRepeatCount NS_REFINED_FOR_SWIFT;// __attribute__((swift_wrapper(enum)))// NS_REFINED_FOR_SWIFT;
/** This will cause a repeating TimelineAnimation to repeat forever. */
static const TimelineAnimationRepeatCount TimelineAnimationRepeatCountInfinite NS_REFINED_FOR_SWIFT = NSUIntegerMax;

static const NSTimeInterval TimelineAnimationMillisecond = 0.001;

//#endif /* Types_h */
