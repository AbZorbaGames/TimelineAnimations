//
//  TimelineAnimationProtected.h
//  TimelineAnimations
//
//  Created by Georges Boumis on 18/02/2016.
//  Copyright © 2016-2017 AbZorba Games. All rights reserved.
//

@class TimelineAnimationsProgressMonitorLayer;
@class TimelineEntity;
@class TimelineAnimationsBlankLayer;
@class TimelineAnimationNotifyBlockInfo;
@class TimelineAnimationWeakLayerBox;

#import "Types.h"
#import "PrivateTypes.h"

@interface TimelineAnimation () {
@protected
    float _speed;
    float _progress;
    
    struct {
        TimelineAnimationRepeatCount count;
        TimelineAnimationRepeatIteration iteration;
        BOOL isRepeating;
        BOOL onStartCalled;
        BOOL onCompleteCalled;
    } _repeat;

    NSSet<TimelineAnimationWeakLayerBox *> *_cachedAffectedLayers;
}

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign, getter=isPaused) BOOL paused;
@property (nonatomic, assign, getter=hasStarted) BOOL started;
@property (nonatomic, assign, getter=hasFinished) BOOL finished;
@property (nonatomic, readwrite, strong, nonnull) NSMutableArray<TimelineEntity *> *animations;

@property (nonatomic, assign, getter=wasOnStartCalled) BOOL onStartCalled;
@property (nonatomic, assign, getter=wasOnCompletionCalled) BOOL onCompletionCalled;
@property (nonatomic, readwrite, getter=isReversed) BOOL reversed;
@property (nonatomic, readwrite, getter=isCleared) BOOL cleared;

@property (nonatomic, readonly, getter=isRepeating) BOOL repeating;
@property (nonatomic, readonly, getter=isInfinitelyRepeating) BOOL infinite;

@property (nonatomic, readonly) NSTimeInterval nonRepeatingDuration;


@property (nonatomic, strong, nonnull) NSMutableArray<TimelineAnimationsBlankLayer *> *blankLayers;

@property (nonatomic, readwrite) float progress;
@property (nonatomic, strong, nullable) TimelineAnimationsProgressMonitorLayer *progressLayer;

@property (nonatomic, strong, nonnull) ProgressNotificationAssociations *progressNotificationAssociations;
@property (nonatomic, strong, nonnull) NotificationAssociations *timeNotificationAssociations;

@property (nonatomic, weak, readwrite, nullable) __kindof TimelineAnimation *originate;
@property (nonatomic, weak, readwrite, nullable) __kindof TimelineAnimation *parent;

@property (nonatomic, readonly, getter=isNonEmpty) BOOL nonEmpty;

@property (nonatomic, readonly) RelativeTime endTimeWithNoRepeating;

@property (nonatomic, readonly, nonnull) NSSet<__kindof CALayer *> *affectedLayers;

@property (nonatomic, readonly, copy, nonnull) TimelineAnimationCurrentMediaTimeBlock currentTime;

@property (nonatomic, readonly, strong) NSSet<TimelineAnimationWeakLayerBox *> *cachedAffectedLayers;

- (void)reset;
- (void)_prepareForRepeat;
- (void)_prepareForReplay;
- (void)_replay;
- (BOOL)_repeatIfNeededHasGracefullyFinished:(BOOL)gracefullyFinished;

- (void)callOnStart;
- (void)callOnComplete:(BOOL)result;
- (void)_callOnComplete:(BOOL)result;

- (void)_setOnStart:(nullable TimelineAnimationOnStartBlock)onStart;
- (void)_setCompletion:(nullable TimelineAnimationCompletionBlock)completion;

- (void)_setupTimeNotifications;
- (void)_setupProgressNotifications;
- (void)_setupProgressMonitoring;

- (void)_cleanUp;

- (void)pauseWithCurrentTime:(nonnull TimelineAnimationCurrentMediaTimeBlock)currentTime
         alreadyPausedLayers:(nonnull NSMutableSet<__kindof CALayer *> *)pausedLayers;

- (void)resumeWithCurrentTime:(nonnull TimelineAnimationCurrentMediaTimeBlock)currentTime
         alreadyResumedLayers:(nonnull NSMutableSet<__kindof CALayer *> *)resumedLayers;

- (void)insertBlankAnimationAtTime:(RelativeTime)time
                           onStart:(nullable TimelineAnimationOnStartBlock)start
                        onComplete:(nullable TimelineAnimationCompletionBlock)complete
                      withDuration:(NSTimeInterval)duration;

- (nonnull NotificationAssociations *)timeNotificationConvertedUsing:(nonnull NS_NOESCAPE TimeNotificationCalculation)calculation;

- (BOOL)_checkForOutOfHierarchyIssues;

// exceptions
- (void)___raiseOrLogException:(nonnull TimelineAnimationExceptionName)exception
                        format:(nonnull NSString *)format
                     arguments:(va_list)arguments NS_FORMAT_FUNCTION(2, 0);

- (void)___raiseException:(nonnull TimelineAnimationExceptionName)exception
                   format:(nonnull NSString *)format
                arguments:(va_list)arguments NS_FORMAT_FUNCTION(2, 0) TIMELINE_ANIMATION_NO_RETURN;

- (void)__raiseTimeNotificationOutOfBoundsExceptionWithReason:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)__raiseNotImplementedMethodExceptionWithReason:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)__raiseOngoingTimelineAnimationWithReason:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)__raiseClearedTimelineAnimationExceptionWithReason:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)__raiseEmptyTimelineAnimationWithReason:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)__raiseImmutableTimelineAnimationExceptionWithReason:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)__raiseUnsupportedMessageExceptionWithReason:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)__raiseConflictingAnimationExceptionWithReason:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)__raiseInvalidNumberOfBlocksExceptionWithReason:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)__raiseInvalidArgumentExceptionWithReason:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);
- (void)__raiseElementsNotInHierarchyExceptionWithReason:(nonnull NSString *)format, ... NS_FORMAT_FUNCTION(1,2);


// protected
- (void)__raiseConflictingAnimationExceptionBetweenEntity:(nonnull TimelineEntity *)entity1
                                                andEntity:(nonnull TimelineEntity *)entity;

@end

@interface TimelineAnimation (ProtectedControl)
- (void)_playWithCurrentTime:(nonnull TimelineAnimationCurrentMediaTimeBlock)currentTime;
@end

@interface TimelineAnimation (ReverseProtected)

- (nonnull instancetype)reversedWithDuration:(NSTimeInterval)duration;

@end
