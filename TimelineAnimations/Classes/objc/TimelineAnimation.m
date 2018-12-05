//
//  TimelineAnimation.m
//  TimelineAnimations
//
//  Created by Georges Boumis on 14/09/2015.
//  Copyright (c) 2015-2016 Abzorba Games. All rights reserved.
//

#import "TimelineAnimation.h"
#import "TimelineEntity.h"
#import "TimelineAnimationProtected.h"
#import "TimelineAnimationsProgressMonitorLayer.h"
#import "KeyValueBlockObservation.h"
#import "TimelineAnimationsBlankLayer.h"
#import "TimelineAudio.h"
#import "TimelineAudioAssociation.h"
#import "TimelineAudioAssociation_Internal.h"
#import "TimelineAnimationNotifyBlockInfo.h"
#import "TimelineAnimationsDisplayLink.h"
#import "NSArray+TimelineSwiftyAdditions.h"
#import "TimelineAnimationDescription.h"
#import "PrivateTypes.h"
@import ObjectiveC;
#import "GroupTimelineAnimation.h"
#import "TimelineAudioAssociation_Internal.h"
#import "NSSet+TimelineSwiftyAdditions.h"
#import "TimelineAnimationWeakLayerBox.h"

TimelineAnimationExceptionName ImmutableTimelineAnimationException = @"ImmutableTimelineAnimation";
TimelineAnimationExceptionName EmptyTimelineAnimationException = @"EmptyTimeline";
TimelineAnimationExceptionName ClearedTimelineAnimationException = @"ClearedTimelineAnimation";
TimelineAnimationExceptionName OngoingTimelineAnimationException = @"OngoingTimelineAnimation";
TimelineAnimationExceptionName TimelineAnimationTimeNotificationOutOfBoundsException = @"TimelineAnimationTimeNotificationOutOfBounds";
TimelineAnimationExceptionName TimelineAnimationMethodNotImplementedYetException = @"MethodNotImplementedYet";
TimelineAnimationExceptionName TimelineAnimationUnsupportedMessageException = @"UnsupportedMessage";
TimelineAnimationExceptionName TimelineAnimationConflictingAnimationsException = @"ConflictingAnimations";
TimelineAnimationExceptionName TimelineAnimationInvalidNumberOfBlocksException = @"TimelineAnimationInvalidNumberOfBlocksException";
TimelineAnimationExceptionName TimelineAnimationElementsNotInHierarchyException = @"TimelineAnimationElementsNotInHierarchyException";

NSErrorDomain const TimelineAnimationsErrorDomain = @"TimelineAnimationsErrorDomain";

NSErrorUserInfoKey const TimelineAnimationReferenceKey = @"timeline";
NSErrorUserInfoKey const TimelineAnimationSummaryKey = @"summary";

@interface TimelineAnimation ()

@property (nonatomic, strong) TimelineAnimationsDisplayLink *displayLink;
@property (nonatomic, strong) NSMutableSet<TimelineEntity *> *unfinishedEntities;

@property (nonatomic, assign) ObservationID progressObservationID;

@end

@implementation TimelineAnimation

@synthesize progress=_progress;

#pragma mark - Initializers

- (instancetype)initWithStart:(nullable TimelineAnimationOnStartBlock)onStart
                   completion:(nullable TimelineAnimationCompletionBlock)completion {
    self = [super init];
    if (self) {
        _onStart       = onStart;
        self.onUpdate  = nil;
        _completion    = completion;

        _animations    = [[NSMutableArray alloc] init];
        _blankLayers   = [[NSMutableArray alloc] init];

        _progressNotificationAssociations = [[ProgressNotificationAssociations alloc] init];
        _timeNotificationAssociations     = [[NotificationAssociations alloc] init];

        _paused        = NO;
        _speed         = 1.0f;
        _progress      = 0.0f;
    }
    return self;
}

- (instancetype)init {
    return [self initWithStart:nil completion:nil];
}

- (instancetype)initWithStart:(nullable TimelineAnimationOnStartBlock)onStart {
    return [self initWithStart:onStart completion:nil];
}

- (instancetype)initWithUpdate:(TimelineAnimationOnUpdateBlock)onUpdate
      preferredFramesPerSecond:(NSInteger)preferredFramesPerSecond {

    NSParameterAssert(onUpdate != nil);
    NSParameterAssert(preferredFramesPerSecond != 0);

    self = [self initWithStart:nil completion:nil];
    if (self) {
        self.onUpdate = onUpdate;
        self.preferredFramesPerSecond = preferredFramesPerSecond;
    }
    return self;
}

- (instancetype)initWithCompletion:(TimelineAnimationCompletionBlock)completion {
    return [self initWithStart:nil completion:completion];
}

+ (instancetype)timelineAnimationWithCompletion:(TimelineAnimationCompletionBlock)completion {
    return [[TimelineAnimation alloc] initWithCompletion:completion];
}

+ (instancetype)timelineAnimation {
    return [[TimelineAnimation alloc] initWithStart:nil completion:nil];
}

+ (instancetype)timelineAnimationOnStart:(TimelineAnimationOnStartBlock)onStart
                              completion:(TimelineAnimationCompletionBlock)completion {
    return [[TimelineAnimation alloc] initWithStart:onStart completion:completion];
}

- (void)dealloc {
    [self _cleanUp];
    //    _blankLayers = nil;
    //    _animations = nil;
    _originate = nil;
    _parent = nil;
}

#pragma mark - On Update Methods -

- (void)setOnUpdate:(TimelineAnimationOnStartBlock)onUpdate {
    if (onUpdate == nil) {
        [self _removeDisplayLink];
        _onUpdate = nil;
        return;
    }
    _onUpdate = [onUpdate copy];
    // Create the display link
    [self _createDisplayLink];
}

#pragma mark - Display Link Methods -

- (void)_createDisplayLink {
    self.displayLink = [TimelineAnimationsDisplayLink displayLinkPreferredFramesPerSecond:self.preferredFramesPerSecond
                                                                                    block:^(CFTimeInterval timestamp) {
                                                                                        [self displayLinkTick:timestamp];
                                                                                    }];
    [self.displayLink pause];
}

- (void)_removeDisplayLink {
    [self.displayLink stop];
    self.displayLink = nil;
    //    [self.displayLink invalidate];
    //    self.displayLink = nil;
}

- (void)_startDisplayLinkIfNeeded {
    if (self.displayLink) {
        [self callOnStart];
        [self.displayLink resume];
    }
}

- (void)_pauseDisplayLink {
    [self.displayLink pause];
}

- (void)displayLinkTick:(CFTimeInterval)timestamp {

    if (_onUpdate != nil) {
        _onUpdate();
    }
    else {
        // if no update exist then the display link should cease to exist
        [self _removeDisplayLink];
    }
}

#pragma mark - Adding Animation Methods -

- (TimelineEntity *)lastEntity {
    __block TimelineEntity *res = nil;
    __block RelativeTime maxTime = 0;
    for (TimelineEntity *const entity in _animations) {
        const RelativeTime endTime = entity.endTime;
        if (endTime >= maxTime) {
            maxTime = endTime;
            res = entity;
        }
    };
    return res;
}

- (void)_addTimelineEntity:(TimelineEntity *)timelineEntity {

    {   // check if already in
        const BOOL alreadyIn = [_animations containsObject:timelineEntity];
        guard (!alreadyIn) else {
            NSIndexSet *const indexes = [_animations indexesOfObjectsPassingTest:^BOOL(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
                const BOOL result = [entity isEqual:timelineEntity];
                *stop = result;
                return result;
            }];
            // raise conflict
            TimelineEntity *const entity = _animations[indexes.firstIndex];
            [self __raiseConflictingAnimationExceptionBetweenEntity:entity
                                                          andEntity:timelineEntity];
            return;
        }
    }

    {   // check if conflicting
        NSIndexSet *const indexes = [_animations indexesOfObjectsPassingTest:^BOOL(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
            const BOOL result = [entity conflictingWith:timelineEntity];
            *stop = result;
            return result;
        }];
        const BOOL conflicting = (indexes.count != 0);
        guard (not(conflicting)) else {
            // raise conflict
            TimelineEntity *const entity = _animations[indexes.firstIndex];
            [self __raiseConflictingAnimationExceptionBetweenEntity:entity
                                                          andEntity:timelineEntity];
            return;
        }
    }

    // add the timeline entity
    [_animations addObject:timelineEntity];
}

#pragma mark - Animation Control Methods -

- (void)callOnStart {

    // call general on start
    if (!_onStartCalled && _onStart) {
        _onStart();
        _onStartCalled = YES;
    }

    if (self.isRepeating) {
        guard (!_repeat.onStartCalled) else { return; }

        if (_repeatOnStart) {
            _repeatOnStart(_repeat.iteration);
            _repeat.onStartCalled = YES;
        }
    }
}

- (void)callOnComplete:(BOOL)gracefullyFinished {
    guard (_unfinishedEntities.count == 0) else { return; }
    [self _callOnComplete:gracefullyFinished];
}

- (void)_callOnComplete:(BOOL)gracefullyFinished {

    self.finished = YES;
    self.started = NO;

    // repeat
    const BOOL repeats = [self _repeatIfNeededHasGracefullyFinished:gracefullyFinished];
    if (repeats) { return; }

    if ((_onCompletionCalled == NO) && (_completion != nil)) {
        _completion(gracefullyFinished);
        _onCompletionCalled = YES;
    }
    [self _removeDisplayLink];
}

- (BOOL)_repeatIfNeededHasGracefullyFinished:(BOOL)gracefullyFinished {
    guard (self.isRepeating) else { return NO; }
    guard (gracefullyFinished) else {
        NSAssert(gracefullyFinished != NO,
                 @"TimelineAnimations: the following animation did not gracefully finish %@",
                 [self summary]);
        return NO;
    }

    BOOL hasMoreIterations = (BOOL)(_repeat.iteration < _repeat.count) || (self.isInfinitelyRepeating);

    // call repeatCompletion if any
    if ((_repeatCompletion != nil) && not(_repeat.onCompleteCalled)) {
        // inform the user that an iteration completed
        // also ask him if he wants to stop
        BOOL shouldStop = NO;
        _repeatCompletion(gracefullyFinished, _repeat.iteration, &shouldStop);
        hasMoreIterations = hasMoreIterations && not(shouldStop);
        _repeat.onCompleteCalled = YES;
    }
    guard (hasMoreIterations) else { return NO; }

    // increment iteration count
    if ((TimelineAnimationRepeatIteration)UINT64_MAX - _repeat.iteration < (TimelineAnimationRepeatIteration)1ULL) {
        _repeat.iteration = (TimelineAnimationRepeatIteration)0ULL;
    }
    _repeat.iteration += (TimelineAnimationRepeatIteration)1ULL;

    guard (self.isNonEmpty) else { return NO; } // has animations

    // replay
    __weak typeof(self) welf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strelf = welf;
        guard (strelf != nil) else { return; }
        guard (not(strelf.isPaused)) else { return; }
        guard (not(strelf.isCleared)) else { return; }
        [strelf _replay];
    });
    return YES;
}

- (TimelineAnimationRepeatCount)repeatCount {
    // not possible to overflow as -setRepeatCount: always subtracts 1
    return _repeat.count + (TimelineAnimationRepeatCount)1LL;
}

- (void)setRepeatCount:(TimelineAnimationRepeatCount)repeatCount {
    guard (repeatCount >= (TimelineAnimationRepeatCount)1LL) else {
        NSAssert(false, @"TimelineAnimations: Wrong repeat count. Should be greater than 0.");
        return;
    }
    if (self.hasStarted) {
        [self __raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }

    const TimelineAnimationRepeatCount realRepeatCount = repeatCount - (TimelineAnimationRepeatCount)1LL;

    _repeat.count = realRepeatCount;
    _repeat.iteration = (TimelineAnimationRepeatIteration)0LL;
    _repeat.isRepeating = (realRepeatCount != (TimelineAnimationRepeatCount)0LL);
}

- (void)_replay {
    [self _prepareForRepeat];
    [self play];
}

- (void)_prepareForRepeat {
    [self reset];

    // restore the begin time for repeating animations.
    // when a repeating timeline is included in a group timeline at an non-zero
    // offset then we should bring the .beginTime back to zero, when -play
    // is called. Trust boumis on this.
    const RelativeTime begin = self.beginTime;
    if (begin != 0.0) {
        self.beginTime = 0.0;
    }
}

- (void)reset {

    if (self.hasStarted) {
        [self __raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }
    // prepare for replay
    for (TimelineEntity *const entity in _animations) {
        [entity reset];
    };

    _repeat.onStartCalled = NO;
    _repeat.onCompleteCalled = NO;


    _onStartCalled = NO;
    _onCompletionCalled = NO;

    self.finished = NO;
}

- (void)_prepareForReplay {
    _onStartCalled = NO;
    _onCompletionCalled = NO;
    self.finished = NO;

    _repeat.iteration = (TimelineAnimationRepeatIteration)0LL;
    _repeat.onStartCalled = NO;
    _repeat.onCompleteCalled = NO;
}

- (void)pauseWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
         alreadyPausedLayers:(nonnull NSMutableSet<__kindof CALayer *> *)pausedLayers {
    self.paused = YES;

    [_animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong __kindof CALayer *const slayer = entity.layer;
        if ([pausedLayers member:slayer]) {
            entity.paused = YES;
            return;
        }
        [entity pauseWithCurrentTime:currentTime];
        [pausedLayers addObject:slayer];
    }];

    [self _pauseDisplayLink];
}

- (void)resumeWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime
         alreadyResumedLayers:(nonnull NSMutableSet<__kindof CALayer *> *)resumedLayers {
    [_animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong __kindof CALayer *const slayer = entity.layer;
        if ([resumedLayers member:slayer]) {
            entity.paused = NO;
            return;
        }
        [entity resumeWithCurrentTime:currentTime];
        [resumedLayers addObject:slayer];
    }];
    self.paused = NO;
    [self _startDisplayLinkIfNeeded];
}

- (NSArray<TimelineEntity *> *)_sortedEntitesUsingKey:(NSString *)key {
    NSSortDescriptor *const sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:key
                                                                           ascending:YES];
    NSArray<NSSortDescriptor *> *const descriptors = @[sortDescriptor];
    NSArray<TimelineEntity *> *const sortedEntities = [_animations sortedArrayUsingDescriptors:descriptors];
    return sortedEntities;
}

#pragma mark - Properties

- (RelativeTime)beginTime {
    const RelativeTime begin = [self _sortedEntitesUsingKey:SortKey(beginTime)].firstObject.beginTime;
    return begin;
}

- (void)setBeginTime:(RelativeTime)beginTime {
    const RelativeTime currentMinBeginTime = self.beginTime;
    [self delay:beginTime - currentMinBeginTime];
}

- (RelativeTime)endTime {
    const RelativeTime endTime = [self _sortedEntitesUsingKey:SortKey(endTime)].lastObject.endTime;
    if (self.isRepeating && !self.isInfinitelyRepeating) {
        return (endTime - self.beginTime) * (RelativeTime)self.repeatCount + self.beginTime;
    }
    return endTime;
}

- (RelativeTime)endTimeWithNoRepeating {
    const RelativeTime endTime = [self _sortedEntitesUsingKey:SortKey(endTime)].lastObject.endTime;
    return endTime;
}

- (NSTimeInterval)duration {
    return (NSTimeInterval)(self.endTime - self.beginTime);
}

- (void)setOnStart:(TimelineAnimationOnStartBlock)onStart {
    NSAssert(onStart != nil, @"TimelineAnimations: Use -removeOnStartBlocks instead.");

    if (self.hasStarted) {
        [self __raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }

    TimelineAnimationOnStartBlock previous = [_onStart copy];
    [self _setOnStart:^{
        if (previous) {
            previous();
        }
        if (onStart) {
            onStart();
        }
    }];
}

// protected
- (void)_setOnStart:(TimelineAnimationOnStartBlock)onStart {
    _onStart = [onStart copy];
}

- (void)_setCompletion:(TimelineAnimationCompletionBlock)completion {
    _completion = [completion copy];
}

- (void)setCompletion:(TimelineAnimationCompletionBlock)completion {
    NSAssert(completion != nil, @"TimelineAnimations: Use -removeCompletionBlocks instead.");

    if (self.hasStarted) {
        [self __raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }
    TimelineAnimationCompletionBlock previous = [_completion copy];
    [self _setCompletion:^(BOOL finished){
        if (previous) {
            previous(finished);
        }
        if (completion) {
            completion(finished);
        }
    }];
}

- (void)setSpeed:(float)speed {
    if (speed < 0) {
        speed = 0;
    }
    _speed = speed;
    for (TimelineEntity *const entity in _animations) {
        entity.speed = speed;
    }
}

- (void)setStarted:(BOOL)started {
    [self willChangeValueForKey:@"started"];
    _started = started;
    [self didChangeValueForKey:@"started"];
}

- (void)setPaused:(BOOL)paused {
    [self willChangeValueForKey:@"paused"];
    _paused = paused;
    [self didChangeValueForKey:@"paused"];
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"finished"];
    _finished = finished;
    [self didChangeValueForKey:@"finished"];

    if (finished == YES) {
        [self _onFinish];
    }
}

- (BOOL)isNonEmpty {
    return !self.isEmpty;
}

- (BOOL)isEmpty {
    return (_animations.count == 0);
}

- (BOOL)isRepeating {
    return _repeat.isRepeating;
}

- (BOOL)isInfinitelyRepeating {
    return (self.repeatCount == TimelineAnimationRepeatCountInfinite);
}

- (void)_onFinish {
    [self _cleanUp];
}

- (void)_cleanUp {
    if (self.progressObservationID) {
        [[KeyValueBlockObservation observatory] removeObservationBlocksOfObject:self
                                                                     forKeyPath:@"progress"
                                                                  observationID:self.progressObservationID
                                                                        context:NULL];
    }

    [_progressLayer removeAllAnimations];
    [_progressLayer removeFromSuperlayer];
    _progressLayer = nil;

    [_blankLayers enumerateObjectsUsingBlock:^(TimelineAnimationsBlankLayer * _Nonnull layer, NSUInteger idx, BOOL * _Nonnull stop) {
        [layer removeAllAnimations];
        [layer removeFromSuperlayer];
    }];
    _blankLayers = [[NSMutableArray alloc] init];

    // remove blank animations
    NSMutableArray<TimelineEntity *> *const blankAnimations = [[NSMutableArray alloc] init];
    [_animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        guard ([entity.animation.keyPath isEqualToString:TimelineAnimationsBlankLayer.keyPath]) else { return; }
        [blankAnimations addObject:entity];
    }];
    [_animations removeObjectsInArray:blankAnimations];
}

- (NSTimeInterval)nonRepeatingDuration {
    const RelativeTime begin = [self _sortedEntitesUsingKey:SortKey(beginTime)].firstObject.beginTime;
    const RelativeTime end = [self _sortedEntitesUsingKey:SortKey(endTime)].lastObject.endTime;
    return (end - begin);
}

- (NSSet<__kindof CALayer *> *)affectedLayers {
    NSMutableSet<CALayer *> *const layers = [[NSMutableSet alloc] init];
    [self.animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong __kindof CALayer *const layer = entity.layer;
        [layers addObject:layer];
    }];
    return [layers copy];
}

- (NotificationAssociations *)timeNotificationConvertedUsing:(NS_NOESCAPE TimeNotificationCalculation)calculation {
    guard (self.timeNotificationAssociations.count > 0 ) else { return self.timeNotificationAssociations; }

    NotificationAssociations *const updatedAssociations = [[NotificationAssociations alloc] initWithCapacity:self.timeNotificationAssociations.count];
    [self.timeNotificationAssociations enumerateKeysAndObjectsUsingBlock:^(RelativeTimeNumber * _Nonnull key, NSMutableArray<TimelineAnimationNotifyBlockInfo *> *_Nonnull infos, BOOL * _Nonnull stop) {
        RelativeTimeNumber *const newKey = calculation(key);
        updatedAssociations[newKey] = [infos mutableCopy];
    }];
    return updatedAssociations;
}


- (TimelineAnimationCurrentMediaTimeBlock)currentTime {
    const CFTimeInterval _currentTime = CACurrentMediaTime();
    TimelineAnimationCurrentMediaTimeBlock currentTime = ^() {
        return _currentTime;
    };
    return [currentTime copy];
}

- (CALayer *)anyLayer {
    return self.cachedAffectedLayers.anyObject.layer;
}

#pragma mark - Exceptions

- (NSSet<TimelineAnimationWeakLayerBox *> *)cachedAffectedLayers {
    guard (_cachedAffectedLayers != nil) else {
        NSArray<TimelineAnimationWeakLayerBox *> *const boxes = [self.affectedLayers _map:^TimelineAnimationWeakLayerBox *_Nonnull(__kindof CALayer * _Nonnull layer) {
            return [[TimelineAnimationWeakLayerBox alloc] initWithLayer:layer];
        }];
        _cachedAffectedLayers = [[NSSet alloc] initWithArray:boxes];
    }
    return _cachedAffectedLayers;
}

- (BOOL)_checkForOutOfHierarchyIssues:(__kindof CALayer *__autoreleasing _Nullable * _Nullable)orphanLayer {

    // check for out of hierarchy problems
    for (TimelineAnimationWeakLayerBox *const box in self.cachedAffectedLayers) {
        __strong __kindof CALayer *const layer = box.layer;

        guard (layer != nil) else {
            if (orphanLayer != nil) {
                *orphanLayer = layer;
            }
            return YES;
        }
        guard (layer.superlayer != nil) else {
            if (orphanLayer != nil) {
                *orphanLayer = layer;
            }
            return YES;
        }
    }
    return NO;
}

- (void)__raiseConflictingAnimationExceptionBetweenEntity:(TimelineEntity *)entity1
                                                andEntity:(TimelineEntity *)entity2 {

    NSString *const reason =
    [[NSString alloc] initWithFormat:
     @"Tried to add an animation to the timeline that conflicts with another"
     " animation that is already present."
     " The conflict resides between \n\ta: %@\n\tb: %@"
     "\nContext: \n%@\n%@.",
     entity1.shortDescription,
     entity2.shortDescription,
     [entity1.timelineAnimation summaryMarkingEntity:entity1],
     [entity2.timelineAnimation summaryMarkingEntity:entity2]
     ];

    [self __raiseConflictingAnimationExceptionWithReason:reason, nil];
}

- (void)__raiseImmutableTimelineExceptionWithSelector:(SEL)sel {
    [self __raiseImmutableTimelineAnimationExceptionWithReason:
     @"Tried to modify %@.%@ in selector: \"%@\""
     " while the animation has already started.",
     NSStringFromClass(self.class),
     self.name,
     NSStringFromSelector(sel)];
}

- (void)___raiseOrLogException:(nonnull TimelineAnimationExceptionName)exception
                        format:(nonnull NSString *)format
                     arguments:(va_list)arguments {

    guard (TimelineAnimation.errorReporting != nil) else {
        [self ___raiseException:exception
                         format:format
                      arguments:arguments];
        return;
    }

    // log exception
    NSString *const reason = [[NSString alloc] initWithFormat:format
                                                    arguments:arguments];
    NSDictionary<NSErrorUserInfoKey, id> *const userInfo = @{
                                                             TimelineAnimationReferenceKey: self,
                                                             TimelineAnimationSummaryKey: self.summary,
                                                             NSLocalizedDescriptionKey: exception,
                                                             NSLocalizedFailureReasonErrorKey: reason
                                                             };
    const TimelineAnimationsErrorDomainCode code = [self.class errorCodeForException:exception];
    NSError *const error = [NSError errorWithDomain:TimelineAnimationsErrorDomain
                                               code:code
                                           userInfo:userInfo];
    TimelineAnimation.errorReporting(self, error);
}

- (void)___raiseException:(nonnull TimelineAnimationExceptionName)exception
                   format:(nonnull NSString *)format
                arguments:(va_list)arguments {

    NSString *const reason = [[NSString alloc] initWithFormat:format
                                                    arguments:arguments];
    NSDictionary<NSErrorUserInfoKey, id> *const userInfo = @{
                                                             TimelineAnimationReferenceKey: self,
                                                             TimelineAnimationSummaryKey: self.summary,
                                                             };

    @throw [NSException exceptionWithName:exception
                                   reason:[@"TimelineAnimations: " stringByAppendingString:reason]
                                 userInfo:userInfo];
}

+ (TimelineAnimationsErrorDomainCode)errorCodeForException:(TimelineAnimationExceptionName)exception {
    if ([exception isEqual:ImmutableTimelineAnimationException]) {
        return TimelineAnimationsErrorDomainCodeImmutbaleTimelineAnimation;
    }
    else if ([exception isEqual:EmptyTimelineAnimationException]) {
        return TimelineAnimationsErrorDomainCodeEmptyTimelineAnimation;
    }
    else if ([exception isEqual:ClearedTimelineAnimationException]) {
        return TimelineAnimationsErrorDomainCodeClearedTimelineAnimation;
    }
    else if ([exception isEqual:OngoingTimelineAnimationException]) {
        return TimelineAnimationsErrorDomainCodeOngoingTimelineAnimation;
    }
    else if ([exception isEqual:TimelineAnimationTimeNotificationOutOfBoundsException]) {
        return TimelineAnimationsErrorDomainCodeTimeNotificationOutOfBounds;
    }
    else if ([exception isEqual:TimelineAnimationUnsupportedMessageException]) {
        return TimelineAnimationsErrorDomainCodeUnsupportedMesasge;
    }
    else if ([exception isEqual:TimelineAnimationConflictingAnimationsException]) {
        return TimelineAnimationsErrorDomainCodeConflictingAnimations;
    }
    else if ([exception isEqual:TimelineAnimationInvalidNumberOfBlocksException]) {
        return TimelineAnimationsErrorDomainCodeInvalidNumberOfBlocks;
    }
    else if ([exception isEqual:TimelineAnimationMethodNotImplementedYetException]) {
        return TimelineAnimationsErrorDomainCodeMethodNotImplementedYet;
    }
    else if ([exception isEqual:TimelineAnimationElementsNotInHierarchyException]) {
        return TimelineAnimationsErrorDomainCodeOutOfHierarchyException;
    }
    return TimelineAnimationsErrorDomainCodeMethodNotImplementedYet;
}

#define _RAISE_WITH_VA_LIST(e) {\
va_list arguments; \
va_start(arguments, format); \
[self ___raiseOrLogException:(e) \
format:format \
arguments:arguments]; \
va_end(arguments); \
}

- (void)__raiseTimeNotificationOutOfBoundsExceptionWithReason:(nonnull NSString *)format, ... {
    _RAISE_WITH_VA_LIST(TimelineAnimationTimeNotificationOutOfBoundsException);
}
- (void)__raiseNotImplementedMethodExceptionWithReason:(nonnull NSString *)format, ... {
    _RAISE_WITH_VA_LIST(TimelineAnimationMethodNotImplementedYetException);
}
- (void)__raiseOngoingTimelineAnimationWithReason:(nonnull NSString *)format, ... {
    _RAISE_WITH_VA_LIST(OngoingTimelineAnimationException);
}
- (void)__raiseClearedTimelineAnimationExceptionWithReason:(nonnull NSString *)format, ... {
    _RAISE_WITH_VA_LIST(ClearedTimelineAnimationException);
}
- (void)__raiseEmptyTimelineAnimationWithReason:(nonnull NSString *)format, ... {
    _RAISE_WITH_VA_LIST(EmptyTimelineAnimationException);
}
- (void)__raiseImmutableTimelineAnimationExceptionWithReason:(nonnull NSString *)format, ... {
    _RAISE_WITH_VA_LIST(ImmutableTimelineAnimationException);
}
- (void)__raiseUnsupportedMessageExceptionWithReason:(nonnull NSString *)format, ... {
    _RAISE_WITH_VA_LIST(TimelineAnimationUnsupportedMessageException);
}
- (void)__raiseConflictingAnimationExceptionWithReason:(nonnull NSString *)format, ... {
    _RAISE_WITH_VA_LIST(TimelineAnimationConflictingAnimationsException);
}
- (void)__raiseInvalidNumberOfBlocksExceptionWithReason:(nonnull NSString *)format, ... {
    _RAISE_WITH_VA_LIST(TimelineAnimationInvalidNumberOfBlocksException);
}
- (void)__raiseInvalidArgumentExceptionWithReason:(nonnull NSString *)format, ... {
    _RAISE_WITH_VA_LIST(NSInvalidArgumentException);
}
- (void)__raiseElementsNotInHierarchyExceptionWithReason:(nonnull NSString *)format, ... {
    _RAISE_WITH_VA_LIST(TimelineAnimationElementsNotInHierarchyException);
}

#undef _RAISE_WITH_VA_LIST

#pragma mark - NSObject

- (BOOL)isEqual:(id)object {
    if (self == object) {
        return YES;
    }

    if (![object isMemberOfClass:[TimelineAnimation class]]) {
        return NO;
    }

    TimelineAnimation *const other = (TimelineAnimation *)object;
    const BOOL same = [other.animations isEqualToArray:_animations];
    return same;
}

#pragma mark - Debug

- (NSString *)description {
    return [[NSString alloc] initWithFormat:
            @"<%@: %p; "
            "\"%@\"; "
            "[%.3lf,%.3lf] (%.3lf); "
            "userInfo = %@;>",
            NSStringFromClass(self.class),
            (void *)self,
            _name,
            self.beginTime, self.endTime, self.duration,
            _userInfo];
}

- (NSString *)debugDescription {
    NSMutableString *string = [[NSMutableString alloc] initWithFormat:@"<%@: %p; "
                               "name = \"%@\"; "
                               "[%.3lf,%.3lf]; ",
                               NSStringFromClass(self.class),
                               (void *)self,
                               _name,
                               self.beginTime, self.endTime
                               ];
    NSString *repeats = @"0";
    if (self.isRepeating) {
        if (self.isInfinitelyRepeating) {
            repeats = @"inf";
        }
        else {
            repeats = @(self.repeatCount).stringValue;
        }
    }
    [string appendFormat:@"isRepeating(%@) = %@; ", repeats, self.isRepeating ? @"YES" : @"NO"];
    if (self.isRepeating) {
        [string appendFormat:@"duration = \"%.3lf\", ", self.nonRepeatingDuration];
        if (self.isInfinitelyRepeating) {
            [string appendFormat:@"repeatingDuration = infinite; "];
        }
        else {
            [string appendFormat:@"repeatingDuration = \"%.3lf\"; ", self.duration];
        }
    }
    [string appendFormat:@"userInfo = %@; "
     "animations = %@; "
     "timeNotifications = %@; "
     "progressNotifications = %@;"
     ">",
     _userInfo,
     _animations.debugDescription,
     _timeNotificationAssociations.allKeys,
     _progressNotificationAssociations.allKeys];
    return [string copy];
}


#pragma mark - Progress

- (void)setProgress:(float)progress {
    [self willChangeValueForKey:@"progress"];
    _progress = progress;
    [self didChangeValueForKey:@"progress"];
}


- (void)_setupProgressMonitoring {
    _progressLayer = [TimelineAnimationsProgressMonitorLayer layer];
    __weak typeof(self) welf = self;
    _progressLayer.progressBlock = ^(float progress) {
        __strong typeof(self) strelf = welf;
        strelf.progress = progress;
    };

    [_animations.firstObject.layer addSublayer:(CALayer *)_progressLayer];

    CABasicAnimation *const anim   = [CABasicAnimation animationWithKeyPath:@"progress"];
    anim.duration            = self.duration;
    anim.fromValue           = @(0.0);
    anim.toValue             = @(1.0);
    [_progressLayer addAnimation:anim forKey:@"progress"];
}

- (void)_setupProgressNotifications {
    // avoid heavy implementation if no progress observer are registered
    guard (_progressNotificationAssociations.count > 0) else { return; }

    [self _setupProgressMonitoring];


    NSMutableSet<ProgressNumber *> *const unfinished = [NSMutableSet setWithArray:_progressNotificationAssociations.allKeys];
    __weak typeof(self) welf = self;
    self.progressObservationID = [[KeyValueBlockObservation observatory] addObservationBlock:^(NSString * _Nonnull keypath, TimelineAnimation  * _Nonnull timeline, NSDictionary * _Nonnull change, void * _Nullable context) {
        __strong typeof(self) strelf = welf;
        guard (strelf != nil) else { return; }
        guard (unfinished.count > 0) else { return; } // already finished

        const float progress = ((ProgressNumber *)change[NSKeyValueChangeNewKey]).floatValue;

        NSMutableSet<ProgressNumber *> *const finished = [NSMutableSet set];
        [unfinished enumerateObjectsUsingBlock:^(ProgressNumber * _Nonnull progressNumber, BOOL * _Nonnull stop) {
            const float progressKey = progressNumber.floatValue;
            if (progress >= progressKey) {
                ((TimelineAnimationNotifyBlock)strelf.progressNotificationAssociations[progressNumber])(); // mind fuck, provided it to you by georges boumis :)
                [finished addObject:progressNumber]; // mark this progress number as finished
            }
        }];
        [unfinished minusSet:finished];
    }
                                                                                      object:self
                                                                                  forKeyPath:@"progress"
                                                                                     options:NSKeyValueObservingOptionNew
                                                                                     context:NULL];
}

#pragma mark - Time Notifications

- (void)_setupTimeNotifications {
    guard (_timeNotificationAssociations.count > 0) else { return; }

    [_timeNotificationAssociations enumerateKeysAndObjectsUsingBlock:^(RelativeTimeNumber  *_Nonnull key, NSMutableArray<TimelineAnimationNotifyBlockInfo *> *_Nonnull infos, BOOL * _Nonnull stop) {
        const RelativeTime time = key.doubleValue;
        __weak typeof(self) welf = self;
        [self insertBlankAnimationAtTime:time
                                 onStart:^{
                                     __strong typeof(welf) strelf = welf;
                                     guard (strelf != nil) else { return; }
                                     [infos enumerateObjectsUsingBlock:^(TimelineAnimationNotifyBlockInfo * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop2) {
                                         [info call:strelf.muteAssociatedSounds];
                                     }];
                                 }
                              onComplete:nil
                            withDuration:TimelineAnimationOneFrame];
    }];
}

- (void)insertBlankAnimationAtTime:(RelativeTime)time
                           onStart:(nullable TimelineAnimationOnStartBlock)start
                        onComplete:(nullable TimelineAnimationCompletionBlock)complete
                      withDuration:(NSTimeInterval)duration {

    // do not uncomment this. it will break GroupTimelineAnimation
    //    guard (self.isNonEmpty) else { return; }

    NSParameterAssert(duration >= TimelineAnimationOneFrame);

    TimelineAnimationsBlankLayer *const blankLayer = [[TimelineAnimationsBlankLayer alloc] init];
    CABasicAnimation *const blankAnimation = [CABasicAnimation animationWithKeyPath:TimelineAnimationsBlankLayer.keyPath];
    blankAnimation.duration = duration;

    __strong __kindof CALayer *const anyLayer = _animations.firstObject.layer;
    [anyLayer addSublayer:blankLayer];
    [_blankLayers addObject:blankLayer];

    [self insertAnimation:blankAnimation
                 forLayer:blankLayer
                   atTime:time
                  onStart:start
               onComplete:complete];
}

- (NSString *)summaryMarkingEntity:(nullable TimelineEntity *)entityToMark {
    NSMutableString *const summary =
    [[NSMutableString alloc] initWithFormat:@"\"%@\":%p;", self.name, self];
    [summary appendFormat:@" [%.3lf,%.3lf] (%.3lf);",
     self.beginTime, self.endTime, self.duration];
    [summary appendFormat:@" animations(%@) = [\n", @(_animations.count)];

    NSArray<TimelineEntity *> *const sorted = [self _sortedEntitesUsingKey:SortKey(beginTime)];
    [sorted enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        __strong __kindof CALayer *const slayer = entity.layer;
        [summary appendFormat:(entity == entityToMark) ? @" -> " : @"    "];
        [summary appendFormat:@"%@: [%.3lf,%.3lf] (%.3lf), \"%@\", layer(%@:%p of %@:%p)\n",
         @(idx),
         entity.beginTime, entity.endTime,
         entity.duration,
         entity.animation.keyPath,
         NSStringFromClass(slayer.class),
         slayer,
         NSStringFromClass(slayer.delegate.class),
         slayer.delegate];
    }];
    [summary appendFormat:@"]"];

    return [summary copy];
}


@end

#pragma mark - Populate

@implementation TimelineAnimation (Populate)

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time {
    [self insertAnimation:animation
                 forLayer:layer
                   atTime:time
                  onStart:nil
               onComplete:nil];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
                onStart:(TimelineAnimationOnStartBlock)start {
    NSParameterAssert(start != nil);
    [self insertAnimation:animation
                 forLayer:layer
                   atTime:time
                  onStart:start
               onComplete:nil];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
             onComplete:(TimelineAnimationCompletionBlock)complete {
    NSParameterAssert(complete != nil);
    [self insertAnimation:animation
                 forLayer:layer
                   atTime:time
                  onStart:nil
               onComplete:complete];
}

- (void)insertAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
                forLayer:(__kindof CALayer *)layer
                  atTime:(RelativeTime)time {

    [self insertAnimations:animations
                  forLayer:layer
                    atTime:time
             onStartBlocks:nil
          completionBlocks:nil];
}

- (void)insertAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
                forLayer:(__kindof CALayer *)layer
                  atTime:(RelativeTime)time
           onStartBlocks:(NSArray<TimelineAnimationOnStartBlock> *)onStartBlocks
        completionBlocks:(NSArray<TimelineAnimationCompletionBlock> *)completionBlocks {

    NSParameterAssert(animations != nil);
    NSParameterAssert(animations.count > 0);

    if (onStartBlocks != nil) {
        NSParameterAssert(onStartBlocks.count == animations.count);
        if (onStartBlocks.count != animations.count) {
            [self __raiseInvalidNumberOfBlocksExceptionWithReason:
             @"Wrong number of 'onStartBlocks' blocks. 'onStartBlocks' in not a "
             "1:1 mapping with animations"];
            return;
        }

    }
    if  (completionBlocks != nil) {
        NSParameterAssert(completionBlocks.count == animations.count);
        if (completionBlocks.count != animations.count) {
            [self __raiseInvalidNumberOfBlocksExceptionWithReason:
             @"Wrong number of 'completionBlocks' blocks. "
             "'completionBlocks' in not a 1:1 mapping with animations"];
            return;
        }

    }

    [animations enumerateObjectsUsingBlock:^(__kindof CAPropertyAnimation * _Nonnull animation, NSUInteger idx, BOOL * _Nonnull stop) {
        TimelineAnimationOnStartBlock onStart = nil;
        if (onStartBlocks) {
            onStart = onStartBlocks[idx];
        }

        TimelineAnimationCompletionBlock completion = nil;
        if (completionBlocks) {
            completion = completionBlocks[idx];
        }

        [self insertAnimation:animation
                     forLayer:layer
                       atTime:time
                      onStart:onStart
                   onComplete:completion];
    }];
}

- (void)insertAnimation:(__kindof CAPropertyAnimation *)animation
               forLayer:(__kindof CALayer *)layer
                 atTime:(RelativeTime)time
                onStart:(nullable TimelineAnimationOnStartBlock)start
             onComplete:(nullable TimelineAnimationCompletionBlock)complete  {

    NSParameterAssert(animation != nil);
    NSParameterAssert(layer != nil);
    NSParameterAssert(animation.duration > 0.0);
    NSParameterAssert(animation.keyPath != nil);

    if (self.hasStarted) {
        [self __raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }
    if (animation == nil) {
        [self __raiseInvalidArgumentExceptionWithReason:
         @"Tried to add a 'nil' animation to a %@",
         NSStringFromClass(self.class)];
        return;
    }
    if (layer == nil) {
        [self __raiseInvalidArgumentExceptionWithReason:
         @"Tried to add an animation with a 'nil' layer to a %@",
         NSStringFromClass(self.class)];
        return;
    }

    __kindof CAPropertyAnimation *const anim = animation.copy;

    TimelineEntity *const entity = [[TimelineEntity alloc] initWithLayer:layer
                                                               animation:anim
                                                               beginTime:time
                                                                 onStart:start
                                                              onComplete:complete
                                                       timelineAnimation:self];

    [self _addTimelineEntity:entity];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
             onStart:(nullable TimelineAnimationOnStartBlock)onStart
          onComplete:(nullable TimelineAnimationCompletionBlock)complete {

    NSParameterAssert(animation != nil);
    NSParameterAssert(layer != nil);
    NSParameterAssert(animation.duration > 0.0);
    NSParameterAssert(animation.keyPath != nil);

    if (self.hasStarted) {
        [self __raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }
    if (animation == nil) {
        [self __raiseInvalidArgumentExceptionWithReason:
         @"Tried to add a 'nil' animation to a %@",
         NSStringFromClass(self.class)];
        return;
    }
    if (layer == nil) {
        [self __raiseInvalidArgumentExceptionWithReason:
         @"Tried to add an animation with a 'nil' layer to a %@",
         NSStringFromClass(self.class)];
        return;
    }

    __kindof CAPropertyAnimation *const anim = animation.copy;

    RelativeTime beginTime = 0.0;
    TimelineEntity *const lastEntity = [self lastEntity];
    if (lastEntity) {
        beginTime = lastEntity.endTime + delay;
    } else if (delay >= 0.0) {
        beginTime = delay;
    }

    TimelineEntity *const entity = [[TimelineEntity alloc] initWithLayer:layer
                                                               animation:anim
                                                               beginTime:beginTime
                                                                 onStart:onStart
                                                              onComplete:complete
                                                       timelineAnimation:self];

    [self _addTimelineEntity:entity];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
             onStart:(TimelineAnimationOnStartBlock)onStart {
    NSParameterAssert(onStart != nil);
    [self addAnimation:animation
              forLayer:layer
             withDelay:delay
               onStart:onStart
            onComplete:nil];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay
          onComplete:( TimelineAnimationCompletionBlock)complete {
    NSParameterAssert(complete != nil);
    [self addAnimation:animation
              forLayer:layer
             withDelay:delay
               onStart:nil
            onComplete:complete];

}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
           withDelay:(NSTimeInterval)delay {
    [self addAnimation:animation
              forLayer:layer
             withDelay:delay
               onStart:nil
            onComplete:nil];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(TimelineAnimationOnStartBlock)onStart
          onComplete:(TimelineAnimationCompletionBlock)complete {
    NSParameterAssert(onStart != nil);
    NSParameterAssert(complete != nil);
    [self addAnimation:animation
              forLayer:layer
             withDelay:0.0
               onStart:onStart
            onComplete:complete];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
          onComplete:(TimelineAnimationCompletionBlock)complete {
    NSParameterAssert(complete != nil);
    [self addAnimation:animation
              forLayer:layer
             withDelay:0.0
               onStart:nil
            onComplete:complete];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation
            forLayer:(__kindof CALayer *)layer
             onStart:(TimelineAnimationOnStartBlock)onStart {
    NSParameterAssert(onStart != nil);
    [self addAnimation:animation
              forLayer:layer
             withDelay:0.0
               onStart:onStart
            onComplete:nil];
}

- (void)addAnimation:(__kindof CAPropertyAnimation *)animation forLayer:(__kindof CALayer *)layer {
    [self addAnimation:animation
              forLayer:layer
             withDelay:0.0
               onStart: nil
            onComplete:nil];
}

- (void)addAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
             forLayer:(__kindof CALayer *)layer
            withDelay:(NSTimeInterval)delay {

    [self addAnimations:animations
               forLayer:layer
              withDelay:delay
          onStartBlocks:nil
       completionBlocks:nil];
}

- (void)addAnimations:(NSArray<__kindof CAPropertyAnimation *> *)animations
             forLayer:(__kindof CALayer *)layer
            withDelay:(NSTimeInterval)delay
        onStartBlocks:(nullable NSArray<TimelineAnimationOnStartBlock> *)onStartBlocks
     completionBlocks:(nullable NSArray<TimelineAnimationCompletionBlock> *)completionBlocks {

    const RelativeTime time = self.duration + delay;

    [self insertAnimations:animations
                  forLayer:layer
                    atTime:time
             onStartBlocks:onStartBlocks
          completionBlocks:completionBlocks];
}

- (void)merge:(TimelineAnimation *)timeline {

    NSParameterAssert(timeline != nil);

    if (self.hasStarted) {
        [self __raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }

    guard ([timeline isMemberOfClass:[TimelineAnimation class]]) else {
        NSAssert(false, @"TimelineAnimations: You should merge with same kinds of timelines.");
        return;
    }

    // add only animations
    [timeline.animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        // can throw
        [self _addTimelineEntity:[entity copy]];
    }];

    if (timeline.onStart) {
        self.onStart = timeline.onStart;
    }
    if (timeline.completion) {
        self.completion = timeline.completion;
    }
}

@end

#pragma mark - Control Blocks

@implementation TimelineAnimation (ControlBlocks)



- (void)removeOnStartBlocks {
    _onStart = nil;
}

- (void)removeCompletionBlocks {
    _completion = nil;
}

@end

#pragma mark - Control

@implementation TimelineAnimation (ProtectedControl)

- (void)_playWithCurrentTime:(TimelineAnimationCurrentMediaTimeBlock)currentTime {

    NSAssert(self.name != nil, @"TimelineAnimations: You should name your animations.");
    NSAssert(self.isNonEmpty || self.onUpdate != nil,
             @"TimelineAnimations: Why are you trying to play an empty %@?",
             NSStringFromClass(self.class));

    if (self.isPaused) {
        [self resume];
        return;
    }

    if (self.hasStarted) {
        [self __raiseOngoingTimelineAnimationWithReason:
         @"TimelineAnimations: You tried to play a non paused or finished %@.\"%@\".",
         NSStringFromClass(self.class),
         self.name];
        return;
    }

    if (self.isCleared) {
        [self __raiseClearedTimelineAnimationExceptionWithReason:
         @"TimelineAnimations: You tried to play the cleared %@.\"%@\"",
         NSStringFromClass(self.class),
         self.name
         ];
        return;
    }

    self.paused = NO;

    if (self.isEmpty && self.onUpdate == nil) {
        if (_onStart) {
            _onStart();
        }
        if (_completion) {
            _completion(NO);
        }
        return;
    }

    [self _setupTimeNotifications];
    [self _setupProgressNotifications];

    __kindof CALayer *potentialOrphanLayer = nil;
    if ([self _checkForOutOfHierarchyIssues:&potentialOrphanLayer]) {
        [self __raiseElementsNotInHierarchyExceptionWithReason:
         @"TimelineAnimations: You tried to play an animation with lost layers %@"
         "\n%@",
         [potentialOrphanLayer debugDescription],
         [self summary]];
    }

    self.started = YES;


    NSArray<TimelineEntity *> *const sortedEntities = [self _sortedEntitesUsingKey:SortKey(beginTime)];
    _unfinishedEntities = [[NSMutableSet alloc] initWithArray:_animations];
    [sortedEntities enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        entity.speed = self.speed;
        [entity playWithCurrentTime:currentTime
                            onStart:^{
                                [self callOnStart];
                            } onComplete:^(BOOL gracefullyFinished) {
                                [self.unfinishedEntities removeObject:entity];
                                [self callOnComplete:gracefullyFinished];
                            } setModelValues:self.setsModelValues];
    }];

    [self _startDisplayLinkIfNeeded];
}

@end

@implementation TimelineAnimation (Control)

- (void)play {
    [self _playWithCurrentTime:self.currentTime];
}

- (void)replay {
    guard (!self.hasStarted) else { return; }

    __weak typeof(self) welf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(self) strelf = welf;
        guard (strelf != nil) else { return; }
        guard (!strelf.isPaused) else { return; }
        guard (!strelf.isCleared) else { return; }
        [strelf _prepareForReplay];
        [strelf _replay];
    });
}

- (void)resume {
    guard (self.isPaused) else { return; }

    [self resumeWithCurrentTime:self.currentTime
           alreadyResumedLayers:[[NSMutableSet alloc] init]];
}

- (void)pause {
    guard (self.hasStarted) else { return; }

    [self pauseWithCurrentTime:self.currentTime
           alreadyPausedLayers:[[NSMutableSet alloc] init]];
}

- (void)clear {
    for (TimelineEntity *const entity in _animations) {
        [entity clear];
    };

    [_animations removeAllObjects];

    self.paused  = NO;
    self.started = NO;
    self.cleared = YES;

    [self removeOnStartBlocks];
    [self removeCompletionBlocks];
    self.onUpdate = nil;

    _progress = 0.0;
}

- (void)stopUpdates {
    guard (self.hasStarted) else { return; }
    guard (self.onUpdate != nil) else { return; }

    self.onUpdate = nil;

    self.paused  = NO;
    self.started = NO;
    self.finished = YES;
}

- (void)delay:(const NSTimeInterval)delay {
    if (self.hasStarted) {
        [self __raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }
    guard (delay != 0.0) else { return; }

    for (TimelineEntity *const entity in _animations) {
        entity.beginTime += delay;
    };

    RelativeTime newBeginTime = self.beginTime;
    // calculate notification time changes
    _timeNotificationAssociations = [self timeNotificationConvertedUsing:^RelativeTimeNumber * _Nonnull(RelativeTimeNumber * _Nonnull key) {
        RelativeTime new = Round(key.doubleValue + delay);
        if (new <= newBeginTime) {
            new = newBeginTime + TimelineAnimationMillisecond;
        }
        return @(new);
    }];
}

- (instancetype)timelineWithDuration:(const NSTimeInterval)duration {
    @autoreleasepool {
        NSParameterAssert(duration > 0.0);


        TimelineAnimation *const updatedTimeline = [self copy];
        if ([updatedTimeline respondsToSelector:@selector(setSetsModelValues:)]) {
            updatedTimeline.setsModelValues = self.setsModelValues;
        }
        const NSTimeInterval currentDuration = self.nonRepeatingDuration; {
            // checks
            const NSUInteger currentDurationInMilliseconds = (NSUInteger)(currentDuration * 1000.0); // in ms
            const NSUInteger durationInMilliseconds = (NSUInteger)(duration * 1000.0); // in ms

            // if same duration do nothing
            guard (durationInMilliseconds != currentDurationInMilliseconds) else {
                return updatedTimeline;
            }

            const NSUInteger millisecond = (NSUInteger)(TimelineAnimationMillisecond * 1000.0);
            // if duration is only 1ms then do nothing
            if (currentDurationInMilliseconds == millisecond) {
                return updatedTimeline;
            }

            const NSUInteger frame = (NSUInteger)(TimelineAnimationOneFrame * 1000.0);
            // if duration is only 16ms (one frame long) then do nothing
            if (currentDurationInMilliseconds == frame) {
                return updatedTimeline;
            }
        }


        NSArray<TimelineEntity *> *const entities = _animations.copy;
        NSMutableArray<TimelineEntity *> *const updatedEntities = [[NSMutableArray alloc] initWithCapacity:entities.count];
        const NSTimeInterval newTimelineDuration = duration;
        const NSTimeInterval oldTimelineDuration = currentDuration;
        const RelativeTime beginTime = self.beginTime;
        for (TimelineEntity *const entity in entities) {
            // adjust if the entity's .beginTime is not the same as the timeline's .beginTime
            const BOOL adjust = fabs((double)(entity.beginTime - beginTime)) >= TimelineAnimationMillisecond;
            const NSTimeInterval newEntityDuration = newTimelineDuration * entity.duration / oldTimelineDuration;
            TimelineEntity *const updatedEntity = [entity copyWithDuration:newEntityDuration
                                                     shouldAdjustBeginTime:adjust
                                                       usingTotalBeginTime:beginTime];
            [updatedEntities addObject:updatedEntity];
        };

        updatedTimeline.animations = updatedEntities;
        [updatedEntities enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
            entity.timelineAnimation = updatedTimeline;
        }];

        for (TimelineEntity *const entity in entities) {
            entity.timelineAnimation = updatedTimeline;
        }

        updatedTimeline.originate = self;
        updatedTimeline.duration = newTimelineDuration;

        // calculate notification time changes
        const double factor = newTimelineDuration / oldTimelineDuration;
        updatedTimeline.timeNotificationAssociations = [self timeNotificationConvertedUsing:^RelativeTimeNumber *(RelativeTimeNumber *key) {
            double value = key.doubleValue;
            if ((value == TimelineAnimationMillisecond)
                || (fabs((double)(value - TimelineAnimationMillisecond)) < 0.001)) {
                return @(TimelineAnimationMillisecond);
            }
            // if around one frame time
            if ((value == TimelineAnimationOneFrame)
                || (fabs((double)(value - TimelineAnimationOneFrame)) < 0.001)) {
                return @(TimelineAnimationOneFrame);
            }
            value *= factor;
            if (value < TimelineAnimationMillisecond) {
                value = TimelineAnimationMillisecond;
            }
            return @(Round(value));
        }];

        return updatedTimeline;
    }
}

@end

#pragma mark - Reverse

@implementation TimelineAnimation (Reverse)

- (instancetype)reversed {
    return [self reversedWithDuration:self.duration];
}

- (instancetype)reversedWithDuration:(NSTimeInterval)duration {
    NSParameterAssert(duration > 0.0);

    NSArray<TimelineEntity *> *const sortedEntities = _animations.copy;
    NSMutableArray<TimelineEntity *> *const reversedEntities = [[NSMutableArray alloc] initWithCapacity:sortedEntities.count];
    const NSTimeInterval timelineDuration = duration;
    for (TimelineEntity *const entity in sortedEntities) {
        // reverse time
        TimelineEntity *const reversedTimelineEntity = [entity reversedCopy];
        const RelativeTime endTime = reversedTimelineEntity.endTime;
        const RelativeTime beginTime = (timelineDuration - endTime);
        reversedTimelineEntity.beginTime = beginTime;
        [reversedEntities addObject:reversedTimelineEntity];
    };

    [reversedEntities sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"beginTime" ascending:YES]]];

    TimelineAnimation *const reversed = [self copy];
    [reversedEntities enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        entity.timelineAnimation = reversed;
    }];
    if (self.setsModelValues) {
        reversed.setsModelValues = YES;
    }
    reversed.animations = reversedEntities;
    reversed.name = [reversed.name stringByAppendingPathExtension:@"reversed"];
    reversed.reversed = YES;
    reversed.originate = self;
    return reversed;
}

@end

#pragma mark - Progress

@implementation TimelineAnimation (Progress)

- (void)playFromProgress:(float)progress catchUpIn:(NSTimeInterval)intervalToCatchUp {
    NSParameterAssert(progress >= 0.0 && progress <= 1.0);
    [self __raiseNotImplementedMethodExceptionWithReason:
     @"The functionality provided by selector "
     "\"%@\" is not yet implemented.",
     NSStringFromSelector(_cmd)];
}


- (void)playFromProgress:(float)progress {
    if (self.hasStarted) {
        [self __raiseImmutableTimelineExceptionWithSelector:_cmd];
        return;
    }

    NSParameterAssert(progress >= 0.0 && progress <= 1.0);

    if (progress < 0.0) {
        progress = 0.0;
    }
    if (progress > 1.0) {
        progress = 1.0;
    }

    const NSTimeInterval duration = self.duration;
    const RelativeTime beginTime  = self.beginTime;

    const NSTimeInterval diff = duration * progress;
    const RelativeTime newBeginTime = beginTime - diff;
    self.beginTime = newBeginTime;

    [self play];
}

@end

#pragma mark - Notify

@implementation TimelineAnimation (Notify)

- (void)notifyAtProgress:(float)progress
              usingBlock:(TimelineAnimationNotifyBlock)block {

    if (self.hasStarted) {
        [self __raiseImmutableTimelineAnimationExceptionWithReason:
         @"You tried to add a progress notification at the ongoing %@.\"%@\"",
         NSStringFromClass(self.class),
         self.name];
        return;
    }

    NSParameterAssert(progress >= 0.0 && progress <= 1.0);

    ProgressNumber *const progressKey = @(progress);
    _progressNotificationAssociations[progressKey] = [block copy];
}

- (void)notifyAtTime:(RelativeTime)time
          usingBlock:(TimelineAnimationNotifyBlock)block {

    if (self.hasStarted) {
        [self __raiseImmutableTimelineAnimationExceptionWithReason:
         @"You tried to add a time notification %.3lf at the ongoing %@.\"%@\"",
         time,
         NSStringFromClass(self.class),
         self.name];
        return;
    }

    if (time < (RelativeTime)self.beginTime) {
        [self __raiseTimeNotificationOutOfBoundsExceptionWithReason:
         @"Tried to add a time notification at %.3lf in %@.\"%@\", before its beginTime(%.3lf).",
         time,
         NSStringFromClass(self.class),
         self.name,
         self.beginTime];
        return;
    }
    if (self.isEmpty) {
        [self __raiseEmptyTimelineAnimationWithReason:
         @"Tried to add a time notification at %.3lf in an empty %@.\"%@\"",
         time,
         NSStringFromClass(self.class),
         self.name];
        return;
    }
    if (time >= self.endTimeWithNoRepeating) {
        [self __raiseTimeNotificationOutOfBoundsExceptionWithReason:
         @"Tried to add a time notification at %.3lf in %@.\"%@\", after its endTime(%.3lf).",
         time,
         NSStringFromClass(self.class),
         self.name,
         self.endTimeWithNoRepeating];
        return;
    }

    TimelineAnimationNotifyBlockInfo *const info = [TimelineAnimationNotifyBlockInfo infoWithBlock:block
                                                                               isSoundNotification:NO];
    [self _appendTimelineAnimationNotifyBlockInfo:info atTime:time];
}

- (void)_appendTimelineAnimationNotifyBlockInfo:(TimelineAnimationNotifyBlockInfo *)info atTime:(RelativeTime)time {
    RelativeTimeNumber *const timeKey = @(Round(time));
    NSMutableArray<TimelineAnimationNotifyBlockInfo *> *infos = _timeNotificationAssociations[timeKey];
    if (infos == nil) {
        infos = [[NSMutableArray alloc] init];
        _timeNotificationAssociations[timeKey] = infos;
    }
    [infos addObject:info];
}

- (void)addBlankAnimationWithDuration:(NSTimeInterval)duration {
    [self addBlankAnimationWithDuration:duration
                                onStart:nil
                             onComplete:nil];
}


- (void)addBlankAnimationWithDuration:(NSTimeInterval)duration
                              onStart:(TimelineAnimationOnStartBlock)start {
    [self addBlankAnimationWithDuration:duration
                                onStart:start
                             onComplete:nil];
}

- (void)addBlankAnimationWithDuration:(NSTimeInterval)duration
                           onComplete:(TimelineAnimationCompletionBlock)complete {
    [self addBlankAnimationWithDuration:duration
                                onStart:nil
                             onComplete:complete];
}

- (void)addBlankAnimationWithDuration:(NSTimeInterval)duration
                              onStart:(nullable TimelineAnimationOnStartBlock)start
                           onComplete:(nullable TimelineAnimationCompletionBlock)complete {


    guard (self.isNonEmpty) else { return; }

    NSParameterAssert(duration >= TimelineAnimationOneFrame);

    TimelineAnimationsBlankLayer *const blankLayer = [[TimelineAnimationsBlankLayer alloc] init];
    CABasicAnimation *const blankAnimation = [CABasicAnimation animationWithKeyPath:TimelineAnimationsBlankLayer.keyPath];
    blankAnimation.duration = duration;

    __strong __kindof CALayer *const anyLayer = _animations.firstObject.layer;
    NSAssert(anyLayer != nil, @"TimelineAnimations: Try to add blank animation but there is no layer to add it to.");

    [anyLayer addSublayer:blankLayer];
    [_blankLayers addObject:blankLayer];

    [self addAnimation:blankAnimation
              forLayer:blankLayer
               onStart:start
            onComplete:complete];
}



- (void)insertBlankAnimationAtTime:(RelativeTime)time
                      withDuration:(NSTimeInterval)duration {
    [self insertBlankAnimationAtTime:time
                             onStart:nil
                          onComplete:nil
                        withDuration:duration];
}

- (void)insertBlankAnimationAtTime:(RelativeTime)time
                           onStart:(TimelineAnimationOnStartBlock)start
                      withDuration:(NSTimeInterval)duration {
    [self insertBlankAnimationAtTime:time
                             onStart:start
                          onComplete:nil
                        withDuration:duration];
}

- (void)insertBlankAnimationAtTime:(RelativeTime)time
                        onComplete:(TimelineAnimationCompletionBlock)complete
                      withDuration:(NSTimeInterval)duration {
    [self insertBlankAnimationAtTime:time
                             onStart:nil
                          onComplete:complete
                        withDuration:duration];
}

@end

#pragma mark - Audio

@implementation TimelineAnimation (Audio)

- (void)associateAudio:(id<TimelineAudio>)audio
  usingTimeAssociation:(TimelineAudioAssociation *)association {

    if (self.hasStarted) {
        [self __raiseImmutableTimelineAnimationExceptionWithReason:
         @"You tried to associate audio at the ongoing %@.\"%@\"",
         NSStringFromClass(self.class),
         self.name];
        return;
    }

    if (self.isEmpty) {
        [self __raiseEmptyTimelineAnimationWithReason:
         @"Tried to associate sound in an empty %@.\"%@\"",
         NSStringFromClass(self.class),
         self.name];
        return;
    }

    const RelativeTime time = [association timeInTimelineAnimation:self];
    if (time < (RelativeTime)self.beginTime) {
        [self __raiseTimeNotificationOutOfBoundsExceptionWithReason:
         @"Tried to associate audio at %.3lf in %@.\"%@\", before its beginTime(%.3lf).",
         time,
         NSStringFromClass(self.class),
         self.name,
         self.beginTime];
        return;
    }

    if (time >= self.endTimeWithNoRepeating) {
        [self __raiseTimeNotificationOutOfBoundsExceptionWithReason:
         @"Tried to associate audio at %.3lf in %@.\"%@\", after its endTime(%.3lf).",
         time,
         NSStringFromClass(self.class),
         self.name,
         self.endTimeWithNoRepeating];
        return;
    }

    TimelineAnimationNotifyBlockInfo *const info = [TimelineAnimationNotifyBlockInfo infoWithBlock:^{
        [audio play];
    } isSoundNotification:YES];
    info.sound = audio;
    [self _appendTimelineAnimationNotifyBlockInfo:info atTime:time];
}

- (void)disassociateAllAudio {

    if (self.hasStarted) {
        [self __raiseImmutableTimelineAnimationExceptionWithReason:
         @"You tried disassociate audio at the ongoing %@.\"%@\"",
         NSStringFromClass(self.class),
         self.name];
        return;
    }

    @autoreleasepool {
        NotificationAssociations *const timeNotifications = [NotificationAssociations dictionaryWithSharedKeySet:
                                                             [NotificationAssociations sharedKeySetForKeys:_timeNotificationAssociations.allKeys]];
        [_timeNotificationAssociations enumerateKeysAndObjectsUsingBlock:^(RelativeTimeNumber * _Nonnull timeKey, NSMutableArray<TimelineAnimationNotifyBlockInfo *> * _Nonnull infos, BOOL * _Nonnull stop) {
            // get all non-sound notifications
            NSIndexSet *const indexes = [infos indexesOfObjectsPassingTest:^BOOL(TimelineAnimationNotifyBlockInfo * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop2) {
                return !info.isSoundNotification;
            }];
            if (indexes.count == 0) {
                timeNotifications[timeKey] = nil;
            }
            else {
                NSMutableArray<TimelineAnimationNotifyBlockInfo *> *const newInfos = [[infos objectsAtIndexes:indexes] mutableCopy];
                timeNotifications[timeKey] = newInfos;
            }
        }];
        _timeNotificationAssociations = timeNotifications;
    }
}

- (void)disassociateAudio:(id<TimelineAudio>)audio {

    if (self.hasStarted) {
        [self __raiseImmutableTimelineAnimationExceptionWithReason:
         @"You tried to disassociate audio at the ongoing %@.\"%@\"",
         NSStringFromClass(self.class),
         self.name];
        return;
    }

    @autoreleasepool {
        NotificationAssociations *const timeNotifications = [NotificationAssociations dictionaryWithSharedKeySet:
                                                             [NotificationAssociations sharedKeySetForKeys:_timeNotificationAssociations.allKeys]];
        [_timeNotificationAssociations enumerateKeysAndObjectsUsingBlock:^(RelativeTimeNumber * _Nonnull timeKey, NSMutableArray<TimelineAnimationNotifyBlockInfo *> * _Nonnull infos, BOOL * _Nonnull stop) {
            // get all notifications where the sound is different from the requested one
            NSIndexSet *const indexes = [infos indexesOfObjectsPassingTest:^BOOL(TimelineAnimationNotifyBlockInfo * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop2) {
                return (info.sound != audio);
            }];
            if (indexes.count == 0) {
                timeNotifications[timeKey] = nil;
            }
            else {
                NSMutableArray<TimelineAnimationNotifyBlockInfo *> *const newInfos = [[infos objectsAtIndexes:indexes] mutableCopy];
                timeNotifications[timeKey] = newInfos;
            }
        }];
        _timeNotificationAssociations = timeNotifications;
    }
}

- (void)disassociateAudioAtTimeAssociation:(TimelineAudioAssociation *)association {

    if (self.hasStarted) {
        [self __raiseImmutableTimelineAnimationExceptionWithReason:
         @"You tried disassociate time association %.3lf notification at the ongoing %@.\"%@\"",
         [association timeInTimelineAnimation:self],
         NSStringFromClass(self.class),
         self.name];
        return;
    }

    const RelativeTime time = [association timeInTimelineAnimation:self];
    RelativeTimeNumber *const timeKey = @(time);
    NSMutableArray<TimelineAnimationNotifyBlockInfo *> *const infos = _timeNotificationAssociations[timeKey];

    NSIndexSet *const indexes = [infos indexesOfObjectsPassingTest:^BOOL(TimelineAnimationNotifyBlockInfo * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
        return !info.isSoundNotification;
    }];
    NSMutableArray<TimelineAnimationNotifyBlockInfo *> *const newInfos = [[infos objectsAtIndexes:indexes] mutableCopy];
    _timeNotificationAssociations[timeKey] = newInfos;
}





- (NSArray<id<TimelineAudio>> *)associatedAudioBeginingAtTime:(RelativeTime)time {
    if (self.hasStarted || self.hasFinished) {
        [self __raiseOngoingTimelineAnimationWithReason:
         @"You tried to associate audio with an ongoing %@.\"%@\".",
         NSStringFromClass(self.class),
         self.name];
        return @[];
    }

    RelativeTimeNumber *const timeKey = @(time);
    NSMutableArray<TimelineAnimationNotifyBlockInfo *> *infos = _timeNotificationAssociations[timeKey];
    guard (infos != nil) else { return @[]; }
    guard (infos.count != 0) else { return @[]; }

    NSArray<TimelineAnimationNotifyBlockInfo *> *sounds = [infos _objectsPassingTest:^BOOL(TimelineAnimationNotifyBlockInfo * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop) {
        return info.isSoundNotification;
    }];
    guard (sounds.count != 0) else { return @[]; }
    return [sounds _map:^id _Nonnull(TimelineAnimationNotifyBlockInfo * _Nonnull info) { return info.sound; }];
}

- (NSArray<id<TimelineAudio>> *)associatedOngoingAtTime:(RelativeTime)time {
    if (self.hasStarted || self.hasFinished) {
        [self __raiseOngoingTimelineAnimationWithReason:
         @"You tried to associate audio with an ongoing %@.\"%@\".",
         NSStringFromClass(self.class),
         self.name];
        return @[];
    }
    NSAssert(NO, @"Not implemented yet");

    NSMutableArray<TimelineAnimationNotifyBlockInfo *> *const ongoingSounds = [[NSMutableArray alloc] init];
    [_timeNotificationAssociations enumerateKeysAndObjectsUsingBlock:^(RelativeTimeNumber * _Nonnull keyTime, NSMutableArray<TimelineAnimationNotifyBlockInfo *> * _Nonnull infos, BOOL * _Nonnull stop) {
        const RelativeTime beginTime = keyTime.doubleValue;
        guard (time >= beginTime) else { return; }
        NSArray<TimelineAnimationNotifyBlockInfo *> *_ongoingSounds =
        [infos _objectsPassingTest:^BOOL(TimelineAnimationNotifyBlockInfo * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop2) {
            __strong typeof(info.sound) sound = info.sound;
            guard (sound != nil) else { return NO; }
            const RelativeTime endTime = beginTime + sound.duration;
            return (time <= endTime);
        }];
        [ongoingSounds addObjectsFromArray:_ongoingSounds];
    }];
    return [ongoingSounds copy];
}

- (NSArray<id<TimelineAudio>> *)associatedAudios {
    return [[self _audioBlockInfos] _map:^id<TimelineAudio>(TimelineAnimationNotifyBlockInfo *info) { return info.sound; } ];
}

- (NSArray<TimelineAnimationNotifyBlockInfo *> *)_audioBlockInfos {
    __block NSMutableArray<TimelineAnimationNotifyBlockInfo *> *blocks = [[NSMutableArray alloc] init];
    [_timeNotificationAssociations enumerateKeysAndObjectsUsingBlock:^(RelativeTimeNumber * _Nonnull timeKey, NSMutableArray<TimelineAnimationNotifyBlockInfo *> * _Nonnull infos, BOOL * _Nonnull stop) {
        // get all sound notifications
        NSArray<TimelineAnimationNotifyBlockInfo *> *const sounds = [infos _objectsPassingTest:^BOOL(TimelineAnimationNotifyBlockInfo * _Nonnull info, NSUInteger idx, BOOL * _Nonnull stop2) {
            return info.isSoundNotification;
        }];
        [blocks addObjectsFromArray:sounds];
    }];

    return [blocks copy];
}

@end

#pragma mark - NSCopying

@implementation TimelineAnimation (Copying)

- (instancetype)initWithTimelineAnimation:(__kindof TimelineAnimation *)timeline {
    self = [self initWithStart:timeline.onStart
                    completion:timeline.completion];
    if (self) {
        _preferredFramesPerSecond = timeline.preferredFramesPerSecond;
        self.onUpdate     = timeline.onUpdate;
        _animations       = [[NSMutableArray alloc] initWithArray:timeline.animations
                                                        copyItems:YES];

        [_animations enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
            entity.timelineAnimation = self;
        }];

        _paused           = timeline.paused;
        _finished         = timeline.finished;

        _speed            = timeline.speed;

        self.beginTime    = timeline.beginTime;
        self.repeatCount  = timeline.repeatCount;

        _repeatOnStart    = [timeline.repeatOnStart copy];
        _repeatCompletion = [timeline.repeatCompletion copy];

        _setsModelValues  = timeline.setsModelValues;

        _name             = timeline.name.copy;
        _userInfo         = timeline.userInfo.copy;

        _completion       = [timeline.completion copy];
        _onStart          = [timeline.onStart copy];
        _onUpdate         = [timeline.onUpdate copy];

        _progress         = timeline.progress;

        _reversed         = timeline.reversed;
        _originate        = timeline.originate;

        _muteAssociatedSounds = timeline.muteAssociatedSounds;

        _progressNotificationAssociations = timeline.progressNotificationAssociations.mutableCopy;
        _timeNotificationAssociations     = timeline.timeNotificationAssociations.mutableCopy;
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    return [[TimelineAnimation alloc] initWithTimelineAnimation:self];
}

@end

@implementation TimelineAnimation (Debug)

- (NSString *)summary {
    return [self summaryMarkingEntity:nil];
}

- (NSArray<__kindof CAPropertyAnimation *> *)animationsBeginingAtTime:(RelativeTime)time {
    NSIndexSet *const indexes = [_animations indexesOfObjectsPassingTest:^BOOL(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        return (entity.beginTime == time);
    }];
    NSArray<TimelineEntity *> *const entities = [_animations objectsAtIndexes:indexes];
    NSArray<__kindof CAPropertyAnimation *> *const animations = [[NSArray alloc] initWithArray:
                                                                 [entities _map:^__kindof CAPropertyAnimation *(TimelineEntity *entity) { return [entity.animation copy]; }]
                                                                 ];
    return animations;
}

- (NSArray<__kindof CAPropertyAnimation *> *)animationsOngoingAtTime:(RelativeTime)time {
    NSIndexSet *const indexes = [_animations indexesOfObjectsPassingTest:^BOOL(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
        return (time >= entity.beginTime) && (time <= entity.endTime);
    }];
    NSArray<TimelineEntity *> *const entities = [_animations objectsAtIndexes:indexes];
    NSArray<__kindof CAPropertyAnimation *> *const animations = [[NSArray alloc] initWithArray:
                                                                 [entities _map:^__kindof CAPropertyAnimation *(TimelineEntity *entity) { return [entity.animation copy]; }]
                                                                 ];
    return animations;
}

- (NSArray<CAPropertyAnimation *> *)allPropertyAnimations {
    return [_animations _map:^__kindof CAPropertyAnimation *(TimelineEntity * _Nonnull entity) {
        return [entity.animation copy];
    }];
}

@end

@implementation TimelineAnimation (Plumbing)

- (NSArray<TimelineAnimationDescription *> *)animationDescriptions {
    if (self.hasStarted) {
        [self __raiseOngoingTimelineAnimationWithReason:
         @"Animation descriptions are not available on ongoing %@.\"%@\".",
         NSStringFromClass(self.class),
         self.name];
        return @[];
    }

    return [_animations _map:^__kindof TimelineAnimationDescription *(TimelineEntity * _Nonnull entity) {
        return [TimelineAnimationDescription descriptionWithAnimation:entity.initialAnimation
                                                             forLayer:entity.layer
                                                              onStart:entity.onStart
                                                           completion:entity.completion];
    }];
}


- (void)combineAnimationDescriptions:(NSArray<TimelineAnimationDescription *> *)animationDescriptions {
    if (self.hasStarted) {
        [self __raiseOngoingTimelineAnimationWithReason:
         @"You tried to play an non paused or finished %@.\"%@\".",
         NSStringFromClass(self.class),
         self.name];
        return;
    }

    NSParameterAssert(animationDescriptions != nil);
    guard (animationDescriptions != nil) else { return; }

    NSParameterAssert(animationDescriptions.count > 0);
    guard (animationDescriptions.count > 0) else { return; }

    [animationDescriptions enumerateObjectsUsingBlock:^(TimelineAnimationDescription * _Nonnull description, NSUInteger idx, BOOL * _Nonnull stop) {
        __kindof CAPropertyAnimation *animation = description.animation;
        [self insertAnimation:animation
                     forLayer:description.layer
                       atTime:animation.beginTime
                      onStart:description.onStart
                   onComplete:description.completion];
    }];
}

- (id)debugQuickLookObject {
    return self.debugDescription;

    //    @autoreleasepool {
    //
    //        NSArray<TimelineEntity *> *const entities = [self _sortedEntitesUsingKey:SortKey(beginTime)];
    //        const RelativeTime enArxi = entities.firstObject.beginTime;
    //
    //        CGSize size = [[entities _reduce:[NSValue valueWithCGSize:CGSizeZero]
    //                                     transform:^NSValue *_Nonnull(NSValue  *_Nonnull partial, TimelineEntity * _Nonnull entity) {
    //                                         CGSize size = partial.CGSizeValue;
    //                                         const CGSize layerSize = entity.layer.preferredFrameSize;
    //                                         size.width += layerSize.width;
    //                                         size.height = MAX(size.height, layerSize.height);
    //                                         return [NSValue valueWithCGSize:size];
    //                                     }] CGSizeValue];
    //
    //        size.height += 50.0;
    //        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    //        const SEL quickLook = @selector(debugQuickLookObject);
    //        __block CGFloat currentX = 0.0;
    //        [[UIColor blackColor] setFill];
    //        [[UIBezierPath bezierPathWithRect:CGRectMake(0, 0, size.width, size.height)] fill];
    //
    //        [entities enumerateObjectsUsingBlock:^(TimelineEntity * _Nonnull entity, NSUInteger idx, BOOL * _Nonnull stop) {
    //            __kindof CALayer *const layer = entity.layer;
    //
    //            if ([layer respondsToSelector:quickLook]) {
    //                _Pragma("clang diagnostic push");
    //                _Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"");
    //                UIImage *const image = [layer performSelector:quickLook];
    //                _Pragma("clang diagnostic pop");
    //                const CGSize imageSize = image.size;
    //                const CGFloat width = imageSize.width;
    //                const CGFloat height = imageSize.height;
    //                const CGRect imageRect = CGRectMake(currentX, size.height - height,
    //                                                    width, height);
    //
    //                [image drawInRect:imageRect];
    //
    //                {
    //                    [self _drawString:[NSString stringWithFormat:
    //                                       @"\"%@\" %ldms",
    //                                       entity.animation.keyPath,
    //                                       (long)(entity.duration * 1000.0)]
    //                             inRect:CGRectMake(currentX, 0, width, 25.0)];
    //                    [self _drawString:[NSString stringWithFormat:
    //                                       @"[%.3lf,%.3lf]",
    //                                       entity.beginTime - enArxi,
    //                                       entity.endTime - enArxi]
    //                               inRect:CGRectMake(currentX, 25.0, width, 25.0)];;
    //                }
    //
    //                currentX += width;
    //            }
    //        }];
    //        UIImage *const preview = UIGraphicsGetImageFromCurrentImageContext();
    //        UIGraphicsEndImageContext();
    //        return preview;
    //    }
}

- (void)_drawString:(NSString *)string inRect:(CGRect)rect {
    NSDictionary<NSString *, id> *attributes =
    [self _findAttributesOfString:string
                        toFitSize:rect.size
       staringWithInitialFontSize:20];

    const CGRect stringRect = CGRectMake(rect.origin.x, rect.origin.y,
                                         rect.size.width, rect.size.height);
    [string drawInRect:stringRect
        withAttributes:attributes];

}

- (NSDictionary<NSString *, id> *)_findAttributesOfString:(NSString *)string
                                                toFitSize:(CGSize)size
                               staringWithInitialFontSize:(CGFloat)fontSize {
    NSDictionary<NSString *, id> *initialAttributes = @{
                                                        NSForegroundColorAttributeName: [UIColor whiteColor],
                                                        NSFontAttributeName: [UIFont systemFontOfSize:fontSize]
                                                        };

    CGSize propertiesSize = [string boundingRectWithSize:size
                                                 options:(NSStringDrawingUsesLineFragmentOrigin)
                                              attributes:initialAttributes
                                                 context:nil].size;
    if (propertiesSize.width > size.width || propertiesSize.height > size.height) {
        return [self _findAttributesOfString:string
                                   toFitSize:size
                  staringWithInitialFontSize:(fontSize * (CGFloat)0.05)];
    }
    return initialAttributes;
}

@end

@implementation TimelineAnimation (ErrorReporting)

static const void *const __kErrorReportingKey = &__kErrorReportingKey;

+ (void)setErrorReporting:(TimelineAnimationErrorReportingBlock)errorReporting {
    objc_setAssociatedObject(self,
                             __kErrorReportingKey,
                             errorReporting,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (TimelineAnimationErrorReportingBlock)errorReporting {
    TimelineAnimationErrorReportingBlock block = objc_getAssociatedObject(self, __kErrorReportingKey);
    return [block copy];
}

@end
